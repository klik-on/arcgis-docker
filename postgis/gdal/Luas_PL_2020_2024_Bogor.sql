WITH

-- Luas per PL ID untuk 2020
LuasPL2020 AS (
  SELECT
    a.pl2020_id::text AS pl_id,
    adm."WADMKK",
    SUM(ST_Area(ST_Transform(ST_Intersection(a.geom, adm.geom), 54034))) / 10000 AS pl_2020
  FROM datagis."PL2020_AR_250K" a
  INNER JOIN datagis."ADM_KAB_KOTA" adm ON ST_Intersects(a.geom, adm.geom)
  WHERE adm."WADMKK" = 'Bogor'
  GROUP BY a.pl2020_id, adm."WADMKK"
),

-- Luas per PL ID untuk 2021
LuasPL2021 AS (
  SELECT
    b.pl2021_id::text AS pl_id,
    adm."WADMKK",
    SUM(ST_Area(ST_Transform(ST_Intersection(b.geom, adm.geom), 54034))) / 10000 AS pl_2021
  FROM datagis."PL2021_AR_250K" b
  INNER JOIN datagis."ADM_KAB_KOTA" adm ON ST_Intersects(b.geom, adm.geom)
  WHERE adm."WADMKK" = 'Bogor'
  GROUP BY b.pl2021_id, adm."WADMKK"
),

-- Luas per PL ID untuk 2022
LuasPL2022 AS (
  SELECT
    c."PL2022_ID"::text AS pl_id,
    adm."WADMKK",
    SUM(ST_Area(ST_Transform(ST_Intersection(c.geom, adm.geom), 54034))) / 10000 AS pl_2022
  FROM datagis."PL2022_AR_250K" c
  INNER JOIN datagis."ADM_KAB_KOTA" adm ON ST_Intersects(c.geom, adm.geom)
  WHERE adm."WADMKK" = 'Bogor'
  GROUP BY c."PL2022_ID", adm."WADMKK"
),

-- Luas per PL ID untuk 2023
LuasPL2023 AS (
  SELECT
    d."PL2023_ID"::text AS pl_id,
    adm."WADMKK",
    SUM(ST_Area(ST_Transform(ST_Intersection(d.geom, adm.geom), 54034))) / 10000 AS pl_2023
  FROM datagis."PL2023_AR_250K" d
  INNER JOIN datagis."ADM_KAB_KOTA" adm ON ST_Intersects(d.geom, adm.geom)
  WHERE adm."WADMKK" = 'Bogor'
  GROUP BY d."PL2023_ID", adm."WADMKK"
),

-- Luas per PL ID untuk 2024
LuasPL2024 AS (
  SELECT
    e."PL2024_ID"::text AS pl_id,
    adm."WADMKK",
    SUM(ST_Area(ST_Transform(ST_Intersection(e.geom, adm.geom), 54034))) / 10000 AS pl_2024
  FROM datagis."PL2024_AR_250K" e
  INNER JOIN datagis."ADM_KAB_KOTA" adm ON ST_Intersects(e.geom, adm.geom)
  WHERE adm."WADMKK" = 'Bogor'
  GROUP BY e."PL2024_ID", adm."WADMKK"
),

-- Gabungkan dan pivot
GabunganPivot AS (
  SELECT
    COALESCE(p20.pl_id, p21.pl_id, p22.pl_id, p23.pl_id, p24.pl_id) AS pl_id,
    COALESCE(k20."NOURUT_PL", k21."NOURUT_PL", k22."NOURUT_PL", k23."NOURUT_PL", k24."NOURUT_PL") AS nourut_pl,
    COALESCE(k20."DESKRIPSI_PL", k21."DESKRIPSI_PL", k22."DESKRIPSI_PL", k23."DESKRIPSI_PL", k24."DESKRIPSI_PL", 'TIDAK DIKETAHUI') AS deskripsi_pl,
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

  -- JOIN kodefikasi.KODE_PL dari masing-masing tahun
  LEFT JOIN kodefikasi."KODE_PL" k20 ON p20.pl_id = k20."KD_PL"::text
  LEFT JOIN kodefikasi."KODE_PL" k21 ON p21.pl_id = k21."KD_PL"::text
  LEFT JOIN kodefikasi."KODE_PL" k22 ON p22.pl_id = k22."KD_PL"::text
  LEFT JOIN kodefikasi."KODE_PL" k23 ON p23.pl_id = k23."KD_PL"::text
  LEFT JOIN kodefikasi."KODE_PL" k24 ON p24.pl_id = k24."KD_PL"::text
),

-- Tambahkan total
GabunganFinal AS (
  SELECT * FROM GabunganPivot
  UNION ALL
  SELECT
    'TOTAL' AS pl_id,
    NULL AS nourut_pl,
    'TOTAL SEMUA PL' AS deskripsi_pl,
    'Bogor' AS wadmkk,
    SUM(pl_2020),
    SUM(pl_2021),
    SUM(pl_2022),
    SUM(pl_2023),
    SUM(pl_2024)
  FROM GabunganPivot
)

-- Final output
SELECT *
FROM GabunganFinal
ORDER BY 
  CASE WHEN pl_id = 'TOTAL' THEN 1 ELSE 0 END,
  nourut_pl NULLS LAST;
