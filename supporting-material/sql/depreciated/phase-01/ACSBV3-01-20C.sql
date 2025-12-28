/*============================================================================================
  Filename:       ACSBV3-01-20C.sql
  Title:          Phase 01 – Weapon DPS Normalization & Subclass Analysis
  Author:         ChatGPT + Aumuz Messick
  Version:        1.0
  Created:        2025-10-22
  Description:    Computes subclass-specific DPS averages and normalizes all weapons against
                  their subclass baseline.  Generates diagnostic summaries and prepares data
                  for DPS-weighted stat cost integration (01-20E).
----------------------------------------------------------------------------------------------
  Notes:
   - Works from ACSBV3_01_20A_stat_cost_weapons (unweighted raw data).
   - Subclass weighting here refers to *within-subclass DPS normalization only*.
   - The `weight` field in ACSBV3_ref_items is **not used** in this step.
   - Items with zero DPS are excluded from normalization.
   - Produces normalized_dps values around 1.00 baseline per subclass.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

-- -------------------------------------------------------------------------------------------
-- 1.  Drop previous tables
-- -------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS ACSBV3_01_20C_dps_subclass_avg;
DROP TABLE IF EXISTS ACSBV3_01_20C_stat_cost_weapons_ext;
DROP TABLE IF EXISTS ACSBV3_01_20C_dps_diagnostic;

-- -------------------------------------------------------------------------------------------
-- 2.  Compute average DPS per subclass
-- -------------------------------------------------------------------------------------------
CREATE TABLE ACSBV3_01_20C_dps_subclass_avg AS
SELECT
    subclass,
    ROUND(AVG(dps),3) AS avg_dps,
    COUNT(*)          AS items
FROM ACSBV3_01_20A_stat_cost_weapons
WHERE dps > 0
GROUP BY subclass
ORDER BY subclass;

-- -------------------------------------------------------------------------------------------
-- 3.  Join averages back to base dataset and compute normalized DPS
-- -------------------------------------------------------------------------------------------
CREATE TABLE ACSBV3_01_20C_stat_cost_weapons_ext AS
SELECT
    a.entry,
    a.name,
    a.Quality,
    a.ItemLevel,
    a.subclass,
    a.InventoryType,
    a.dmg_min1,
    a.dmg_max1,
    a.delay,
    a.dps,
    s.avg_dps,
    ROUND(a.dps / s.avg_dps,3) AS normalized_dps,
    a.stat_type,
    a.stat_value
FROM ACSBV3_01_20A_stat_cost_weapons AS a
JOIN ACSBV3_01_20C_dps_subclass_avg AS s
  ON a.subclass = s.subclass
WHERE a.dps > 0;

-- -------------------------------------------------------------------------------------------
-- 4.  Diagnostic aggregation (sanity check on normalization)
-- -------------------------------------------------------------------------------------------
CREATE TABLE ACSBV3_01_20C_dps_diagnostic AS
SELECT
    subclass,
    ROUND(AVG(dps),3)            AS avg_dps_raw,
    ROUND(AVG(normalized_dps),3) AS avg_norm_dps,
    ROUND(STDDEV_SAMP(normalized_dps),3) AS stdev_norm_dps,
    COUNT(*) AS items
FROM ACSBV3_01_20C_stat_cost_weapons_ext
GROUP BY subclass
ORDER BY subclass;

-- -------------------------------------------------------------------------------------------
-- 5.  Verification queries
-- -------------------------------------------------------------------------------------------

-- Check subclass average table
SELECT * FROM ACSBV3_01_20C_dps_subclass_avg ORDER BY subclass;

-- Verify normalized DPS stability (should average ˜ 1.00 per subclass)
SELECT * FROM ACSBV3_01_20C_dps_diagnostic ORDER BY subclass;

-- Global summary (all subclasses combined)
SELECT
    ROUND(AVG(normalized_dps),3) AS global_avg_norm_dps,
    ROUND(STDDEV_SAMP(normalized_dps),3) AS global_stdev_norm_dps,
    COUNT(*) AS total_items
FROM ACSBV3_01_20C_stat_cost_weapons_ext;

-- Top and bottom 5 normalized DPS examples (for quick sanity check)
SELECT entry, name, subclass, ItemLevel, dps, normalized_dps
FROM ACSBV3_01_20C_stat_cost_weapons_ext
ORDER BY normalized_dps DESC
LIMIT 5;

SELECT entry, name, subclass, ItemLevel, dps, normalized_dps
FROM ACSBV3_01_20C_stat_cost_weapons_ext
ORDER BY normalized_dps ASC
LIMIT 5;

/*============================================================================================
  End of File
============================================================================================*/
