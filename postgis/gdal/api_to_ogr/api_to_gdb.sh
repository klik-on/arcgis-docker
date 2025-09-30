#!/bin/bash
set -e

IGT="ADM_KAB_KOTA"
DATA_DIR="/app/data"

echo "🚀 Menjalankan script Python untuk ambil data dan buat GeoJSON..."
echo "Ganti menjadi  python3 api_to_geojson.py "WADMPR=eq.Jawa Tengah" untuk kondisi bukan DEFAULT "
if ! python3 api_to_geojson.py; then
  echo "❌ Gagal menjalankan api_to_geojson.py"
  exit 1
fi

GEOJSON_PATH="${DATA_DIR}/${IGT}.geojson"
GDB_PATH="${DATA_DIR}/${IGT}.gdb"
ZIP_PATH="${DATA_DIR}/${IGT}.gdb.zip"

if [ ! -f "$GEOJSON_PATH" ]; then
  echo "❌ File GeoJSON tidak ditemukan: $GEOJSON_PATH"
  exit 1
fi

if ! command -v ogr2ogr &> /dev/null; then
  echo "❌ Perintah 'ogr2ogr' tidak ditemukan. Pastikan GDAL terinstal dengan benar."
  exit 1
fi

if ! command -v zip &> /dev/null; then
  echo "❌ Perintah 'zip' tidak ditemukan. Pastikan sudah terinstal."
  exit 1
fi

echo "🚀 Mengkonversi GeoJSON ke OpenFileGDB menggunakan ogr2ogr..."
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

echo "📦 Membuat archive ZIP dari $GDB_PATH ..."
pushd "$DATA_DIR" > /dev/null
zip -r "$ZIP_PATH" "$(basename "$GDB_PATH")"
popd > /dev/null

echo "🧹 Menghapus folder $GDB_PATH dan file $GEOJSON_PATH ..."
rm -rf "$GDB_PATH"
rm -f "$GEOJSON_PATH"

echo "✅ Proses selesai! File ZIP tersimpan di: $ZIP_PATH"
