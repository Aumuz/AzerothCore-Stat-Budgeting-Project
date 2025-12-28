/*============================================================================================
  Filename:       ACSBV3-01-10E.sql
  Title:          Phase 01 - Equipment Drop Modifiers (Environment Averages)
  Author:         ChatGPT + Aumuz Messick
  Version:        1.0
  Created:        2025-10-22
  Description:    Calculates average normalized item budgets by drop environment
                  (World, Dungeon, Raid) excluding vendor items. Uses slot modifiers
                  from ACSBV3_ref_slotmod_equipment to remove slot bias before comparison.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

-- -------------------------------------------------------------------------------------------
-- 1. Drop existing tables
-- -------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS ACSBV3_01_10E_dropmod_equipment_raw;
DROP TABLE IF EXISTS ACSBV3_ref_dropmod_equipment;

-- -------------------------------------------------------------------------------------------
-- 2. Join environment and source data, apply slot normalization
-- -------------------------------------------------------------------------------------------
CREATE TABLE ACSBV3_01_10E_dropmod_equipment_raw AS
SELECT
    a.entry,
    a.name,
    a.Quality,
    a.ItemLevel,
    a.InventoryType,
    r.drop_environment,
    r.source_type,
    a.total_budget,
    s.slot_modifier,
    ROUND(a.total_budget / (s.slot_modifier / 100),3) AS normalized_1
FROM ACSBV3_01_10A_budget_equipment AS a
JOIN ACSBV3_ref_items AS r  ON a.entry = r.entry
JOIN ACSBV3_ref_slotmod_equipment AS s ON a.InventoryType = s.InventoryType
WHERE a.total_budget > 0
  AND (r.source_type <> 'VENDOR' AND r.source_type IS NOT NULL)
  AND r.drop_environment IN ('WORLD','DUNGEON','RAID');

-- -------------------------------------------------------------------------------------------
-- 3. Compute environment averages
-- -------------------------------------------------------------------------------------------
CREATE TABLE ACSBV3_ref_dropmod_equipment AS
SELECT
    drop_environment,
    Quality,
    COUNT(*) AS item_count,
    ROUND(AVG(normalized_1),3) AS avg_normalized_budget,
    ROUND(STDDEV_SAMP(normalized_1),3) AS stdev_normalized_budget
FROM ACSBV3_01_10E_dropmod_equipment_raw
GROUP BY drop_environment, Quality
ORDER BY Quality, drop_environment;

-- -------------------------------------------------------------------------------------------
-- 4. Compute ratios (World = 100%)
-- -------------------------------------------------------------------------------------------
-- Note: This view shows relative modifiers per quality.
SELECT
    e.Quality,
    e.drop_environment,
    ROUND((e.avg_normalized_budget / w.avg_normalized_budget) * 100,2) AS drop_modifier
FROM ACSBV3_ref_dropmod_equipment AS e
JOIN ACSBV3_ref_dropmod_equipment AS w
  ON e.Quality = w.Quality AND w.drop_environment = 'WORLD'
ORDER BY e.Quality, e.drop_environment;

-- -------------------------------------------------------------------------------------------
-- 5. Verification Queries
-- -------------------------------------------------------------------------------------------

-- Check total items and environments
SELECT drop_environment, COUNT(*) AS items
FROM ACSBV3_01_10E_dropmod_equipment_raw
GROUP BY drop_environment;

-- Summary of averages by environment
SELECT * FROM ACSBV3_ref_dropmod_equipment;

/*============================================================================================
  End of File
============================================================================================*/
