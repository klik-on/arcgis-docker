-- CEK dan Perbaiki Valid GEOM
UPDATE datagis."KWSHUTAN_AR_250K"
SET geom = ST_Multi(ST_CollectionExtract(ST_MakeValid(geom), 3))  -- 3 = Polygon
WHERE NOT ST_IsValid(geom);

-- Cek Valid geometri, pastikan semua geometri valid: Data count 0
SELECT COUNT(*) FROM datagis."KWSHUTAN_AR_250K" WHERE NOT ST_IsValid(geom);

-- CEK  pastikan semua bertipe MultiPolygon
SELECT DISTINCT GeometryType(geom) FROM datagis."KWSHUTAN_AR_250K";
