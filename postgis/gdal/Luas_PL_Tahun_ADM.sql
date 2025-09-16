WITH LuasPL2020 AS (
  SELECT
    a.pl2020_id::text AS pl_id,
    adm."WADMPR",
    SUM(ST_Area(ST_Transform(a.geom, 54034))) / 10000 AS luas_2020
  FROM 
    datagis."PL2020_AR_250K" a
  INNER JOIN datagis."ADM_KAB_KOTA" adm
    ON ST_Intersects(a.geom, adm.geom)
  WHERE adm."WADMPR" = 'Bali'
  GROUP BY 
    a.pl2020_id, adm."WADMPR"
),

LuasPL2021 AS (
  SELECT
    b.pl2021_id::text AS pl_id,
    adm."WADMPR",
    SUM(ST_Area(ST_Transform(b.geom, 54034))) / 10000 AS luas_2021
  FROM 
    datagis."PL2021_AR_250K" b
  INNER JOIN datagis."ADM_KAB_KOTA" adm
    ON ST_Intersects(b.geom, adm.geom)
  WHERE adm."WADMPR" = 'Bali'
  GROUP BY 
    b.pl2021_id, adm."WADMPR"
),

LuasPL2022 AS (
  SELECT
    c."PL2022_ID"::text AS pl_id,
    adm."WADMPR",
    SUM(ST_Area(ST_Transform(c.geom, 54034))) / 10000 AS luas_2022
  FROM 
    datagis."PL2022_AR_250K" c
  INNER JOIN datagis."ADM_KAB_KOTA" adm
    ON ST_Intersects(c.geom, adm.geom)
  WHERE adm."WADMPR" = 'Bali'
  GROUP BY 
    c."PL2022_ID", adm."WADMPR"
),

LuasPL2023 AS (
  SELECT
    d.pl2023_id::text AS pl_id,
    adm."WADMPR",
    SUM(ST_Area(ST_Transform(d.geom, 54034))) / 10000 AS luas_2023
  FROM 
    datagis."PL2023_AR_250K" d
  INNER JOIN datagis."ADM_KAB_KOTA" adm
    ON ST_Intersects(d.geom, adm.geom)
  WHERE adm."WADMPR" = 'Bali'
  GROUP BY 
    d.pl2023_id, adm."WADMPR"
),

LuasPL2024 AS (
  SELECT
    e.pl2024_id::text AS pl_id,
    adm."WADMPR",
    SUM(ST_Area(ST_Transform(e.geom, 54034))) / 10000 AS luas_2024
  FROM 
    datagis."PL2024_AR_250K" e
  INNER JOIN datagis."ADM_KAB_KOTA" adm
    ON ST_Intersects(e.geom, adm.geom)
  WHERE adm."WADMPR" = 'Bali'
  GROUP BY 
    e.pl2024_id, adm."WADMPR"
),

GabunganPivot AS (
  SELECT
    COALESCE(p20.pl_id, p21.pl_id, p22.pl_id, p23.pl_id, p24.pl_id) AS pl_id,
    COALESCE(p20."WADMPR", p21."WADMPR", p22."WADMPR", p23."WADMPR", p24."WADMPR") AS wadmpr,
    p20.luas_2020,
    p21.luas_2021,
    p22.luas_2022,
    p23.luas_2023,
    p24.luas_2024
  FROM 
    LuasPL2020 p20
  FULL OUTER JOIN LuasPL2021 p21 ON p20.pl_id = p21.pl_id AND p20."WADMPR" = p21."WADMPR"
  FULL OUTER JOIN LuasPL2022 p22 ON COALESCE(p20.pl_id, p21.pl_id) = p22.pl_id AND COALESCE(p20."WADMPR", p21."WADMPR") = p22."WADMPR"
  FULL OUTER JOIN LuasPL2023 p23 ON COALESCE(p20.pl_id, p21.pl_id, p22.pl_id) = p23.pl_id AND COALESCE(p20."WADMPR", p21."WADMPR", p22."WADMPR") = p23."WADMPR"
  FULL OUTER JOIN LuasPL2024 p24 ON COALESCE(p20.pl_id, p21.pl_id, p22.pl_id, p23.pl_id) = p24.pl_id AND COALESCE(p20."WADMPR", p21."WADMPR", p22."WADMPR", p23."WADMPR") = p24."WADMPR"
),

GabunganFinal AS (
  SELECT * FROM GabunganPivot
  UNION ALL
  SELECT
    'TOTAL' AS pl_id,
    'Bali' AS wadmpr,
    SUM(luas_2020),
    SUM(luas_2021),
    SUM(luas_2022),
    SUM(luas_2023),
    SUM(luas_2024)
  FROM GabunganPivot
)

-- Final output
SELECT *
FROM GabunganFinal
ORDER BY 
  CASE WHEN pl_id = 'TOTAL' THEN 1 ELSE 0 END,
  pl_id;
