/*======================================================================================================================================
  Filename:       ACSBV3-04-02C.sql
  Title:          Curve Fit Quality Summary View
  Author:         ChatGPT + Aumuz Messick
  Version:        1.0
  Created:        2025-10-31
  Description:    Provides a simplified developer-facing summary of mean curve-fit accuracy by quality tier.
                  Draws data from ACSBV3_04_02B_summary_normalized (Level 1 group).

  Notes:
   • Intended as a quick diagnostic / publication reference view.
   • Operates in normalized space (no modifiers applied).
   • Precision: analytical (DOUBLE).  Round to 2 decimals in final documentation.
======================================================================================================================================*/


/*======================================================================================================================================
  1. Drop and Create View
======================================================================================================================================*/

DROP VIEW IF EXISTS ACSBV3_view_curve_fit_quality;

CREATE VIEW ACSBV3_view_curve_fit_quality AS
SELECT
    s.family                                        AS family,
    s.Quality                                       AS quality_id,
    CASE s.Quality
        WHEN 0 THEN 'Poor'
        WHEN 1 THEN 'Common'
        WHEN 2 THEN 'Uncommon'
        WHEN 3 THEN 'Rare'
        WHEN 4 THEN 'Epic'
        WHEN 5 THEN 'Legendary'
        ELSE CONCAT('Q', s.Quality)
    END                                             AS quality_name,
    ROUND(AVG(s.avg_budget_percent),2)              AS mean_budget_percent,
    ROUND(AVG(s.avg_abs_percent),2)                 AS mean_abs_dev_percent,
    COUNT(DISTINCT s.ItemLevel)                     AS n_ilvl_groups
FROM ACSBV3_04_02B_summary_normalized AS s
WHERE s.group_level = 1
GROUP BY s.family, s.Quality
ORDER BY s.family, s.Quality;


/*======================================================================================================================================
  2. Verification Block
======================================================================================================================================*/

-- Quick visual check of overall curve accuracy
SELECT * FROM ACSBV3_view_curve_fit_quality;


/*======================================================================================================================================
  End of File
======================================================================================================================================*/
