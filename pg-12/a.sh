for pg_ags in ./lib/*.so; do
  docker cp $pg_ags PGSQL-12:/opt/bitnami/postgresql/lib
done

