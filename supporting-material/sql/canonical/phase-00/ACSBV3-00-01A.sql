/*============================================================================================
Filename:       ACSBV3-00-01A.sql
Title:          Phase 00 – Source Linkage (Creature Drops, Reference-Aware)
Author:         ChatGPT + Aumuz Messick
Version:        1.3
Created:        2025-10-19
Description:    Links valid items from ACSBV3_00_00A_raw_items to all creature sources,
                including both direct and reference-based loot templates. Each record
                represents one (Item × Creature) pairing with drop chance, environment,
                and spawn-context information. No weighting calculations are applied here.
----------------------------------------------------------------------------------------------
Notes:
 - v1.1  Corrected faction column (ct.faction_A/H ? ct.faction)
 - v1.2  Added distinct item count
 - v1.3  Rewritten to:
          • Include reference_loot_template entries
          • Join primarily via creature_template (for scripted creatures)
          • Integrate ACSBV3_ref_map_environment table for classification
          • Collect spawn context from creature table (map, zone, area)
          • Defer weighting calculations to 00-01B
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS ACSBV3_00_01A_creature_src;

CREATE TABLE ACSBV3_00_01A_creature_src AS
WITH
/*---------------------------------------------------------------
  1. Build unified creature–item loot mapping
     (handles both direct and reference-based templates)
---------------------------------------------------------------*/
creature_loot AS (
    SELECT clt.Entry AS creature_entry, clt.Item AS ItemID, clt.Chance AS drop_chance
    FROM creature_loot_template AS clt
    WHERE clt.Reference = 0

    UNION ALL

    SELECT clt.Entry AS creature_entry, rlt.Item AS ItemID, rlt.Chance AS drop_chance
    FROM creature_loot_template AS clt
    JOIN reference_loot_template AS rlt
      ON clt.Reference = rlt.Entry
    WHERE clt.Reference > 0
),
/*---------------------------------------------------------------
  2. Summarize spawn context (map, zone, area, spawn count)
---------------------------------------------------------------*/
spawn_summary AS (
    SELECT
        creature_entry,
        COUNT(*)      AS spawn_count,
        MIN(map)      AS rep_map,
        MIN(zoneId)   AS rep_zoneId,
        MIN(areaId)   AS rep_areaId
    FROM (
        SELECT id1 AS creature_entry, map, zoneId, areaId FROM creature WHERE id1 > 0
        UNION ALL
        SELECT id2 AS creature_entry, map, zoneId, areaId FROM creature WHERE id2 > 0
        UNION ALL
        SELECT id3 AS creature_entry, map, zoneId, areaId FROM creature WHERE id3 > 0
    ) AS x
    GROUP BY creature_entry
)
/*---------------------------------------------------------------
  3. Build final enriched mapping
---------------------------------------------------------------*/
SELECT
    it.ItemID,
    cl.creature_entry,
    COALESCE(ct.name, 'Unknown')  AS CreatureName,
    COALESCE(ct.rank, 0)          AS CreatureRank,
    COALESCE(ct.type, 0)          AS CreatureType,
    COALESCE(ct.faction, 0)       AS FactionID,
    COALESCE(ct.exp, 0)           AS Expansion,
    COALESCE(s.spawn_count, 0)    AS spawn_count,
    s.rep_map,
    s.rep_zoneId,
    s.rep_areaId,
    cl.drop_chance,
    /*-----------------------------------------------------------
      Environment classification via reference table
      Fallback: rank-based heuristic if no map match found
    -----------------------------------------------------------*/
    COALESCE(env.environment,
             CASE
               WHEN ct.rank = 3 THEN 'Raid'
               WHEN ct.rank = 2 THEN 'Dungeon'
               ELSE 'World'
             END)                 AS drop_environment,
    CASE
      WHEN COALESCE(env.environment,
                    CASE
                      WHEN ct.rank = 3 THEN 'Raid'
                      WHEN ct.rank = 2 THEN 'Dungeon'
                      ELSE 'World'
                    END) = 'Raid' THEN 0.50
      WHEN COALESCE(env.environment,
                    CASE
                      WHEN ct.rank = 3 THEN 'Raid'
                      WHEN ct.rank = 2 THEN 'Dungeon'
                      ELSE 'World'
                    END) = 'Dungeon' THEN 0.75
      ELSE 1.00
    END                          AS encounter_weight_base,
    'Creature'                   AS source_type,
    NOW()                        AS date_linked
FROM creature_loot AS cl
JOIN creature_template AS ct
  ON ct.entry = cl.creature_entry
LEFT JOIN spawn_summary AS s
  ON s.creature_entry = cl.creature_entry
LEFT JOIN ACSBV3_ref_map_environment AS env
  ON s.rep_map = env.map_id
JOIN ACSBV3_00_00A_raw_items AS it
  ON it.ItemID = cl.ItemID
WHERE cl.ItemID > 0;

/*============================================================================================
Verification Block
----------------------------------------------------------------------------------------------
 - Confirms linkage counts, environment distribution, and distinct item coverage.
============================================================================================*/

SELECT COUNT(*) AS total_links FROM ACSBV3_00_01A_creature_src;

SELECT
    drop_environment,
    COUNT(*) AS count_per_env,
    ROUND(AVG(drop_chance), 2) AS avg_drop_chance
FROM ACSBV3_00_01A_creature_src
GROUP BY drop_environment
ORDER BY drop_environment;

SELECT
    Quality,
    drop_environment,
    COUNT(*) AS items_per_quality_env
FROM ACSBV3_00_01A_creature_src AS s
JOIN ACSBV3_00_00A_raw_items AS i ON s.ItemID = i.ItemID
GROUP BY Quality, drop_environment
ORDER BY Quality, drop_environment;

SELECT COUNT(DISTINCT ItemID) AS distinct_items
FROM ACSBV3_00_01A_creature_src;

/*============================================================================================
End of File
============================================================================================*/
