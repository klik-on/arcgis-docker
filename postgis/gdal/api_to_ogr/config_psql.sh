#!/bin/bash
# -------------------------------------------------------------------
# Script: config_psql.sh
# Deskripsi: Modifikasi postgresql.conf di dalam container Supabase
#            tanpa perlu masuk ke dalam container
# -------------------------------------------------------------------

CONTAINER="supabase-db"
CONF="/etc/postgresql/postgresql.conf"
CONF_BAK="/etc/postgresql/postgresql.conf.bak"

echo "==> Membuat backup konfigurasi PostgreSQL..."
docker exec "$CONTAINER" cp "$CONF" "$CONF_BAK"

echo "==> Mengubah parameter konfigurasi PostgreSQL..."
docker exec "$CONTAINER" sed -i "s/^#*shared_buffers.*/shared_buffers = 8GB/" "$CONF"
docker exec "$CONTAINER" sed -i "s/^#*work_mem.*/work_mem = 256MB/" "$CONF"
docker exec "$CONTAINER" sed -i "s/^#*maintenance_work_mem.*/maintenance_work_mem = 1GB/" "$CONF"
docker exec "$CONTAINER" sed -i "s/^#*max_parallel_workers_per_gather.*/max_parallel_workers_per_gather = 8/
" "$CONF"
docker exec "$CONTAINER" sed -i "s/^#*temp_buffers.*/temp_buffers = 512MB/" "$CONF"

echo "==> Restart container Supabase DB..."
docker restart "$CONTAINER"

echo "==> Menunggu PostgreSQL siap..."
sleep 5

echo "==> Mengecek konfigurasi PostgreSQL..."

get_val() {
    docker exec "$CONTAINER" psql -U postgres -d postgres -t -A -c "$1"
}

shared_buffers=$(get_val "SHOW shared_buffers;")
work_mem=$(get_val "SHOW work_mem;")
maintenance_work_mem=$(get_val "SHOW maintenance_work_mem;")
max_parallel_workers=$(get_val "SHOW max_parallel_workers_per_gather;")
temp_buffers=$(get_val "SHOW temp_buffers;")

echo ""
echo "==================== PostgreSQL Current Config ===================="
printf "%-35s | %s\n" "shared_buffers" "$shared_buffers"
printf "%-35s | %s\n" "work_mem" "$work_mem"
printf "%-35s | %s\n" "maintenance_work_mem" "$maintenance_work_mem"
printf "%-35s | %s\n" "max_parallel_workers_per_gather" "$max_parallel_workers"
printf "%-35s | %s\n" "temp_buffers" "$temp_buffers"
echo "==================================================================="
echo ""

echo "==> Selesai! Konfigurasi telah diterapkan dan diverifikasi."
