/*============================================================================================
  Filename:       ACSBV3-01-10J.sql
  Title:          Phase 01 - Validation: Drop Modifiers with Refined Random Property Rule
  Author:         ChatGPT + Aumuz Messick
  Version:        1.0
  Created:        2025-10-23
  Description:    Recalculates environment drop modifiers using refined logic for
                  RandomProperty/Suffix multipliers.  The 1.35x correction is now
                  applied only to unrolled templates (items with RandomProperty/Suffix > 0
                  and all stat_type fields = 0).  Rolled items with visible stats are
                  left unchanged.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

-- -------------------------------------------------------------------------------------------
-- 1. Drop any prior test tables
-- -------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS ACSBV3_01_10J_dropmod_equipment_retest;

-- -------------------------------------------------------------------------------------------
-- 2. Build working dataset with refined random-suffix rule
-- -------------------------------------------------------------------------------------------
CREATE TABLE ACSBV3_01_10J_dropmod_equipment_retest AS
SELECT
    d.entry,
    d.name,
    d.Quality,
    d.ItemLevel,
    d.InventoryType,
    d.drop_environment,
    d.source_type,
    d.total_budget,
    d.normalized_1,

    -- Check if the item is an unrolled random template
    CASE
        WHEN (r.RandomProperty > 0 OR r.RandomSuffix > 0)
             AND COALESCE(r.stat_type1,0) = 0
             AND COALESCE(r.stat_type2,0) = 0
             AND COALESCE(r.stat_type3,0) = 0
             AND COALESCE(r.stat_type4,0) = 0
             AND COALESCE(r.stat_type5,0) = 0
             AND COALESCE(r.stat_type6,0) = 0
             AND COALESCE(r.stat_type7,0) = 0
             AND COALESCE(r.stat_type8,0) = 0
             AND COALESCE(r.stat_type9,0) = 0
             AND COALESCE(r.stat_type10,0) = 0
        THEN d.normalized_1 / 1.35   -- Apply correction only to unrolled templates
        ELSE d.normalized_1
    END AS normalized_2

FROM ACSBV3_01_10E_dropmod_equipment_raw AS d
JOIN ACSBV3_ref_items AS r ON d.entry = r.entry
WHERE d.total_budget > 0
  AND (r.source_type <> 'VENDOR' AND r.source_type IS NOT NULL)
  AND r.drop_environment IN ('WORLD','DUNGEON','RAID');

-- -------------------------------------------------------------------------------------------
-- 3. Compute new environment averages
-- -------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ACSBV3_01_10J_env_averages AS
SELECT
    drop_environment,
    Quality,
    COUNT(*) AS item_count,
    ROUND(AVG(normalized_2),3) AS avg_norm2,
    ROUND(STDDEV_SAMP(normalized_2),3) AS stdev_norm2
FROM ACSBV3_01_10J_dropmod_equipment_retest
GROUP BY drop_environment, Quality
ORDER BY Quality, drop_environment;

-- -------------------------------------------------------------------------------------------
-- 4. Compare against World baseline
-- -------------------------------------------------------------------------------------------
SELECT
    e.Quality,
    e.drop_environment,
    ROUND((e.avg_norm2 / w.avg_norm2) * 100,2) AS drop_modifier_refined
FROM ACSBV3_01_10J_env_averages AS e
JOIN ACSBV3_01_10J_env_averages AS w
  ON e.Quality = w.Quality AND w.drop_environment = 'WORLD'
ORDER BY e.Quality, e.drop_environment;

-- -------------------------------------------------------------------------------------------
-- 5. Optional summary by environment
-- -------------------------------------------------------------------------------------------
SELECT drop_environment,
       COUNT(*) AS items,
       ROUND(AVG(normalized_2),2) AS avg_budget
FROM ACSBV3_01_10J_dropmod_equipment_retest
GROUP BY drop_environment
ORDER BY drop_environment;

/*============================================================================================
  End of File
============================================================================================*/
