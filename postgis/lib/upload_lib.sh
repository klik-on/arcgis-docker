# Cek port yang digunakan
# sudo lsof -i -P -n | grep LISTEN
# sudo netstat -tuln | grep LISTEN
# sudo ss -tulwn
# Cek Lokasi lib PostgreSQL
# docker exec -it `docker ps | grep supabase-db | cut -b -12` /bin/bash
# pg_config --pkglibdir
# /nix/store/z7wx806c53g1ggmvsff47qnfyk47jkn4-postgresql-15.14-lib/lib
# chmod 555 /usr/lib/postgresql/15/lib/{st_geometry.so PGSQLEngine.so}
# chown root:root /usr/lib/postgresql/15/lib/st_geometry.so
# ls -l /usr/lib/postgresql/15/lib/st_geometry.so

# lib ArcGIS Desktop 10.8.2 ==> POSTGRESQL 12
# lib ArcGIS PRO 3.5 ==> POSTGRESQL 15

#!/bin/bash

# Cek apakah container supabase-db sedang berjalan
if ! docker ps --format '{{.Names}}' | grep -q '^supabase-db$'; then
  echo "❌ Container 'supabase-db' tidak ditemukan atau tidak sedang berjalan."
  exit 1
fi

# Ambil path library PostgreSQL dari dalam container
lok_lib=$(docker exec supabase-db pg_config --pkglibdir 2>/dev/null)

# Cek jika gagal mengambil path
if [ -z "$lok_lib" ]; then
  echo "❌ Gagal mendapatkan path library PostgreSQL dari container menggunakan 'pg_config --pkglibdir'."
  exit 1
fi

echo "📁 Target path PostgreSQL dalam container: $lok_lib"

# Cari file .so di direktori saat ini
so_files=(*.so)

# Cek apakah ada file .so
if [ "${so_files[0]}" == "*.so" ]; then
  echo "❌ Tidak ditemukan file .so di direktori ini."
  exit 1
fi

# Proses tiap file .so
for pg_ags in "${so_files[@]}"; do
  echo "📦 Menyalin $pg_ags ke container..."

  # Copy file .so ke dalam container
  docker cp "$pg_ags" "supabase-db:$lok_lib/"
  if [ $? -ne 0 ]; then
    echo "❌ Gagal menyalin $pg_ags ke container."
    continue
  fi

  # Ambil nama file
  file_name=$(basename "$pg_ags")

  # Set permission dan ownership
  docker exec supabase-db chmod 555 "$lok_lib/$file_name" || echo "⚠️ Gagal chmod $file_name"
  docker exec supabase-db chown root:root "$lok_lib/$file_name" || echo "⚠️ Gagal chown $file_name"

  echo "✅ $file_name berhasil disalin dan diatur permission/ownership."
done
