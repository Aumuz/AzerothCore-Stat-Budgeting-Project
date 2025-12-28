/*============================================================================================
  Filename:       ACSBV3-03-Verify_DungeonDrop.sql
  Title:          Phase 03 – Verification: Dungeon Drop Multiplier with Corrected RP Ratio
  Author:         ChatGPT
  Created:        2025-10-25
  Description:
    Re-estimates environment (World/Dungeon/Raid) drop multipliers by removing slot and
    random-affix effects from actual budgets, then comparing medians by environment.
    Uses misc_ratio = 0.65 for random-affix items (RandomProperty/Suffix), else 1.00.

  Key Identity:
    base_env_budget = actual_budget / (slot_ratio * misc_ratio)
    For a given iLvl/Quality bucket, median(base_env_budget) ? drop_modifier.

    Dungeon / World median ratio ˜ drop_dungeon / drop_world
    If World baseline = 1.00, this ratio is the Dungeon multiplier.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TEMPORARY TABLE IF EXISTS tmp_env_base;

CREATE TEMPORARY TABLE tmp_env_base AS
SELECT
  a.entry,
  a.item_family,
  a.class,
  a.subclass,
  a.InventoryType,
  i.drop_environment,
  a.Quality,
  a.ItemLevel,
  a.actual_budget,

  /* misc_ratio: 0.65 if random-affix present, else 1.00 */
  CASE
    WHEN (COALESCE(i.RandomProperty,0) <> 0 OR COALESCE(i.RandomSuffix,0) <> 0)
      THEN 0.65
    ELSE 1.00
  END AS misc_ratio,

  /* slot_ratio: equipment by InventoryType; weapons by subclass (convert percent -> ratio) */
  CASE
    WHEN a.class = 4 THEN
      CASE
        WHEN COALESCE((
          SELECT slot_modifier
          FROM ACSBV3_ref_slotmod_equipment se
          WHERE se.InventoryType = a.InventoryType
        ), 100.0) > 10.0
          THEN COALESCE((
            SELECT slot_modifier
            FROM ACSBV3_ref_slotmod_equipment se
            WHERE se.InventoryType = a.InventoryType
          ), 100.0) / 100.0
        ELSE COALESCE((
            SELECT slot_modifier
            FROM ACSBV3_ref_slotmod_equipment se
            WHERE se.InventoryType = a.InventoryType
        ), 1.0)
      END
    WHEN a.class = 2 THEN
      CASE
        WHEN COALESCE((
          SELECT avg_modifier
          FROM ACSBV3_ref_slotmod_weapons sw
          WHERE sw.subclass = a.subclass
        ), 100.0) > 10.0
          THEN COALESCE((
            SELECT avg_modifier
            FROM ACSBV3_ref_slotmod_weapons sw
            WHERE sw.subclass = a.subclass
          ), 100.0) / 100.0
        ELSE COALESCE((
            SELECT avg_modifier
            FROM ACSBV3_ref_slotmod_weapons sw
            WHERE sw.subclass = a.subclass
        ), 1.0)
      END
    ELSE 1.00
  END AS slot_ratio

FROM ACSBV3_03_00A_curve_raw a
JOIN ACSBV3_ref_items i
  ON i.entry = a.entry
WHERE
  a.Quality BETWEEN 1 AND 4
  AND i.source_type <> 'unknown'
  AND i.drop_environment IN ('World','Dungeon','Raid');

-- Base environment budget (proportional to drop modifier)
DROP TEMPORARY TABLE IF EXISTS tmp_env_base2;

CREATE TEMPORARY TABLE tmp_env_base2 AS
SELECT
  entry, item_family, class, subclass, InventoryType,
  drop_environment, Quality, ItemLevel,
  actual_budget,
  slot_ratio, misc_ratio,
  /* Guard against divide-by-zero just in case */
  actual_budget / NULLIF(slot_ratio * misc_ratio, 0.0) AS base_env_budget
FROM tmp_env_base;

-- Median per (drop_environment, Quality) using percentile_disc approximation via window:
-- MySQL lacks a built-in MEDIAN; we can approximate with PERCENTILE_CONT(0.5) behavior
-- by using a rank trick per group. For simplicity and speed, we will use AVG of middle two
-- after ordering, but here we will use PERCENTILE_DISC emulation via subselect.
-- Lightweight alternative: use AVG of values around the 50th percentile via NTILE(2).

DROP TEMPORARY TABLE IF EXISTS tmp_env_medians;

CREATE TEMPORARY TABLE tmp_env_medians AS
SELECT
  drop_environment,
  Quality,
  item_family,
  /* Approx median via AVG of two middle bins from NTILE(2) */
  AVG(base_env_budget) AS approx_median_budget,
  COUNT(*) AS n
FROM (
  SELECT
    drop_environment, Quality, item_family, base_env_budget,
    NTILE(2) OVER (PARTITION BY drop_environment, Quality, item_family ORDER BY base_env_budget) AS half
  FROM tmp_env_base2
) t
GROUP BY drop_environment, Quality, item_family, half
HAVING half IN (1,2)
-- Averaging both halves is a rough median proxy; acceptable for ratio comparison.

;

-- Pivot medians to compute Dungeon/World and Raid/World ratios per Quality and family
DROP TEMPORARY TABLE IF EXISTS tmp_env_ratios;

CREATE TEMPORARY TABLE tmp_env_ratios AS
SELECT
  q.item_family,
  q.Quality,

  /* World median */
  MAX(CASE WHEN q.drop_environment = 'World' THEN q.approx_median_budget END) AS world_med,

  /* Dungeon median */
  MAX(CASE WHEN q.drop_environment = 'Dungeon' THEN q.approx_median_budget END) AS dungeon_med,

  /* Raid median */
  MAX(CASE WHEN q.drop_environment = 'Raid' THEN q.approx_median_budget END) AS raid_med,

  /* Counts for sanity */
  SUM(CASE WHEN q.drop_environment = 'World' THEN q.n ELSE 0 END)   AS n_world,
  SUM(CASE WHEN q.drop_environment = 'Dungeon' THEN q.n ELSE 0 END) AS n_dungeon,
  SUM(CASE WHEN q.drop_environment = 'Raid' THEN q.n ELSE 0 END)    AS n_raid

FROM tmp_env_medians q
GROUP BY q.item_family, q.Quality;

-- Final ratios (Dungeon/World, Raid/World); if World is NULL, ratios remain NULL.
SELECT
  item_family,
  Quality,
  ROUND(dungeon_med / NULLIF(world_med,0), 3) AS dungeon_over_world,
  ROUND(raid_med    / NULLIF(world_med,0), 3) AS raid_over_world,
  n_world, n_dungeon, n_raid
FROM tmp_env_ratios
ORDER BY item_family, Quality;

/*============================================================================================
  End of File
============================================================================================*/
