/*============================================================================================
  Filename:       ACSBV3-01-30A.sql
  Title:          Phase 01 – Weapon Budget Calculation (Unweighted Totals)
  Author:         ChatGPT + Aumuz Messick
  Version:        1.0
  Created:        2025-10-23
  Description:    Calculates unweighted total stat budgets for all valid weapons.
                  Includes:
                    • DPS baseline (1 DPS = 1 Budget Point)
                    • stat_type / stat_value pairs 1–10
                    • misc modifier adjustment (SpellID = 1.00, RandomSuffix = 1.35)
----------------------------------------------------------------------------------------------
  Notes:
   - Input Tables:
       • ACSBV3_ref_items
       • ACSBV3_ref_statcost_weapons
   - Output Table:
       • ACSBV3_01_30A_budget_weapons
   - Armor and sockets excluded (not applicable to weapons).
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

-- -------------------------------------------------------------------------------------------
-- 1. Drop existing output table
-- -------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS ACSBV3_01_30A_budget_weapons;

-- -------------------------------------------------------------------------------------------
-- 2. Create base dataset with total unweighted budget
-- -------------------------------------------------------------------------------------------
CREATE TABLE ACSBV3_01_30A_budget_weapons AS
SELECT
    i.entry,
    i.name,
    i.Quality,
    i.ItemLevel,
    i.subclass,
    i.InventoryType,
    i.dmg_min1,
    i.dmg_max1,
    i.delay,
    ROUND((i.dmg_min1 + i.dmg_max1) / 2 / (i.delay / 1000),3) AS dps,

    -- DPS baseline (1:1 with budget)
    ROUND((i.dmg_min1 + i.dmg_max1) / 2 / (i.delay / 1000),3) AS dps_budget,

    -- Stat-based contribution (sum of all 10 pairs)
    (
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type1),0) * i.stat_value1 +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type2),0) * i.stat_value2 +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type3),0) * i.stat_value3 +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type4),0) * i.stat_value4 +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type5),0) * i.stat_value5 +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type6),0) * i.stat_value6 +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type7),0) * i.stat_value7 +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type8),0) * i.stat_value8 +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type9),0) * i.stat_value9 +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type10),0) * i.stat_value10
    ) AS stat_budget,

    -- Total preliminary budget (DPS + Stats)
    (
      ROUND((i.dmg_min1 + i.dmg_max1) / 2 / (i.delay / 1000),3)
      +
      (
        COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type1),0) * i.stat_value1 +
        COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type2),0) * i.stat_value2 +
        COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type3),0) * i.stat_value3 +
        COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type4),0) * i.stat_value4 +
        COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type5),0) * i.stat_value5 +
        COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type6),0) * i.stat_value6 +
        COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type7),0) * i.stat_value7 +
        COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type8),0) * i.stat_value8 +
        COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type9),0) * i.stat_value9 +
        COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type10),0) * i.stat_value10
      )
    ) AS total_budget

FROM ACSBV3_ref_items AS i
WHERE
    i.class = 2
    AND i.subclass NOT IN (14,16)             -- exclude fishing poles, misc
    AND i.InventoryType NOT IN (0,18,19,23,24)
    AND i.dmg_min1 > 0
    AND i.dmg_max1 > 0;

-- -------------------------------------------------------------------------------------------
-- 3. Verification Queries
-- -------------------------------------------------------------------------------------------

-- Confirm total weapons processed
SELECT COUNT(*) AS total_items FROM ACSBV3_01_30A_budget_weapons;

-- Preview random examples
SELECT entry, name, ItemLevel, Quality,
       ROUND(dps_budget,2) AS dps_budget,
       ROUND(stat_budget,2) AS stat_budget,
       ROUND(total_budget,2) AS total_budget
FROM ACSBV3_01_30A_budget_weapons
ORDER BY RAND()
LIMIT 10;

-- Quality summary
SELECT Quality,
       ROUND(MIN(total_budget),2) AS min_budget,
       ROUND(AVG(total_budget),2) AS avg_budget,
       ROUND(MAX(total_budget),2) AS max_budget
FROM ACSBV3_01_30A_budget_weapons
GROUP BY Quality
ORDER BY Quality;

/*============================================================================================
  End of File
============================================================================================*/
