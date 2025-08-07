import os
import json
import requests
import urllib3

# === KONFIGURASI ===
folder_path = "C:/app/data"
json_path = os.path.join(folder_path, "kups.json")
geojson_path = os.path.join(folder_path, "kups.geojson")
url = "https://gokups.menlhk.go.id/api/v1/kups"

# === BUAT FOLDER TUJUAN ===
os.makedirs(folder_path, exist_ok=True)

# === NONAKTIFKAN PERINGATAN SSL ===
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# === UNDUH DATA DARI API ===
print("🔄 Mengambil data dari API...")
try:
    response = requests.get(url, verify=False, timeout=10)
    response.raise_for_status()
    with open(json_path, "w", encoding="utf-8") as f:
        f.write(response.text)
    print(f"✅ Data berhasil disimpan: {json_path}")
except requests.RequestException as e:
    print(f"❌ Gagal mengambil data: {e}")
    exit(1)

# === KONVERSI JSON KE GEOJSON ===
print("🛠️  Mengonversi ke GeoJSON...")

with open(json_path, "r", encoding="utf-8") as f:
    raw_data = json.load(f)

kups_list = raw_data.get("data", [])
features = []

for item in kups_list:
    try:
        lon = float(item["nujur"])
        lat = float(item["lintang"])
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
    except (KeyError, ValueError, TypeError):
        continue

geojson_data = {
    "type": "FeatureCollection",
    "features": features
}

with open(geojson_path, "w", encoding="utf-8") as f:
    json.dump(geojson_data, f, ensure_ascii=False, indent=2)

print(f"✅ Konversi selesai. File GeoJSON disimpan di: {geojson_path}")
print(f"📌 Jumlah titik valid: {len(features)}")

# === PESAN TAMBAHAN ===
print("📍 Kamu bisa membuka file GeoJSON ini di QGIS secara manual.")
