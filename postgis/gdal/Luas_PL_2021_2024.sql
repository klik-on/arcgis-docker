WITH pl2021_luas AS (
  SELECT
    pl."pl2021_id" AS "PL_ID",
    ROUND(
      SUM(
        ST_Area(
          ST_Transform(pl.geom, 54034)
        )
      )::numeric / 10000, 2
    ) AS "LUAS_PL2021_HA"
  FROM datagis."PL2021_AR_250K" pl
  GROUP BY pl."pl2021_id"
),

pl2022_luas AS (
  SELECT
    pl."PL2022_ID" AS "PL_ID",
    ROUND(
      SUM(
        ST_Area(
          ST_Transform(pl.geom, 54034)
        )
      )::numeric / 10000, 2
    ) AS "LUAS_PL2022_HA"
  FROM datagis."PL2022_AR_250K" pl
  GROUP BY pl."PL2022_ID"
),

pl2023_luas AS (
  SELECT
    pl."PL2023_ID" AS "PL_ID",
    ROUND(
      SUM(
        ST_Area(
          ST_Transform(pl.geom, 54034)
        )
      )::numeric / 10000, 2
    ) AS "LUAS_PL2023_HA"
  FROM datagis."PL2023_AR_250K" pl
  GROUP BY pl."PL2023_ID"
),

pl2024_luas AS (
  SELECT
    pl."PL2024_ID" AS "PL_ID",
    ROUND(
      SUM(
        ST_Area(
          ST_Transform(pl.geom, 54034)
        )
      )::numeric / 10000, 2
    ) AS "LUAS_PL2024_HA"
  FROM datagis."PL2024_AR_250K" pl
  GROUP BY pl."PL2024_ID"
),

gabungan AS (
  SELECT
    COALESCE(k21."NOURUT_PL", k22."NOURUT_PL", k23."NOURUT_PL", k24."NOURUT_PL") AS "NOURUT_PL",
    COALESCE(k21."DESKRIPSI_PL", k22."DESKRIPSI_PL", k23."DESKRIPSI_PL", k24."DESKRIPSI_PL", 'TIDAK DIKETAHUI') AS "DESKRIPSI_PL",
    COALESCE(p21."PL_ID", p22."PL_ID", p23."PL_ID", p24."PL_ID") AS "PL_ID",
    p21."LUAS_PL2021_HA",
    p22."LUAS_PL2022_HA",
    p23."LUAS_PL2023_HA",
    p24."LUAS_PL2024_HA"
  FROM pl2021_luas p21
  FULL OUTER JOIN pl2022_luas p22
    ON p21."PL_ID" = p22."PL_ID"
  FULL OUTER JOIN pl2023_luas p23
    ON COALESCE(p21."PL_ID", p22."PL_ID") = p23."PL_ID"
  FULL OUTER JOIN pl2024_luas p24
    ON COALESCE(p21."PL_ID", p22."PL_ID", p23."PL_ID") = p24."PL_ID"

  LEFT JOIN kodefikasi."KODE_PL" k21 ON p21."PL_ID" = k21."KD_PL"
  LEFT JOIN kodefikasi."KODE_PL" k22 ON p22."PL_ID" = k22."KD_PL"
  LEFT JOIN kodefikasi."KODE_PL" k23 ON p23."PL_ID" = k23."KD_PL"
  LEFT JOIN kodefikasi."KODE_PL" k24 ON p24."PL_ID" = k24."KD_PL"
)

SELECT * FROM gabungan

UNION ALL

SELECT
  NULL AS "NOURUT_PL",
  'TOTAL SEMUA PL' AS "DESKRIPSI_PL",
  NULL AS "PL_ID",
  ROUND(SUM("LUAS_PL2021_HA")::numeric, 2) AS "LUAS_PL2021_HA",
  ROUND(SUM("LUAS_PL2022_HA")::numeric, 2) AS "LUAS_PL2022_HA",
  ROUND(SUM("LUAS_PL2023_HA")::numeric, 2) AS "LUAS_PL2023_HA",
  ROUND(SUM("LUAS_PL2024_HA")::numeric, 2) AS "LUAS_PL2024_HA"
FROM gabungan

ORDER BY "NOURUT_PL" NULLS LAST;
