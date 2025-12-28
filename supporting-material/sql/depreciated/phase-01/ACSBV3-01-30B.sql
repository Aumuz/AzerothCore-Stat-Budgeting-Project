/*============================================================================================
  Filename:       ACSBV3-01-30B.sql
  Title:          Phase 01 – Weapon Subclass Modifiers (Unweighted)
  Author:         ChatGPT + Aumuz Messick
  Version:        1.0
  Created:        2025-10-23
  Description:    Aggregates total weapon budgets by ItemLevel, Quality, and Subclass to
                  compute subclass weighting factors.  Normalizes against a chosen baseline
                  subclass (default: 2H Axe = 100 percent).
----------------------------------------------------------------------------------------------
  Notes:
   - Input Table:
       • ACSBV3_01_30A_budget_weapons
   - Output Tables:
       • ACSBV3_01_30B_budget_subclass_averages
       • ACSBV3_01_30B_subclassmod_weapons_raw
       • ACSBV3_ref_slotmod_weapons   (final reference)
   - Baseline subclass = 0 (2H Axe).  Adjust below if a different baseline is desired.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

-- -------------------------------------------------------------------------------------------
-- 1. Drop any existing output tables
-- -------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS ACSBV3_01_30B_budget_subclass_averages;
DROP TABLE IF EXISTS ACSBV3_01_30B_subclassmod_weapons_raw;
DROP TABLE IF EXISTS ACSBV3_ref_slotmod_weapons;

-- -------------------------------------------------------------------------------------------
-- 2. Compute averages per ItemLevel, Quality, and Subclass
-- -------------------------------------------------------------------------------------------
CREATE TABLE ACSBV3_01_30B_budget_subclass_averages AS
SELECT
    ItemLevel,
    Quality,
    subclass,
    COUNT(*) AS item_count,
    ROUND(AVG(total_budget),3) AS avg_budget,
    ROUND(STDDEV_SAMP(total_budget),3) AS stdev_budget,
    ROUND(MIN(total_budget),3) AS min_budget,
    ROUND(MAX(total_budget),3) AS max_budget
FROM ACSBV3_01_30A_budget_weapons
WHERE total_budget > 0
GROUP BY ItemLevel, Quality, subclass
ORDER BY Quality, ItemLevel, subclass;

-- -------------------------------------------------------------------------------------------
-- 3. Derive subclass modifiers relative to baseline subclass (2H Axe = subclass 0)
-- -------------------------------------------------------------------------------------------
CREATE TABLE ACSBV3_01_30B_subclassmod_weapons_raw AS
SELECT
    a.Quality,
    a.subclass,
    ROUND(a.avg_budget,3) AS avg_budget,
    ROUND(b.avg_budget,3) AS base_avg_budget,
    ROUND((a.avg_budget / b.avg_budget) * 100,2) AS subclass_modifier
FROM ACSBV3_01_30B_budget_subclass_averages AS a
JOIN ACSBV3_01_30B_budget_subclass_averages AS b
  ON a.Quality = b.Quality AND b.subclass = 0        -- baseline subclass = 0 (2H Axe)
WHERE a.avg_budget > 0
ORDER BY a.Quality, a.subclass;

-- -------------------------------------------------------------------------------------------
-- 4. Create unified reference table (average across qualities)
-- -------------------------------------------------------------------------------------------
CREATE TABLE ACSBV3_ref_slotmod_weapons AS
SELECT
    subclass,
    COUNT(DISTINCT Quality) AS quality_count,
    ROUND(AVG(subclass_modifier),2) AS avg_modifier,
    ROUND(STDDEV_SAMP(subclass_modifier),2) AS stdev_modifier,
    ROUND(MIN(subclass_modifier),2) AS min_modifier,
    ROUND(MAX(subclass_modifier),2) AS max_modifier
FROM ACSBV3_01_30B_subclassmod_weapons_raw
GROUP BY subclass
ORDER BY subclass;

-- -------------------------------------------------------------------------------------------
-- 5. Verification Queries
-- -------------------------------------------------------------------------------------------

-- Confirm total subclass groups
SELECT COUNT(*) AS total_groups FROM ACSBV3_01_30B_budget_subclass_averages;

-- Sample subclass averages (first 20)
SELECT * FROM ACSBV3_01_30B_budget_subclass_averages
ORDER BY Quality, ItemLevel, subclass
LIMIT 20;

-- Check subclass modifier spread
SELECT * FROM ACSBV3_01_30B_subclassmod_weapons_raw
ORDER BY Quality, subclass
LIMIT 25;

-- Final averaged reference
SELECT * FROM ACSBV3_ref_slotmod_weapons ORDER BY subclass;

/*============================================================================================
  End of File
============================================================================================*/
