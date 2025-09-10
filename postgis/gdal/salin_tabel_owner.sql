-- Buat salinan tabel dengan owner baru:
CREATE TABLE datagis."KODE_PL_copy" (LIKE datagis."KODE_PL" INCLUDING ALL);
INSERT INTO datagis."KODE_PL_copy" SELECT * FROM datagis."KODE_PL";

-- Drop tabel lama (jika sudah yakin):
DROP TABLE datagis."KODE_PL";

-- Rename salinan ke nama lama:
ALTER TABLE datagis."KODE_PL_copy" RENAME TO datagis."KODE_PL";
