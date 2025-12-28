/*============================================================================================
  Filename:       ACSBV3-02-00C.sql
  Title:          Phase 02 – Weighted Budget Prep (Equipment, Q1–Q4)
  Author:         ChatGPT
  Version:        1.0
  Created:        2025-10-23
  Description:    Consolidates actual and normalized budgets into a single weighted dataset
                  for curve construction.  Includes encounter weights and excludes null or
                  zero-budget items.
----------------------------------------------------------------------------------------------
  Inputs:
    • ACSBV3_02_00A_budget_equipment
    • ACSBV3_02_00B_budget_normalized
  Output:
    • ACSBV3_02_00C_budget_weighted
  Notes:
    • Excludes items where actual_stat_budget <= 0 OR normalized_budget <= 0.
    • Dataset is used for both unweighted and weighted iLvl ? Budget curve studies.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS ACSBV3_02_00C_budget_weighted;

CREATE TABLE ACSBV3_02_00C_budget_weighted AS
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
    b.normalized_budget
FROM
    ACSBV3_02_00A_budget_equipment AS a
    JOIN ACSBV3_02_00B_budget_normalized AS b
      ON b.entry = a.entry
WHERE
    a.actual_stat_budget   > 0
    AND b.normalized_budget > 0;

-- -------------------------------------------------------------------------------------------
-- Indexes
-- -------------------------------------------------------------------------------------------
ALTER TABLE ACSBV3_02_00C_budget_weighted
  ADD PRIMARY KEY (entry),
  ADD INDEX idx_ilvl_quality (ItemLevel, Quality),
  ADD INDEX idx_weight (weight),
  ADD INDEX idx_env (drop_environment);

-- -------------------------------------------------------------------------------------------
-- Verification Queries
-- -------------------------------------------------------------------------------------------

-- Confirm total items included (after filtering)
SELECT COUNT(*) AS total_items FROM ACSBV3_02_00C_budget_weighted;

-- Verify expected ranges
SELECT
    ROUND(MIN(actual_stat_budget),2)    AS min_actual,
    ROUND(AVG(actual_stat_budget),2)    AS avg_actual,
    ROUND(MAX(actual_stat_budget),2)    AS max_actual,
    ROUND(MIN(normalized_budget),2)     AS min_norm,
    ROUND(AVG(normalized_budget),2)     AS avg_norm,
    ROUND(MAX(normalized_budget),2)     AS max_norm
FROM ACSBV3_02_00C_budget_weighted;

-- Random sample for sanity check
SELECT entry, name, ItemLevel, Quality,
       ROUND(actual_stat_budget,2)    AS actual_budget,
       ROUND(normalized_budget,2)     AS normalized_budget,
       ROUND(weight,4)                AS weight
FROM ACSBV3_02_00C_budget_weighted
ORDER BY RAND()
LIMIT 10;

/*============================================================================================
  End of File
============================================================================================*/
