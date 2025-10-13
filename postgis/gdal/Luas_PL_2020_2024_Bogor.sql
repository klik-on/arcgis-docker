WITH

-- Hitung luas per PL ID untuk 2020
LuasPL2020 AS (
  SELECT
    a.pl2020_id::text AS pl_id,
    adm."WADMKK",
    SUM(
      ST_Area(
        ST_Transform(ST_Intersection(a.geom, adm.geom), 54034)
      )
    ) / 10000 AS pl_2020
  FROM datagis."PL2020_AR_250K" a
  INNER JOIN datagis."ADM_KAB_KOTA" adm ON ST_Intersects(a.geom, adm.geom)
  WHERE adm."WADMKK" = 'Bogor'
  GROUP BY a.pl2020_id, adm."WADMKK"
),

LuasPL2021 AS (
  SELECT
    b.pl2021_id::text AS pl_id,
    adm."WADMKK",
    SUM(
      ST_Area(
        ST_Transform(ST_Intersection(b.geom, adm.geom), 54034)
      )
    ) / 10000 AS pl_2021
  FROM datagis."PL2021_AR_250K" b
  INNER JOIN datagis."ADM_KAB_KOTA" adm ON ST_Intersects(b.geom, adm.geom)
  WHERE adm."WADMKK" = 'Bogor'
  GROUP BY b.pl2021_id, adm."WADMKK"
),

LuasPL2022 AS (
  SELECT
    c."PL2022_ID"::text AS pl_id,
    adm."WADMKK",
    SUM(
      ST_Area(
        ST_Transform(ST_Intersection(c.geom, adm.geom), 54034)
      )
    ) / 10000 AS pl_2022
  FROM datagis."PL2022_AR_250K" c
  INNER JOIN datagis."ADM_KAB_KOTA" adm ON ST_Intersects(c.geom, adm.geom)
  WHERE adm."WADMKK" = 'Bogor'
  GROUP BY c."PL2022_ID", adm."WADMKK"
),

LuasPL2023 AS (
  SELECT
    d."PL2023_ID"::text AS pl_id,
    adm."WADMKK",
    SUM(
      ST_Area(
        ST_Transform(ST_Intersection(d.geom, adm.geom), 54034)
      )
    ) / 10000 AS pl_2023
  FROM datagis."PL2023_AR_250K" d
  INNER JOIN datagis."ADM_KAB_KOTA" adm ON ST_Intersects(d.geom, adm.geom)
  WHERE adm."WADMKK" = 'Bogor'
  GROUP BY d."PL2023_ID", adm."WADMKK"
),

LuasPL2024 AS (
  SELECT
    e."PL2024_ID"::text AS pl_id,
    adm."WADMKK",
    SUM(
      ST_Area(
        ST_Transform(ST_Intersection(e.geom, adm.geom), 54034)
      )
    ) / 10000 AS pl_2024
  FROM datagis."PL2024_AR_250K" e
  INNER JOIN datagis."ADM_KAB_KOTA" adm ON ST_Intersects(e.geom, adm.geom)
  WHERE adm."WADMKK" = 'Bogor'
  GROUP BY e."PL2024_ID", adm."WADMKK"
),

GabunganPivot AS (
  SELECT
    COALESCE(p20.pl_id, p21.pl_id, p22.pl_id, p23.pl_id, p24.pl_id) AS pl_id,
    COALESCE(p20."WADMKK", p21."WADMKK", p22."WADMKK", p23."WADMKK", p24."WADMKK") AS wadmkk,
    p20.pl_2020,
    p21.pl_2021,
    p22.pl_2022,
    p23.pl_2023,
    p24.pl_2024
  FROM LuasPL2020 p20
  FULL OUTER JOIN LuasPL2021 p21 ON p20.pl_id = p21.pl_id AND p20."WADMKK" = p21."WADMKK"
  FULL OUTER JOIN LuasPL2022 p22 ON COALESCE(p20.pl_id, p21.pl_id) = p22.pl_id AND COALESCE(p20."WADMKK", p21."WADMKK") = p22."WADMKK"
  FULL OUTER JOIN LuasPL2023 p23 ON COALESCE(p20.pl_id, p21.pl_id, p22.pl_id) = p23.pl_id AND COALESCE(p20."WADMKK", p21."WADMKK", p22."WADMKK") = p23."WADMKK"
  FULL OUTER JOIN LuasPL2024 p24 ON COALESCE(p20.pl_id, p21.pl_id, p22.pl_id, p23.pl_id) = p24.pl_id AND COALESCE(p20."WADMKK", p21."WADMKK", p22."WADMKK", p23."WADMKK") = p24."WADMKK"
),

GabunganFinal AS (
  SELECT * FROM GabunganPivot
  UNION ALL
  SELECT
    'TOTAL' AS pl_id,
    'Bogor' AS wadmkk,
    SUM(pl_2020),
    SUM(pl_2021),
    SUM(pl_2022),
    SUM(pl_2023),
    SUM(pl_2024)
  FROM GabunganPivot
)

SELECT *
FROM GabunganFinal
ORDER BY 
  CASE WHEN pl_id = 'TOTAL' THEN 1 ELSE 0 END,
  pl_id;
