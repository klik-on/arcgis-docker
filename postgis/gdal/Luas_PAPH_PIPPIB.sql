-- Luas PAPH berdasarkan ARAHAN dalam hektar
WITH Luaspaph AS (
  SELECT
    a."ARAHAN",
    SUM(
      ST_Area(
        ST_Transform(a.geom, 54034)
      )
    ) / 10000 AS "LUAS_CEA_HA"
  FROM 
    datagis."PAPH_AR_250K" a
  GROUP BY 
    a."ARAHAN"
)

-- Tambahkan baris TOTAL dengan UNION ALL
SELECT * FROM Luaspaph

UNION ALL

SELECT
  'TOTAL' AS "ARAHAN",
  SUM("LUAS_CEA_HA") AS "LUAS_CEA_HA"
FROM Luaspaph;



-- Luas PAPH - PIPPIB dengan Total Akhir
WITH Luaspaph AS (
  SELECT
    a."ARAHAN",
    b."pippib",
    SUM(
      ST_Area(
        ST_Transform(
          ST_Intersection(a.geom, b.geom), 
          54034
        )
      )
    ) / 10000 AS "LUAS_CEA_HA"
  FROM 
    datagis."PAPH_AR_250K" a
  INNER JOIN 
    datagis."PIPPIB_AR_250K_2025_1" b 
    ON ST_Intersects(a.geom, b.geom)
  WHERE 
    b."pippib" IN ('PIPPIB GAMBUT', 'PIPPIB PRIMER')
  GROUP BY 
    a."ARAHAN",
    b."pippib"
)

-- Gabungkan hasil detail + total
SELECT * FROM Luaspaph
UNION ALL
SELECT 
  'TOTAL' AS "ARAHAN",
  NULL AS "pippib",
  SUM("LUAS_CEA_HA") AS "LUAS_CEA_HA"
FROM Luaspaph;
