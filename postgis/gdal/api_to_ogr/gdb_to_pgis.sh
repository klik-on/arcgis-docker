#!/bin/bash
set -e

# === Konfigurasi ===
DB_HOST="172.16.2.122"
DB_PORT="5432"
DB_NAME="postgres"
DB_USER="postgres.67888"
DB_PASS="password00"
SCHEMA="datagis"

DATA_DIR="/app/data"
ZIP_FILE="pbph_definitif.gdb.zip"
GDB_FOLDER="pbph_definitif.gdb"
TABLE_NAME="PBPH_DEFINITIF"

ZIP_PATH="${DATA_DIR}/${ZIP_FILE}"
GDB_PATH="${DATA_DIR}/${GDB_FOLDER}"

# === Ekstrak ZIP jika perlu ===
if [ ! -d "$GDB_PATH" ]; then
  echo "?? Mengekstrak ZIP: $ZIP_PATH"
  if [ -f "$ZIP_PATH" ]; then
    unzip -o "$ZIP_PATH" -d "$DATA_DIR"
  else
    echo "? File ZIP tidak ditemukan: $ZIP_PATH"
    exit 1
  fi
fi

# === Impor ke PostgreSQL ===
echo "?? Mengimpor ${GDB_FOLDER} ke PostgreSQL..."
ogr2ogr -f "PostgreSQL" \
  PG:"host=${DB_HOST} port=${DB_PORT} dbname=${DB_NAME} user=${DB_USER} password=${DB_PASS}" \
  "$GDB_PATH" \
  -nlt MULTIPOLYGON \
  -nln "${TABLE_NAME}" \
  -dim 2 \
  -lco SCHEMA=${SCHEMA} \
  -lco GEOMETRY_NAME=geom \
  -lco FID=id \
  -lco SPATIAL_INDEX=GIST \
  -lco LAUNDER=NO \
  -lco OVERWRITE=YES \
  -t_srs EPSG:4326 \
  -progress \
  --config OGR_OPENFILEGDB_METHOD SKIP \
  --config OGR_ENABLE_CURVE_REDUCTION YES \
  --config OGR_FORCE_GML_MULTISURFACE_AS_MULTIPOLYGON YES \
  --config OGR_ORGANIZE_POLYGONS SKIP

echo "? Impor selesai."

# === (Opsional) Bersihkan folder GDB hasil ekstrak ===
rm -rf "$GDB_PATH"
