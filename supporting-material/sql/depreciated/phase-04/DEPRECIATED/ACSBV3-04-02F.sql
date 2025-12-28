/*======================================================================================================================================
  Filename:       ACSBV3-04-02F.sql
  Title:          ? (Delta) Comparison – Equipment vs Weapon Curve Alignment
  Author:         ChatGPT + Aumuz Messick
  Version:        1.0
  Created:        2025-10-31
  Description:    Re-evaluates cross-family deviation between Equipment and Weapon final curves.
                  Confirms whether harmonization (Phase 04) has unified both curve systems.

  Notes:
   • Operates on _final_fixed tables produced in Phase 04-01.
   • ? = |Budget_equipment - Budget_weapon| / AVG(Budget_equipment, Budget_weapon) × 100
   • Expected Result: mean ? ˜ 10 ± 3 %.
======================================================================================================================================*/


/*======================================================================================================================================
  1. Create Working Comparison Table
======================================================================================================================================*/

DROP TABLE IF EXISTS ACSBV3_04_02F_delta;

CREATE TABLE ACSBV3_04_02F_delta AS
SELECT
    e.Quality,
    e.ItemLevel,
    e.curve_value AS equip_curve,
    w.curve_value AS weap_curve,
    ROUND(ABS(e.curve_value - w.curve_value)
          / ((e.curve_value + w.curve_value) / 2) * 100, 5) AS delta_percent
FROM ACSBV3_ref_curve_equipment_final_fixed AS e
JOIN ACSBV3_ref_curve_weapons_final_fixed   AS w
  ON e.ItemLevel = w.ItemLevel
 AND e.Quality   = w.Quality
WHERE e.curve_value  IS NOT NULL
  AND w.curve_value  IS NOT NULL;


/*======================================================================================================================================
  2. Summary Statistics  (MySQL-compatible)
======================================================================================================================================*/

-- Per-Quality ? summary
SELECT
    Quality,
    ROUND(AVG(delta_percent),2)  AS mean_delta,
    ROUND(SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(delta_percent ORDER BY delta_percent), ',', FLOOR(COUNT(*)/2)+1), ',', -1),2)
        AS median_delta,
    ROUND(SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(delta_percent ORDER BY delta_percent), ',', FLOOR(COUNT(*)*0.9)+1), ',', -1),2)
        AS p90_delta,
    ROUND(MAX(delta_percent),2)  AS max_delta,
    COUNT(*) AS n_points
FROM ACSBV3_04_02F_delta
GROUP BY Quality
ORDER BY Quality;

-- Overall summary
SELECT
    ROUND(AVG(delta_percent),2) AS overall_mean_delta,
    ROUND(SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(delta_percent ORDER BY delta_percent), ',', FLOOR(COUNT(*)/2)+1), ',', -1),2)
        AS overall_median_delta,
    ROUND(SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(delta_percent ORDER BY delta_percent), ',', FLOOR(COUNT(*)*0.9)+1), ',', -1),2)
        AS overall_p90_delta,
    ROUND(MAX(delta_percent),2) AS overall_max_delta
FROM ACSBV3_04_02F_delta;


/*======================================================================================================================================
  3. Quick Visual Sanity Check (optional)
     Shows how ? changes across ItemLevel bands per Quality.
======================================================================================================================================*/
SELECT
    Quality,
    FLOOR(ItemLevel/10)*10 AS iLvl_band,
    ROUND(AVG(delta_percent),2) AS mean_delta_band,
    COUNT(*) AS n_points
FROM ACSBV3_04_02F_delta
GROUP BY Quality, iLvl_band
ORDER BY Quality, iLvl_band;

/*======================================================================================================================================
  End of File
======================================================================================================================================*/
