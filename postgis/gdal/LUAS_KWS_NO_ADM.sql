-- Luas Fungsi Kawasan Hutan Tanpa Batas Admin
SELECT 
  c."NOURUT_KWS", 
  a."FUNGSIKWS" AS "KODEKWS", 
  c."FUNGSI_KWS", 
  SUM(
    ST_Area(
      ST_Transform(a.geom, 54034)  -- Proyeksi ESRI CEA (meter)
    )
  ) / 10000 AS "LUAS_CEA_HA"  -- Konversi ke hektar
FROM 
  datagis."KWSHUTAN_AR_250K" a
LEFT JOIN 
  kodefikasi."KODE_KWS" c
    ON a."FUNGSIKWS" = c."KD_KWS"
WHERE 
  a.geom IS NOT NULL
GROUP BY 
  c."NOURUT_KWS", a."FUNGSIKWS", c."FUNGSI_KWS"

UNION ALL

-- Grand Total
SELECT 
  NULL AS "NOURUT_KWS", 
  NULL AS "KODEKWS", 
  'Grand Total' AS "FUNGSI_KWS", 
  SUM(
    ST_Area(
      ST_Transform(a.geom, 54034)
    )
  ) / 10000 AS "LUAS_CEA_HA"
FROM 
  datagis."KWSHUTAN_AR_250K" a
WHERE 
  a.geom IS NOT NULL

ORDER BY 
  "NOURUT_KWS" NULLS LAST;
