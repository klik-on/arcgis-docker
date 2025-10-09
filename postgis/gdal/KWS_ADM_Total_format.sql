-- CTE untuk menghitung luas fungsi kawasan hutan berdasarkan provinsi
WITH LuasKawasan AS (
  SELECT
    c."NOURUT_KWS" AS "ID_KAWASAN",              -- ID urut fungsi kawasan
    a."FUNGSIKWS" AS "KODE_KAWASAN",             -- Kode fungsi kawasan
    b."WADMPR" AS "PROVINSI",                    -- Nama provinsi
    c."FUNGSI_KWS" AS "NAMA_FUNGSI_KAWASAN",     -- Nama fungsi kawasan
    SUM(
      ST_Area(
        ST_Transform(
          ST_Intersection(a.geom, b.geom), 
          54034									                 -- Proyeksi Cylindrical Equal Area 
        )
      )
    ) / 10000 AS "LUAS_CEA_HEKTAR"               -- Konversi ke hektar
  FROM 
    datagis."KWSHUTAN_AR_250K" a
  INNER JOIN 
    datagis."ADM_KAB_KOTA" b 
    ON ST_Intersects(a.geom, b.geom)
  LEFT JOIN 
    kodefikasi."KODE_KWS" c 
    ON a."FUNGSIKWS" = c."KD_KWS"
  WHERE 
    ST_IsValid(a.geom) 
    AND ST_IsValid(b.geom)
    AND b."WADMPR" = 'DKI Jakarta'                -- Filter untuk provinsi Dki Jakarta
  GROUP BY 
    a."FUNGSIKWS",
    b."WADMPR",
    c."FUNGSI_KWS",
    c."NOURUT_KWS"
)

-- Bungkus hasil akhir agar sort_order tidak muncul
SELECT 
  "ID_KAWASAN",
  "KODE_KAWASAN",
  "PROVINSI",
  "NAMA_FUNGSI_KAWASAN",
  "LUAS_CEA_HEKTAR"
FROM (
  -- Gabungkan hasil utama dan grand total
  SELECT 
    "ID_KAWASAN",           
    "KODE_KAWASAN",         
    "PROVINSI",             
    "NAMA_FUNGSI_KAWASAN",  
    TO_CHAR("LUAS_CEA_HEKTAR", '999,999,999.999') AS "LUAS_CEA_HEKTAR",
    1 AS sort_order
  FROM 
    LuasKawasan

  UNION ALL

  -- Grand Total
  SELECT 
    NULL AS "ID_KAWASAN",           
    NULL AS "KODE_KAWASAN",         
    NULL AS "PROVINSI",             
    'TOTAL LUAS' AS "NAMA_FUNGSI_KAWASAN",  
    TO_CHAR(SUM("LUAS_CEA_HEKTAR"), '999,999,999.999') AS "LUAS_CEA_HEKTAR",
    2 AS sort_order
  FROM 
    LuasKawasan
) AS final_result
ORDER BY 
  sort_order, "ID_KAWASAN";
