#!/bin/bash

# === Variabel koneksi PostgreSQL ===
PG_HOST=localhost
PG_PORT=5432
PG_DB=mygisdb
PG_USER=postgres
PG_PASS=secret

# === Variabel data & output ===
PG_SCHEMA=datagis
LAYER_NAME=adm_provinsi_clean
DATA_DIR="$(pwd)"  # Direktori kerja/output
OUTPUT_GDB="${DATA_DIR}/${LAYER_NAME}.gdb"
OUTPUT_ZIP="${DATA_DIR}/${LAYER_NAME}.gdb.zip"

# === Remote Nextcloud (via rclone) ===
NEXTCLOUD_REMOTE="nextcloud"           # Nama remote di rclone config
NEXTCLOUD_PATH="GIS/Export"            # Folder tujuan di Nextcloud

# === 1. Ekspor dari PostGIS ke OpenFileGDB ===
echo "🚀 Mengekspor layer ${LAYER_NAME} ke OpenFileGDB..."
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

# === 2. Kompres ke ZIP ===
echo "📦 Mengarsipkan ${LAYER_NAME}.gdb ke ZIP..."
pushd "$DATA_DIR" > /dev/null
zip -r "${LAYER_NAME}.gdb.zip" "${LAYER_NAME}.gdb" > /dev/null
popd > /dev/null

# === 3. Hapus folder GDB setelah ZIP ===
echo "🧹 Menghapus folder ${LAYER_NAME}.gdb setelah kompresi..."
rm -rf "${OUTPUT_GDB}"

# === 4. Upload ke Nextcloud via rclone ===
echo "☁️ Mengunggah ${LAYER_NAME}.gdb.zip ke Nextcloud..."
rclone copy "${OUTPUT_ZIP}" "${NEXTCLOUD_REMOTE}:${NEXTCLOUD_PATH}" --progress

echo "✅ Semua selesai. File ZIP diunggah ke Nextcloud: ${NEXTCLOUD_PATH}/${LAYER_NAME}.gdb.zip"
