#!/bin/bash
set -e  # Stop on first error

# === Konfigurasi Database ===
DB_HOST="172.16.2.122"
DB_PORT="5432"
DB_NAME="postgres"
DB_USER="postgres.67888"
DB_PASS="password00"
SCHEMA="datagis"

# === Lokasi Data ===
DATA_DIR="/app/data"
ZIP_FILE="KWSHUTAN_AR_250K_v18102025.gdb.zip"
GDB_FOLDER="KWSHUTAN_AR_250K_v18102025.gdb"

ZIP_PATH="${DATA_DIR}/${ZIP_FILE}"
GDB_PATH="${DATA_DIR}/${GDB_FOLDER}"

# === Export password agar tidak terlihat di argumen ps ===
export PGPASSWORD="${DB_PASS}"

# === Ekstrak ZIP jika belum ada folder GDB ===
if [ ! -d "$GDB_PATH" ]; then
  echo "🔍 Mengekstrak ZIP: $ZIP_PATH"
  if [ -f "$ZIP_PATH" ]; then
    unzip -o "$ZIP_PATH" -d "$DATA_DIR"
  else
    echo "❌ File ZIP tidak ditemukan: $ZIP_PATH"
    exit 1
  fi
fi

# === Ambil semua nama layer dari file GDB ===
mapfile -t LAYERS < <(
  ogrinfo "$GDB_PATH" |
  grep 'Layer:' |
  awk -F'Layer: ' '{print $2}' |
  sed -E 's/ \(.+//'
)

# === Validasi layer ditemukan ===
if [ ${#LAYERS[@]} -eq 0 ]; then
  echo "❌ Tidak ada layer ditemukan di GDB: $GDB_PATH"
  exit 1
fi

# === Tampilkan daftar layer yang ditemukan ===
echo "📋 Ditemukan ${#LAYERS[@]} layer:"
for L in "${LAYERS[@]}"; do
  echo "   - $L"
done

# === Impor ke PostgreSQL/PostGIS ===
for LAYER in "${LAYERS[@]}"; do
  # Lewati jika nama layer kosong
  if [ -z "$LAYER" ]; then
    echo "⚠️  Layer kosong, dilewati"
    continue
  fi

  echo "📥 Mengimpor layer: $LAYER"

  ogr2ogr -f "PostgreSQL" \
    PG:"host=${DB_HOST} port=${DB_PORT} dbname=${DB_NAME} user=${DB_USER}" \
    "$GDB_PATH" \
    -nlt CONVERT_TO_LINEAR \
    -nln "$LAYER" \
    -dim 2 \
    -lco SCHEMA=${SCHEMA} \
    -lco GEOMETRY_NAME=geom \
    -lco SPATIAL_INDEX=GIST \
    -lco LAUNDER=NO \
    -lco OVERWRITE=YES \
    -t_srs EPSG:4326 \
    -progress \
    --config OGR_OPENFILEGDB_METHOD SKIP \
    --config OGR_ENABLE_CURVE_REDUCTION YES \
    --config OGR_FORCE_GML_MULTISURFACE_AS_MULTIPOLYGON YES \
    --config OGR_ORGANIZE_POLYGONS SKIP \
    --config PG_USE_COPY YES
done

# === Bersihkan folder GDB setelah impor ===
echo "🧹 Menghapus folder GDB: $GDB_PATH"
rm -rf "$GDB_PATH"

echo "✅ Impor selesai pada $(date)"
