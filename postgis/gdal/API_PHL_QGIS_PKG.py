import os
import sys
import json
import binascii
import requests
import subprocess
from shapely import wkb
from shapely.geometry import mapping
from qgis.core import (
    QgsVectorLayer,
    QgsProject,
    QgsCoordinateReferenceSystem
)

# ---------- KONFIGURASI ----------
IGT = "pbph_definitif"
USERNAME = "user"
PASSWORD = "password"
BASE_URL = "https://phl.menlhk.go.id"
PAGE_SIZE = 1000

# OUTPUT
GEOJSON_PATH = f"C:/app/data/{IGT}.geojson"
GPKG_PATH = f"C:/app/data/{IGT}.gpkg"
GPKG_LAYER_NAME = IGT

os.makedirs(os.path.dirname(GEOJSON_PATH), exist_ok=True)

# ---------- FUNGSI ----------
def fetch_paginated_data():
    offset = 0
    all_features = []

    while True:
        print(f"🔄 Ambil data halaman offset {offset}...")
        url = f"{BASE_URL}/api/v1/{IGT}?select=*&limit={PAGE_SIZE}&offset={offset}"
        resp = requests.get(url, auth=(USERNAME, PASSWORD))

        if resp.status_code != 200:
            print(f"❌ Gagal ambil data (offset {offset}): {resp.status_code}")
            print(resp.text)
            break

        try:
            data_json = resp.json()
        except Exception as e:
            print(f"❌ Gagal parsing JSON: {e}")
            break

        entries = data_json.get("data", [])
        if not entries:
            print("✅ Tidak ada data lagi.")
            break

        for idx, item in enumerate(entries, start=1):
            geom_hex = item.get("geom")
            if not geom_hex:
                print(f"⚠️ Entry offset {offset} ke-{idx} tidak punya geom.")
                continue

            try:
                geom_wkb = binascii.unhexlify(geom_hex)
                geom = wkb.loads(geom_wkb)
                geojson_geom = mapping(geom)
            except Exception as e:
                print(f"⚠️ Gagal parsing WKB di offset {offset} entry ke-{idx}: {e}")
                continue

            feature = {
                "type": "Feature",
                "geometry": geojson_geom,
                "properties": {k: v for k, v in item.items() if k != "geom"}
            }
            all_features.append(feature)

        offset += PAGE_SIZE

    return all_features

# ---------- EKSEKUSI ----------
features = fetch_paginated_data()

if not features:
    print("❌ Tidak ada fitur valid ditemukan.")
    sys.exit()

geojson_obj = {
    "type": "FeatureCollection",
    "features": features
}

# Simpan ke GeoJSON
with open(GEOJSON_PATH, "w", encoding="utf-8") as f:
    json.dump(geojson_obj, f, ensure_ascii=False, indent=2)

print(f"✅ GeoJSON disimpan ke: {GEOJSON_PATH}")
print(f"ℹ️ Total fitur: {len(features)}")

# ---------- KONVERSI KE GPKG ----------
print("🔄 Konversi GeoJSON → GPKG...")
ogr_cmd = [
    "ogr2ogr",
    "-f", "GPKG",
    GPKG_PATH,
    GEOJSON_PATH,
    "-nln", GPKG_LAYER_NAME,
    "-overwrite"
]

try:
    result = subprocess.run(ogr_cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print("❌ Gagal konversi ke GPKG:")
        print(result.stderr)
        sys.exit()
    else:
        print(f"✅ GPKG berhasil dibuat: {GPKG_PATH}")
except Exception as e:
    print(f"❌ Error menjalankan ogr2ogr: {e}")
    sys.exit()

# ---------- BUKA DI QGIS ----------
layer = QgsVectorLayer(GPKG_PATH, GPKG_LAYER_NAME, "ogr")
layer.setCrs(QgsCoordinateReferenceSystem("EPSG:4326"))

if not layer.isValid():
    raise Exception("❌ Layer GPKG tidak valid. Periksa file.")

QgsProject.instance().addMapLayer(layer)
print(f"✅ Layer '{GPKG_LAYER_NAME}' berhasil ditambahkan ke QGIS! Jumlah fitur: {layer.featureCount()}")
