/*============================================================================================
  Filename:       ACSBV3-01-10I.sql
  Title:          Phase 01 - Validation: Drop Modifiers with Misc Multipliers
  Author:         ChatGPT + Aumuz Messick
  Version:        1.0
  Created:        2025-10-22
  Description:    Recalculates environment drop modifiers after applying the
                  RandomPropertySuffix multiplier from ACSBV3_ref_miscmod_equipment.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

-- -------------------------------------------------------------------------------------------
-- 1. Drop temporary results
-- -------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS ACSBV3_01_10I_dropmod_equipment_retest;

-- -------------------------------------------------------------------------------------------
-- 2. Apply random property multiplier
-- -------------------------------------------------------------------------------------------
CREATE TABLE ACSBV3_01_10I_dropmod_equipment_retest AS
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
    CASE
        WHEN (r.RandomProperty > 0 OR r.RandomSuffix > 0)
             THEN d.normalized_1 / 1.35
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
CREATE OR REPLACE VIEW ACSBV3_01_10I_env_averages AS
SELECT
    drop_environment,
    Quality,
    COUNT(*) AS item_count,
    ROUND(AVG(normalized_2),3) AS avg_norm2,
    ROUND(STDDEV_SAMP(normalized_2),3) AS stdev_norm2
FROM ACSBV3_01_10I_dropmod_equipment_retest
GROUP BY drop_environment, Quality
ORDER BY Quality, drop_environment;

-- -------------------------------------------------------------------------------------------
-- 4. Compare against World baseline
-- -------------------------------------------------------------------------------------------
SELECT
    e.Quality,
    e.drop_environment,
    ROUND((e.avg_norm2 / w.avg_norm2) * 100,2) AS drop_modifier_retest
FROM ACSBV3_01_10I_env_averages AS e
JOIN ACSBV3_01_10I_env_averages AS w
  ON e.Quality = w.Quality AND w.drop_environment = 'WORLD'
ORDER BY e.Quality, e.drop_environment;

/*============================================================================================
  End of File
============================================================================================*/
