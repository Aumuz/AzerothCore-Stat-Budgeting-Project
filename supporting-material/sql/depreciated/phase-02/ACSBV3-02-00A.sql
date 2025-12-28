/*============================================================================================
Filename: ACSBV3-02-00A.sql
Title: Phase 02 – Actual Stat Budget (Equipment, Q1–Q4)
Author: ChatGPT
Version: 1.1
Created: 2025-10-23
Description: Computes Actual Stat Budget for valid equipment items from ACSBV3_ref_items.
Includes:
- stat_type / stat_value pairs 1–10
- socketBonus contribution via ACSBV3_ref_statcost_equipment (id match)
- armor contribution: (armor / 5) * cost(id = -1)
Filters:
- class = 4 (equipment only)
- Quality between 1 and 4 (exclude legendary+)
- source_type <> 'unknown'
- Exclude trinkets, relics, and non-gear InventoryTypes

Notes:
- Socket bonus ids (1597–3882) are priced directly from ACSBV3_ref_statcost_equipment.
- Negative stat values (e.g., cursed items) are clamped to zero to prevent
negative budgets.
- Resistances intentionally excluded per Phase 01 findings (negligible).
- Core item fields retained for downstream normalization (02-00B) and weighting (02-00C).
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS ACSBV3_02_00A_budget_equipment;

CREATE TABLE ACSBV3_02_00A_budget_equipment AS
SELECT
i.entry,
i.name,
i.Quality,
i.ItemLevel,
i.InventoryType,
i.drop_environment,
i.source_type,
i.weight,
i.RandomProperty,
i.RandomSuffix,

-- Armor contribution
(i.armor / 5) *
    (SELECT normalized_cost
     FROM ACSBV3_ref_statcost_equipment
     WHERE id = -1) AS armor_budget,

-- Socket bonus contribution (priced directly by socketBonus id; 0 if no match)
COALESCE(
    (SELECT normalized_cost
     FROM ACSBV3_ref_statcost_equipment
     WHERE id = i.socketBonus),
    0
) AS socket_budget,

-- Stat-based contribution (sum of all 10 pairs, negative values clamped to zero)
(
  COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type1),0)  * GREATEST(i.stat_value1,0)  +
  COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type2),0)  * GREATEST(i.stat_value2,0)  +
  COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type3),0)  * GREATEST(i.stat_value3,0)  +
  COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type4),0)  * GREATEST(i.stat_value4,0)  +
  COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type5),0)  * GREATEST(i.stat_value5,0)  +
  COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type6),0)  * GREATEST(i.stat_value6,0)  +
  COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type7),0)  * GREATEST(i.stat_value7,0)  +
  COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type8),0)  * GREATEST(i.stat_value8,0)  +
  COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type9),0)  * GREATEST(i.stat_value9,0)  +
  COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type10),0) * GREATEST(i.stat_value10,0)
) AS stat_budget,

-- Total actual stat budget (stats + armor + socket)
(
    (i.armor / 5) *
        (SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = -1)
    +
    (
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type1),0)  * GREATEST(i.stat_value1,0)  +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type2),0)  * GREATEST(i.stat_value2,0)  +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type3),0)  * GREATEST(i.stat_value3,0)  +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type4),0)  * GREATEST(i.stat_value4,0)  +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type5),0)  * GREATEST(i.stat_value5,0)  +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type6),0)  * GREATEST(i.stat_value6,0)  +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type7),0)  * GREATEST(i.stat_value7,0)  +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type8),0)  * GREATEST(i.stat_value8,0)  +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type9),0)  * GREATEST(i.stat_value9,0)  +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type10),0) * GREATEST(i.stat_value10,0)
    )
    +
    COALESCE(
        (SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.socketBonus),
        0
    )
) AS actual_stat_budget


FROM ACSBV3_ref_items AS i
WHERE
i.class = 4
AND i.Quality BETWEEN 1 AND 4
AND i.source_type <> 'unknown'
AND i.subclass NOT IN (8,11) -- Exclude trinkets, relics
AND i.InventoryType NOT IN (0,18,19,24); -- Exclude non-gear

-- Indexes (optional but helpful for downstream joins and filters)

ALTER TABLE ACSBV3_02_00A_budget_equipment
ADD INDEX idx_ilvl_quality (ItemLevel, Quality),
ADD INDEX idx_invtype (InventoryType),
ADD INDEX idx_env (drop_environment);

-- Verification Queries

-- Confirm total items processed
SELECT COUNT(*) AS total_items FROM ACSBV3_02_00A_budget_equipment;

-- Check for any remaining negatives
SELECT COUNT(*) AS negative_budgets
FROM ACSBV3_02_00A_budget_equipment
WHERE actual_stat_budget < 0;

-- Random sample for manual spot-check
SELECT entry, name, ItemLevel, Quality,
ROUND(stat_budget,2) AS stat_budget,
ROUND(armor_budget,2) AS armor_budget,
ROUND(socket_budget,2) AS socket_budget,
ROUND(actual_stat_budget,2) AS actual_stat_budget
FROM ACSBV3_02_00A_budget_equipment
ORDER BY RAND()
LIMIT 10;

-- Summary by Quality
SELECT Quality,
ROUND(MIN(actual_stat_budget),2) AS min_budget,
ROUND(AVG(actual_stat_budget),2) AS avg_budget,
ROUND(MAX(actual_stat_budget),2) AS max_budget
FROM ACSBV3_02_00A_budget_equipment
GROUP BY Quality
ORDER BY Quality;

/*============================================================================================
End of File
============================================================================================*/
