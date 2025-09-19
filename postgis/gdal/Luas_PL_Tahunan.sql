-- Hitung luas per PL ID untuk 2020
WITH LuasPL2020 AS (
  SELECT
    a.pl2020_id::text AS pl_id,
    SUM(ST_Area(ST_Transform(a.geom, 54034))) / 10000 AS luas_2020
  FROM 
    datagis."PL2020_AR_250K" a
  GROUP BY 
    a.pl2020_id
),

-- Hitung luas per PL ID untuk 2021
LuasPL2021 AS (
  SELECT
    b.pl2021_id::text AS pl_id,
    SUM(ST_Area(ST_Transform(b.geom, 54034))) / 10000 AS luas_2021
  FROM 
    datagis."PL2021_AR_250K" b
  GROUP BY 
    b.pl2021_id
),

-- Hitung luas per PL ID untuk 2022
LuasPL2022 AS (
  SELECT
    c."PL2022_ID"::text AS pl_id,
    SUM(ST_Area(ST_Transform(c.geom, 54034))) / 10000 AS luas_2022
  FROM 
    datagis."PL2022_AR_250K" c
  GROUP BY 
    c."PL2022_ID"
),

-- Hitung luas per PL ID untuk 2023
LuasPL2023 AS (
  SELECT
    d.pl2023_id::text AS pl_id,
    SUM(ST_Area(ST_Transform(d.geom, 54034))) / 10000 AS luas_2023
  FROM 
    datagis."PL2023_AR_250K" d
  GROUP BY 
    d.pl2023_id
),

-- Hitung luas per PL ID untuk 2024
LuasPL2024 AS (
  SELECT
    e.pl2024_id::text AS pl_id,
    SUM(ST_Area(ST_Transform(e.geom, 54034))) / 10000 AS luas_2024
  FROM 
    datagis."PL2024_AR_250K" e
  GROUP BY 
    e.pl2024_id
),

-- Gabungkan hasil per tahun (pivot)
GabunganPivot AS (
  SELECT
    COALESCE(p20.pl_id, p21.pl_id, p22.pl_id, p23.pl_id, p24.pl_id) AS pl_id,
    p20.luas_2020,
    p21.luas_2021,
    p22.luas_2022,
    p23.luas_2023,
    p24.luas_2024
  FROM 
    LuasPL2020 p20
  FULL OUTER JOIN LuasPL2021 p21 ON p20.pl_id = p21.pl_id
  FULL OUTER JOIN LuasPL2022 p22 ON COALESCE(p20.pl_id, p21.pl_id) = p22.pl_id
  FULL OUTER JOIN LuasPL2023 p23 ON COALESCE(p20.pl_id, p21.pl_id, p22.pl_id) = p23.pl_id
  FULL OUTER JOIN LuasPL2024 p24 ON COALESCE(p20.pl_id, p21.pl_id, p22.pl_id, p23.pl_id) = p24.pl_id
),

-- Tambahkan baris TOTAL
GabunganFinal AS (
  SELECT * FROM GabunganPivot
  UNION ALL
  SELECT
    'TOTAL' AS pl_id,
    SUM(luas_2020),
    SUM(luas_2021),
    SUM(luas_2022),
    SUM(luas_2023),
    SUM(luas_2024)
  FROM GabunganPivot
)

-- Final output
-- Gabungkan dengan tabel kodefikasi."KODE_PL"
SELECT 
  g.pl_id,
  g.luas_2020,
  g.luas_2021,
  g.luas_2022,
  g.luas_2023,
  g.luas_2024,
  k."KD_PL",  -- Contoh kolom dari tabel KODE_PL, ganti sesuai kebutuhan
  k."DESKRIPSI_PL"      -- Misal kamu ingin menambahkan kolom deskripsi atau lainnya
FROM 
  GabunganFinal g
LEFT JOIN 
  kodefikasi."KODE_PL" k 
  ON g.pl_id = k."KD_PL"::text
ORDER BY 
  CASE WHEN g.pl_id = 'TOTAL' THEN 1 ELSE 0 END,
  g.pl_id
