-- ===============================================
-- FUNCTION: overlay_penutupan_lahan_provinsi_kawasan
-- Deskripsi: Overlay Penutupan Lahan + Kawasan + Provinsi (1 provinsi)
-- Tabel output: datagis."Luas_Penutupan_Lahan_Provinsi_Kawasan"
-- ===============================================

CREATE OR REPLACE FUNCTION datagis.overlay_penutupan_lahan_provinsi_kawasan(nama_provinsi TEXT)
RETURNS void AS
$$
BEGIN
  -- 1. Drop dan buat ulang tabel output
  DROP TABLE IF EXISTS datagis."Luas_Penutupan_Lahan_Provinsi_Kawasan";

  CREATE TABLE datagis."Luas_Penutupan_Lahan_Provinsi_Kawasan" (
    "NOURUT_PL" INT,
    "KODEPL" TEXT,
    "WADMPR" TEXT,
    "DESKRIPSI_PL" TEXT,
    "NOURUT_KWS" INT,
    "KODEKWS" TEXT,
    "FUNGSI_KWS" TEXT,
    "geom" GEOMETRY(MULTIPOLYGON, 4326),
    "LUAS_HA" NUMERIC
  );

  COMMENT ON TABLE datagis."Luas_Penutupan_Lahan_Provinsi_Kawasan" IS 
  'Hasil overlay Penutupan Lahan, Administrasi, dan Kawasan Hutan dengan luas dalam hektar';

  -- 2. Insert hasil intersection + perhitungan luas
  WITH geom_intersection AS (
    SELECT
      c."NOURUT_PL",
      a."pl2024_id" AS "KODEPL",
      b."WADMPR",
      c."DESKRIPSI_PL",
      e."NOURUT_KWS",
      d."FUNGSIKWS" AS "KODEKWS",
      e."FUNGSI_KWS",
      
      ST_Multi(
        ST_CollectionExtract(
          ST_Intersection(
            a.geom,
            ST_Intersection(b.geom, d.geom)
          ), 3
        )
      ) AS geom
    FROM 
      datagis."PL2024_AR_250K" a
    INNER JOIN 
      datagis."ADM_KAB_KOTA" b ON ST_Intersects(a.geom, b.geom)
    INNER JOIN 
      datagis."KWSHUTAN_AR_250K" d ON ST_Intersects(a.geom, d.geom)
    LEFT JOIN 
      kodefikasi."KODE_PL" c ON a."pl2024_id" = c."KD_PL"
    LEFT JOIN 
      kodefikasi."KODE_KWS" e ON d."FUNGSIKWS" = e."KD_KWS"
    WHERE 
      b."WADMPR" = nama_provinsi
      AND a.geom && b.geom
      AND a.geom && d.geom
  ),
  luas_per_provinsi AS (
    SELECT 
      "NOURUT_PL",
      "KODEPL",
      "WADMPR",
      "DESKRIPSI_PL",
      "NOURUT_KWS",
      "KODEKWS",
      "FUNGSI_KWS",
      geom,
      ST_Area(ST_Transform(geom, 54034)) / 10000 AS LUAS_HA
    FROM geom_intersection
    WHERE geom IS NOT NULL AND NOT ST_IsEmpty(geom) AND ST_IsValid(geom)
  )
  INSERT INTO datagis."Luas_Penutupan_Lahan_Provinsi_Kawasan" (
    "NOURUT_PL", 
    "KODEPL", 
    "WADMPR", 
    "DESKRIPSI_PL", 
    "NOURUT_KWS", 
    "KODEKWS", 
    "FUNGSI_KWS", 
    "geom",
    "LUAS_HA"
  )
  SELECT 
    "NOURUT_PL", 
    "KODEPL", 
    "WADMPR", 
    "DESKRIPSI_PL", 
    "NOURUT_KWS", 
    "KODEKWS", 
    "FUNGSI_KWS", 
    geom,
    LUAS_HA
  FROM luas_per_provinsi;

  -- 3. Tambahkan indeks GIST
  CREATE INDEX idx_luas_pl_prov_kws_geom 
  ON datagis."Luas_Penutupan_Lahan_Provinsi_Kawasan" USING GIST (geom);
END;
$$
LANGUAGE plpgsql;
