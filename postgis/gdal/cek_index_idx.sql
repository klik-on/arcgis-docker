SELECT
    indexname,
    indexdef
FROM
    pg_indexes
WHERE
    schemaname = 'datagis'
    AND tablename = 'ADM_KAB_KOTA';


## CEK -- Output Index Scan using "ADM_KAB_KOTA_geom_idx" on "ADM_KAB_KOTA"  
EXPLAIN
SELECT * 
FROM datagis."ADM_KAB_KOTA"
WHERE ST_Intersects(
  geom,
  ST_GeomFromText('POLYGON((115.0 -8.5, 115.2 -8.5, 115.2 -8.3, 115.0 -8.3, 115.0 -8.5))', 4326)
);
