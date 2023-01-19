for pg_ags in *.so; do
  docker cp $pg_ags debian-11-postgresql-1:/opt/bitnami/postgresql/lib
done

