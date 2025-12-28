/*============================================================================================
Filename:       ACSBV3-00-06B.sql
Title:          Phase 00 – Encounter Weighting (Crafted / Residual Items)
Author:         ChatGPT + Aumuz Messick
Version:        1.0
Created:        2025-10-20
Description:    Applies deterministic weighting to residual (crafted) items.
                Reclassifies Legendary items by provenance:
                  • Sulfuras  ? Crafted
                  • Andonisus ? Conjured
                  • Others    ? Unknown
----------------------------------------------------------------------------------------------
Notes:
 - Based on ACSBV3_00_06A_crafted_src.
 - Deterministic source: p_eff = 1, freq_weight = 1, final_weight = 1.
 - Provides explicit Legendary overrides for transparency in later analysis.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS ACSBV3_00_06B_weighted_crafted;

CREATE TABLE ACSBV3_00_06B_weighted_crafted AS
SELECT
    s.ItemID,
    s.ItemName,
    s.Quality,
    s.ItemLevel,
    s.RequiredLevel,
    s.drop_environment,
    s.encounter_weight_base,
    s.encounters_per_week,

    /*---------------------------------------------------------------
      Reclassify Legendary items by explicit provenance
    ---------------------------------------------------------------*/
    CASE
        WHEN s.ItemID = 17182 THEN 'Crafted'
        WHEN s.ItemID = 22736 THEN 'Conjured'
        WHEN s.ItemID IN (23051,17782,17783,50442,17142) THEN 'Unknown'
        ELSE 'Crafted'
    END AS source_type,

    /* Deterministic weights for residual items */
    100.0 AS effective_chance,
    1.0 AS freq_weight,
    s.encounter_weight_base * 1.0 AS final_weight,

    NOW() AS date_weighted
FROM ACSBV3_00_06A_crafted_src AS s;

/*============================================================================================
Verification Block
----------------------------------------------------------------------------------------------
 - Confirms residual totals and Legendary reclassification summary.
============================================================================================*/

SELECT COUNT(*) AS total_records,
       COUNT(DISTINCT ItemID) AS distinct_items,
       ROUND(AVG(final_weight),3) AS avg_final_weight
FROM ACSBV3_00_06B_weighted_crafted;

SELECT source_type,
       COUNT(*) AS count_per_type
FROM ACSBV3_00_06B_weighted_crafted
GROUP BY source_type
ORDER BY source_type;

/*============================================================================================
End of File
============================================================================================*/
