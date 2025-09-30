#!/bin/bash
set -e

IGT_BASE="ADM_KAB_KOTA"
DATA_DIR="/app/data"

echo "🕒 Mulai proses: $(date)"

# === Gabungkan semua argumen menjadi 1 filter string ===
FILTER="${*}"  # Gabung semua argumen jadi 1 string, dipisah spasi

if [ -n "$FILTER" ]; then
  echo "🚀 Menjalankan api_to_geojson.py dengan filter: \"$FILTER\""
  python3 api_to_geojson.py "$FILTER"
else
  echo "🚀 Menjalankan api_to_geojson.py dengan filter default (Kalimantan Barat)"
  python3 api_to_geojson.py
fi

# === Ekstrak nama wilayah dari filter ===
if [[ "$FILTER" =~ WADMPR=eq[.\ ]*([^[:space:]]+.*) ]]; then
  RAW_WILAYAH="${BASH_REMATCH[1]}"
else
  RAW_WILAYAH="Kalimantan_Barat"
fi

# Format nama wilayah (hapus spasi, karakter spesial)
ALIAS=$(echo "$RAW_WILAYAH" | tr ' ' '_' | tr -cd '[:alnum:]_')
IGT="${IGT_BASE}_${ALIAS}"

# === Lokasi file ===
GEOJSON_PATH="${DATA_DIR}/${IGT}.geojson"
GDB_PATH="${DATA_DIR}/${IGT}.gdb"
ZIP_PATH="${DATA_DIR}/${IGT}.gdb.zip"

# === Cek hasil GeoJSON (asalnya disimpan dengan nama tetap) ===
if [ ! -f "${DATA_DIR}/${IGT_BASE}.geojson" ]; then
  echo "❌ File GeoJSON tidak ditemukan: ${DATA_DIR}/${IGT_BASE}.geojson"
  exit 1
fi

# Rename ke nama wilayah
mv "${DATA_DIR}/${IGT_BASE}.geojson" "$GEOJSON_PATH"

# === Validasi dependencies ===
if ! command -v ogr2ogr &> /dev/null; then
  echo "❌ Perintah 'ogr2ogr' tidak ditemukan. Pastikan GDAL terinstal dengan benar."
  exit 1
fi

if ! command -v zip &> /dev/null; then
  echo "❌ Perintah 'zip' tidak ditemukan. Pastikan sudah terinstal."
  exit 1
fi

# === Konversi GeoJSON → FileGDB ===
echo "🚀 Mengkonversi GeoJSON ke FileGDB..."
if ! ogr2ogr -f "OpenFileGDB" \
  "$GDB_PATH" \
  "$GEOJSON_PATH" \
  -dim 2 \
  -nln "$IGT" \
  -nlt PROMOTE_TO_MULTI \
  -t_srs EPSG:4326 \
  -lco OVERWRITE=YES \
  -progress \
  --config OGR_OPENFILEGDB_METHOD SKIP \
  --config OGR_ENABLE_CURVE_REDUCTION YES \
  --config OGR_ORGANIZE_POLYGONS SKIP; then
  echo "❌ Konversi GeoJSON ke GDB gagal."
  exit 1
fi

# === Compress hasil ===
echo "📦 Membuat archive ZIP dari $GDB_PATH ..."
pushd "$DATA_DIR" > /dev/null
zip -r "$ZIP_PATH" "$(basename "$GDB_PATH")"
popd > /dev/null

# === Cleanup sementara ===
echo "🧹 Menghapus folder $GDB_PATH dan file $GEOJSON_PATH ..."
rm -rf "$GDB_PATH"
rm -f "$GEOJSON_PATH"

echo "✅ Proses selesai! File ZIP tersimpan di: $ZIP_PATH"
echo "🕒 Selesai: $(date)"
