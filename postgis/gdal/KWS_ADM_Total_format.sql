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
          54034
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
    AND b."WADMPR" = 'Bali'                      -- Filter untuk provinsi Bali
  GROUP BY 
    a."FUNGSIKWS",
    b."WADMPR",
    c."FUNGSI_KWS",
    c."NOURUT_KWS"
)

-- Gabungkan hasil utama dan total dengan kontrol urutan
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

-- Baris grand total
SELECT 
  NULL AS "ID_KAWASAN",           
  NULL AS "KODE_KAWASAN",         
  NULL AS "PROVINSI",             
  'TOTAL LUAS' AS "NAMA_FUNGSI_KAWASAN",  
  TO_CHAR(SUM("LUAS_CEA_HEKTAR"), '999,999,999.999') AS "LUAS_CEA_HEKTAR",
  2 AS sort_order
FROM 
  LuasKawasan

-- Urutkan berdasarkan sort_order supaya Grand Total di bawah
ORDER BY 
  sort_order, "ID_KAWASAN";
