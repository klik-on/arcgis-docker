# Cek Lokasi lib PostgreSQL
# pg_config --pkglibdir
# /usr/lib/postgresql/12/lib
# chmod 644 /usr/lib/postgresql/12/lib/st_geometry.so

for pg_ags in ./lib/*.so; do
  docker cp $pg_ags PGSQL-12:/opt/bitnami/postgresql/lib
done
