/*============================================================================================
  Filename:       ACSBV3-01-20D.sql
  Title:          Phase 01 – Weapon Misc Modifier & Effect Mapping
  Author:         ChatGPT + Aumuz Messick
  Version:        1.0
  Created:        2025-10-22
  Description:    Integrates SpellID and RandomProperty/Suffix modifiers for weapons.
                  Applies empirical multipliers defined in ACSBV3_ref_miscmod_equipment
                  (SpellID = 1.00, RandomPropertySuffix = 1.35).  Produces adjusted
                  normalized DPS and a finalized dataset for stat-cost derivation.
----------------------------------------------------------------------------------------------
  Notes:
   - Works from ACSBV3_01_20C_stat_cost_weapons_ext (normalized DPS dataset).
   - Uses same correction logic validated in equipment phase (01-10J).
   - Only affects items with unrolled random templates (visible RandomProperty/Suffix pairs).
   - SpellIDs are retained for documentation but do not alter cost scaling (×1.00).
   - All values remain normalized by subclass; modifiers only shift effective budget weight.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

-- -------------------------------------------------------------------------------------------
-- 1. Drop previous tables
-- -------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS ACSBV3_01_20D_miscmod_weapons;
DROP TABLE IF EXISTS ACSBV3_01_20D_miscmod_diagnostic;

-- -------------------------------------------------------------------------------------------
-- 2. Create working table with modifier application
-- -------------------------------------------------------------------------------------------
CREATE TABLE ACSBV3_01_20D_miscmod_weapons AS
SELECT
    w.entry,
    w.name,
    w.ItemLevel,
    w.Quality,
    w.subclass,
    w.InventoryType,
    w.stat_type,
    w.stat_value,
    w.dps,
    w.normalized_dps,
    w.avg_dps,
    COALESCE(i.spellid_1,0) AS spellid_1,
    COALESCE(i.RandomProperty,0) AS RandomProperty,
    COALESCE(i.RandomSuffix,0)   AS RandomSuffix,
    CASE
        WHEN i.RandomProperty > 0 OR i.RandomSuffix > 0 THEN 1.35     -- Randomized template
        ELSE 1.00
    END AS random_mod,
    1.00 AS spell_mod,
    ROUND(w.normalized_dps *
          CASE
              WHEN i.RandomProperty > 0 OR i.RandomSuffix > 0 THEN 1.35
              ELSE 1.00
          END,3) AS adj_normalized_dps
FROM ACSBV3_01_20C_stat_cost_weapons_ext AS w
LEFT JOIN ACSBV3_ref_items AS i
  ON w.entry = i.entry;

-- -------------------------------------------------------------------------------------------
-- 3. Diagnostic aggregation
-- -------------------------------------------------------------------------------------------
CREATE TABLE ACSBV3_01_20D_miscmod_diagnostic AS
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN RandomProperty > 0 OR RandomSuffix > 0 THEN 1 ELSE 0 END) AS randomized_items,
    ROUND(SUM(CASE WHEN RandomProperty > 0 OR RandomSuffix > 0 THEN 1 ELSE 0 END) /
          COUNT(*) * 100,2) AS pct_randomized,
    ROUND(AVG(random_mod),3) AS avg_random_mod,
    ROUND(AVG(adj_normalized_dps),3) AS avg_adj_norm_dps,
    ROUND(STDDEV_SAMP(adj_normalized_dps),3) AS stdev_adj_norm_dps
FROM ACSBV3_01_20D_miscmod_weapons;

-- -------------------------------------------------------------------------------------------
-- 4. Verification queries
-- -------------------------------------------------------------------------------------------

-- Basic diagnostic summary
SELECT * FROM ACSBV3_01_20D_miscmod_diagnostic;

-- Preview randomized vs. static sample
SELECT entry, name, subclass, ItemLevel, normalized_dps, adj_normalized_dps,
       random_mod, RandomProperty, RandomSuffix
FROM ACSBV3_01_20D_miscmod_weapons
WHERE random_mod > 1.0
ORDER BY ItemLevel DESC
LIMIT 10;

SELECT entry, name, subclass, ItemLevel, normalized_dps, adj_normalized_dps,
       random_mod
FROM ACSBV3_01_20D_miscmod_weapons
WHERE random_mod = 1.0
ORDER BY ItemLevel DESC
LIMIT 10;

-- Cross-check distribution of adjustment multipliers
SELECT random_mod, COUNT(*) AS items,
       ROUND(AVG(adj_normalized_dps),3) AS avg_adj_dps
FROM ACSBV3_01_20D_miscmod_weapons
GROUP BY random_mod
ORDER BY random_mod;

/*============================================================================================
  End of File
============================================================================================*/
