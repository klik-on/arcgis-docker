import os
import sys
import json
import requests
import urllib3
import logging
from datetime import datetime

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
FOLDER_PATH = "C:/app/data"
JSON_PATH = os.path.join(FOLDER_PATH, "kups.json")
GEOJSON_PATH = os.path.join(FOLDER_PATH, "kups.geojson")
API_URL = "https://gokups.menlhk.go.id/api/v1/kups"

# ========== PERSIAPAN FOLDER ==========
try:
    os.makedirs(FOLDER_PATH, exist_ok=True)
    logging.info(f"📁 Folder disiapkan: {FOLDER_PATH}")
except Exception as e:
    logging.error(f"❌ Gagal membuat folder: {e}")
    sys.exit(1)

# ========== NONAKTIFKAN PERINGATAN SSL ==========
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# ========== AMBIL DATA DARI API ==========
try:
    response = requests.get(API_URL, verify=False, timeout=10)
    response.raise_for_status()
    with open(JSON_PATH, "w", encoding="utf-8") as f:
        f.write(response.text)
    logging.info(f"✅ Data berhasil diambil dan disimpan: {JSON_PATH}")
except requests.RequestException as e:
    logging.error(f"❌ Gagal mengambil data dari API: {e}")
    sys.exit(1)

# ========== MEMBACA DAN KONVERSI KE GEOJSON ==========
try:
    with open(JSON_PATH, "r", encoding="utf-8") as f:
        raw_data = json.load(f)
except Exception as e:
    logging.error(f"❌ Gagal membuka file JSON: {e}")
    sys.exit(1)

kups_list = raw_data.get("data", [])
features = []
invalid_count = 0

for item in kups_list:
    try:
        lon = float(item.get("nujur", 0))
        lat = float(item.get("lintang", 0))

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
        invalid_count += 1
        logging.warning(f"⚠️ Data dilewati (koordinat tidak valid): {e}")

geojson_data = {
    "type": "FeatureCollection",
    "features": features,
    "metadata": {
        "sumber": API_URL,
        "jumlah_titik": len(features),
        "jumlah_tidak_valid": invalid_count,
        "waktu_dibuat": datetime.now().isoformat()
    }
}

# ========== SIMPAN GEOJSON ==========
try:
    with open(GEOJSON_PATH, "w", encoding="utf-8") as f:
        json.dump(geojson_data, f, ensure_ascii=False, indent=2)
    logging.info(f"✅ Konversi selesai. GeoJSON disimpan di: {GEOJSON_PATH}")
    logging.info(f"🧾 Jumlah titik valid: {len(features)}")
    logging.info(f"🚫 Jumlah titik dilewati (tidak valid): {invalid_count}")
except Exception as e:
    logging.error(f"❌ Gagal menyimpan GeoJSON: {e}")
    sys.exit(1)

# ========== OPSIONAL: BUKA DI QGIS ==========
try:
    from qgis.core import QgsVectorLayer, QgsProject

    layer = QgsVectorLayer(GEOJSON_PATH, "KUPS GeoJSON", "ogr")
    if layer.isValid():
        QgsProject.instance().addMapLayer(layer)
        logging.info("🗺️  Layer berhasil ditambahkan ke QGIS.")
    else:
        logging.error("❌ Gagal memuat layer ke QGIS.")
except ImportError:
    logging.info("ℹ️ Jalankan bagian QGIS hanya jika di dalam Python Console QGIS.")
except Exception as e:
    logging.error(f"❌ Error saat memuat layer ke QGIS: {e}")
