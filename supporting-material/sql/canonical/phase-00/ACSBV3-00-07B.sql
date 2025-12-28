/*============================================================================================
Filename:       ACSBV3-00-07B.sql
Title:          Phase 00 – Reduction to One Distinct Item (Probabilistic Combination)
Author:         ChatGPT + Aumuz Messick
Version:        1.1
Created:        2025-10-20
Description:    v1.1 Added guard for LOG() input to prevent invalid arguments (effective_chance = 100 or = 0).
                     Wrapped LOG() terms with GREATEST/LEAST bounds. No logic change, ensures stability.
                Collapses all per-source records for each ItemID into a single record
                using probabilistic combination of effective chances.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS ACSBV3_00_07B_reduced_items;

CREATE TABLE ACSBV3_00_07B_reduced_items AS
SELECT
    ItemID,

    /* Combined effective probability across all sources (guarded log) */
    100 * (1 - EXP(SUM(LOG(GREATEST(1 - LEAST(effective_chance,99.9999)/100, 0.000001))))) AS effective_chance_total,

    /* Frequency weighting curve */
    LEAST(
        0.5 + 0.7 * SQRT(
            (100 * (1 - EXP(SUM(LOG(GREATEST(1 - LEAST(effective_chance,99.9999)/100, 0.000001))))))/100
        ),
        1.0
    ) AS freq_weight_total,

    MAX(encounter_weight_base) AS encounter_weight_base,

    MAX(encounter_weight_base) *
    LEAST(
        0.5 + 0.7 * SQRT(
            (100 * (1 - EXP(SUM(LOG(GREATEST(1 - LEAST(effective_chance,99.9999)/100, 0.000001))))))/100
        ),
        1.0
    ) AS final_weight_total,

    COUNT(*) AS source_count,
    CASE WHEN COUNT(DISTINCT source_type) > 1 THEN 1 ELSE 0 END AS multi_source_flag,
    MAX(source_type) AS source_type,
    MAX(drop_environment) AS drop_environment,
    NOW() AS date_finalized
FROM ACSBV3_00_07A_all_sources
GROUP BY ItemID;

/* Verification */
SELECT COUNT(*) AS total_records,
       COUNT(DISTINCT ItemID) AS distinct_items,
       ROUND(AVG(final_weight_total),3) AS avg_final_weight
FROM ACSBV3_00_07B_reduced_items;
/*============================================================================================*/
