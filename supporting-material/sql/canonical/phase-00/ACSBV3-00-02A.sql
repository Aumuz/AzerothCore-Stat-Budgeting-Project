/*============================================================================================
Filename:       ACSBV3-00-02A.sql
Title:          Phase 00 – Source Linkage (Gameobject Containers)
Author:         ChatGPT + Aumuz Messick
Version:        1.4
Created:        2025-10-20
Description:    Links valid items from ACSBV3_00_00A_raw_items to all gameobject sources.
                Each record represents one (Item × Gameobject Template) pairing with drop
                chance, spawn context, and environment classification. Weighting occurs
                later in 00-02B.
----------------------------------------------------------------------------------------------
Notes:
 - v1.1 Corrected column references (Entry/id mismatches)
 - v1.2 Replaced missing fields (faction / expansion) with constants for schema alignment
 - v1.3 Restored template-based linkage (Entry ? entry)
 - v1.4 Switched to LEFT JOIN for template lookup (to include all loot templates),
         keeping entries even if no matching template or spawn exists.
         Default environment ? 'World' for unmapped containers.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS ACSBV3_00_02A_gameobject_src;

CREATE TABLE ACSBV3_00_02A_gameobject_src AS
WITH
/*---------------------------------------------------------------
  1. Build unified gameobject–item loot mapping
     (handles both direct and reference-based templates)
---------------------------------------------------------------*/
gameobject_loot AS (
    SELECT glt.Entry AS gameobject_template_entry,
           glt.Item  AS ItemID,
           glt.Chance AS drop_chance
    FROM gameobject_loot_template AS glt
    WHERE glt.Reference = 0

    UNION ALL

    SELECT glt.Entry AS gameobject_template_entry,
           rlt.Item  AS ItemID,
           rlt.Chance AS drop_chance
    FROM gameobject_loot_template AS glt
    JOIN reference_loot_template AS rlt
      ON glt.Reference = rlt.Entry
    WHERE glt.Reference > 0
),
/*---------------------------------------------------------------
  2. Summarize spawn context (map, zone, area, spawn count)
---------------------------------------------------------------*/
spawn_summary AS (
    SELECT
        g.id          AS gameobject_template_entry,
        COUNT(*)      AS spawn_count,
        MIN(g.map)    AS rep_map,
        MIN(g.zoneId) AS rep_zoneId,
        MIN(g.areaId) AS rep_areaId
    FROM gameobject AS g
    GROUP BY g.id
)
/*---------------------------------------------------------------
  3. Build final enriched mapping
---------------------------------------------------------------*/
SELECT
    it.ItemID,
    gl.gameobject_template_entry     AS gameobject_entry,
    COALESCE(gt.name, 'Unknown')     AS GameobjectName,
    COALESCE(gt.type, 0)             AS GameobjectType,
    0                                AS FactionID,
    0                                AS Expansion,
    COALESCE(s.spawn_count, 0)       AS spawn_count,
    s.rep_map,
    s.rep_zoneId,
    s.rep_areaId,
    gl.drop_chance,

    /*-----------------------------------------------------------
      Environment classification via reference table.
      Defaults to 'World' for unmapped or missing templates.
    -----------------------------------------------------------*/
    COALESCE(env.environment, 'World') AS drop_environment,

    CASE
      WHEN COALESCE(env.environment, 'World') = 'Raid' THEN 0.50
      WHEN COALESCE(env.environment, 'World') = 'Dungeon' THEN 0.75
      ELSE 1.00
    END AS encounter_weight_base,

    'Gameobject' AS source_type,
    NOW() AS date_linked

FROM gameobject_loot AS gl
LEFT JOIN gameobject_template AS gt
  ON gt.entry = gl.gameobject_template_entry      -- switched to LEFT JOIN for completeness
LEFT JOIN spawn_summary AS s
  ON s.gameobject_template_entry = gl.gameobject_template_entry
LEFT JOIN ACSBV3_ref_map_environment AS env
  ON s.rep_map = env.map_id
JOIN ACSBV3_00_00A_raw_items AS it
  ON it.ItemID = gl.ItemID
WHERE gl.ItemID > 0;

/*============================================================================================
Verification Block
----------------------------------------------------------------------------------------------
 - Confirms linkage counts, environment distribution, and distinct item coverage.
============================================================================================*/

SELECT COUNT(*) AS total_links FROM ACSBV3_00_02A_gameobject_src;

SELECT
    drop_environment,
    COUNT(*) AS count_per_env,
    ROUND(AVG(drop_chance), 3) AS avg_drop_chance
FROM ACSBV3_00_02A_gameobject_src
GROUP BY drop_environment
ORDER BY drop_environment;

SELECT
    Quality,
    drop_environment,
    COUNT(*) AS items_per_quality_env
FROM ACSBV3_00_02A_gameobject_src AS s
JOIN ACSBV3_00_00A_raw_items AS i ON s.ItemID = i.ItemID
GROUP BY Quality, drop_environment
ORDER BY Quality, drop_environment;

SELECT COUNT(DISTINCT ItemID) AS distinct_items
FROM ACSBV3_00_02A_gameobject_src;

/*============================================================================================
End of File
============================================================================================*/
