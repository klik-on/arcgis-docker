#!/bin/bash
set -e

# === Konfigurasi ===
LAYER_NAME="PBPH_DEFINITIF"
DATA_DIR="/app/data"
OUTPUT_GDB="${DATA_DIR}/${LAYER_NAME}.gdb"

PG_HOST="172.16.2.122"
PG_PORT="5432"
PG_DB="postgres"
PG_USER="postgres.67888"
PG_PASS="password00"
PG_SCHEMA="datagis"

# === Cek dependencies ===
command -v ogr2ogr >/dev/null 2>&1 || { echo "❌ ogr2ogr tidak ditemukan"; exit 1; }
command -v zip >/dev/null 2>&1 || { echo "❌ zip tidak ditemukan"; exit 1; }

# === Siapkan folder ===
mkdir -p "$DATA_DIR"

# === Ekspor dari PostgreSQL ke FileGDB ===
echo "📤 Mengekspor layer ${LAYER_NAME} dari PostgreSQL ke FileGDB..."

PGPASSWORD="${PG_PASS}" ogr2ogr -f "OpenFileGDB" \
  "${OUTPUT_GDB}" \
  PG:"host=${PG_HOST} port=${PG_PORT} dbname=${PG_DB} user=${PG_USER}" \
  ${PG_SCHEMA}."${LAYER_NAME}" \
  -nln "${LAYER_NAME}" \
  -dim 2 \
  -t_srs EPSG:4326 \
  -overwrite \
  -progress \
  -lco LAUNDER=NO \
  --config OGR_OPENFILEGDB_METHOD SKIP \
  --config OGR_ENABLE_CURVE_REDUCTION YES \
  --config OGR_FORCE_GML_MULTISURFACE_AS_MULTIPOLYGON YES \
  --config OGR_ORGANIZE_POLYGONS SKIP

# === Kompres output ke ZIP ===
echo "📦 Mengarsipkan ${LAYER_NAME}.gdb ke ZIP..."
pushd "$DATA_DIR" > /dev/null
zip -r "${LAYER_NAME}.gdb.zip" "${LAYER_NAME}.gdb"
popd > /dev/null

# === Hapus folder GDB setelah ZIP ===
rm -rf "${OUTPUT_GDB}"

echo "✅ File ZIP berhasil dibuat: ${DATA_DIR}/${LAYER_NAME}.gdb.zip"
