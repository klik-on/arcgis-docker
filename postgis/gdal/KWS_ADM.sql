-- Luas Total KWS + ADMIN
WITH LuasKawasan AS (
  SELECT
    c."NOURUT_KWS",
    a."FUNGSIKWS" AS "KODEKWS",
    b."WADMPR",
    c."FUNGSI_KWS",
    SUM(
      ST_Area(
        ST_Transform(
          ST_Intersection(a.geom, b.geom), 
          54034                       -- Proyeksi ESRI CEA dengan satuan meter
        )
      )
    ) / 10000 AS "LUAS_CEA_HA"       -- Total luas dalam hektar
  FROM 
    datagis."KWSHUTAN_AR_250K" a
  INNER JOIN 
    "datagis"."ADM_KAB_KOTA" b 
    ON ST_Intersects(a.geom, b.geom)  -- Sudah cukup tanpa && karena ST_Intersects mencakup itu
  LEFT JOIN 
    "datagis"."KODE_KWS" c 
    ON a."FUNGSIKWS" = c."KD_KWS"
  WHERE 
    ST_IsValid(a.geom) 
    AND ST_IsValid(b.geom)
    AND b."WADMPR" = 'Bali'
  GROUP BY 
    a."FUNGSIKWS",
    b."WADMPR",
    c."FUNGSI_KWS",
    c."NOURUT_KWS"
)

-- Query untuk hasil data per wilayah
SELECT 
  "NOURUT_KWS",
  "KODEKWS",
  "WADMPR",
  "FUNGSI_KWS",
  "LUAS_CEA_HA"
FROM 
  LuasKawasan

UNION ALL

-- Query untuk total luas
SELECT 
  NULL AS "NOURUT_KWS",  -- NULL untuk kolom NOURUT_KWS
  NULL AS "KODEKWS",
  NULL AS "WADMPR",
  'TOTAL LUAS' AS "FUNGSI_KWS",  -- Tulis "TOTAL LUAS" di kolom FUNGSI_KWS
  SUM("LUAS_CEA_HA") AS "LUAS_CEA_HA"
FROM 
  LuasKawasan;
