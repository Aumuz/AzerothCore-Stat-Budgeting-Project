/*============================================================================================
  Filename:       ACSBV3-02-01A.sql
  Title:          Phase 02 – Crude Curve Construction (Unweighted, Equipment)
  Author:         ChatGPT
  Version:        1.1
  Created:        2025-10-23
  Description:    Builds unweighted iLvl ? Budget curves using normalized budgets.
                  Each curve point is the median normalized budget for a given
                  ItemLevel and Quality tier (bin size = 1).
----------------------------------------------------------------------------------------------
  Inputs:
    • ACSBV3_02_00C_budget_weighted
  Output:
    • ACSBV3_02_01A_curve_unweighted
  Notes:
    • Zero/NULL budgets excluded.
    • Median computed via ROW_NUMBER / COUNT window functions.
    • No smoothing applied.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS ACSBV3_02_01A_curve_unweighted;

CREATE TABLE ACSBV3_02_01A_curve_unweighted AS
SELECT
    t.ItemLevel,
    t.Quality,
    AVG(t.normalized_budget) AS median_budget,
    MAX(t.cnt)               AS item_count
FROM (
    SELECT
        ItemLevel,
        Quality,
        normalized_budget,
        ROW_NUMBER() OVER (
            PARTITION BY ItemLevel, Quality
            ORDER BY normalized_budget
        ) AS rn,
        COUNT(*) OVER (
            PARTITION BY ItemLevel, Quality
        ) AS cnt
    FROM ACSBV3_02_00C_budget_weighted
    WHERE normalized_budget > 0
) AS t
WHERE t.rn IN (FLOOR((t.cnt + 1)/2), CEIL((t.cnt + 1)/2))
GROUP BY t.ItemLevel, t.Quality
ORDER BY t.Quality, t.ItemLevel;

-- -------------------------------------------------------------------------------------------
-- Indexes
-- -------------------------------------------------------------------------------------------
ALTER TABLE ACSBV3_02_01A_curve_unweighted
  ADD INDEX idx_quality_ilvl (Quality, ItemLevel);

-- -------------------------------------------------------------------------------------------
-- Verification Queries
-- -------------------------------------------------------------------------------------------

-- Confirm curve points generated
SELECT COUNT(*) AS curve_points FROM ACSBV3_02_01A_curve_unweighted;

-- Sample preview by quality tier
SELECT Quality,
       ItemLevel,
       ROUND(median_budget,2) AS median_budget,
       item_count
FROM ACSBV3_02_01A_curve_unweighted
WHERE Quality BETWEEN 1 AND 4
ORDER BY Quality, ItemLevel
LIMIT 20;

-- Quick range summary
SELECT Quality,
       ROUND(MIN(median_budget),2) AS min_med,
       ROUND(AVG(median_budget),2) AS avg_med,
       ROUND(MAX(median_budget),2) AS max_med
FROM ACSBV3_02_01A_curve_unweighted
GROUP BY Quality
ORDER BY Quality;

/*============================================================================================
  End of File
============================================================================================*/
