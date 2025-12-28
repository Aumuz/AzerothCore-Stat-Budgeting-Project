/*============================================================================================
  Filename:       ACSBV3-01-10C.sql
  Title:          Phase 01 – Equipment Slot Modifiers (Unweighted, Per Quality)
  Author:         ChatGPT + Aumuz Messick
  Version:        1.0
  Created:        2025-10-22
  Description:    Calculates slot modifiers by quality tier using chest (InventoryType=5)
                  as the 100% baseline.  Produces per-quality slot tables and a combined
                  summary for cross-quality comparison.
----------------------------------------------------------------------------------------------
  Notes:
   - Input Table:  ACSBV3_01_10B_budget_slot_averages
   - Output Tables:
         • ACSBV3_01_10C_slotmod_equipment_raw
         • ACSBV3_01_10C_slotmod_equipment_summary
   - Formula:
         slot_modifier = (avg_budget / chest_avg_budget) * 100
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

-- -------------------------------------------------------------------------------------------
-- 1. Drop previous output tables
-- -------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS ACSBV3_01_10C_slotmod_equipment_raw;
DROP TABLE IF EXISTS ACSBV3_01_10C_slotmod_equipment_summary;

-- -------------------------------------------------------------------------------------------
-- 2. Build per-quality slot modifiers
-- -------------------------------------------------------------------------------------------
CREATE TABLE ACSBV3_01_10C_slotmod_equipment_raw AS
SELECT
    a.Quality,
    a.InventoryType,
    ROUND(a.avg_budget,3) AS avg_budget,
    ROUND(c.avg_budget,3) AS chest_avg_budget,
    ROUND((a.avg_budget / c.avg_budget) * 100,2) AS slot_modifier
FROM ACSBV3_01_10B_budget_slot_averages AS a
JOIN ACSBV3_01_10B_budget_slot_averages AS c
  ON a.Quality = c.Quality AND c.InventoryType = 5   -- chest baseline
WHERE a.avg_budget > 0
ORDER BY a.Quality, a.InventoryType;

-- -------------------------------------------------------------------------------------------
-- 3. Create summary table averaging across qualities
-- -------------------------------------------------------------------------------------------
CREATE TABLE ACSBV3_01_10C_slotmod_equipment_summary AS
SELECT
    InventoryType,
    COUNT(DISTINCT Quality) AS quality_count,
    ROUND(AVG(slot_modifier),2) AS avg_modifier,
    ROUND(STDDEV_SAMP(slot_modifier),2) AS stdev_modifier,
    ROUND(MIN(slot_modifier),2) AS min_modifier,
    ROUND(MAX(slot_modifier),2) AS max_modifier
FROM ACSBV3_01_10C_slotmod_equipment_raw
GROUP BY InventoryType
ORDER BY InventoryType;

-- -------------------------------------------------------------------------------------------
-- 4. Verification Queries
-- -------------------------------------------------------------------------------------------

-- Check number of per-quality slot entries
SELECT COUNT(*) AS total_rows FROM ACSBV3_01_10C_slotmod_equipment_raw;

-- Sample output by Quality
SELECT *
FROM ACSBV3_01_10C_slotmod_equipment_raw
ORDER BY Quality, InventoryType
LIMIT 25;

-- Cross-quality summary (variance per slot)
SELECT *
FROM ACSBV3_01_10C_slotmod_equipment_summary
ORDER BY InventoryType;

/*============================================================================================
  End of File
============================================================================================*/
