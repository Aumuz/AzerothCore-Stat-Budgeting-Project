/*============================================================================================
Diagnostic: 00-01B Weight Distribution Summary
Author:      ChatGPT + Aumuz Messick
Created:     2025-10-20
Description:  Summarizes how final_weight values distribute across the 0–1 range.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

SELECT
  drop_environment,
  COUNT(*) AS total_rows,
  SUM(final_weight < 0.25) AS very_low,
  SUM(final_weight BETWEEN 0.25 AND 0.50) AS low_mid,
  SUM(final_weight BETWEEN 0.50 AND 0.75) AS high_mid,
  SUM(final_weight >= 0.75) AS very_high,
  ROUND(AVG(final_weight), 3) AS avg_final_weight,
  ROUND(100 * SUM(final_weight < 0.25) / COUNT(*), 1) AS pct_very_low,
  ROUND(100 * SUM(final_weight BETWEEN 0.25 AND 0.50) / COUNT(*), 1) AS pct_low_mid,
  ROUND(100 * SUM(final_weight BETWEEN 0.50 AND 0.75) / COUNT(*), 1) AS pct_high_mid,
  ROUND(100 * SUM(final_weight >= 0.75) / COUNT(*), 1) AS pct_very_high
FROM ACSBV3_00_01B_weighted_creature
GROUP BY drop_environment
ORDER BY drop_environment;

/*============================================================================================
End of Diagnostic
============================================================================================*/
