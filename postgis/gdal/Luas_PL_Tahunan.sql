-- Hitung luas per PL ID untuk 2020
WITH LuasPL2020 AS (
  SELECT
    a.pl2020_id::text AS pl_id,
    SUM(
      ST_Area(
        ST_Transform(a.geom, 54034)
      )
    ) / 10000 AS luas_2020
  FROM 
    datagis."PL2020_AR_250K" a
  GROUP BY 
    a.pl2020_id
),

-- Hitung luas per PL ID untuk 2021
LuasPL2021 AS (
  SELECT
    b.pl2021_id::text AS pl_id,
    SUM(
      ST_Area(
        ST_Transform(b.geom, 54034)
      )
    ) / 10000 AS luas_2021
  FROM 
    datagis."PL2021_AR_250K" b
  GROUP BY 
    b.pl2021_id
),

-- Gabungkan kedua tahun berdasarkan PL ID
GabunganPivot AS (
  SELECT
    COALESCE(p20.pl_id, p21.pl_id) AS pl_id,
    p20.luas_2020,
    p21.luas_2021
  FROM 
    LuasPL2020 p20
    FULL OUTER JOIN LuasPL2021 p21 ON p20.pl_id = p21.pl_id
),

-- Tambahkan baris TOTAL
GabunganFinal AS (
  SELECT * FROM GabunganPivot
  UNION ALL
  SELECT
    'TOTAL' AS pl_id,
    SUM(luas_2020),
    SUM(luas_2021)
  FROM GabunganPivot
)

-- Final output
SELECT *
FROM GabunganFinal
ORDER BY 
  CASE WHEN pl_id = 'TOTAL' THEN 1 ELSE 0 END,
  pl_id;
