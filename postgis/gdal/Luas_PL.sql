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
