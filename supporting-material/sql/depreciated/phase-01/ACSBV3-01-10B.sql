/*============================================================================================
  Filename:       ACSBV3-01-10B.sql
  Title:          Phase 01 – Equipment Budget Slot Averages (Unweighted)
  Author:         ChatGPT + Aumuz Messick
  Version:        1.0
  Created:        2025-10-22
  Description:    Groups all valid equipment items by ItemLevel, Quality, and InventoryType
                  to produce unweighted average and variance statistics for total budgets.
----------------------------------------------------------------------------------------------
  Notes:
   - Input Table:
       • ACSBV3_01_10A_budget_equipment  (created in 01-10A)
   - Output Table:
       • ACSBV3_01_10B_budget_slot_averages
   - Items with total_budget <= 0 are ignored in calculations but remain in source data.
   - Results are used for deriving Slot Modifiers (Sub-Phase 2, Step 3).
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

-- -------------------------------------------------------------------------------------------
-- 1. Drop existing output table
-- -------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS ACSBV3_01_10B_budget_slot_averages;

-- -------------------------------------------------------------------------------------------
-- 2. Create grouped averages by ItemLevel, Quality, and InventoryType
-- -------------------------------------------------------------------------------------------
CREATE TABLE ACSBV3_01_10B_budget_slot_averages AS
SELECT
    ItemLevel,
    Quality,
    InventoryType,
    COUNT(*)                         AS item_count,
    ROUND(AVG(total_budget),3)       AS avg_budget,
    ROUND(STDDEV_SAMP(total_budget),3) AS stdev_budget,
    ROUND(MIN(total_budget),3)       AS min_budget,
    ROUND(MAX(total_budget),3)       AS max_budget
FROM ACSBV3_01_10A_budget_equipment
WHERE total_budget > 0
GROUP BY ItemLevel, Quality, InventoryType
ORDER BY Quality, ItemLevel, InventoryType;

-- -------------------------------------------------------------------------------------------
-- 3. Verification Queries
-- -------------------------------------------------------------------------------------------

-- Confirm total grouped combinations
SELECT COUNT(*) AS total_groups FROM ACSBV3_01_10B_budget_slot_averages;

-- Quick sample by quality tier
SELECT *
FROM ACSBV3_01_10B_budget_slot_averages
WHERE Quality IN (2,3,4)
ORDER BY Quality, ItemLevel, InventoryType
LIMIT 20;

-- Summary by slot (InventoryType)
SELECT InventoryType,
       ROUND(AVG(avg_budget),2) AS global_avg_budget,
       ROUND(STDDEV_SAMP(avg_budget),2) AS global_stdev_budget,
       COUNT(*) AS group_count
FROM ACSBV3_01_10B_budget_slot_averages
GROUP BY InventoryType
ORDER BY InventoryType;

/*============================================================================================
  End of File
============================================================================================*/
