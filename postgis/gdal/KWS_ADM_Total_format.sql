WITH LuasKawasan AS (
  SELECT
    c."NOURUT_KWS" AS "ID_KAWASAN",          -- Aliasing untuk ID Kawasan
    a."FUNGSIKWS" AS "KODE_KAWASAN",         -- Aliasing untuk Kode Fungsi Kawasan
    b."WADMPR" AS "PROVINSI",                -- Aliasing untuk Kode Wilayah yang diganti menjadi "PROVINSI"
    c."FUNGSI_KWS" AS "NAMA_FUNGSI_KAWASAN", -- Aliasing untuk Nama Fungsi Kawasan
    SUM(
      ST_Area(
        ST_Transform(
          ST_Intersection(a.geom, b.geom), 
          54034                       -- Proyeksi ESRI CEA dengan satuan meter
        )
      )
    ) / 10000 AS "LUAS_CEA_HEKTAR"           -- Total luas dalam hektar
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
  "ID_KAWASAN",           -- Aliasing ID kawasan
  "KODE_KAWASAN",         -- Aliasing Kode Fungsi Kawasan
  "PROVINSI",             -- Menggunakan alias "PROVINSI" untuk WADMPR
  "NAMA_FUNGSI_KAWASAN",  -- Aliasing Nama Fungsi Kawasan
  TO_CHAR("LUAS_CEA_HEKTAR", '999,999,999.999') AS "LUAS_CEA_HEKTAR"  -- Format angka dengan pemisah ribuan
FROM 
  LuasKawasan

UNION ALL

-- Query untuk total luas
SELECT 
  NULL AS "ID_KAWASAN",           -- NULL untuk kolom ID_KAWASAN
  NULL AS "KODE_KAWASAN",         -- NULL untuk kolom KODE_KAWASAN
  NULL AS "PROVINSI",             -- NULL untuk kolom PROVINSI
  'TOTAL LUAS' AS "NAMA_FUNGSI_KAWASAN",  -- Tulis "TOTAL LUAS" di kolom Nama Fungsi Kawasan
  TO_CHAR(SUM("LUAS_CEA_HEKTAR"), '999,999,999.999') AS "LUAS_CEA_HEKTAR"  -- Format total luas dengan pemisah ribuan
FROM 
  LuasKawasan

-- Tambahkan urutan berdasarkan NOURUT_KWS, NULLS FIRST
ORDER BY 
  "ID_KAWASAN" NULLS FIRST;
