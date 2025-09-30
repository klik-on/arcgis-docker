import urllib3
import json
import os
import sys
from dotenv import load_dotenv

# === Load environment dari .env ===
load_dotenv()

# === Konfigurasi ===
IGT = "ADM_KAB_KOTA"
DEFAULT_KONDISI = "WADMPR=eq.Kalimantan Barat"
KONDISI = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_KONDISI
print(f"ℹ️ Menggunakan filter: {KONDISI}")

BASE_URL = "https://dbgis.planologi.kehutanan.go.id"
ENDPOINT = f"{BASE_URL}/datagis/api/rest/v1/{IGT}?{KONDISI}"

geojson_path = "data/ADM_KAB_KOTA.geojson"
os.makedirs(os.path.dirname(geojson_path), exist_ok=True)

if os.path.exists(geojson_path):
    print(f"⚠️ File sudah ada dan akan ditimpa: {geojson_path}")

# === Ambil API Key dari .env ===
ANON_KEY = os.getenv("SUPABASE_ANON_KEY")
if not ANON_KEY:
    print("❌ API Key tidak ditemukan. Pastikan file .env tersedia dan SUPABASE_ANON_KEY terisi.")
    sys.exit(1)

http = urllib3.PoolManager(cert_reqs='CERT_NONE')

headers = {
    "apikey": ANON_KEY,
    "Accept": "application/json"
}

response = http.request("GET", ENDPOINT, headers=headers)

if response.status >= 400:
    print(f"⚠️ Gagal ambil dari {ENDPOINT}, mencoba fallback ke datagis-proxy...")
    ENDPOINT = f"{BASE_URL}/datagis/api/{IGT}?{KONDISI}"
    response = http.request("GET", ENDPOINT, headers=headers)

    if response.status >= 400:
        print(f"❌ Gagal mengambil data dari API. Status: {response.status}")
        print(f"Response error: {response.data.decode('utf-8')}")
        sys.exit(1)

print(f"✅ Data berhasil diambil dari: {ENDPOINT}")

try:
    data = json.loads(response.data.decode("utf-8"))
except Exception as e:
    print(f"❌ Gagal parsing JSON: {e}")
    sys.exit(1)

if not data:
    print("⚠️ API mengembalikan data kosong.")
    sys.exit(1)

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

    if idx % 100 == 0 or idx == total:
        print(f"🔄 Diproses: {idx}/{total} fitur")

if not features:
    print("⚠️ Tidak ada fitur valid ditemukan. Proses dihentikan.")
    sys.exit(1)

geojson = {
    "type": "FeatureCollection",
    "features": features
}

try:
    with open(geojson_path, "w", encoding="utf-8") as f:
        json.dump(geojson, f, ensure_ascii=False, indent=2)
    print(f"✅ GeoJSON berhasil disimpan di: {geojson_path}")
    print(f"ℹ️ Total fitur valid: {len(features)}")
except Exception as e:
    print(f"❌ Gagal menyimpan file GeoJSON: {e}")
    sys.exit(1)
