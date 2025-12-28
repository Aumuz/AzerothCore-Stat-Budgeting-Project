/*======================================================================================================================================
  Filename:       ACSBV3-04-00C.sql
  Title:          Populate Budget Fields and Clean Documentation Table (Canonical DPS Logic)
  Author:         ChatGPT + Aumuz Messick
  Version:        1.2
  Created:        2025-10-28
  Description:    Calculates actual and normalized budgets for all items in ACSBV3_doc_item_template.
                  Uses canonical Phase 01 rule: 1 DPS = 1 budget unit.
                  Removes invalid or unavailable entries after calculation.
----------------------------------------------------------------------------------------------------------------------------------------
  Notes:
   - Distinguishes between Equipment (class=4) and Weapons (class=2).
   - Armor contributes at 0.20 budget per armor point.
   - DPS contributes at 1.00 budget per damage-per-second.
   - Excludes zero/negative budgets and items with source_type='Unknown'.
======================================================================================================================================*/


/*======================================================================================================================================
  1. Compute and Update Actual Budgets
======================================================================================================================================*/

UPDATE ACSBV3_doc_item_template AS i
JOIN (
    SELECT
        s.entry,
        ROUND(SUM(
            CASE
                WHEN r.class = 2 AND cw.cost IS NOT NULL THEN s.val * cw.cost         -- Weapons
                WHEN r.class = 4 AND ce.cost IS NOT NULL THEN s.val * ce.cost         -- Equipment
                ELSE 0
            END
        ), 2) AS total_cost
    FROM (
        SELECT entry, stat_type1 AS stat_type, stat_value1 AS val FROM ACSBV3_doc_item_template
        UNION ALL SELECT entry, stat_type2, stat_value2 FROM ACSBV3_doc_item_template
        UNION ALL SELECT entry, stat_type3, stat_value3 FROM ACSBV3_doc_item_template
        UNION ALL SELECT entry, stat_type4, stat_value4 FROM ACSBV3_doc_item_template
        UNION ALL SELECT entry, stat_type5, stat_value5 FROM ACSBV3_doc_item_template
        UNION ALL SELECT entry, stat_type6, stat_value6 FROM ACSBV3_doc_item_template
        UNION ALL SELECT entry, stat_type7, stat_value7 FROM ACSBV3_doc_item_template
        UNION ALL SELECT entry, stat_type8, stat_value8 FROM ACSBV3_doc_item_template
        UNION ALL SELECT entry, stat_type9, stat_value9 FROM ACSBV3_doc_item_template
        UNION ALL SELECT entry, stat_type10, stat_value10 FROM ACSBV3_doc_item_template
    ) AS s
    JOIN ACSBV3_doc_item_template r ON s.entry = r.entry
    LEFT JOIN ACSBV3_doc_cost_equipment ce ON s.stat_type = ce.stat_type
    LEFT JOIN ACSBV3_doc_cost_weapons   cw ON s.stat_type = cw.stat_type
    GROUP BY s.entry
) AS calc ON i.entry = calc.entry
SET i.budget_actual = ROUND(
    calc.total_cost
    + CASE WHEN i.armor > 0 THEN i.armor * 0.20 ELSE 0 END               -- Armor contribution
    + CASE
        WHEN (i.dmg_min1 + i.dmg_max1) > 0 AND i.delay > 0 THEN
             ((i.dmg_min1 + i.dmg_max1) / 2) / (i.delay / 1000)          -- True DPS contribution (1 DPS = 1 budget)
        ELSE 0
      END
, 2);


/*======================================================================================================================================
  2. Calculate Normalized Budgets
     Diagnostic Family-Scale Patch (Inverted Constants)
======================================================================================================================================*/

-- Corrected constants (inverse of previous)
SET @equip_scale := 1.39;   -- Increase denominator ? reduce Equipment normalized budgets
SET @weap_scale  := 0.75;   -- Decrease denominator ? increase Weapon normalized budgets

UPDATE ACSBV3_doc_item_template
SET budget_normalized = ROUND(
      CASE
        WHEN family = 'Equipment'
             THEN budget_actual / (slot_mod * drop_mod * misc_mod * @equip_scale)
        WHEN family = 'Weapon'
             THEN budget_actual / (slot_mod * drop_mod * misc_mod * @weap_scale)
        ELSE NULL
      END
, 5)
WHERE budget_actual IS NOT NULL AND budget_actual > 0;


/*======================================================================================================================================
  3. Trim Dataset
======================================================================================================================================*/

-- Remove items with zero or negative budgets
DELETE FROM ACSBV3_doc_item_template
WHERE budget_actual <= 0 OR budget_normalized <= 0;

-- Remove unavailable items
DELETE FROM ACSBV3_doc_item_template
WHERE source_type = 'Unknown';


/*======================================================================================================================================
  4. Verification Queries
======================================================================================================================================*/

SELECT
  COUNT(*) AS total_items,
  SUM(CASE WHEN misc_mod < 1.00 THEN 1 ELSE 0 END) AS random_affix_items,
  ROUND(AVG(budget_actual),2) AS avg_budget_actual,
  ROUND(AVG(budget_normalized),2) AS avg_budget_normalized
FROM ACSBV3_doc_item_template;

SELECT * FROM ACSBV3_doc_item_template ORDER BY entry LIMIT 10;


/*======================================================================================================================================
  End of File
======================================================================================================================================*/
