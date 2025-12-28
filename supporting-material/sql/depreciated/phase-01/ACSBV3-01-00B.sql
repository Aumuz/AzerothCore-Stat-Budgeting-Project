/*============================================================================================
  Filename:       ACSBV3-01-00B.sql
  Title:          Phase 01 – Equipment Stat Cost Expansion (Aggregation and Diagnostic)
  Author:         ChatGPT + Aumuz Messick
  Version:        1.2
  Created:        2025-10-21
  Description:    Aggregates raw stat data from ACSBV3_01_00A_stat_cost_equipment to produce
                  unweighted summary statistics by stat_type. Compatible with MySQL 8.0.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS ACSBV3_01_00B_statcost_diagnostic;

CREATE TABLE ACSBV3_01_00B_statcost_diagnostic AS
SELECT
    s.stat_type,
    t.stat_name,
    COUNT(*)                             AS occurrences,
    ROUND(AVG(s.stat_value),2)           AS avg_value,
    ROUND(STDDEV_SAMP(s.stat_value),2)   AS stdev_value,
    MIN(s.stat_value)                    AS min_value,
    MAX(s.stat_value)                    AS max_value
FROM ACSBV3_01_00A_stat_cost_equipment AS s
LEFT JOIN (
    SELECT 0 AS stat_type,'ITEM_MOD_MANA' AS stat_name UNION ALL
    SELECT 1,'ITEM_MOD_HEALTH' UNION ALL
    SELECT 3,'ITEM_MOD_AGILITY' UNION ALL
    SELECT 4,'ITEM_MOD_STRENGTH' UNION ALL
    SELECT 5,'ITEM_MOD_INTELLECT' UNION ALL
    SELECT 6,'ITEM_MOD_SPIRIT' UNION ALL
    SELECT 7,'ITEM_MOD_STAMINA' UNION ALL
    SELECT 12,'ITEM_MOD_DEFENSE_SKILL_RATING' UNION ALL
    SELECT 13,'ITEM_MOD_DODGE_RATING' UNION ALL
    SELECT 14,'ITEM_MOD_PARRY_RATING' UNION ALL
    SELECT 15,'ITEM_MOD_BLOCK_RATING' UNION ALL
    SELECT 16,'ITEM_MOD_HIT_MELEE_RATING' UNION ALL
    SELECT 17,'ITEM_MOD_HIT_RANGED_RATING' UNION ALL
    SELECT 18,'ITEM_MOD_HIT_SPELL_RATING' UNION ALL
    SELECT 19,'ITEM_MOD_CRIT_MELEE_RATING' UNION ALL
    SELECT 20,'ITEM_MOD_CRIT_RANGED_RATING' UNION ALL
    SELECT 21,'ITEM_MOD_CRIT_SPELL_RATING' UNION ALL
    SELECT 22,'ITEM_MOD_HIT_TAKEN_MELEE_RATING' UNION ALL
    SELECT 23,'ITEM_MOD_HIT_TAKEN_RANGED_RATING' UNION ALL
    SELECT 24,'ITEM_MOD_HIT_TAKEN_SPELL_RATING' UNION ALL
    SELECT 25,'ITEM_MOD_CRIT_TAKEN_MELEE_RATING' UNION ALL
    SELECT 26,'ITEM_MOD_CRIT_TAKEN_RANGED_RATING' UNION ALL
    SELECT 27,'ITEM_MOD_CRIT_TAKEN_SPELL_RATING' UNION ALL
    SELECT 28,'ITEM_MOD_HASTE_MELEE_RATING' UNION ALL
    SELECT 29,'ITEM_MOD_HASTE_RANGED_RATING' UNION ALL
    SELECT 30,'ITEM_MOD_HASTE_SPELL_RATING' UNION ALL
    SELECT 31,'ITEM_MOD_HIT_RATING' UNION ALL
    SELECT 32,'ITEM_MOD_CRIT_RATING' UNION ALL
    SELECT 33,'ITEM_MOD_HIT_TAKEN_RATING' UNION ALL
    SELECT 34,'ITEM_MOD_CRIT_TAKEN_RATING' UNION ALL
    SELECT 35,'ITEM_MOD_RESILIENCE_RATING' UNION ALL
    SELECT 36,'ITEM_MOD_HASTE_RATING' UNION ALL
    SELECT 37,'ITEM_MOD_EXPERTISE_RATING' UNION ALL
    SELECT 38,'ITEM_MOD_ATTACK_POWER' UNION ALL
    SELECT 39,'ITEM_MOD_RANGED_ATTACK_POWER' UNION ALL
    SELECT 40,'ITEM_MOD_FERAL_ATTACK_POWER' UNION ALL
    SELECT 41,'ITEM_MOD_SPELL_HEALING_DONE' UNION ALL
    SELECT 42,'ITEM_MOD_SPELL_DAMAGE_DONE' UNION ALL
    SELECT 43,'ITEM_MOD_MANA_REGENERATION' UNION ALL
    SELECT 44,'ITEM_MOD_ARMOR_PENETRATION_RATING' UNION ALL
    SELECT 45,'ITEM_MOD_SPELL_POWER' UNION ALL
    SELECT 46,'ITEM_MOD_HEALTH_REGEN' UNION ALL
    SELECT 47,'ITEM_MOD_SPELL_PENETRATION' UNION ALL
    SELECT 48,'ITEM_MOD_BLOCK_VALUE'
) AS t ON s.stat_type = t.stat_type
GROUP BY s.stat_type, t.stat_name
ORDER BY s.stat_type;

-- Verification Queries
SELECT COUNT(*) AS total_rows FROM ACSBV3_01_00B_statcost_diagnostic;

SELECT *
FROM ACSBV3_01_00B_statcost_diagnostic
ORDER BY stat_type;

SELECT stat_name, occurrences
FROM ACSBV3_01_00B_statcost_diagnostic
ORDER BY occurrences DESC
LIMIT 10;

/*============================================================================================
  End of File
============================================================================================*/
