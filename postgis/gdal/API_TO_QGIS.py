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
DEFAULT_KONDISI = "WADMPR=eq.Kalimantan Barat"  # Default filter jika tidak ada argumen

# Gunakan argumen CLI jika ada
KONDISI = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_KONDISI
print(f"ℹ️ Menggunakan filter: {KONDISI}")

# URL API Supabase
BASE_URL = "https://dbgis.planologi.kehutanan.go.id"
ENDPOINT = f"{BASE_URL}/datagis/api/rest/v1/{IGT}?{KONDISI}"

# Lokasi output file GeoJSON
geojson_path = "C:/app/data/data_datagis.geojson"
os.makedirs(os.path.dirname(geojson_path), exist_ok=True)

if os.path.exists(geojson_path):
    print(f"⚠️ File sudah ada dan akan ditimpa: {geojson_path}")

# === HTTP Request ===
http = urllib3.PoolManager(cert_reqs='CERT_NONE')
response = http.request("GET", ENDPOINT)

if response.status != 200:
    # Coba fallback jika endpoint utama gagal
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
total = len(data)
print(f"ℹ️ Memproses {total} entri...")

for idx, row in enumerate(data, start=1):
    geom = row.get("geom") or row.get("geometry")
    if isinstance(geom, str):
        try:
            geom = json.loads(geom)
        except Exception as e:
            print(f"❌ Gagal parsing geometry di entri ke-{idx}: {e}")
            continue

    if not isinstance(geom, dict) or "type" not in geom or "coordinates" not in geom:
        print(f"⚠️ Geometry tidak valid di entri ke-{idx}, dilewati.")
        continue

    feature = {
        "type": "Feature",
        "geometry": geom,
        "properties": {k: v for k, v in row.items() if k not in ["geom", "geometry"]}
    }
    features.append(feature)

    # === Progress Logging setiap 100 fitur ===
    if idx % 100 == 0 or idx == total:
        print(f"🔄 Diproses: {idx}/{total} fitur")

if not features:
    print("⚠️ Tidak ada fitur valid ditemukan. Proses dihentikan.")
    exit()

geojson = {
    "type": "FeatureCollection",
    "features": features
}

# === Simpan GeoJSON ke file ===
with open(geojson_path, "w", encoding="utf-8") as f:
    json.dump(geojson, f, ensure_ascii=False, indent=2)

print(f"✅ GeoJSON berhasil disimpan di: {geojson_path}")
print(f"ℹ️ Total fitur valid: {len(features)}")

# === Tambahkan ke QGIS ===
layer = QgsVectorLayer(geojson_path, IGT, "ogr")
layer.setCrs(QgsCoordinateReferenceSystem("EPSG:4326"))

if not layer.isValid():
    raise Exception(f"❌ Layer '{IGT}' tidak valid. Cek struktur GeoJSON dan geometri.")

QgsProject.instance().addMapLayer(layer)
print(f"✅ Layer '{IGT}' berhasil ditambahkan ke QGIS! Jumlah fitur: {layer.featureCount()}")


