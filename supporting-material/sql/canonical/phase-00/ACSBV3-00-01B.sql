/*============================================================================================
Filename:       ACSBV3-00-01B.sql
Title:          Phase 00 – Encounter Weighting (Creature Sources)
Author:         ChatGPT + Aumuz Messick
Version:        1.0
Created:        2025-10-20
Description:    Applies encounter cadence, computes effective probability (p_eff),
                and derives frequency-adjusted final weights for each creature-item pair.
                This table preserves multiple sources per item for later reduction (00-01C).
----------------------------------------------------------------------------------------------
Notes:
 - Builds upon ACSBV3_00_01A_creature_src.
 - Applies cadence constants per environment type (Raid, Dungeon, World).
 - Calculates p_eff = 1 - (1 - p)^n and frequency-adjusted weight curves.
 - Final collapse to one best source occurs in 00-01C.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS ACSBV3_00_01B_weighted_creature;

CREATE TABLE ACSBV3_00_01B_weighted_creature AS
SELECT
    s.ItemID,
    s.creature_entry,
    s.CreatureName,
    s.CreatureRank,
    s.CreatureType,
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
        WHEN s.drop_environment = 'Dungeon' THEN 10    -- daily heroics, farmable
        WHEN s.drop_environment = 'World'   THEN 168   -- hourly respawns × 7 days
        ELSE 1
    END AS encounters_per_week,

    /*---------------------------------------------------------------
      Effective probability (p_eff) for multiple encounters:
      1 - (1 - drop_chance/100)^encounters
    ---------------------------------------------------------------*/
    CASE
        WHEN s.drop_chance <= 0 THEN 0
        ELSE (1 - POW(1 - (s.drop_chance / 100.0),
                      CASE
                          WHEN s.drop_environment = 'Raid'    THEN 1
                          WHEN s.drop_environment = 'Dungeon' THEN 10
                          WHEN s.drop_environment = 'World'   THEN LEAST(GREATEST(s.spawn_count, 1), 168)
                          ELSE 1
                      END)) * 100.0
    END AS effective_chance,

    /*---------------------------------------------------------------
      Frequency-weighting curve: 0.5 + 0.7 × v(p_eff)
      (capped at 1.0 for very common items)
    ---------------------------------------------------------------*/
    LEAST(
        0.5 + 0.7 * SQRT(
            CASE
                WHEN s.drop_chance <= 0 THEN 0
                ELSE (1 - POW(1 - (s.drop_chance / 100.0),
                              CASE
                                  WHEN s.drop_environment = 'Raid'    THEN 1
                                  WHEN s.drop_environment = 'Dungeon' THEN 10
                                  WHEN s.drop_environment = 'World'   THEN LEAST(GREATEST(s.spawn_count, 1), 168)
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
                                  WHEN s.drop_environment = 'World'   THEN LEAST(GREATEST(s.spawn_count, 1), 168)
                                  ELSE 1
                              END))
            END
        ),
        1.0
    ) AS final_weight,

    'Creature' AS source_type,
    NOW() AS date_weighted

FROM ACSBV3_00_01A_creature_src AS s;

/*============================================================================================
Verification Block
----------------------------------------------------------------------------------------------
 - Confirms total records, distinct items, and average weights by environment.
============================================================================================*/

SELECT COUNT(*) AS total_records,
       COUNT(DISTINCT ItemID) AS distinct_items
FROM ACSBV3_00_01B_weighted_creature;

SELECT
    drop_environment,
    ROUND(AVG(drop_chance), 3) AS avg_drop,
    ROUND(AVG(effective_chance), 3) AS avg_eff_chance,
    ROUND(AVG(freq_weight), 3) AS avg_freq_weight,
    ROUND(AVG(final_weight), 3) AS avg_final_weight
FROM ACSBV3_00_01B_weighted_creature
GROUP BY drop_environment
ORDER BY drop_environment;

/*============================================================================================
End of File
============================================================================================*/
