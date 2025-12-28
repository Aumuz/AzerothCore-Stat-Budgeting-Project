/*======================================================================================================================================
  Filename:       ACSBV3-04-00A.sql
  Title:          Create Documentation Ready Tables.
  Author:         Aumuz Messick
  Version:        1.3
  Created:        2025-10-27
  Description:    This script creates "Documentation Ready" tables (ACSBV3_doc_).
                  The following tables will be created:

                   - 1. ACSBV3_doc_cost_equipment     -> Replacing: ACSBV3_ref_statcost_equipment (id: -1 to 45)
                   - 2. ACSBV3_doc_cost_socket        -> Replacing: ACSBV3_ref_statcost_equipment (id: 1597 to 3882)
                   - 3. ACSBV3_doc_cost_weapons       -> Replacing: ACSBV3_ref_statcost_weapons
                   - 4. ACSBV3_doc_mod_drop           -> Replacing: ACSBV3_ref_dropmod
                   - 5. ACSBV3_doc_mod_slot_equipment -> Replacing: ACSBV3_ref_slotmod_equipment
                   - 6. ACSBV3_doc_mod_slot_weapons   -> Replacing: ACSBV3_ref_slotmod_weapons

                  ACSBV3_ref_items will be replaced by ACSBV3_doc_item_template in ACSBV3-04-00B.sql.
----------------------------------------------------------------------------------------------------------------------------------------
  Updates:
   - v1.0 -> Script Created.
   - v1.1 -> (2025-10-31) Slot modifiers harmonized for Equipment family-scale alignment.
                          Reduced accessory variance; retained Shield offset pending further analysis.
   - v1.2 -> (2025-11-01) Costs equalized for equipment and weapons (normalized to weapons).
                          Will combine tables in v2.0.
   - v1.3 -> (2025-11-01) Final Harmonization (2025-10-31)
                          Global mean_norm_ratio ˜ 1.0 ± 0.1 across Equipment & Weapons

======================================================================================================================================*/



/*======================================================================================================================================
  1. Create Table and Populate: ACSBV3_doc_cost_equipment
======================================================================================================================================*/

DROP TABLE IF EXISTS ACSBV3_doc_cost_equipment;

CREATE TABLE ACSBV3_doc_cost_equipment
(

  `stat_type` INT PRIMARY KEY COMMENT "stat_type value from item_template (ACSBV3_ref_items OR ACSBV3_doc_item_template).",
  `stat_name` VARCHAR(64)     COMMENT "Human readable stat_type name.",
  `cost`      DECIMAL(8,2)    COMMENT "Multiply by stat_value to get cost (Normalized to Stamina = 100%).",
  `role`      VARCHAR(64)     COMMENT "Notes on in-game role.",
  `notes`     VARCHAR(255)    COMMENT "Notes on in-game usage."

);

INSERT INTO ACSBV3_doc_cost_equipment ( `stat_type`, `stat_name`, `cost`, `role`, `notes` ) VALUES
(  -1, "Armor",                             0.20, "ANY",            "Scaled Logarithmically (~1 Budget Per 5 Armor)." ),
(   0, "ITEM_MOD_MANA",                     0.00, "NONE",           "Excluded From Stats Budget." ),
(   3, "ITEM_MOD_AGILITY",                  1.10, "PRIMARY DPS",    "Increase Attack Power of Melee and Ranged Weapons." ),
(   4, "ITEM_MOD_STRENGTH",                 0.85, "PRIMARY MELEE",  "Increase Melee Attack Power and Perry Rating." ),
(   5, "ITEM_MOD_INTELLECT",                0.90, "PRIMARY CASTER", "Increase Spell Power and Mana Pool." ),
(   6, "ITEM_MOD_SPIRIT",                   0.80, "ANY",            "Increase Health and Mana Regeneration." ),
(   7, "ITEM_MOD_STAMINA",                  1.00, "ANY",            "Increase Health." ),
(  12, "ITEM_MOD_DEFENSE_SKILL_RATING",     0.80, "TANK",           "Reduce Chance of Being Hit, or Critically Hit. Increase Chance to Block, Dodge, and Perry an Attack." ),
(  13, "ITEM_MOD_DODGE_RATING",             0.85, "TANK",           "Increase Chance to Dodge an Attack." ),
(  14, "ITEM_MOD_PARRY_RATING",             0.25, "TANK",           "Increase Chance to Perry an Attack." ),
(  15, "ITEM_MOD_BLOCK_RATING",             0.55, "TANK",           "Increase Chance to Block an Attack." ),
(  31, "ITEM_MOD_HIT_RATING",               0.85, "DPS",            "Increase Chance of Successful Hit." ),
(  32, "ITEM_MOD_CRIT_RATING",              0.90, "DPS",            "Increase Chance of Critical Hit." ),
(  35, "ITEM_MOD_RESILIENCE_RATING",        0.70, "PVP",            "Reduce PVP Damage Taken." ),
(  36, "ITEM_MOD_HASTE_RATING",             0.90, "DPS",            "Increase Attack Speed. Reduce Cast Time." ),
(  37, "ITEM_MOD_EXPERTISE_RATING",         1.10, "MELEE",          "Reduce Chance of Melee Attack Being Avoided by Target." ),
(  38, "ITEM_MOD_ATTACK_POWER",             0.40, "DPS",            "Increase Base Weapon Damage." ),
(  39, "ITEM_MOD_RANGED_ATTACK_POWER",      0.40, "RANGED",         "Increase Ranged Weapon Damage." ),
(  42, "ITEM_MOD_SPELL_DAMAGE_DONE",        0.45, "CASTER",         "Legacy Stat -> Mirrors Spell Power." ),
(  44, "ITEM_MOD_ARMOR_PENETRATION_RATING", 0.90, "MELEE DPS",      "Increase Amount of Armor Player Attack can Ignore." ),
(  45, "ITEM_MOD_SPELL_POWER",              0.90, "CASTER",         "Increase Effectiveness of Spells." ),
( 100, "Other",                             0.25, "UNKNOWN",        "All Other Stats." );

SELECT * FROM ACSBV3_doc_cost_equipment;



/*======================================================================================================================================
  2. Create Table and Populate: ACSBV3_doc_cost_socket
======================================================================================================================================*/

DROP TABLE IF EXISTS ACSBV3_doc_cost_socket;

CREATE TABLE ACSBV3_doc_cost_socket
(

  `socketBonus`      INT PRIMARY KEY COMMENT "socketBonus value from item_template (ACSBV3_ref_items OR ACSBV3_doc_item_template).",
  `socketBonus_name` VARCHAR(64)     COMMENT "Human readable socketBonus name.",
  `cost`             DECIMAL(8,2)    COMMENT "Fixed cost of socketBonus."

);

INSERT INTO ACSBV3_doc_cost_socket ( `socketBonus`, `socketBonus_name`, `cost` ) VALUES
( 3015, "+2 Strength",               1.00 ),
( 2879, "+3 Strength",               1.50 ),
( 2927, "+4 Strength",               2.00 ),
( 3357, "+6 Strength",               3.00 ),
( 3312, "+8 Strength",               4.00 ),

( 3149, "+2 Agility",                1.25 ),
( 2893, "+3 Agility",                1.87 ),
( 2877, "+4 Agility",                2.50 ),
( 3355, "+6 Agility",                3.75 ),
( 3313, "+8 Agility",                5.00 ),

( 3164, "+3 Stamina",                1.50 ),
( 2895, "+4 Stamina",                2.00 ),
( 2882, "+6 Stamina",                3.00 ),
( 3307, "+9 Stamina",                4.50 ),
( 3766, "+12 Stamina",               6.00 ),

( 3016, "+2 Intellect",              1.02 ),
( 2863, "+3 Intellect",              1.53 ),
( 2869, "+4 Intellect",              2.04 ),
( 3310, "+6 Intellect",              3.06 ),
( 3353, "+8 Intellect",              4.08 ),

( 3097, "+2 Spirit",                 0.85 ),
( 2866, "+3 Spirit",                 1.27 ),
( 2890, "+4 Spirit",                 1.70 ),
( 3311, "+6 Spirit",                 2.55 ),
( 3352, "+8 Spirit",                 3.40 ),

( 3114, "+4 Attack Power",           0.84 ),
( 2973, "+6 Attack Power",           1.26 ),
( 2936, "+8 Attack Power",           1.68 ),
( 3764, "+12 Attack Power",          2.52 ),
( 3877, "+16 Attack Power",          3.36 ),
( 1597, "+32 Attack Power",          6.72 ),

( 3153, "+2 Spell Power",            0.88 ),
( 2974, "+4 Spell Power",            1.76 ),
( 3752, "+5 Spell Power",            2.20 ),
( 3602, "+7 Spell Power",            3.08 ),
( 3753, "+9 Spell Power",            3.96 ),

( 2941, "+2 Hit Rating",             1.00 ),
( 2880, "+3 Hit Rating",             1.50 ),
( 2908, "+4 Hit Rating",             2.00 ),
( 3351, "+6 Hit Rating",             3.00 ),
( 2844, "+8 Hit Rating",             4.00 ),

( 3152, "+2 Critical Strike Rating", 1.00 ),
( 3205, "+3 Critical Strike Rating", 1.50 ),
( 3263, "+4 Critical Strike Rating", 2.00 ),
( 3316, "+6 Critical Strike Rating", 3.00 ),
( 3314, "+8 Critical Strike Rating", 4.00 ),

( 3308, "+4 Haste Rating",           1.80 ),
( 3309, "+6 Haste Rating",           2.70 ),
( 3303, "+8 Haste Rating",           3.60 ),

( 3094, "+4 Expertise Rating",       2.72 ),
( 3362, "+6 Expertise Rating",       4.08 ),
( 3778, "+8 Expertise Rating",       5.44 ),

( 3765, "+4 Armor Penetration",      1.80 ),
( 3880, "+6 Armor Penetration",      2.70 ),
( 3882, "+8 Armor Penetration",      3.60 ),

( 2976, "+2 Defense Rating",         0.84 ),
( 2861, "+3 Defense Rating",         1.26 ),
( 2932, "+4 Defense Rating",         1.68 ),
( 3857, "+6 Defense Rating",         2.52 ),
( 3302, "+8 Defense Rating",         3.36 ),

( 2926, "+2 Dodge Rating",           0.97 ),
( 2876, "+3 Dodge Rating",           1.45 ),
( 2871, "+4 Dodge Rating",           1.94 ),
( 3358, "+6 Dodge Rating",           2.91 ),
( 3304, "+8 Dodge Rating",           3.88 ),

( 2907, "+2 Parry Rating",           0.25 ),
( 2870, "+3 Parry Rating",           0.37 ),
( 3359, "+4 Parry Rating",           0.50 ),
( 3871, "+6 Parry Rating",           0.75 ),
( 3360, "+8 Parry Rating",           1.00 ),

( 3017, "+3 Block Rating",           0.94 ),
( 2972, "+4 Block Rating",           1.26 ),
( 3361, "+6 Block Rating",           1.89 ),

( 2975, "+5 Block Value",            0.62 ),
( 2888, "+6 Block Value",            0.75 ),
( 3363, "+9 Block Value",            1.12 ),

( 2881, "+1 Mana per 5 sec",         0.50 ),
( 2865, "+2 Mana per 5 sec",         1.00 ),
( 2370, "+3 Mana per 5 sec",         1.50 ),
( 2371, "+4 Mana per 5 sec",         2.00 ),
( 2392, "+12 Mana per 5 sec",        6.00 ),

( 2867, "+2 Resilience Rating",      0.70 ),
( 2862, "+3 Resilience Rating",      1.05 ),
( 2878, "+4 Resilience Rating",      1.40 ),
( 3600, "+6 Resilience Rating",      2.10 ),
( 3821, "+8 Resilience Rating",      2.80 );


SELECT * FROM ACSBV3_doc_cost_socket;



/*======================================================================================================================================
  3. Create Table and Populate: ACSBV3_doc_cost_weapons
======================================================================================================================================*/

DROP TABLE IF EXISTS ACSBV3_doc_cost_weapons;

CREATE TABLE ACSBV3_doc_cost_weapons
(

  `stat_type` INT PRIMARY KEY COMMENT "stat_type value from item_template (ACSBV3_ref_items OR ACSBV3_doc_item_template).",
  `stat_name` VARCHAR(64)     COMMENT "Human readable stat_type name.",
  `cost`      DECIMAL(8,2)    COMMENT "Multiply by stat_value to get cost (Normalized to Stamina = 100%).",
  `role`      VARCHAR(64)     COMMENT "Notes on in-game role.",
  `notes`     VARCHAR(255)    COMMENT "Notes on in-game usage."

);

INSERT INTO ACSBV3_doc_cost_weapons ( `stat_type`, `stat_name`, `cost`, `role`, `notes` ) VALUES
(  -1, "DPS",                               1.00, "ANY",            "DPS Baseline (Subclass-Normalized Mean = 1.0)." ),
(   0, "ITEM_MOD_MANA",                     0.00, "NONE",           "Excluded From Stats Budget." ),
(   3, "ITEM_MOD_AGILITY",                  1.10, "PRIMARY DPS",    "Increase Attack Power of Melee and Ranged Weapons." ),
(   4, "ITEM_MOD_STRENGTH",                 0.85, "PRIMARY MELEE",  "Increase Melee Attack Power and Perry Rating." ),
(   5, "ITEM_MOD_INTELLECT",                0.90, "PRIMARY CASTER", "Increase Spell Power and Mana Pool." ),
(   6, "ITEM_MOD_SPIRIT",                   0.80, "ANY",            "Increase Health and Mana Regeneration." ),
(   7, "ITEM_MOD_STAMINA",                  1.00, "ANY",            "Increase Health." ),
(  12, "ITEM_MOD_DEFENSE_SKILL_RATING",     0.80, "TANK",           "Reduce Chance of Being Hit, or Critically Hit. Increase Chance to Block, Dodge, and Perry an Attack." ),
(  13, "ITEM_MOD_DODGE_RATING",             0.85, "TANK",           "Increase Chance to Dodge an Attack." ),
(  14, "ITEM_MOD_PARRY_RATING",             0.25, "TANK",           "Increase Chance to Perry an Attack." ),
(  15, "ITEM_MOD_BLOCK_RATING",             0.55, "TANK",           "Increase Chance to Block an Attack." ),
(  31, "ITEM_MOD_HIT_RATING",               0.85, "DPS",            "Increase Chance of Successful Hit." ),
(  32, "ITEM_MOD_CRIT_RATING",              0.90, "DPS",            "Increase Chance of Critical Hit." ),
(  35, "ITEM_MOD_RESILIENCE_RATING",        0.70, "PVP",            "Reduce PVP Damage Taken." ),
(  36, "ITEM_MOD_HASTE_RATING",             0.90, "DPS",            "Increase Attack Speed. Reduce Cast Time." ),
(  37, "ITEM_MOD_EXPERTISE_RATING",         1.10, "MELEE",          "Reduce Chance of Melee Attack Being Avoided by Target." ),
(  38, "ITEM_MOD_ATTACK_POWER",             0.40, "DPS",            "Increase Base Weapon Damage." ),
(  39, "ITEM_MOD_RANGED_ATTACK_POWER",      0.40, "RANGED",         "Increase Ranged Weapon Damage." ),
(  42, "ITEM_MOD_SPELL_DAMAGE_DONE",        0.45, "CASTER",         "Legacy Stat -> Mirrors Spell Power." ),
(  44, "ITEM_MOD_ARMOR_PENETRATION_RATING", 0.90, "MELEE DPS",      "Increase Amount of Armor Player Attack can Ignore." ),
(  45, "ITEM_MOD_SPELL_POWER",              0.90, "CASTER",         "Increase Effectiveness of Spells." ),
( 100, "Other",                             0.25, "UNKNOWN",        "All Other Stats." );

SELECT * FROM ACSBV3_doc_cost_weapons;



/*======================================================================================================================================
  4. Create Table and Populate: ACSBV3_doc_mod_drop
======================================================================================================================================*/

DROP TABLE IF EXISTS ACSBV3_doc_mod_drop;

CREATE TABLE ACSBV3_doc_mod_drop
(

  `drop_environment` VARCHAR(64)     COMMENT "drop_environment value from ACSBV3_ref_items (OR ACSBV3_doc_item_template).",
  `multiplier`       DECIMAL(8,2)    COMMENT "Drop Multiplier (Normalized to World = 100%)."

);

INSERT INTO ACSBV3_doc_mod_drop ( `drop_environment`, `multiplier` ) VALUES
( "Dungeon", 0.75 ),
( "Raid",    1.25 ),
( "World",   1.00 );

SELECT * FROM ACSBV3_doc_mod_drop;



/*======================================================================================================================================
  5. Create Table and Populate: ACSBV3_doc_mod_slot_equipment
======================================================================================================================================*/

DROP TABLE IF EXISTS ACSBV3_doc_mod_slot_equipment;

CREATE TABLE ACSBV3_doc_mod_slot_equipment
(

  `InventoryType` INT PRIMARY KEY COMMENT "InventoryType value from item_template (ACSBV3_ref_items OR ACSBV3_doc_item_template).",
  `InventoryName` VARCHAR(64)     COMMENT "Human readable InventoryType name.",
  `multiplier`    DECIMAL(8,2)    COMMENT "Slot Multiplier (Normalized to Chest = 100%)."

);

INSERT INTO ACSBV3_doc_mod_slot_equipment ( `InventoryType`, `InventoryName`, `multiplier` ) VALUES
(  1, "Head",             1.21 ),
(  2, "Neck",             0.97 ),
(  3, "Shoulder",         1.09 ),
(  5, "Chest",            1.21 ),
(  6, "Waist",            0.97 ),
(  7, "Legs",             1.21 ),
(  8, "Feet",             0.97 ),
(  9, "Wrists",           0.79 ),
( 10, "Hands",            0.97 ),
( 11, "Finger",           0.97 ),
( 14, "Shield",           4.24 ),
( 16, "Back",             0.91 ),
( 20, "Robe",             1.21 ),
( 23, "Held in Off-Hand", 0.97 );

SELECT * FROM ACSBV3_doc_mod_slot_equipment;



/*======================================================================================================================================
  6. Create Table and Populate: ACSBV3_doc_mod_slot_weapons
======================================================================================================================================*/

DROP TABLE IF EXISTS ACSBV3_doc_mod_slot_weapons;

CREATE TABLE ACSBV3_doc_mod_slot_weapons
(

  `subclass`      INT PRIMARY KEY COMMENT "subclass value from item_template (ACSBV3_ref_items OR ACSBV3_doc_item_template).",
  `subclass_name` VARCHAR(64)     COMMENT "Human readable subclass name.",
  `multiplier`    DECIMAL(8,2)    COMMENT "Slot Multiplier (Normalized to 1H Axe = 100%)."

);

INSERT INTO ACSBV3_doc_mod_slot_weapons ( `subclass`, `subclass_name`, `multiplier` ) VALUES
(  0, "1H Axe",      0.80 ),
(  1, "2H Axe",      1.16 ),
(  2, "Bow",         1.04 ),
(  3, "Gun",         1.04 ),
(  4, "1H Mace",     1.25 ),
(  5, "2H Mace",     0.96 ),
(  6, "Polearm",     0.92 ),
(  7, "1H Sword",    1.32 ),
(  8, "2H Sword",    1.16 ),
( 10, "Staff",       1.36 ),
( 13, "Fist Weapon", 1.12 ),
( 15, "Dagger",      1.00 ),
( 18, "Crossbow",    1.04 ),
( 19, "Wand",        1.20 );

SELECT * FROM ACSBV3_doc_mod_slot_weapons;



/*======================================================================================================================================
  End of File
======================================================================================================================================*/
