/*============================================================================================
  Filename:       ACSBV3-00-08A.sql
  Title:          Phase 00 – Canonical Reference Enhancement (Add Resistances)
  Author:         ChatGPT + Aumuz Messick
  Version:        1.0
  Created:        2025-10-21
  Description:    Permanently augments ACSBV3_ref_items with resistance fields pulled from
                  item_template.  This restores full environmental fidelity for later phases.
----------------------------------------------------------------------------------------------
  Notes:
   - Run once after Phase 00 completion (before any Phase 01 work).
   - Safe to re-run; uses ALTER TABLE IF NOT EXISTS and UPDATE JOIN.
   - Affects only ACSBV3_ref_items.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

-- -------------------------------------------------------------------------------------------
-- 1.  Add missing resistance columns if they do not already exist
-- -------------------------------------------------------------------------------------------
ALTER TABLE ACSBV3_ref_items
  ADD COLUMN holy_res   SMALLINT DEFAULT 0,
  ADD COLUMN fire_res   SMALLINT DEFAULT 0,
  ADD COLUMN nature_res SMALLINT DEFAULT 0,
  ADD COLUMN frost_res  SMALLINT DEFAULT 0,
  ADD COLUMN shadow_res SMALLINT DEFAULT 0,
  ADD COLUMN arcane_res SMALLINT DEFAULT 0;

-- -------------------------------------------------------------------------------------------
-- 2.  Populate resistance values from item_template
-- -------------------------------------------------------------------------------------------
UPDATE ACSBV3_ref_items AS r
JOIN item_template AS i ON r.entry = i.entry
SET
  r.holy_res   = i.holy_res,
  r.fire_res   = i.fire_res,
  r.nature_res = i.nature_res,
  r.frost_res  = i.frost_res,
  r.shadow_res = i.shadow_res,
  r.arcane_res = i.arcane_res;

-- -------------------------------------------------------------------------------------------
-- 3.  Verification Queries
-- -------------------------------------------------------------------------------------------

SELECT *
FROM ACSBV3_ref_items
INTO OUTFILE '/var/lib/mysql-files/ACSBV3_ref_items.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n';

-- Confirm row counts match
SELECT
  (SELECT COUNT(*) FROM ACSBV3_ref_items) AS ref_rows,
  (SELECT COUNT(*) FROM item_template)    AS item_rows;

-- Quick null / non-zero check
SELECT
  COUNT(*) AS total_items,
  SUM(holy_res   <> 0) AS has_holy,
  SUM(fire_res   <> 0) AS has_fire,
  SUM(nature_res <> 0) AS has_nature,
  SUM(frost_res  <> 0) AS has_frost,
  SUM(shadow_res <> 0) AS has_shadow,
  SUM(arcane_res <> 0) AS has_arcane
FROM ACSBV3_ref_items;

-- Spot-check high-resistance gear
SELECT entry, name, ItemLevel,
       holy_res, fire_res, nature_res, frost_res, shadow_res, arcane_res
FROM ACSBV3_ref_items
WHERE (holy_res + fire_res + nature_res + frost_res + shadow_res + arcane_res) > 0
ORDER BY ItemLevel DESC
LIMIT 20;

/*============================================================================================
  End of File
============================================================================================*/
