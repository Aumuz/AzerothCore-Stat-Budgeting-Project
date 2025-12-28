/*============================================================================================
  Filename:       ACSBV3-02-01B.sql
  Title:          Phase 02 – Crude Curve Construction (Weighted, Equipment)
  Author:         ChatGPT
  Version:        1.0
  Created:        2025-10-23
  Description:    Builds weighted iLvl ? Budget curves using normalized budgets and encounter
                  weights.  Each curve point represents the weighted median normalized budget
                  for a given ItemLevel and Quality tier (bin size = 1).
----------------------------------------------------------------------------------------------
  Inputs:
    • ACSBV3_02_00C_budget_weighted
  Output:
    • ACSBV3_02_01B_curve_weighted
  Notes:
    • Zero/NULL budgets excluded.
    • Median determined by cumulative encounter weight (weight field).
    • No smoothing applied.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS ACSBV3_02_01B_curve_weighted;

CREATE TABLE ACSBV3_02_01B_curve_weighted AS
SELECT
    t.ItemLevel,
    t.Quality,
    AVG(t.normalized_budget) AS weighted_median_budget,
    MAX(t.total_weight)      AS total_weight,
    MAX(t.item_count)        AS item_count
FROM (
    SELECT
        ItemLevel,
        Quality,
        normalized_budget,
        weight,
        SUM(weight) OVER (
            PARTITION BY ItemLevel, Quality
            ORDER BY normalized_budget
        ) AS cum_weight,
        SUM(weight) OVER (
            PARTITION BY ItemLevel, Quality
        ) AS total_weight,
        COUNT(*) OVER (
            PARTITION BY ItemLevel, Quality
        ) AS item_count
    FROM ACSBV3_02_00C_budget_weighted
    WHERE normalized_budget > 0 AND weight > 0
) AS t
WHERE t.cum_weight >= 0.5 * t.total_weight
  AND t.cum_weight - t.weight <= 0.5 * t.total_weight
GROUP BY t.ItemLevel, t.Quality
ORDER BY t.Quality, t.ItemLevel;

-- -------------------------------------------------------------------------------------------
-- Indexes
-- -------------------------------------------------------------------------------------------
ALTER TABLE ACSBV3_02_01B_curve_weighted
  ADD INDEX idx_quality_ilvl (Quality, ItemLevel);

-- -------------------------------------------------------------------------------------------
-- Verification Queries
-- -------------------------------------------------------------------------------------------

-- Confirm curve points generated
SELECT COUNT(*) AS curve_points FROM ACSBV3_02_01B_curve_weighted;

-- Sample preview by quality tier
SELECT Quality,
       ItemLevel,
       ROUND(weighted_median_budget,2) AS weighted_median,
       ROUND(total_weight,2)           AS total_weight,
       item_count
FROM ACSBV3_02_01B_curve_weighted
WHERE Quality BETWEEN 1 AND 4
ORDER BY Quality, ItemLevel
LIMIT 20;

-- Quick range summary
SELECT Quality,
       ROUND(MIN(weighted_median_budget),2) AS min_med,
       ROUND(AVG(weighted_median_budget),2) AS avg_med,
       ROUND(MAX(weighted_median_budget),2) AS max_med
FROM ACSBV3_02_01B_curve_weighted
GROUP BY Quality
ORDER BY Quality;

/*============================================================================================
  End of File
============================================================================================*/
