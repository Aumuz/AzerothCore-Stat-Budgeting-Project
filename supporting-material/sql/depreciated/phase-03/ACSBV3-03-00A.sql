/*============================================================================================
  Filename:       ACSBV3-03-00A.sql
  Title:          Phase 03 – Unified Actual and Normalized Budgets (Equipment + Weapons)
  Author:         ChatGPT
  Version:        1.0
  Created:        2025-10-24
  Description:
    Reconstructs actual_budget and normalized_budget for equipment (class=4) and weapons
    (class=2) from the canonical dataset ACSBV3_ref_items. Outputs a single combined table
    for downstream smoothing and cross-family comparison.

    Key rules:
      - actual_budget (equipment) = armor_budget + socket_budget + sum(stat_value * cost)
      - actual_budget (weapons)  = DPS + sum(stat_value * cost)  (DPS is 1:1 with cost id = -1)
      - normalized_budget = actual_budget / (slot_mod * drop_mod * misc_mod)
        * slot_mod: equipment by InventoryType, weapons by subclass
        * drop_mod: by drop_environment
        * misc_mod: 1.35 if RandomProperty or RandomSuffix present, else 1.00
      - Mixed percent formats are auto-corrected:
          CASE WHEN value > 10 THEN value/100.0 ELSE value END
      - Resistances excluded, negative stat values clamped to zero.

  Inputs:
    - ACSBV3_ref_items
    - ACSBV3_ref_statcost_equipment
    - ACSBV3_ref_statcost_weapons
    - ACSBV3_ref_slotmod_equipment    (slot_modifier as percent or decimal)
    - ACSBV3_ref_slotmod_weapons      (avg_modifier as percent or decimal)
    - ACSBV3_ref_dropmod              (drop_modifier as percent or decimal)
    - ACSBV3_ref_miscmod              (multiplier decimal; random_property_correction)

  Output:
    - ACSBV3_03_00A_curve_raw

  Filters:
    - Quality between 1 and 4
    - source_type <> 'unknown'
    - class in (2,4)
    - Equipment excludes trinkets and relics; excludes non-gear InventoryTypes as in Phase 02.

  Notes:
    - DPS uses physical damage only and the first damage pair:
        DPS = ((dmg_min1 + dmg_max1) / 2) / (delay / 1000)
    - If ACSBV3_ref_statcost_weapons has id = -1 != 1.0, it will scale DPS accordingly.
      Default fallback is 1.0 if missing.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS ACSBV3_03_00A_curve_raw;

CREATE TABLE ACSBV3_03_00A_curve_raw AS

-- ==========================================================================================
-- Equipment branch (class = 4)
-- ==========================================================================================
SELECT
  i.entry,
  i.name,
  i.class,
  i.subclass,
  i.InventoryType,
  i.Quality,
  i.ItemLevel,
  'equipment' AS item_family,

  /* Actual budget: armor + socket + summed stats (negatives clamped to zero) */
  (
    /* Armor */
    (i.armor / 5.0) *
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = -1), 0.0)

    +
    /* Stat pairs */
    (
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type1), 0.0)  * GREATEST(i.stat_value1, 0)  +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type2), 0.0)  * GREATEST(i.stat_value2, 0)  +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type3), 0.0)  * GREATEST(i.stat_value3, 0)  +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type4), 0.0)  * GREATEST(i.stat_value4, 0)  +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type5), 0.0)  * GREATEST(i.stat_value5, 0)  +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type6), 0.0)  * GREATEST(i.stat_value6, 0)  +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type7), 0.0)  * GREATEST(i.stat_value7, 0)  +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type8), 0.0)  * GREATEST(i.stat_value8, 0)  +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type9), 0.0)  * GREATEST(i.stat_value9, 0)  +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type10), 0.0) * GREATEST(i.stat_value10, 0)
    )

    +
    /* Socket bonus valued directly by its id (0 if none/unknown) */
    COALESCE((SELECT normalized_cost
              FROM ACSBV3_ref_statcost_equipment
              WHERE id = i.socketBonus), 0.0)
  ) AS actual_budget,

  /* Normalized budget: reverse slot, drop, misc modifiers */
  (
    (
      /* Armor + stats + socket (repeat expression to avoid subselect aliasing limits in MySQL CREATE TABLE AS) */
      (i.armor / 5.0) *
        COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = -1), 0.0)
      +
      (
        COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type1), 0.0)  * GREATEST(i.stat_value1, 0)  +
        COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type2), 0.0)  * GREATEST(i.stat_value2, 0)  +
        COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type3), 0.0)  * GREATEST(i.stat_value3, 0)  +
        COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type4), 0.0)  * GREATEST(i.stat_value4, 0)  +
        COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type5), 0.0)  * GREATEST(i.stat_value5, 0)  +
        COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type6), 0.0)  * GREATEST(i.stat_value6, 0)  +
        COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type7), 0.0)  * GREATEST(i.stat_value7, 0)  +
        COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type8), 0.0)  * GREATEST(i.stat_value8, 0)  +
        COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type9), 0.0)  * GREATEST(i.stat_value9, 0)  +
        COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_equipment WHERE id = i.stat_type10), 0.0) * GREATEST(i.stat_value10, 0)
      )
      +
      COALESCE((SELECT normalized_cost
                FROM ACSBV3_ref_statcost_equipment
                WHERE id = i.socketBonus), 0.0)
    )
    /
    NULLIF(
      (
        /* slot_mod (InventoryType-based; accept 100 or 1.00) */
        CASE
          WHEN COALESCE((SELECT slot_modifier
                         FROM ACSBV3_ref_slotmod_equipment
                         WHERE InventoryType = i.InventoryType), 100.0) > 10.0
            THEN COALESCE((SELECT slot_modifier
                           FROM ACSBV3_ref_slotmod_equipment
                           WHERE InventoryType = i.InventoryType), 100.0) / 100.0
          ELSE COALESCE((SELECT slot_modifier
                         FROM ACSBV3_ref_slotmod_equipment
                         WHERE InventoryType = i.InventoryType), 1.0)
        END
        *
        /* drop_mod (environment-based; accept 100 or 1.00) */
        CASE
          WHEN COALESCE((SELECT drop_modifier
                         FROM ACSBV3_ref_dropmod
                         WHERE drop_environment = i.drop_environment), 100.0) > 10.0
            THEN COALESCE((SELECT drop_modifier
                           FROM ACSBV3_ref_dropmod
                           WHERE drop_environment = i.drop_environment), 100.0) / 100.0
          ELSE COALESCE((SELECT drop_modifier
                         FROM ACSBV3_ref_dropmod
                         WHERE drop_environment = i.drop_environment), 1.0)
        END
        *
        /* misc_mod (decimal; 1.35 if RP/Suffix present, else 1.00) */
        CASE
          WHEN (COALESCE(i.RandomProperty,0) <> 0 OR COALESCE(i.RandomSuffix,0) <> 0)
            THEN COALESCE((SELECT multiplier
                           FROM ACSBV3_ref_miscmod
                           WHERE modifier_name = 'random_property_correction'), 1.35)
          ELSE 1.00
        END
      ),
      0
    )
  ) AS normalized_budget

FROM ACSBV3_ref_items AS i
WHERE
  i.class = 4
  AND i.Quality BETWEEN 1 AND 4
  AND i.source_type <> 'unknown'
  AND i.subclass NOT IN (8,11)           -- exclude trinkets and relics
  AND i.InventoryType NOT IN (0,18,19,24) -- exclude non-gear per Phase 02

UNION ALL

-- ==========================================================================================
-- Weapons branch (class = 2)
-- ==========================================================================================
SELECT
  i.entry,
  i.name,
  i.class,
  i.subclass,
  i.InventoryType,
  i.Quality,
  i.ItemLevel,
  'weapon' AS item_family,

  /* Actual budget: DPS (1:1 with cost id=-1; fallback 1.0) + summed weapon stat costs */
  (
    /* DPS core */
    (
      ((i.dmg_min1 + i.dmg_max1) / 2.0) / NULLIF(i.delay / 1000.0, 0.0)
    ) * COALESCE((SELECT normalized_cost
                  FROM ACSBV3_ref_statcost_weapons
                  WHERE id = -1), 1.0)

    +
    /* Weapon stat pairs (negatives clamped to zero) */
    (
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type1), 0.0)  * GREATEST(i.stat_value1, 0)  +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type2), 0.0)  * GREATEST(i.stat_value2, 0)  +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type3), 0.0)  * GREATEST(i.stat_value3, 0)  +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type4), 0.0)  * GREATEST(i.stat_value4, 0)  +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type5), 0.0)  * GREATEST(i.stat_value5, 0)  +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type6), 0.0)  * GREATEST(i.stat_value6, 0)  +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type7), 0.0)  * GREATEST(i.stat_value7, 0)  +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type8), 0.0)  * GREATEST(i.stat_value8, 0)  +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type9), 0.0)  * GREATEST(i.stat_value9, 0)  +
      COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type10), 0.0) * GREATEST(i.stat_value10, 0)
    )
  ) AS actual_budget,

  /* Normalized budget: reverse subclass-based slot, drop, misc modifiers */
  (
    (
      /* DPS + weapon stats (repeat expression) */
      (
        ((i.dmg_min1 + i.dmg_max1) / 2.0) / NULLIF(i.delay / 1000.0, 0.0)
      ) * COALESCE((SELECT normalized_cost
                    FROM ACSBV3_ref_statcost_weapons
                    WHERE id = -1), 1.0)
      +
      (
        COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type1), 0.0)  * GREATEST(i.stat_value1, 0)  +
        COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type2), 0.0)  * GREATEST(i.stat_value2, 0)  +
        COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type3), 0.0)  * GREATEST(i.stat_value3, 0)  +
        COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type4), 0.0)  * GREATEST(i.stat_value4, 0)  +
        COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type5), 0.0)  * GREATEST(i.stat_value5, 0)  +
        COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type6), 0.0)  * GREATEST(i.stat_value6, 0)  +
        COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type7), 0.0)  * GREATEST(i.stat_value7, 0)  +
        COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type8), 0.0)  * GREATEST(i.stat_value8, 0)  +
        COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type9), 0.0)  * GREATEST(i.stat_value9, 0)  +
        COALESCE((SELECT normalized_cost FROM ACSBV3_ref_statcost_weapons WHERE id = i.stat_type10), 0.0) * GREATEST(i.stat_value10, 0)
      )
    )
    /
    NULLIF(
      (
        /* slot_mod (subclass-based; accept 100 or 1.00) */
        CASE
          WHEN COALESCE((SELECT avg_modifier
                         FROM ACSBV3_ref_slotmod_weapons
                         WHERE subclass = i.subclass), 100.0) > 10.0
            THEN COALESCE((SELECT avg_modifier
                           FROM ACSBV3_ref_slotmod_weapons
                           WHERE subclass = i.subclass), 100.0) / 100.0
          ELSE COALESCE((SELECT avg_modifier
                         FROM ACSBV3_ref_slotmod_weapons
                         WHERE subclass = i.subclass), 1.0)
        END
        *
        /* drop_mod (environment-based; accept 100 or 1.00) */
        CASE
          WHEN COALESCE((SELECT drop_modifier
                         FROM ACSBV3_ref_dropmod
                         WHERE drop_environment = i.drop_environment), 100.0) > 10.0
            THEN COALESCE((SELECT drop_modifier
                           FROM ACSBV3_ref_dropmod
                           WHERE drop_environment = i.drop_environment), 100.0) / 100.0
          ELSE COALESCE((SELECT drop_modifier
                         FROM ACSBV3_ref_dropmod
                         WHERE drop_environment = i.drop_environment), 1.0)
        END
        *
        /* misc_mod (decimal; 1.35 if RP/Suffix present, else 1.00) */
        CASE
          WHEN (COALESCE(i.RandomProperty,0) <> 0 OR COALESCE(i.RandomSuffix,0) <> 0)
            THEN COALESCE((SELECT multiplier
                           FROM ACSBV3_ref_miscmod
                           WHERE modifier_name = 'random_property_correction'), 1.35)
          ELSE 1.00
        END
      ),
      0
    )
  ) AS normalized_budget

FROM ACSBV3_ref_items AS i
WHERE
  i.class = 2
  AND i.Quality BETWEEN 1 AND 4
  AND i.source_type <> 'unknown'
;

-- -------------------------------------------------------------------------------------------
-- Indexes for downstream grouping and export
-- -------------------------------------------------------------------------------------------
ALTER TABLE ACSBV3_03_00A_curve_raw
  ADD INDEX idx_family_ilvl_quality (item_family, ItemLevel, Quality),
  ADD INDEX idx_class_sub_inv (class, subclass, InventoryType);

-- -------------------------------------------------------------------------------------------
-- Verification (lightweight)
-- -------------------------------------------------------------------------------------------

-- 1) Row counts overall and by family
SELECT COUNT(*) AS total_rows FROM ACSBV3_03_00A_curve_raw;
SELECT item_family, COUNT(*) AS rows_per_family
FROM ACSBV3_03_00A_curve_raw
GROUP BY item_family;

-- 2) iLvl range by family and quality
SELECT item_family, Quality,
       MIN(ItemLevel) AS min_ilvl,
       MAX(ItemLevel) AS max_ilvl,
       COUNT(*)       AS n
FROM ACSBV3_03_00A_curve_raw
GROUP BY item_family, Quality
ORDER BY item_family, Quality;

/*============================================================================================
  End of File
============================================================================================*/
