# Cek Lokasi lib PostgreSQL
# pg_config --pkglibdir
# /opt/bitnami/postgresql/lib
# chmod 644 /opt/bitnami/postgresql/lib/{st_geometry.so PGSQLEngine.so}

# lib ArcGIS Server 10.9.1
for pg_ags in ./lib/*.so; do
  docker cp $pg_ags PGSQL-12:/opt/bitnami/postgresql/lib
done
