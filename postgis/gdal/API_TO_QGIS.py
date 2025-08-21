# -- Contoh Query QGIS Menggunakan PILIHAN
import urllib3
import json
import os
import sys
from qgis.core import (
    QgsVectorLayer,
    QgsProject,
    QgsCoordinateReferenceSystem
)

# === Konfigurasi ===
IGT = "ADM_KAB_KOTA"  # Nama tabel layer
DEFAULT_KONDISI = "WADMPR=eq.Bali"  # Default filter

# Gunakan argumen dari CLI jika ada
KONDISI = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_KONDISI
print(f"ℹ️ Menggunakan filter: {KONDISI}")

# URL endpoint API Supabase
BASE_URL = "https://dbgis.menlhk.go.id"
ENDPOINT = f"{BASE_URL}/supabase/api/{IGT}?{KONDISI}"

# Lokasi penyimpanan GeoJSON
geojson_path = "C:/app/data/data_supabase.geojson"
os.makedirs(os.path.dirname(geojson_path), exist_ok=True)

# Cek jika file sudah ada
if os.path.exists(geojson_path):
    print(f"⚠️ File sudah ada dan akan ditimpa: {geojson_path}")

# === HTTP Request ===
http = urllib3.PoolManager(cert_reqs='CERT_NONE')
response = http.request("GET", ENDPOINT)

if response.status != 200:
    # Coba fallback ke supabase-proxy
    print(f"⚠️ Gagal ambil dari {ENDPOINT}, mencoba fallback ke supabase-proxy...")
    ENDPOINT = f"{BASE_URL}/supabase-proxy/api/{IGT}?{KONDISI}"
    response = http.request("GET", ENDPOINT)

    if response.status != 200:
        raise Exception(f"❌ Gagal mengambil data dari API. Status: {response.status}")

print(f"✅ Data berhasil diambil dari: {ENDPOINT}")

# === Parsing JSON Response ===
try:
    data = json.loads(response.data.decode("utf-8"))
except Exception as e:
    raise Exception(f"❌ Gagal parsing JSON: {e}")

# === Konversi ke GeoJSON FeatureCollection ===
features = []
for row in data:
    geom = row.get("geom") or row.get("geometry")
    if isinstance(geom, str):
        try:
            geom = json.loads(geom)
        except Exception as e:
            print("❌ Gagal parsing geometry:", e)
            continue

    if not isinstance(geom, dict) or "type" not in geom or "coordinates" not in geom:
        print("⚠️ Geometry tidak valid, dilewati:", geom)
        continue

    feature = {
        "type": "Feature",
        "geometry": geom,
        "properties": {k: v for k, v in row.items() if k not in ["geom", "geometry"]}
    }
    features.append(feature)

if not features:
    print("⚠️ Tidak ada fitur ditemukan. Proses dihentikan.")
    exit()

geojson = {
    "type": "FeatureCollection",
    "features": features
}

# === Simpan GeoJSON ke file ===
with open(geojson_path, "w", encoding="utf-8") as f:
    json.dump(geojson, f, ensure_ascii=False, indent=2)

print(f"✅ GeoJSON berhasil disimpan di: {geojson_path}")
print(f"ℹ️ Jumlah fitur: {len(features)}")

# === Tambahkan ke QGIS ===
layer = QgsVectorLayer(geojson_path, IGT, "ogr")
layer.setCrs(QgsCoordinateReferenceSystem("EPSG:4326"))

if not layer.isValid():
    raise Exception(f"❌ Layer '{IGT}' tidak valid. Cek struktur GeoJSON dan geometri.")

QgsProject.instance().addMapLayer(layer)
print(f"✅ Layer '{IGT}' berhasil ditambahkan ke QGIS! Jumlah fitur: {layer.featureCount()}")