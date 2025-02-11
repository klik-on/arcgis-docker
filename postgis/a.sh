# Cek port yang digunakan
# sudo lsof -i -P -n | grep LISTEN
# sudo netstat -tuln | grep LISTEN
# sudo ss -tulwn
# Cek Lokasi lib PostgreSQL
# pg_config --pkglibdir
# /usr/lib/postgresql/15/lib
# chmod 644 /usr/lib/postgresql/15/lib/{st_geometry.so PGSQLEngine.so}
# chown root. /usr/lib/postgresql/15/lib/st_geometry.so
# ls -l /usr/lib/postgresql/15/lib/st_geometry.so

# lib ArcGIS Desktop 10.8.2
for pg_ags in ./lib/*.so; do
  docker cp $pg_ags PGIS-15:/usr/lib/postgresql/15/lib 
done

