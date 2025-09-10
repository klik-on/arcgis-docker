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

for pg_ags in *.so; do
  docker cp $pg_ags supabase-db:/nix/store/z7wx806c53g1ggmvsff47qnfyk47jkn4-postgresql-15.14-lib/lib

done
