/*============================================================================================
  Filename:       ACSBV3-02-00B.sql
  Title:          Phase 02 – Normalized Stat Budget (Equipment, Q1–Q4)
  Author:         ChatGPT
  Version:        1.1
  Created:        2025-10-23
  Description:    Produces normalized budgets by reversing slot, drop, and misc modifiers.
                  Baselines:
                    • Chest = 1.00
                    • World = 1.00
                    • No RandomProperty/Suffix = 1.00
----------------------------------------------------------------------------------------------
  Inputs:
    • ACSBV3_02_00A_budget_equipment
    • ACSBV3_ref_slotmod_equipment
    • ACSBV3_ref_dropmod
    • ACSBV3_ref_miscmod
  Output:
    • ACSBV3_02_00B_budget_normalized
  Notes:
    • slot_modifier and drop_modifier are stored as percentage values (e.g., 87 = 87%).
      These must be divided by 100 when applied.
    • misc_mod (random_property_correction) is already in decimal form (e.g., 1.35)
      and is NOT divided.
    • Division by zero safely handled with NULLIF().
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS ACSBV3_02_00B_budget_normalized;

CREATE TABLE ACSBV3_02_00B_budget_normalized AS
SELECT
    a.entry,
    a.name,
    a.Quality,
    a.ItemLevel,
    a.InventoryType,
    a.drop_environment,
    a.source_type,
    a.weight,
    a.RandomProperty,
    a.RandomSuffix,
    a.actual_stat_budget,

    -- Slot modifier (InventoryType-based, convert percent ? decimal)
    COALESCE(
        (SELECT slot_modifier
         FROM ACSBV3_ref_slotmod_equipment
         WHERE InventoryType = a.InventoryType),
        100.00
    ) AS slot_mod,

    -- Drop modifier (environment-based, convert percent ? decimal)
    COALESCE(
        (SELECT drop_modifier
         FROM ACSBV3_ref_dropmod
         WHERE drop_environment = a.drop_environment),
        100.00
    ) AS drop_mod,

    -- Misc modifier (RandomProperty / RandomSuffix correction, already decimal)
    CASE
        WHEN (COALESCE(a.RandomProperty,0) <> 0 OR COALESCE(a.RandomSuffix,0) <> 0)
             THEN COALESCE(
                      (SELECT multiplier
                       FROM ACSBV3_ref_miscmod
                       WHERE modifier_name = 'random_property_correction'),
                      1.35
                  )
        ELSE 1.00
    END AS misc_mod,

    -- Normalized budget: reverse all modifiers
    a.actual_stat_budget /
        NULLIF(
            (
              (COALESCE(
                 (SELECT slot_modifier
                  FROM ACSBV3_ref_slotmod_equipment
                  WHERE InventoryType = a.InventoryType),
                 100.00
               ) / 100.0)
              *
              (COALESCE(
                 (SELECT drop_modifier
                  FROM ACSBV3_ref_dropmod
                  WHERE drop_environment = a.drop_environment),
                 100.00
               ) / 100.0)
              *
              CASE
                WHEN (COALESCE(a.RandomProperty,0) <> 0 OR COALESCE(a.RandomSuffix,0) <> 0)
                     THEN COALESCE(
                              (SELECT multiplier
                               FROM ACSBV3_ref_miscmod
                               WHERE modifier_name = 'random_property_correction'),
                              1.35
                          )
                ELSE 1.00
              END
            ),
            0
        ) AS normalized_budget

FROM ACSBV3_02_00A_budget_equipment AS a;

-- -------------------------------------------------------------------------------------------
-- Indexes
-- -------------------------------------------------------------------------------------------
ALTER TABLE ACSBV3_02_00B_budget_normalized
  ADD INDEX idx_ilvl_quality (ItemLevel, Quality),
  ADD INDEX idx_invtype (InventoryType),
  ADD INDEX idx_env (drop_environment);

-- -------------------------------------------------------------------------------------------
-- Verification Queries
-- -------------------------------------------------------------------------------------------

-- Confirm total items processed
SELECT COUNT(*) AS total_items FROM ACSBV3_02_00B_budget_normalized;

-- Check for invalid or NULL budgets
SELECT COUNT(*) AS null_budgets
FROM ACSBV3_02_00B_budget_normalized
WHERE normalized_budget IS NULL OR normalized_budget <= 0;

-- Sample preview
SELECT entry, name, ItemLevel, Quality,
       ROUND(actual_stat_budget,2) AS actual_budget,
       ROUND(slot_mod,2)  AS slot_mod_percent,
       ROUND(drop_mod,2)  AS drop_mod_percent,
       ROUND(misc_mod,2)  AS misc_mod,
       ROUND(normalized_budget,2) AS normalized_budget
FROM ACSBV3_02_00B_budget_normalized
ORDER BY RAND()
LIMIT 10;

/*============================================================================================
  End of File
============================================================================================*/
