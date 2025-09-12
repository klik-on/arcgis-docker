# kolom geom berisi WKB HEX (Well-Known Binary dalam format heksadesimal), bukan GeoJSON biasa
# cek decode WKB HEX ke GeoJSON
# Script Final (Gunakan shapely untuk parse HEX ke GeoJSON)

import os
import sys
import json
import binascii
import requests
from shapely import wkb
from shapely.geometry import mapping
from qgis.core import (
    QgsVectorLayer,
    QgsProject,
    QgsCoordinateReferenceSystem
)

# ---------- KONFIGURASI ----------
IGT = "pbph_definitif"
KONDISI = "select=*&limit=2"
USERNAME = "test"
PASSWORD = "*******"
BASE_URL = "https://phl.menlhk.go.id"
ENDPOINT = f"{BASE_URL}/api/v1/{IGT}?{KONDISI}"

OUTPUT_PATH = "C:/app/data/pbph_definitif_limit2.geojson"
os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)

# ---------- AMBIL DATA ----------
response = requests.get(ENDPOINT, auth=(USERNAME, PASSWORD))

if response.status_code != 200:
    print(f"❌ Gagal mengambil data dari API. Status: {response.status_code}")
    print(response.text)
    sys.exit()

print("✅ Data berhasil diambil.")

try:
    data_json = response.json()
except Exception as e:
    print(f"❌ Gagal parsing JSON: {e}")
    sys.exit()

if not data_json.get("status") or "data" not in data_json:
    print("❌ Struktur respons tidak sesuai.")
    sys.exit()

entries = data_json["data"]

# ---------- KONVERSI KE GEOJSON ----------
features = []
for idx, item in enumerate(entries, start=1):
    geom_wkb_hex = item.get("geom")
    if not geom_wkb_hex:
        print(f"⚠️ Entry ke-{idx} tidak memiliki 'geom'.")
        continue

    try:
        geom_wkb = binascii.unhexlify(geom_wkb_hex)
        geom = wkb.loads(geom_wkb)
        geojson_geom = mapping(geom)
    except Exception as e:
        print(f"⚠️ Gagal parsing WKB di entry ke-{idx}: {e}")
        continue

    feature = {
        "type": "Feature",
        "geometry": geojson_geom,
        "properties": {k: v for k, v in item.items() if k != "geom"}
    }
    features.append(feature)

    print(f"✅ Parsed entry ke-{idx}")

if not features:
    print("❌ Tidak ada fitur valid untuk disimpan.")
    sys.exit()

geojson_obj = {
    "type": "FeatureCollection",
    "features": features
}

with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
    json.dump(geojson_obj, f, ensure_ascii=False, indent=2)

print(f"✅ GeoJSON berhasil disimpan di: {OUTPUT_PATH}")
print(f"ℹ️ Jumlah fitur valid: {len(features)}")

# ---------- BUKA DI QGIS ----------
layer = QgsVectorLayer(OUTPUT_PATH, IGT, "ogr")
layer.setCrs(QgsCoordinateReferenceSystem("EPSG:4326"))

if not layer.isValid():
    raise Exception("❌ Layer tidak valid. Cek struktur GeoJSON atau geometri.")

QgsProject.instance().addMapLayer(layer)
print(f"✅ Layer '{IGT}' berhasil ditambahkan ke QGIS! Jumlah fitur: {layer.featureCount()}")
