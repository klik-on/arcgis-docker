-- Luas Fungsi Kawasan Hutan Tanpa Batas Admin
SELECT 
  c."NOURUT_KWS", 
  a."FUNGSIKWS" AS "KODEKWS", 
  c."FUNGSI_KWS", 
  SUM(
    ST_Area(
      ST_Transform(a.geom, 54034)   -- Proyeksi  ESRI CEA dengan satuan meter
    )
  ) / 10000 AS "LUAS_CEA_HA"        -- Total luas dalam hektar
FROM 
  datagis."KWSHUTAN_AR_250K" a        -- Tabel Data IGT KWS
LEFT JOIN 
  kodefikasi."KODE_KWS" c                        -- Tabel Kodefikasi KODE_KWS
    ON a."FUNGSIKWS" = c."KD_KWS"
WHERE 
  a.geom IS NOT NULL                   -- hanya geometri yang valid (tidak kosong) yang dihitung
GROUP BY 
  a."FUNGSIKWS", c."KD_KWS", c."FUNGSI_KWS", c."NOURUT_KWS"
UNION ALL
SELECT 
  NULL AS "NOURUT_KWS", 
  NULL AS "KODEKWS", 
  'Grand Total' AS "FUNGSI_KWS",   -- Mengganti kolom ini dengan Grand Total sebagai string
  SUM(
    ST_Area(
      ST_Transform(a.geom, 54034)   -- Proyeksi  ESRI CEA dengan satuan meter
    )
  ) / 10000 AS "LUAS_CEA_HA"        -- Total luas dalam hektar
FROM 
  datagis."KWSHUTAN_AR_250K" a
LEFT JOIN 
  kodefikasi."KODE_KWS" c 
    ON a."FUNGSIKWS" = c."KD_KWS"
WHERE 
  a.geom IS NOT NULL
ORDER BY 
  "NOURUT_KWS" NULLS FIRST;         -- Menempatkan Grand Total di bagian bawah
