SELECT
    indexname,
    indexdef
FROM
    pg_indexes
WHERE
    schemaname = 'datagis'
    AND tablename = 'ADM_KAB_KOTA';
