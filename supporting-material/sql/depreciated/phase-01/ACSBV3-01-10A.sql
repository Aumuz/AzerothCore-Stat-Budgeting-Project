/*============================================================================================
  Filename:       ACSBV3-01-10A.sql
  Title:          Phase 01 – Equipment Budget Calculation (Unweighted Totals, v3)
  Author:         ChatGPT + Aumuz Messick
  Version:        1.2
  Created:        2025-10-22
  Description:    Calculates unweighted total stat budgets for all valid equipment items.
                  Includes:
                    • stat_type / stat_value pairs 1–10
                    • socketBonus contribution (via ACSBV3_ref_statcost_equipment)
                    • armor contribution: (armor / 5) × cost(-1)
----------------------------------------------------------------------------------------------
  Notes:
   - Input:
       • ACSBV3_ref_items
       • ACSBV3_ref_statcost_equipment
   - Output:
       • ACSBV3_01_10A_budget_equipment
   - All weights are empirical and unsmoothed.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS ACSBV3_01_10A_budget_equipment;

CREATE TABLE ACSBV3_01_10A_budget_equipment AS
SELECT
    i.entry,
    i.name,
    i.Quality,
    i.ItemLevel,
    i.InventoryType,

    -- Armor contribution
    (i.armor / 5) *
        (SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = -1) AS armor_budget,

    -- Socket bonus contribution
    COALESCE(
        (SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.socketBonus),
        0
    ) AS socket_budget,

    -- Stat-based contribution (sum of all 10 pairs)
    (
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type1),0) * i.stat_value1 +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type2),0) * i.stat_value2 +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type3),0) * i.stat_value3 +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type4),0) * i.stat_value4 +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type5),0) * i.stat_value5 +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type6),0) * i.stat_value6 +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type7),0) * i.stat_value7 +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type8),0) * i.stat_value8 +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type9),0) * i.stat_value9 +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type10),0) * i.stat_value10
    ) AS stat_budget,

    -- Total combined budget (stats + armor + socket)
    (
        (i.armor / 5) *
            (SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = -1)
        +
        (
          COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type1),0) * i.stat_value1 +
          COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type2),0) * i.stat_value2 +
          COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type3),0) * i.stat_value3 +
          COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type4),0) * i.stat_value4 +
          COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type5),0) * i.stat_value5 +
          COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type6),0) * i.stat_value6 +
          COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type7),0) * i.stat_value7 +
          COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type8),0) * i.stat_value8 +
          COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type9),0) * i.stat_value9 +
          COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type10),0) * i.stat_value10
        )
        +
        COALESCE(
            (SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.socketBonus),
            0
        )
    ) AS total_budget

FROM ACSBV3_ref_items AS i
WHERE
    i.class = 4
    AND i.subclass NOT IN (8,11)             -- Exclude trinkets, relics
    AND i.InventoryType NOT IN (0,18,19,24); -- Exclude non-gear

-- -------------------------------------------------------------------------------------------
-- Verification Queries
-- -------------------------------------------------------------------------------------------

-- Confirm total items processed
SELECT COUNT(*) AS total_items FROM ACSBV3_01_10A_budget_equipment;

-- Preview structure and random examples
SELECT entry, name, ItemLevel, Quality,
       ROUND(stat_budget,2) AS stat_budget,
       ROUND(armor_budget,2) AS armor_budget,
       ROUND(socket_budget,2) AS socket_budget,
       ROUND(total_budget,2) AS total_budget
FROM ACSBV3_01_10A_budget_equipment
ORDER BY RAND()
LIMIT 10;

-- Quality summary
SELECT Quality,
       ROUND(MIN(total_budget),2) AS min_budget,
       ROUND(AVG(total_budget),2) AS avg_budget,
       ROUND(MAX(total_budget),2) AS max_budget
FROM ACSBV3_01_10A_budget_equipment
GROUP BY Quality
ORDER BY Quality;

/*============================================================================================
  End of File
============================================================================================*/
