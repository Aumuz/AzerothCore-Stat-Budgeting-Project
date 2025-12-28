/*============================================================================================
  Filename:       ACSBV3-02-02A.sql
  Title:          Phase 02 – Validation Sample (2,000 Equipment Items)
  Author:         ChatGPT
  Version:        1.0
  Created:        2025-10-23
  Description:    Creates a reproducible, stratified random sample of 2,000 items for
                  validation testing of unweighted and weighted budget curves.
----------------------------------------------------------------------------------------------
  Inputs:
    • ACSBV3_02_00C_budget_weighted
  Output:
    • ACSBV3_02_02A_testset_equipment
  Notes:
    • Stratified by Quality and InventoryType to ensure coverage.
    • Uses RAND(42) for reproducibility.
    • Zero or NULL budgets excluded.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS ACSBV3_02_02A_testset_equipment;

CREATE TABLE ACSBV3_02_02A_testset_equipment AS
SELECT *
FROM (
    SELECT
        a.entry,
        a.name,
        a.Quality,
        a.ItemLevel,
        a.InventoryType,
        a.drop_environment,
        a.source_type,
        a.weight,
        a.actual_stat_budget,
        a.normalized_budget,
        ROW_NUMBER() OVER (
            PARTITION BY a.Quality, a.InventoryType
            ORDER BY RAND(42)
        ) AS rn
    FROM ACSBV3_02_00C_budget_weighted AS a
    WHERE a.actual_stat_budget > 0
      AND a.normalized_budget > 0
) AS sub
WHERE rn <= (
    -- Sample roughly proportional to slot count; tune as needed
    CASE
        WHEN Quality = 1 THEN 300
        WHEN Quality = 2 THEN 500
        WHEN Quality = 3 THEN 600
        WHEN Quality = 4 THEN 600
        ELSE 0
    END / 19   -- divide roughly among InventoryTypes (19 common slots)
)
LIMIT 2000;

-- -------------------------------------------------------------------------------------------
-- Indexes
-- -------------------------------------------------------------------------------------------
ALTER TABLE ACSBV3_02_02A_testset_equipment
  ADD INDEX idx_quality (Quality),
  ADD INDEX idx_ilvl (ItemLevel);

-- -------------------------------------------------------------------------------------------
-- Verification Queries
-- -------------------------------------------------------------------------------------------

-- Confirm total sample size
SELECT COUNT(*) AS total_sampled FROM ACSBV3_02_02A_testset_equipment;

-- Distribution check by Quality
SELECT Quality, COUNT(*) AS items
FROM ACSBV3_02_02A_testset_equipment
GROUP BY Quality
ORDER BY Quality;

-- Distribution check by InventoryType
SELECT InventoryType, COUNT(*) AS items
FROM ACSBV3_02_02A_testset_equipment
GROUP BY InventoryType
ORDER BY InventoryType;

-- Random preview
SELECT entry, name, ItemLevel, Quality,
       ROUND(actual_stat_budget,2)    AS actual_budget,
       ROUND(normalized_budget,2)     AS normalized_budget,
       ROUND(weight,4)                AS weight
FROM ACSBV3_02_02A_testset_equipment
ORDER BY RAND(42)
LIMIT 10;

/*============================================================================================
  End of File
============================================================================================*/
