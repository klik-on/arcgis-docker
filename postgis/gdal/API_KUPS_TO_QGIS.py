### Versi lengkap API → GeoJSON → QGIS
import os
import json
import requests
import urllib3
import logging

# ========== KONFIGURASI LOGGING ==========
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler("log_kups.log", encoding="utf-8")
    ]
)

# ========== KONFIGURASI ==========
folder_path = "C:/app/data"
json_path = os.path.join(folder_path, "kups.json")
geojson_path = os.path.join(folder_path, "kups.geojson")
url = "https://gokups.menlhk.go.id/api/v1/kups"

# ========== PERSIAPAN FOLDER ==========
os.makedirs(folder_path, exist_ok=True)
logging.info(f"📁 Folder disiapkan: {folder_path}")

# ========== NONAKTIFKAN PERINGATAN SSL ==========
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# ========== AMBIL DATA DARI API ==========
try:
    response = requests.get(url, verify=False, timeout=10)
    response.raise_for_status()
    with open(json_path, "w", encoding="utf-8") as f:
        f.write(response.text)
    logging.info(f"✅ Data berhasil diambil dan disimpan: {json_path}")
except requests.RequestException as e:
    logging.error(f"❌ Gagal mengambil data dari API: {e}")
    exit()

# ========== KONVERSI KE GEOJSON ==========
try:
    with open(json_path, "r", encoding="utf-8") as f:
        raw_data = json.load(f)
except Exception as e:
    logging.error(f"❌ Gagal membuka file JSON: {e}")
    exit()

kups_list = raw_data.get("data", [])
features = []

for item in kups_list:
    try:
        lon = float(item["nujur"])
        lat = float(item["lintang"])

        # ===== VALIDASI KOORDINAT =====
        if not (-180 <= lon <= 180 and -90 <= lat <= 90):
            raise ValueError(f"Koordinat di luar batas: lon={lon}, lat={lat}")

        feature = {
            "type": "Feature",
            "geometry": {
                "type": "Point",
                "coordinates": [lon, lat]
            },
            "properties": {
                k: v for k, v in item.items() if k not in ["lintang", "nujur"]
            }
        }
        features.append(feature)
    except (KeyError, ValueError, TypeError) as e:
        logging.warning(f"⚠️ Data dilewati (koordinat tidak valid): {e}")

geojson_data = {
    "type": "FeatureCollection",
    "features": features
}

try:
    with open(geojson_path, "w", encoding="utf-8") as f:
        json.dump(geojson_data, f, ensure_ascii=False, indent=2)
    logging.info(f"✅ Konversi selesai. GeoJSON disimpan di: {geojson_path}")
    logging.info(f"🧾 Jumlah titik valid: {len(features)}")
except Exception as e:
    logging.error(f"❌ Gagal menyimpan GeoJSON: {e}")
    exit()

# ========== OPSIONAL: BUKA DI QGIS ==========
try:
    from qgis.core import QgsVectorLayer, QgsProject
    layer = QgsVectorLayer(geojson_path, "KUPS GeoJSON", "ogr")
    if layer.isValid():
        QgsProject.instance().addMapLayer(layer)
        logging.info("🗺️  Layer berhasil ditambahkan ke QGIS.")
    else:
        logging.error("❌ Gagal memuat layer ke QGIS.")
except ImportError:
    logging.info("ℹ️ Jalankan bagian QGIS hanya jika di dalam Python Console QGIS.")
