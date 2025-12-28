/*======================================================================================================================================
  Filename:       ACSBV3-04-02D.sql
  Title:          Outlier Diagnostics – Normalized Budget Verification
  Author:         ChatGPT + Aumuz Messick
  Version:        1.0
  Created:        2025-10-31
  Description:    Identifies and ranks items with extreme deviation from the normalized curve.
                  Used to isolate low-end or misfit entries prior to rebalancing or exclusion.

  Notes:
   • Operates on ACSBV3_04_02A_verification_normalized.
   • Uses abs_percent (absolute deviation) to identify statistical outliers.
   • Typical removal threshold: abs_percent > 100 (% deviation from curve).
   • No normalization modifiers applied (pure normalized space).
======================================================================================================================================*/


/*======================================================================================================================================
  1. Quick Global Statistics
     Purpose: Establish baseline deviation distribution for threshold selection.
======================================================================================================================================*/

-- Overall deviation metrics
SELECT
    family,
    Quality,
    ROUND(AVG(abs_percent),2) AS mean_abs_percent,
    ROUND(STDDEV(abs_percent),2) AS stddev_abs_percent,
    ROUND(MAX(abs_percent),2) AS max_abs_percent,
    COUNT(*) AS n_items
FROM ACSBV3_04_02A_verification_normalized
GROUP BY family, Quality
ORDER BY family, Quality;


/*======================================================================================================================================
  2. Outlier Identification
     Purpose: List items that deviate excessively from their curve (>100 % typical).
======================================================================================================================================*/

-- Adjustable threshold section
SET @threshold := 100.00;  -- Modify this value if needed (e.g., 75.00 or 125.00)

SELECT
    entry,
    name,
    family,
    Quality,
    ItemLevel,
    budget_normalized,
    curve_value,
    ROUND(budget_diff,3) AS budget_diff,
    ROUND(budget_percent,3) AS budget_percent,
    ROUND(abs_percent,3) AS abs_percent,
    drop_environment,
    InventoryType,
    subclass,
    random_property
FROM ACSBV3_04_02A_verification_normalized
WHERE abs_percent > @threshold
ORDER BY abs_percent DESC
LIMIT 100;


/*======================================================================================================================================
  3. Low-Level Outlier Focus
     Purpose: Zoom in on early-game Common/Uncommon items (often most erratic).
======================================================================================================================================*/

SELECT
    entry,
    name,
    family,
    Quality,
    ItemLevel,
    ROUND(budget_percent,2) AS budget_percent,
    ROUND(abs_percent,2) AS abs_percent
FROM ACSBV3_04_02A_verification_normalized
WHERE ItemLevel < 40
  AND Quality <= 2
  AND abs_percent > 50
ORDER BY abs_percent DESC
LIMIT 100;


/*======================================================================================================================================
  4. Slot & Drop Correlation Check
     Purpose: Identify if specific slots or environments dominate outliers.
======================================================================================================================================*/

-- Equipment: use InventoryType
SELECT
    'Equipment' AS family,
    Quality,
    InventoryType AS slot_id,
    NULL AS subclass_id,
    drop_environment,
    COUNT(*) AS n_outliers,
    ROUND(AVG(abs_percent),2) AS mean_abs_percent
FROM ACSBV3_04_02A_verification_normalized
WHERE abs_percent > @threshold
  AND family = 'Equipment'
GROUP BY Quality, InventoryType, drop_environment

UNION ALL

-- Weapons: use subclass
SELECT
    'Weapon' AS family,
    Quality,
    NULL AS slot_id,
    subclass AS subclass_id,
    drop_environment,
    COUNT(*) AS n_outliers,
    ROUND(AVG(abs_percent),2) AS mean_abs_percent
FROM ACSBV3_04_02A_verification_normalized
WHERE abs_percent > @threshold
  AND family = 'Weapon'
GROUP BY Quality, subclass, drop_environment

ORDER BY family, mean_abs_percent DESC;


/*======================================================================================================================================
  End of File
======================================================================================================================================*/
