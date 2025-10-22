-- Menyimpan Geometri dengan SRID 4326
-- Hapus tabel jika sudah ada
DROP TABLE IF EXISTS datagis.hasil_luas_pl_aceh;

-- Buat tabel hasil analisis spasial
CREATE TABLE datagis.hasil_luas_pl_aceh AS
WITH luas_per_provinsi AS (
  SELECT
    c."NOURUT_PL",
    a."PL2024_ID" AS "KODEPL",
    b."WADMPR",
    c."DESKRIPSI_PL",

    -- Luas dihitung dalam meter (SRID 54034) lalu dikonversi ke hektar
    ST_Area(
      ST_Intersection(
        ST_Transform(a.geom, 54034),
        ST_Transform(b.geom, 54034)
      )
    ) / 10000 AS "LUAS_CEA_HA",

    -- Geometri hasil intersect ditransform ke 4326 dan dipastikan menjadi MULTIPOLYGON
    ST_Multi(
      ST_Transform(
        ST_Intersection(
          ST_Transform(a.geom, 54034),
          ST_Transform(b.geom, 54034)
        ),
        4326
      )
    ) AS geom

  FROM 
    datagis."PL2024_AR_250K" a
  INNER JOIN 
    datagis."ADM_KAB_KOTA" b
      ON a.geom && b.geom AND ST_Intersects(a.geom, b.geom)
  LEFT JOIN 
    kodefikasi."KODE_PL" c
      ON a."PL2024_ID" = c."KD_PL"
  WHERE 
    b."WADMPR" = 'Aceh'
)

-- Simpan hasil ke tabel
SELECT 
  "NOURUT_PL",
  "KODEPL",
  "WADMPR",
  "DESKRIPSI_PL",
  "LUAS_CEA_HA",
  geom
FROM luas_per_provinsi;

-- Registrasi geometri ke metadata PostGIS (opsional tapi direkomendasikan)
SELECT Populate_Geometry_Columns('datagis.hasil_luas_pl_aceh'::regclass);

-- Tambah index spasial untuk performa
CREATE INDEX ON datagis.hasil_luas_pl_aceh USING GIST (geom);
