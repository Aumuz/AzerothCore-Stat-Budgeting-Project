/*============================================================================================
Filename:       ACSBV3-00-02B.sql
Title:          Phase 00 – Encounter Weighting (Gameobject Containers)
Author:         ChatGPT + Aumuz Messick
Version:        1.0
Created:        2025-10-20
Description:    Applies encounter cadence and weighting formulas to gameobject loot sources.
                Produces weighted probabilities and final weights per item-source pair.
                Collapsing to a single best source per item occurs later (00-07B).
----------------------------------------------------------------------------------------------
Notes:
 - Built on ACSBV3_00_02A_gameobject_src.
 - Mirrors creature weighting logic (00-01B) for schema alignment.
 - Uses same cadence constants and frequency curve.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS ACSBV3_00_02B_weighted_gameobject;

CREATE TABLE ACSBV3_00_02B_weighted_gameobject AS
SELECT
    s.ItemID,
    s.gameobject_entry,
    s.GameobjectName,
    s.GameobjectType,
    s.FactionID,
    s.Expansion,
    s.spawn_count,
    s.rep_map,
    s.rep_zoneId,
    s.rep_areaId,
    s.drop_environment,
    s.encounter_weight_base,
    s.drop_chance,

    /*---------------------------------------------------------------
      Encounter cadence per environment
      (approximate encounters per week for 3.3.5a gameplay)
    ---------------------------------------------------------------*/
    CASE
        WHEN s.drop_environment = 'Raid'    THEN 1     -- weekly lockout
        WHEN s.drop_environment = 'Dungeon' THEN 10    -- repeatable dungeon runs
        WHEN s.drop_environment = 'World'   THEN LEAST(GREATEST(s.spawn_count,1),168)
        ELSE 1
    END AS encounters_per_week,

    /*---------------------------------------------------------------
      Effective probability (p_eff)
      1 - (1 - drop_chance/100)^encounters
    ---------------------------------------------------------------*/
    CASE
        WHEN s.drop_chance <= 0 THEN 0
        ELSE (1 - POW(1 - (s.drop_chance / 100.0),
                      CASE
                          WHEN s.drop_environment = 'Raid'    THEN 1
                          WHEN s.drop_environment = 'Dungeon' THEN 10
                          WHEN s.drop_environment = 'World'   THEN LEAST(GREATEST(s.spawn_count,1),168)
                          ELSE 1
                      END)) * 100.0
    END AS effective_chance,

    /*---------------------------------------------------------------
      Frequency-weighting curve: 0.5 + 0.7 × v(p_eff)
      (capped at 1.0)
    ---------------------------------------------------------------*/
    LEAST(
        0.5 + 0.7 * SQRT(
            CASE
                WHEN s.drop_chance <= 0 THEN 0
                ELSE (1 - POW(1 - (s.drop_chance / 100.0),
                              CASE
                                  WHEN s.drop_environment = 'Raid'    THEN 1
                                  WHEN s.drop_environment = 'Dungeon' THEN 10
                                  WHEN s.drop_environment = 'World'   THEN LEAST(GREATEST(s.spawn_count,1),168)
                                  ELSE 1
                              END))
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
                ELSE (1 - POW(1 - (s.drop_chance / 100.0),
                              CASE
                                  WHEN s.drop_environment = 'Raid'    THEN 1
                                  WHEN s.drop_environment = 'Dungeon' THEN 10
                                  WHEN s.drop_environment = 'World'   THEN LEAST(GREATEST(s.spawn_count,1),168)
                                  ELSE 1
                              END))
            END
        ),
        1.0
    ) AS final_weight,

    'Gameobject' AS source_type,
    NOW() AS date_weighted

FROM ACSBV3_00_02A_gameobject_src AS s;

/*============================================================================================
Verification Block
----------------------------------------------------------------------------------------------
 - Confirms total records, distinct items, and average weights by environment.
============================================================================================*/

SELECT COUNT(*) AS total_records,
       COUNT(DISTINCT ItemID) AS distinct_items
FROM ACSBV3_00_02B_weighted_gameobject;

SELECT
    drop_environment,
    ROUND(AVG(drop_chance), 3) AS avg_drop,
    ROUND(AVG(effective_chance), 3) AS avg_eff_chance,
    ROUND(AVG(freq_weight), 3) AS avg_freq_weight,
    ROUND(AVG(final_weight), 3) AS avg_final_weight
FROM ACSBV3_00_02B_weighted_gameobject
GROUP BY drop_environment
ORDER BY drop_environment;

/*============================================================================================
End of File
============================================================================================*/
