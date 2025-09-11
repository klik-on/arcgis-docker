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

# Ambil path library PostgreSQL dari dalam container
lok_lib=$(docker exec supabase-db pg_config --pkglibdir)

# Cek jika gagal mengambil path
if [ -z "$lok_lib" ]; then
  echo "Gagal mendapatkan path library PostgreSQL dari container."
  exit 1
fi

echo "📁 Target path di dalam container: $lok_lib"

# Loop semua file .so di direktori saat ini
for pg_ags in *.so; do
  echo "📦 Menyalin $pg_ags ke container..."

  # Copy file .so ke dalam container
  docker cp "$pg_ags" "supabase-db:$lok_lib/"

  # Ambil nama file saja
  file_name=$(basename "$pg_ags")

  # Set permission dan ownership
  docker exec supabase-db chmod 555 "$lok_lib/$file_name"
  docker exec supabase-db chown root:root "$lok_lib/$file_name"

  echo "✅ $file_name berhasil disalin dan di-set permission."
done
