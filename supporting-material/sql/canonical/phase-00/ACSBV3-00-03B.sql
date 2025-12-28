/*============================================================================================
Filename:       ACSBV3-00-03B.sql
Title:          Phase 00 – Encounter Weighting (Item-Loot Containers)
Author:         ChatGPT + Aumuz Messick
Version:        1.0
Created:        2025-10-20
Description:    Applies encounter cadence, computes effective probability (p_eff),
                and derives frequency-adjusted final weights for item-loot containers.
                Each row represents one (Item × Container Item) pairing.
----------------------------------------------------------------------------------------------
Notes:
 - Based on ACSBV3_00_03A_itemloot_src output.
 - Inherited environment, encounter_weight_base, and encounters_per_week
   are used directly (no additional classification).
 - Collapsing to one best source per item occurs later in 00-07B.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS ACSBV3_00_03B_weighted_itemloot;

CREATE TABLE ACSBV3_00_03B_weighted_itemloot AS
SELECT
    s.ItemID,
    s.container_item,
    s.container_name,
    s.container_class,
    s.container_subclass,
    s.drop_environment,
    s.encounter_weight_base,
    s.encounters_per_week,
    s.drop_chance,

    /*---------------------------------------------------------------
      Effective probability (p_eff)
      1 - (1 - drop_chance/100)^encounters_per_week
    ---------------------------------------------------------------*/
    CASE
        WHEN s.drop_chance <= 0 THEN 0
        ELSE (1 - POW(1 - (s.drop_chance / 100.0), s.encounters_per_week)) * 100.0
    END AS effective_chance,

    /*---------------------------------------------------------------
      Frequency-weighting curve: 0.5 + 0.7 × v(p_eff)
      (capped at 1.0)
    ---------------------------------------------------------------*/
    LEAST(
        0.5 + 0.7 * SQRT(
            CASE
                WHEN s.drop_chance <= 0 THEN 0
                ELSE (1 - POW(1 - (s.drop_chance / 100.0), s.encounters_per_week))
            END
        ),
        1.0
    ) AS freq_weight,

    /*---------------------------------------------------------------
      Final per-source weight = encounter_weight_base × freq_weight
    ---------------------------------------------------------------*/
    s.encounter_weight_base *
    LEAST(
        0.5 + 0.7 * SQRT(
            CASE
                WHEN s.drop_chance <= 0 THEN 0
                ELSE (1 - POW(1 - (s.drop_chance / 100.0), s.encounters_per_week))
            END
        ),
        1.0
    ) AS final_weight,

    'Item_Loot' AS source_type,
    NOW() AS date_weighted

FROM ACSBV3_00_03A_itemloot_src AS s;

/*============================================================================================
Verification Block
----------------------------------------------------------------------------------------------
 - Confirms total records, distinct items, and average weights by environment.
============================================================================================*/

SELECT COUNT(*) AS total_records,
       COUNT(DISTINCT ItemID) AS distinct_items
FROM ACSBV3_00_03B_weighted_itemloot;

SELECT
    drop_environment,
    ROUND(AVG(drop_chance), 3) AS avg_drop,
    ROUND(AVG(effective_chance), 3) AS avg_eff_chance,
    ROUND(AVG(freq_weight), 3) AS avg_freq_weight,
    ROUND(AVG(final_weight), 3) AS avg_final_weight
FROM ACSBV3_00_03B_weighted_itemloot
GROUP BY drop_environment
ORDER BY drop_environment;

/*============================================================================================
End of File
============================================================================================*/
