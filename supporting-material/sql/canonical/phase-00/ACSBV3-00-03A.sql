/*============================================================================================
Filename:       ACSBV3-00-03A.sql
Title:          Phase 00 – Source Linkage (Item-Loot Containers)
Author:         ChatGPT + Aumuz Messick
Version:        1.0
Created:        2025-10-20
Description:    Builds linkage between items and container items defined in item_loot_template.
                Inherits environment and cadence data from parent sources (creature/gameobject)
                where available.  Defaults to World/0.85/1 for unanchored containers.
----------------------------------------------------------------------------------------------
Notes:
 - Combines direct and reference-based item_loot_template entries.
 - Joins to ACSBV3_00_01B_weighted_creature and ACSBV3_00_02B_weighted_gameobject
   for environment inheritance.
 - Weighting calculations are deferred to 00-03B.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS ACSBV3_00_03A_itemloot_src;

CREATE TABLE ACSBV3_00_03A_itemloot_src AS
WITH
/*---------------------------------------------------------------
  1. Build unified item-loot mapping (direct + reference)
---------------------------------------------------------------*/
item_loot AS (
    SELECT ilt.Entry AS container_item,
           ilt.Item  AS ItemID,
           ilt.Chance AS drop_chance
    FROM item_loot_template AS ilt
    WHERE ilt.Reference = 0

    UNION ALL

    SELECT ilt.Entry AS container_item,
           rlt.Item  AS ItemID,
           rlt.Chance AS drop_chance
    FROM item_loot_template AS ilt
    JOIN reference_loot_template AS rlt
      ON ilt.Reference = rlt.Entry
    WHERE ilt.Reference > 0
),

/*---------------------------------------------------------------
  2. Determine parent (container) environment and encounter weight
     via inheritance from prior Phase 00 tables.
---------------------------------------------------------------*/
parent_env AS (
    SELECT
        c.ItemID             AS container_item,
        c.drop_environment   AS inherited_environment,
        c.encounter_weight_base,
        CASE
            WHEN c.drop_environment = 'Raid'    THEN 1
            WHEN c.drop_environment = 'Dungeon' THEN 10
            WHEN c.drop_environment = 'World'   THEN LEAST(GREATEST(c.spawn_count,1),168)
            ELSE 1
        END AS encounters_per_week
    FROM ACSBV3_00_01B_weighted_creature AS c

    UNION ALL

    SELECT
        g.ItemID             AS container_item,
        g.drop_environment   AS inherited_environment,
        g.encounter_weight_base,
        CASE
            WHEN g.drop_environment = 'Raid'    THEN 1
            WHEN g.drop_environment = 'Dungeon' THEN 10
            WHEN g.drop_environment = 'World'   THEN LEAST(GREATEST(g.spawn_count,1),168)
            ELSE 1
        END AS encounters_per_week
    FROM ACSBV3_00_02B_weighted_gameobject AS g
)

/*---------------------------------------------------------------
  3. Build final enriched item-loot linkage
---------------------------------------------------------------*/
SELECT
    it.ItemID,
    il.container_item,
    COALESCE(pt.name, 'Unknown') AS container_name,
    COALESCE(pt.class, 0)        AS container_class,
    COALESCE(pt.subclass, 0)     AS container_subclass,
    il.drop_chance,

    /*-----------------------------------------------------------
      Inherit environment/cadence from parent if found,
      otherwise default to World / 0.85 / 1.
    -----------------------------------------------------------*/
    COALESCE(p.inherited_environment, 'World') AS drop_environment,
    COALESCE(p.encounter_weight_base, 0.85)    AS encounter_weight_base,
    COALESCE(p.encounters_per_week, 1)         AS encounters_per_week,

    'Item_Loot' AS source_type,
    NOW() AS date_linked

FROM item_loot AS il
LEFT JOIN item_template AS pt
  ON pt.entry = il.container_item
LEFT JOIN parent_env AS p
  ON p.container_item = il.container_item
JOIN ACSBV3_00_00A_raw_items AS it
  ON it.ItemID = il.ItemID
WHERE il.ItemID > 0;

/*============================================================================================
Verification Block
----------------------------------------------------------------------------------------------
 - Confirms linkage counts and distinct items.
============================================================================================*/

SELECT COUNT(*) AS total_links,
       COUNT(DISTINCT ItemID) AS distinct_items
FROM ACSBV3_00_03A_itemloot_src;

SELECT
    drop_environment,
    COUNT(*) AS count_per_env,
    ROUND(AVG(drop_chance),3) AS avg_drop_chance
FROM ACSBV3_00_03A_itemloot_src
GROUP BY drop_environment
ORDER BY drop_environment;

/*============================================================================================
End of File
============================================================================================*/
