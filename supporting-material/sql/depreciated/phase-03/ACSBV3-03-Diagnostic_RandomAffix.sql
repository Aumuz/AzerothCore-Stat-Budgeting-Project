/*============================================================================================
  Filename: ACSBV3-03-Diagnostic_RandomAffix.sql
  Title:    Diagnostic – Random Property / Suffix Prevalence
  Author:   ChatGPT
  Created:  2025-10-25
  Description:
    Quantifies how many items in the unified dataset use RandomProperty or RandomSuffix.
    This helps assess whether the 1.35?0.65 correction meaningfully affects the global curves.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

-- 1) Overall counts
SELECT
  COUNT(*) AS total_items,
  SUM(CASE WHEN COALESCE(RandomProperty,0) <> 0 OR COALESCE(RandomSuffix,0) <> 0 THEN 1 ELSE 0 END) AS random_affix_items,
  ROUND(
    SUM(CASE WHEN COALESCE(RandomProperty,0) <> 0 OR COALESCE(RandomSuffix,0) <> 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2
  ) AS percent_random
FROM ACSBV3_03_00A_curve_raw;

-- 2) Breakdown by family and quality
SELECT
  item_family,
  Quality,
  COUNT(*) AS total_items,
  SUM(CASE WHEN COALESCE(RandomProperty,0) <> 0 OR COALESCE(RandomSuffix,0) <> 0 THEN 1 ELSE 0 END) AS random_affix_items,
  ROUND(
    SUM(CASE WHEN COALESCE(RandomProperty,0) <> 0 OR COALESCE(RandomSuffix,0) <> 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2
  ) AS percent_random
FROM ACSBV3_03_00A_curve_raw
GROUP BY item_family, Quality
ORDER BY item_family, Quality;

/*============================================================================================
  End of File
============================================================================================*/
