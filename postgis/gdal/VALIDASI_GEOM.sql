-- CEK dan Perbaiki Valid GEOM
UPDATE datagis."KWSHUTAN_AR_250K"
SET geom = ST_Multi(ST_CollectionExtract(ST_MakeValid(geom), 3))  -- 3 = Polygon
WHERE NOT ST_IsValid(geom);

-- Rekomendasi lebih Aman
UPDATE datagis."KWSHUTAN_AR_250K"
SET geom = ST_Multi(
              ST_CollectionExtract(
                  ST_MakeValid(geom), 3
              )
          )
WHERE geom IS NOT NULL
  AND NOT ST_IsValid(geom)
  AND GeometryType(geom) IN ('POLYGON', 'MULTIPOLYGON');


-- Cek Valid geometri, pastikan semua geometri valid: Data count 0
SELECT COUNT(*) FROM datagis."KWSHUTAN_AR_250K" WHERE NOT ST_IsValid(geom);
-- atau
SELECT COUNT(*)
FROM datagis."KWSHUTAN_AR_250K"
WHERE NOT ST_IsValid(geom)
   OR GeometryType(geom) != 'MULTIPOLYGON';


-- CEK  pastikan semua bertipe MultiPolygon
SELECT DISTINCT GeometryType(geom) FROM datagis."KWSHUTAN_AR_250K";


Verifikasi Akhir di Database GEOPANDAS
-- 1. Pastikan jumlah baris cocok
SELECT count(*) FROM datagis."MANGROVE_AR_25K_24";

-- 2. Pastikan SRID adalah 4326 (WGS84)
SELECT ST_SRID(geom), count(*) 
FROM datagis."MANGROVE_AR_25K_24" 
GROUP BY 1;

-- 3. Periksa validitas geometri (karena adanya warning tadi)
SELECT count(*) 
FROM datagis."MANGROVE_AR_25K_24" 
WHERE ST_IsValid(geom) = false;

Jika ditemukan geometri yang tidak valid (false), Anda bisa memperbaikinya langsung dengan:
UPDATE datagis."MANGROVE_AR_25K_24" 
SET geom = ST_MakeValid(geom) 
WHERE ST_IsValid(geom) = false;
