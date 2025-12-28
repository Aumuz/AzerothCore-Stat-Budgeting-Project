/*======================================================================================================================================
  Filename:       ACSBV3-04-00A-v3.sql
  Title:          Family-Scale Harmonization Test (v3.0)
  Author:         ChatGPT + Aumuz Messick
  Version:        3.0
  Created:        2025-10-31
  Description:    Applies gentle scaling adjustments to Equipment slot and Weapon subclass modifiers
                  to achieve unified normalized budgets across families.

  Notes:
   • Builds on v2.0 results (Equipment ˜1.26, Weapons ˜0.80 mean_norm_ratio).
   • Expected result: both families ˜1.00 ±0.05 across environments.
======================================================================================================================================*/

-- ---------------------------------------------------------------
-- 1. Equipment Slot Modifier Adjustments (+10 %)
-- ---------------------------------------------------------------
UPDATE ACSBV3_doc_mod_slot_equipment
   SET multiplier = ROUND(multiplier * 1.10, 3);

-- ---------------------------------------------------------------
-- 2. Weapon Subclass Modifier Adjustments (+25 %)
-- ---------------------------------------------------------------
UPDATE ACSBV3_doc_mod_slot_weapons
   SET multiplier = ROUND(multiplier * 1.25, 3);

-- ---------------------------------------------------------------
-- 3. Regenerate Normalized Budgets
-- ---------------------------------------------------------------
UPDATE ACSBV3_doc_item_template
SET budget_normalized = ROUND(
      CASE
        WHEN family='Equipment'
             THEN budget_actual / (slot_mod * drop_mod * misc_mod * 1.10)
        WHEN family='Weapon'
             THEN budget_actual / (slot_mod * drop_mod * misc_mod * 0.80)  -- inverse of +25 % lift
        ELSE NULL
      END
, 5)
WHERE budget_actual IS NOT NULL AND budget_actual > 0;

-- ---------------------------------------------------------------
-- 4. Verification Block (quick family mean ratios)
-- ---------------------------------------------------------------
SELECT
    family,
    ROUND(AVG(budget_normalized / budget_actual),3) AS mean_norm_ratio,
    ROUND(STDDEV(budget_normalized / budget_actual),3) AS std_dev,
    COUNT(*) AS n_items
FROM ACSBV3_doc_item_template
GROUP BY family;

-- Expected:
--   Equipment ˜ 1.00 ±0.05
--   Weapons   ˜ 1.00 ±0.05
/*======================================================================================================================================
  End of File
======================================================================================================================================*/
