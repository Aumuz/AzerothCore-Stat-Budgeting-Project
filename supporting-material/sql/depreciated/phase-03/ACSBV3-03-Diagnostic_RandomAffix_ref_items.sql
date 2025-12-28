/*============================================================================================
  Filename: ACSBV3-03-Diagnostic_RandomAffix_ref_items.sql
  Title:    Diagnostic – Random Property / Suffix Prevalence (Reference Dataset)
  Author:   ChatGPT
  Created:  2025-10-25
  Description:
    Estimates the proportion of items that include RandomProperty or RandomSuffix fields.
    Although ACSBV3_ref_items includes non-study items, this provides a representative
    estimate of random-affix prevalence in the overall dataset.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

-- 1) Global summary
SELECT
  COUNT(*) AS total_items,
  SUM(CASE WHEN COALESCE(RandomProperty,0) <> 0 OR COALESCE(RandomSuffix,0) <> 0 THEN 1 ELSE 0 END) AS random_affix_items,
  ROUND(
    SUM(CASE WHEN COALESCE(RandomProperty,0) <> 0 OR COALESCE(RandomSuffix,0) <> 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2
  ) AS percent_random
FROM ACSBV3_ref_items;

-- 2) Breakdown by class and quality
SELECT
  class,
  Quality,
  COUNT(*) AS total_items,
  SUM(CASE WHEN COALESCE(RandomProperty,0) <> 0 OR COALESCE(RandomSuffix,0) <> 0 THEN 1 ELSE 0 END) AS random_affix_items,
  ROUND(
    SUM(CASE WHEN COALESCE(RandomProperty,0) <> 0 OR COALESCE(RandomSuffix,0) <> 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2
  ) AS percent_random
FROM ACSBV3_ref_items
WHERE class IN (2,4)  -- weapons and equipment only
GROUP BY class, Quality
ORDER BY class, Quality;

/*============================================================================================
  End of File
============================================================================================*/
