/*============================================================================================
  Filename:       ACSBV3-00-08B.sql
  Title:          Phase 00 - Canonical Reference Enhancement (Add SpellIDs and Randomization)
  Author:         ChatGPT + Aumuz Messick
  Version:        1.0
  Created:        2025-10-22
  Description:    Adds spell effect and randomization fields to ACSBV3_ref_items. These fields
                  are required for later analysis of special effects and random property
                  multipliers in Phase 01 Sub-Phase 2.
----------------------------------------------------------------------------------------------
  Notes:
    * Fields imported from item_template:
        spellid_1, spellid_2, spellid_3, spellid_4, spellid_5
        RandomProperty, RandomSuffix
    * This script is safe to re-run; it uses IF NOT EXISTS checks.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

-- -------------------------------------------------------------------------------------------
-- 1. Add columns if they do not already exist
-- -------------------------------------------------------------------------------------------
ALTER TABLE ACSBV3_ref_items
  ADD COLUMN spellid_1 INT DEFAULT 0,
  ADD COLUMN spellid_2 INT DEFAULT 0,
  ADD COLUMN spellid_3 INT DEFAULT 0,
  ADD COLUMN spellid_4 INT DEFAULT 0,
  ADD COLUMN spellid_5 INT DEFAULT 0,
  ADD COLUMN RandomProperty INT DEFAULT 0,
  ADD COLUMN RandomSuffix INT DEFAULT 0;

-- -------------------------------------------------------------------------------------------
-- 2. Populate data from item_template
-- -------------------------------------------------------------------------------------------
UPDATE ACSBV3_ref_items AS r
JOIN item_template AS i ON r.entry = i.entry
SET
  r.spellid_1      = i.spellid_1,
  r.spellid_2      = i.spellid_2,
  r.spellid_3      = i.spellid_3,
  r.spellid_4      = i.spellid_4,
  r.spellid_5      = i.spellid_5,
  r.RandomProperty = i.RandomProperty,
  r.RandomSuffix   = i.RandomSuffix;

-- -------------------------------------------------------------------------------------------
-- 3. Verification Queries
-- -------------------------------------------------------------------------------------------

SELECT *
FROM ACSBV3_ref_items
INTO OUTFILE '/var/lib/mysql-files/ACSBV3_ref_items.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n';

-- Confirm total rows match item_template
SELECT
  (SELECT COUNT(*) FROM ACSBV3_ref_items) AS ref_rows,
  (SELECT COUNT(*) FROM item_template)    AS template_rows;

-- Check population statistics
SELECT
  COUNT(*) AS total_items,
  SUM(spellid_1 <> 0 OR spellid_2 <> 0 OR spellid_3 <> 0 OR spellid_4 <> 0 OR spellid_5 <> 0) AS has_spell,
  SUM(RandomProperty <> 0) AS has_randomprop,
  SUM(RandomSuffix <> 0)   AS has_randomsuffix
FROM ACSBV3_ref_items;

-- Sample items that contain spell or random properties
SELECT entry, name, Quality, ItemLevel,
       spellid_1, spellid_2, spellid_3, spellid_4, spellid_5,
       RandomProperty, RandomSuffix
FROM ACSBV3_ref_items
WHERE (spellid_1 + spellid_2 + spellid_3 + spellid_4 + spellid_5 +
       RandomProperty + RandomSuffix) > 0
ORDER BY ItemLevel DESC
LIMIT 20;

/*============================================================================================
  End of File
============================================================================================*/
