/*======================================================================================================================================
  Filename:       ACSBV3-04-02E.sql
  Title:          Normalization Sanity Check
  Author:         ChatGPT + Aumuz Messick
  Version:        1.0
  Created:        2025-10-31
  Description:    Confirms correct application of slot, drop, and misc modifiers within normalized budgets.
======================================================================================================================================*/

-- 1. Verify mean modifiers per environment
SELECT
    drop_environment,
    ROUND(AVG(slot_mod),3) AS avg_slot_mod,
    ROUND(AVG(drop_mod),3) AS avg_drop_mod,
    ROUND(AVG(misc_mod),3) AS avg_misc_mod,
    COUNT(*) AS n_items
FROM ACSBV3_doc_item_template
GROUP BY drop_environment
ORDER BY drop_environment;

-- 2. Check normalization ratio behaviour (actual vs normalized)
SELECT
    family,
    drop_environment,
    ROUND(AVG(budget_normalized / budget_actual),3) AS norm_ratio,
    ROUND(MIN(budget_normalized / budget_actual),3) AS min_ratio,
    ROUND(MAX(budget_normalized / budget_actual),3) AS max_ratio,
    COUNT(*) AS n_items
FROM ACSBV3_doc_item_template
GROUP BY family, drop_environment
ORDER BY family, drop_environment;

-- 3. Cross-check for any items with drop_mod = 1.00 outside 'World'
SELECT entry, name, drop_environment, drop_mod
FROM ACSBV3_doc_item_template
WHERE drop_environment <> 'World'
  AND drop_mod = 1.00;
