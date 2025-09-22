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
ZIP_FILE="kups.gdb.zip"
ZIP_PATH="${DATA_DIR}/${ZIP_FILE}"
TABLE_NAME="KUPS"

# === Impor ke PostgreSQL ===
echo "?? Mengimpor ${ZIP_PATH} ke PostgreSQL..."
ogr2ogr -f "PostgreSQL" \
  PG:"host=${DB_HOST} port=${DB_PORT} dbname=${DB_NAME} user=${DB_USER} password=${DB_PASS}" \
  "$ZIP_PATH" \
  -nlt MULTIPOINT \
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
  --config OGR_OPENFILEGDB_METHOD SKIP

echo "? Impor selesai."
