/*============================================================================================
  Filename:       ACSBV3-01-00D.sql
  Title:          Phase 01 – Equipment Stat Cost Expansion (Socket Bonus Mapping & Analysis)
  Author:         ChatGPT + Aumuz Messick
  Version:        1.0
  Created:        2025-10-21
  Description:    Maps socketBonus IDs from equipment items to their corresponding stat
                  effects.  Generates an expanded dataset and diagnostic summary of socket
                  bonus frequency and magnitude.
----------------------------------------------------------------------------------------------
  Notes:
   - Draws source data from ACSBV3_01_00C_stat_cost_equipment_ext.
   - Uses static ID?Effect reference table (provided by Aumuz Messick).
   - Produces both detailed and summarized outputs.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

-- -------------------------------------------------------------------------------------------
-- 1.  Drop existing tables (safe to re-run)
-- -------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS ACSBV3_01_00D_socketbonus_map;
DROP TABLE IF EXISTS ACSBV3_01_00D_stat_cost_socketbonus;
DROP TABLE IF EXISTS ACSBV3_01_00D_socketbonus_diagnostic;

-- -------------------------------------------------------------------------------------------
-- 2.  Create socket bonus reference map
-- -------------------------------------------------------------------------------------------
CREATE TABLE ACSBV3_01_00D_socketbonus_map (
    id INT PRIMARY KEY,
    effect VARCHAR(64),
    stat_name VARCHAR(64),
    stat_value INT
);

-- -------------------------------------------------------------------------------------------
-- 3.  Populate socket bonus map (Aumuz Messick reference)
-- -------------------------------------------------------------------------------------------
INSERT INTO ACSBV3_01_00D_socketbonus_map (id,effect,stat_name,stat_value) VALUES
(3015,'+2 Strength','ITEM_MOD_STRENGTH',2),
(2879,'+3 Strength','ITEM_MOD_STRENGTH',3),
(2927,'+4 Strength','ITEM_MOD_STRENGTH',4),
(3357,'+6 Strength','ITEM_MOD_STRENGTH',6),
(3312,'+8 Strength','ITEM_MOD_STRENGTH',8),
(3149,'+2 Agility','ITEM_MOD_AGILITY',2),
(2893,'+3 Agility','ITEM_MOD_AGILITY',3),
(2877,'+4 Agility','ITEM_MOD_AGILITY',4),
(3355,'+6 Agility','ITEM_MOD_AGILITY',6),
(3313,'+8 Agility','ITEM_MOD_AGILITY',8),
(3164,'+3 Stamina','ITEM_MOD_STAMINA',3),
(2895,'+4 Stamina','ITEM_MOD_STAMINA',4),
(2882,'+6 Stamina','ITEM_MOD_STAMINA',6),
(3307,'+9 Stamina','ITEM_MOD_STAMINA',9),
(3766,'+12 Stamina','ITEM_MOD_STAMINA',12),
(3016,'+2 Intellect','ITEM_MOD_INTELLECT',2),
(2863,'+3 Intellect','ITEM_MOD_INTELLECT',3),
(2869,'+4 Intellect','ITEM_MOD_INTELLECT',4),
(3310,'+6 Intellect','ITEM_MOD_INTELLECT',6),
(3353,'+8 Intellect','ITEM_MOD_INTELLECT',8),
(3097,'+2 Spirit','ITEM_MOD_SPIRIT',2),
(2866,'+3 Spirit','ITEM_MOD_SPIRIT',3),
(2890,'+4 Spirit','ITEM_MOD_SPIRIT',4),
(3311,'+6 Spirit','ITEM_MOD_SPIRIT',6),
(3352,'+8 Spirit','ITEM_MOD_SPIRIT',8),
(3114,'+4 Attack Power','ITEM_MOD_ATTACK_POWER',4),
(2973,'+6 Attack Power','ITEM_MOD_ATTACK_POWER',6),
(2936,'+8 Attack Power','ITEM_MOD_ATTACK_POWER',8),
(3764,'+12 Attack Power','ITEM_MOD_ATTACK_POWER',12),
(3877,'+16 Attack Power','ITEM_MOD_ATTACK_POWER',16),
(1597,'+32 Attack Power','ITEM_MOD_ATTACK_POWER',32),
(3153,'+2 Spell Power','ITEM_MOD_SPELL_POWER',2),
(2974,'+4 Spell Power','ITEM_MOD_SPELL_POWER',4),
(3752,'+5 Spell Power','ITEM_MOD_SPELL_POWER',5),
(3602,'+7 Spell Power','ITEM_MOD_SPELL_POWER',7),
(3753,'+9 Spell Power','ITEM_MOD_SPELL_POWER',9),
(2941,'+2 Hit Rating','ITEM_MOD_HIT_RATING',2),
(2880,'+3 Hit Rating','ITEM_MOD_HIT_RATING',3),
(2908,'+4 Hit Rating','ITEM_MOD_HIT_RATING',4),
(3351,'+6 Hit Rating','ITEM_MOD_HIT_RATING',6),
(2844,'+8 Hit Rating','ITEM_MOD_HIT_RATING',8),
(3152,'+2 Critical Strike Rating','ITEM_MOD_CRIT_RATING',2),
(3205,'+3 Critical Strike Rating','ITEM_MOD_CRIT_RATING',3),
(3263,'+4 Critical Strike Rating','ITEM_MOD_CRIT_RATING',4),
(3316,'+6 Critical Strike Rating','ITEM_MOD_CRIT_RATING',6),
(3314,'+8 Critical Strike Rating','ITEM_MOD_CRIT_RATING',8),
(3308,'+4 Haste Rating','ITEM_MOD_HASTE_RATING',4),
(3309,'+6 Haste Rating','ITEM_MOD_HASTE_RATING',6),
(3303,'+8 Haste Rating','ITEM_MOD_HASTE_RATING',8),
(3094,'+4 Expertise Rating','ITEM_MOD_EXPERTISE_RATING',4),
(3362,'+6 Expertise Rating','ITEM_MOD_EXPERTISE_RATING',6),
(3778,'+8 Expertise Rating','ITEM_MOD_EXPERTISE_RATING',8),
(3765,'+4 Armor Penetration','ITEM_MOD_ARMOR_PENETRATION_RATING',4),
(3880,'+6 Armor Penetration','ITEM_MOD_ARMOR_PENETRATION_RATING',6),
(3882,'+8 Armor Penetration','ITEM_MOD_ARMOR_PENETRATION_RATING',8),
(2976,'+2 Defense Rating','ITEM_MOD_DEFENSE_SKILL_RATING',2),
(2861,'+3 Defense Rating','ITEM_MOD_DEFENSE_SKILL_RATING',3),
(2932,'+4 Defense Rating','ITEM_MOD_DEFENSE_SKILL_RATING',4),
(3857,'+6 Defense Rating','ITEM_MOD_DEFENSE_SKILL_RATING',6),
(3302,'+8 Defense Rating','ITEM_MOD_DEFENSE_SKILL_RATING',8),
(2926,'+2 Dodge Rating','ITEM_MOD_DODGE_RATING',2),
(2876,'+3 Dodge Rating','ITEM_MOD_DODGE_RATING',3),
(2871,'+4 Dodge Rating','ITEM_MOD_DODGE_RATING',4),
(3358,'+6 Dodge Rating','ITEM_MOD_DODGE_RATING',6),
(3304,'+8 Dodge Rating','ITEM_MOD_DODGE_RATING',8),
(2907,'+2 Parry Rating','ITEM_MOD_PARRY_RATING',2),
(2870,'+3 Parry Rating','ITEM_MOD_PARRY_RATING',3),
(3359,'+4 Parry Rating','ITEM_MOD_PARRY_RATING',4),
(3871,'+6 Parry Rating','ITEM_MOD_PARRY_RATING',6),
(3360,'+8 Parry Rating','ITEM_MOD_PARRY_RATING',8),
(3017,'+3 Block Rating','ITEM_MOD_BLOCK_RATING',3),
(2972,'+4 Block Rating','ITEM_MOD_BLOCK_RATING',4),
(3361,'+6 Block Rating','ITEM_MOD_BLOCK_RATING',6),
(2975,'+5 Block Value','ITEM_MOD_BLOCK_VALUE',5),
(2888,'+6 Block Value','ITEM_MOD_BLOCK_VALUE',6),
(3363,'+9 Block Value','ITEM_MOD_BLOCK_VALUE',9),
(2881,'+1 Mana per 5 sec','ITEM_MOD_MANA_REGENERATION',1),
(2865,'+2 Mana per 5 sec','ITEM_MOD_MANA_REGENERATION',2),
(2370,'+3 Mana per 5 sec','ITEM_MOD_MANA_REGENERATION',3),
(2371,'+4 Mana per 5 sec','ITEM_MOD_MANA_REGENERATION',4),
(2392,'+12 Mana per 5 sec','ITEM_MOD_MANA_REGENERATION',12),
(2867,'+2 Resilience Rating','ITEM_MOD_RESILIENCE_RATING',2),
(2862,'+3 Resilience Rating','ITEM_MOD_RESILIENCE_RATING',3),
(2878,'+4 Resilience Rating','ITEM_MOD_RESILIENCE_RATING',4),
(3600,'+6 Resilience Rating','ITEM_MOD_RESILIENCE_RATING',6),
(3821,'+8 Resilience Rating','ITEM_MOD_RESILIENCE_RATING',8);

-- -------------------------------------------------------------------------------------------
-- 4.  Join socket bonuses with items
-- -------------------------------------------------------------------------------------------
CREATE TABLE ACSBV3_01_00D_stat_cost_socketbonus AS
SELECT
    i.entry,
    i.name,
    i.ItemLevel,
    i.Quality,
    i.InventoryType,
    i.socketBonus,
    m.stat_name,
    m.stat_value
FROM ACSBV3_01_00C_stat_cost_equipment_ext AS i
JOIN ACSBV3_01_00D_socketbonus_map AS m
  ON i.socketBonus = m.id
WHERE i.has_socket_bonus = 1;

-- -------------------------------------------------------------------------------------------
-- 5.  Diagnostic aggregation
-- -------------------------------------------------------------------------------------------
CREATE TABLE ACSBV3_01_00D_socketbonus_diagnostic AS
SELECT
    stat_name,
    COUNT(*) AS occurrences,
    ROUND(AVG(stat_value),2) AS avg_bonus,
    MIN(stat_value) AS min_bonus,
    MAX(stat_value) AS max_bonus
FROM ACSBV3_01_00D_stat_cost_socketbonus
GROUP BY stat_name
ORDER BY occurrences DESC;

-- -------------------------------------------------------------------------------------------
-- 6.  Verification queries
-- -------------------------------------------------------------------------------------------

-- Confirm total joined records
SELECT COUNT(*) AS total_rows FROM ACSBV3_01_00D_stat_cost_socketbonus;

-- Quick diagnostic summary
SELECT * FROM ACSBV3_01_00D_socketbonus_diagnostic ORDER BY stat_name;

-- Most frequent bonuses
SELECT stat_name, occurrences
FROM ACSBV3_01_00D_socketbonus_diagnostic
ORDER BY occurrences DESC
LIMIT 10;

/*============================================================================================
  End of File
============================================================================================*/
