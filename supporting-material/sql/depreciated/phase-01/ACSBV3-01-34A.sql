/*============================================================================================
  Filename:       ACSBV3-01-34A.sql
  Title:          Phase 01 – Weapon Drop Modifiers (Environment Averages)
  Author:         ChatGPT + Aumuz Messick
  Version:        1.0
  Created:        2025-10-23
  Description:    Calculates environment-based weapon budget modifiers (World, Dungeon, Raid)
                  after subclass normalization.  Produces canonical environment reference
                  identical in structure to ACSBV3_ref_dropmod_equipment.
----------------------------------------------------------------------------------------------
  Notes:
   - Input Tables:
       • ACSBV3_01_30A_budget_weapons
       • ACSBV3_ref_slotmod_weapons
       • ACSBV3_ref_items
   - Output Tables:
       • ACSBV3_01_34A_dropmod_weapons_raw
       • ACSBV3_ref_dropmod_weapons
   - Formula:
       normalized_budget = total_budget / (subclass_modifier / 100)
   - Expected Results:
       WORLD   ˜ 100 %
       DUNGEON ˜ 75 %
       RAID    ˜ 125 %
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

-- -------------------------------------------------------------------------------------------
-- 1. Drop any existing tables
-- -------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS ACSBV3_01_34A_dropmod_weapons_raw;
DROP TABLE IF EXISTS ACSBV3_ref_dropmod_weapons;

-- -------------------------------------------------------------------------------------------
-- 2. Build environment-normalized dataset
-- -------------------------------------------------------------------------------------------
CREATE TABLE ACSBV3_01_34A_dropmod_weapons_raw AS
SELECT
    w.entry,
    w.name,
    w.Quality,
    w.ItemLevel,
    w.subclass,
    r.drop_environment,
    r.source_type,
    w.total_budget,
    s.avg_modifier AS subclass_modifier,
    ROUND(w.total_budget / (s.avg_modifier / 100),3) AS normalized_budget
FROM ACSBV3_01_30A_budget_weapons AS w
JOIN ACSBV3_ref_items AS r ON w.entry = r.entry
JOIN ACSBV3_ref_slotmod_weapons AS s ON w.subclass = s.subclass
WHERE w.total_budget > 0
  AND (r.source_type <> 'VENDOR' AND r.source_type IS NOT NULL)
  AND r.drop_environment IN ('WORLD','DUNGEON','RAID');

-- -------------------------------------------------------------------------------------------
-- 3. Compute per-environment averages
-- -------------------------------------------------------------------------------------------
CREATE TABLE ACSBV3_ref_dropmod_weapons AS
SELECT
    drop_environment,
    Quality,
    COUNT(*) AS item_count,
    ROUND(AVG(normalized_budget),3) AS avg_normalized_budget,
    ROUND(STDDEV_SAMP(normalized_budget),3) AS stdev_normalized_budget
FROM ACSBV3_01_34A_dropmod_weapons_raw
GROUP BY drop_environment, Quality
ORDER BY Quality, drop_environment;

-- -------------------------------------------------------------------------------------------
-- 4. Derive relative modifiers (World = 100%)
-- -------------------------------------------------------------------------------------------
SELECT
    e.Quality,
    e.drop_environment,
    ROUND((e.avg_normalized_budget / w.avg_normalized_budget) * 100,2) AS drop_modifier
FROM ACSBV3_ref_dropmod_weapons AS e
JOIN ACSBV3_ref_dropmod_weapons AS w
  ON e.Quality = w.Quality AND w.drop_environment = 'WORLD'
ORDER BY e.Quality, e.drop_environment;

-- -------------------------------------------------------------------------------------------
-- 5. Verification Queries
-- -------------------------------------------------------------------------------------------

-- Check total rows and distribution
SELECT drop_environment, COUNT(*) AS items
FROM ACSBV3_01_34A_dropmod_weapons_raw
GROUP BY drop_environment
ORDER BY drop_environment;

-- Show summary averages
SELECT * FROM ACSBV3_ref_dropmod_weapons ORDER BY Quality, drop_environment;

-- Optional sanity check: mean modifier across qualities
SELECT
    drop_environment,
    ROUND(AVG(avg_normalized_budget),2) AS global_avg,
    ROUND(STDDEV_SAMP(avg_normalized_budget),2) AS global_stdev
FROM ACSBV3_ref_dropmod_weapons
GROUP BY drop_environment;

/*============================================================================================
  End of File
============================================================================================*/
