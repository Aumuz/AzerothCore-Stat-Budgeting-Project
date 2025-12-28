/*============================================================================================
  Filename:       ACSBV3-01-10G.sql
  Title:          Phase 01 - Diagnostic: SpellID and Randomization Multipliers
  Author:         ChatGPT + Aumuz Messick
  Version:        1.0
  Created:        2025-10-22
  Description:    Compares normalized equipment budgets for items with spell effects and
                  random properties to determine whether statistical multipliers are needed.
----------------------------------------------------------------------------------------------
  Notes:
    * Uses normalized_1 from ACSBV3_01_10E_dropmod_equipment_raw.
    * Joins ACSBV3_ref_items to bring in spellid_1-5, RandomProperty, and RandomSuffix.
    * Groups by Quality and ItemLevel bands to find consistent ratio patterns.
    * Output:
         - ACSBV3_01_10G_spell_random_diagnostic (per-quality averages and ratios)
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

-- -------------------------------------------------------------------------------------------
-- 1. Drop previous diagnostic table
-- -------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS ACSBV3_01_10G_spell_random_diagnostic;

-- -------------------------------------------------------------------------------------------
-- 2. Create working table with flags
-- -------------------------------------------------------------------------------------------
CREATE TABLE ACSBV3_01_10G_spell_random_diagnostic AS
SELECT
    r.Quality,
    ROUND(r.ItemLevel, -1) AS iLvl_band,
    COUNT(*) AS total_items,

    -- Spell flag
    SUM(
        (r.spellid_1 <> 0) OR (r.spellid_2 <> 0) OR
        (r.spellid_3 <> 0) OR (r.spellid_4 <> 0) OR
        (r.spellid_5 <> 0)
    ) AS items_with_spell,

    -- Random property flag
    SUM((r.RandomProperty <> 0) OR (r.RandomSuffix <> 0)) AS items_with_random,

    -- Average normalized_1 for items with/without spell effects
    ROUND(AVG(CASE
        WHEN (r.spellid_1 <> 0 OR r.spellid_2 <> 0 OR r.spellid_3 <> 0 OR
              r.spellid_4 <> 0 OR r.spellid_5 <> 0)
        THEN d.normalized_1 END),3) AS avg_with_spell,

    ROUND(AVG(CASE
        WHEN NOT (r.spellid_1 <> 0 OR r.spellid_2 <> 0 OR r.spellid_3 <> 0 OR
                  r.spellid_4 <> 0 OR r.spellid_5 <> 0)
        THEN d.normalized_1 END),3) AS avg_no_spell,

    -- Average normalized_1 for items with/without random properties
    ROUND(AVG(CASE
        WHEN (r.RandomProperty <> 0 OR r.RandomSuffix <> 0)
        THEN d.normalized_1 END),3) AS avg_with_random,

    ROUND(AVG(CASE
        WHEN NOT (r.RandomProperty <> 0 OR r.RandomSuffix <> 0)
        THEN d.normalized_1 END),3) AS avg_no_random

FROM ACSBV3_01_10E_dropmod_equipment_raw AS d
JOIN ACSBV3_ref_items AS r ON d.entry = r.entry
WHERE d.total_budget > 0
GROUP BY r.Quality, ROUND(r.ItemLevel, -1)
ORDER BY r.Quality, iLvl_band;

-- -------------------------------------------------------------------------------------------
-- 3. Add computed ratios for analysis
-- -------------------------------------------------------------------------------------------
ALTER TABLE ACSBV3_01_10G_spell_random_diagnostic
  ADD COLUMN spell_ratio DECIMAL(8,3),
  ADD COLUMN random_ratio DECIMAL(8,3);

UPDATE ACSBV3_01_10G_spell_random_diagnostic
SET
  spell_ratio  = ROUND((avg_with_spell / avg_no_spell) * 100,3),
  random_ratio = ROUND((avg_with_random / avg_no_random) * 100,3);

-- -------------------------------------------------------------------------------------------
-- 4. Verification Queries
-- -------------------------------------------------------------------------------------------

-- Summary overview
SELECT Quality, iLvl_band,
       items_with_spell, spell_ratio,
       items_with_random, random_ratio
FROM ACSBV3_01_10G_spell_random_diagnostic
ORDER BY Quality, iLvl_band;

-- Global averages across all bands
SELECT
  Quality,
  ROUND(AVG(spell_ratio),2) AS avg_spell_ratio,
  ROUND(STDDEV_SAMP(spell_ratio),2) AS stdev_spell_ratio,
  ROUND(AVG(random_ratio),2) AS avg_random_ratio,
  ROUND(STDDEV_SAMP(random_ratio),2) AS stdev_random_ratio
FROM ACSBV3_01_10G_spell_random_diagnostic
GROUP BY Quality
ORDER BY Quality;

/*============================================================================================
  End of File
============================================================================================*/
