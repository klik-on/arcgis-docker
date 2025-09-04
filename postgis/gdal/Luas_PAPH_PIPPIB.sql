-- Luas PAPH - PIPPIB
WITH Luaspaph AS (
  SELECT
    a."ARAHAN",
    b."pippib",
    SUM(
      ST_Area(
        ST_Transform(
          ST_Intersection(a.geom, b.geom), 
          54034                       -- Proyeksi ESRI CEA dengan satuan meter
        )
      )
    ) / 10000 AS "LUAS_CEA_HA"       -- Total luas dalam hektar
  FROM 
    datagis."PAPH_AR_250K" a
  INNER JOIN 
    datagis."PIPPIB_AR_250K_2025_1" b 
    ON ST_Intersects(a.geom, b.geom)
  GROUP BY 
    a."ARAHAN",
    b."pippib"
)

-- Anda bisa menambahkan SELECT berikut jika ingin melihat hasilnya
SELECT * FROM Luaspaph;
