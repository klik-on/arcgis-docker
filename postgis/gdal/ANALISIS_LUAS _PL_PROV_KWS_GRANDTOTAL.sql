-- ANALISA LUAS PENUTUPAN LAHAN PER PROVINSI & FUNGSI KAWASAN + GRAND TOTAL
WITH luas_per_provinsi AS (
  SELECT
    c."NOURUT_PL",                         
    a."pl2024_id" AS "KODEPL",             
    b."WADMPR",                             
    c."DESKRIPSI_PL",                       
    e."NOURUT_KWS",
    d."FUNGSIKWS" AS "KODEKWS",
    e."FUNGSI_KWS",
    SUM(
      ST_Area(
        ST_Intersection(
          ST_Transform(ST_MakeValid(a.geom), 54034),  -- PL2024
          ST_Intersection(
            ST_Transform(ST_MakeValid(b.geom), 54034),  -- Provinsi/Kabupaten
            ST_Transform(ST_MakeValid(d.geom), 54034)   -- Fungsi Kawasan
          )
        )
      )
    ) / 10000 AS "LUAS_CEA_HA"              
  FROM 
    datagis."PL2024_AR_250K" a
  INNER JOIN 
    datagis."ADM_KAB_KOTA" b
      ON ST_Intersects(a.geom, b.geom)
  INNER JOIN 
    datagis."KWSHUTAN_AR_250K" d
      ON ST_Intersects(a.geom, d.geom) 
  LEFT JOIN 
    kodefikasi."KODE_PL" c
      ON a."pl2024_id" = c."KD_PL"
  LEFT JOIN 
    kodefikasi."KODE_KWS" e               
      ON d."FUNGSIKWS" = e."KD_KWS"
  WHERE 
    b."WADMPR" = 'DKI Jakarta'             
  GROUP BY 
    a."pl2024_id",
    b."WADMPR",
    c."DESKRIPSI_PL",
    c."NOURUT_PL",
    e."NOURUT_KWS",
    d."FUNGSIKWS",
    e."FUNGSI_KWS"
)
SELECT 
  "NOURUT_PL",           
  "KODEPL",         
  "WADMPR",             
  "DESKRIPSI_PL",  
  "NOURUT_KWS",  
  "KODEKWS",  
  "FUNGSI_KWS", 
  TO_CHAR("LUAS_CEA_HA", '999,999,999.999') AS "LUAS_CEA_HA",
  1 AS "sort_order"
FROM 
  luas_per_provinsi

UNION ALL

SELECT 
  NULL AS "NOURUT_PL",           
  NULL AS "KODEPL",         
  'GRAND TOTAL' AS "WADMPR",  
  NULL AS "DESKRIPSI_PL",
  NULL AS "NOURUT_KWS",
  NULL AS "KODEKWS",
  NULL AS "FUNGSI_KWS",
  TO_CHAR(SUM("LUAS_CEA_HA"), '999,999,999.999') AS "LUAS_CEA_HA",
  2 AS "sort_order"
FROM 
  luas_per_provinsi

-- Urutkan berdasarkan sort_order supaya Grand Total di bawah
ORDER BY 
  "sort_order", "NOURUT_PL" NULLS LAST, "NOURUT_KWS" NULLS LAST;

