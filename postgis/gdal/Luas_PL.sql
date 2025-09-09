-- Luas  pl2020_id dalam hektar
WITH Luaspl AS (
  SELECT
    a.pl2020_id::text AS pl2020_id,  -- Cast ke TEXT agar bisa gabung dengan 'TOTAL'
    SUM(
      ST_Area(
        ST_Transform(a.geom, 54034)
      )
    ) / 10000 AS "LUAS_CEA_HA"
  FROM 
    datagis."PL2020_AR_250K" a
  GROUP BY 
    a.pl2020_id
),
Gabungan AS (
  SELECT * FROM Luaspl
  UNION ALL
  SELECT
    'TOTAL' AS pl2020_id,
    SUM("LUAS_CEA_HA") AS "LUAS_CEA_HA"
  FROM Luaspl
)

-- ORDER BY setelah dibungkus dalam CTE
SELECT * FROM Gabungan
ORDER BY
  CASE WHEN pl2020_id = 'TOTAL' THEN 1 ELSE 0 END,
  pl2020_id;


-- Hitung luas per pl2024_id di wilayah Bali, ditambah deskripsi dari KODE_PL
WITH Luaspl AS (
  SELECT
    a.pl2024_id::text AS pl2024_id,
    SUM(
      ST_Area(
        ST_Transform(ST_Intersection(a.geom, b.geom), 54034)
      )
    ) / 10000 AS "LUAS_CEA_HA"
  FROM 
    datagis."PL2024_AR_250K" a
  JOIN 
    datagis."ADM_KAB_KOTA" b
    ON ST_Intersects(a.geom, b.geom)
  WHERE 
    b."WADMPR" = 'Bali'
  GROUP BY 
    a.pl2024_id
),
Luaspl_dengan_ket AS (
  SELECT
    l.pl2024_id,
    k."DESKRIPSI_PL",
    l."LUAS_CEA_HA"
  FROM
    Luaspl l
  LEFT JOIN
    datagis."KODE_PL" k ON l.pl2024_id = k."KD_PL"::text
),
Gabungan AS (
  SELECT * FROM Luaspl_dengan_ket
  UNION ALL
  SELECT
    'TOTAL' AS pl2024_id,
    NULL AS "DESKRIPSI_PL",
    SUM("LUAS_CEA_HA") AS "LUAS_CEA_HA"
  FROM Luaspl_dengan_ket
)

SELECT * FROM Gabungan
ORDER BY
  CASE WHEN pl2024_id = 'TOTAL' THEN 1 ELSE 0 END,
  pl2024_id;
