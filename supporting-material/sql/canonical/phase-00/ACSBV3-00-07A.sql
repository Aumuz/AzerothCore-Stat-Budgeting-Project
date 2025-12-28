/*============================================================================================
Filename:       ACSBV3-00-07A.sql
Title:          Phase 00 – Source Consolidation (Union All Weighted Sources)
Author:         ChatGPT + Aumuz Messick
Version:        1.0
Created:        2025-10-20
Description:    Unifies all Phase 00 weighted source tables into a single dataset.
                This table serves as input for the probabilistic reduction in 00-07B.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS ACSBV3_00_07A_all_sources;

CREATE TABLE ACSBV3_00_07A_all_sources AS
SELECT ItemID, drop_environment, encounter_weight_base, effective_chance,
       freq_weight, final_weight, source_type, NOW() AS date_linked
FROM ACSBV3_00_01B_weighted_creature
UNION ALL
SELECT ItemID, drop_environment, encounter_weight_base, effective_chance,
       freq_weight, final_weight, source_type, NOW()
FROM ACSBV3_00_02B_weighted_gameobject
UNION ALL
SELECT ItemID, drop_environment, encounter_weight_base, effective_chance,
       freq_weight, final_weight, source_type, NOW()
FROM ACSBV3_00_03B_weighted_itemloot
UNION ALL
SELECT ItemID, drop_environment, encounter_weight_base, effective_chance,
       freq_weight, final_weight, source_type, NOW()
FROM ACSBV3_00_04B_weighted_vendor
UNION ALL
SELECT ItemID, drop_environment, encounter_weight_base, effective_chance,
       freq_weight, final_weight, source_type, NOW()
FROM ACSBV3_00_05B_weighted_quest
UNION ALL
SELECT ItemID, drop_environment, encounter_weight_base, effective_chance,
       freq_weight, final_weight, source_type, NOW()
FROM ACSBV3_00_06B_weighted_crafted;

/* Verification */
SELECT COUNT(*) AS total_records,
       COUNT(DISTINCT ItemID) AS distinct_items
FROM ACSBV3_00_07A_all_sources;
/*============================================================================================*/
