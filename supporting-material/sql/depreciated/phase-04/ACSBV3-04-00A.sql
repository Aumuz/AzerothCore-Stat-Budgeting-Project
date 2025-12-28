/*=============================================================================================================================================
  Filename:       ACSBV3-04-00A.sql
  Title:          Create Documentation Ready Tables.
  Author:         Aumuz Messick
  Version:        2.5
  Created:        2025-11-02
  Description:    This script creates "Documentation Ready" tables (ACSBV3_doc_).

                  The following tables will be created:

                   - 1. ACSBV3_doc_cost           -> Replacing: ACSBV3_ref_statcost_equipment (id: -1 to 45), and ACSBV3_ref_statcost_weapons
                   - 2. ACSBV3_doc_socket         -> Replacing: ACSBV3_ref_statcost_equipment (id: 1597 to 3882)
                   - 3. ACSBV3_doc_drop           -> Replacing: ACSBV3_ref_dropmod
                   - 4. ACSBV3_doc_source         -> New to v2.3
                   - 5. ACSBV3_doc_slot_equipment -> Replacing: ACSBV3_ref_slotmod_equipment
                   - 6. ACSBV3_doc_slot_weapons   -> Replacing: ACSBV3_ref_slotmod_weapons
                   - 7. ACSBV3_doc_armor          -> New to v2.5

                  ACSBV3_ref_items will be replaced by ACSBV3_doc_item_template in ACSBV3-04-00B.sql.

-----------------------------------------------------------------------------------------------------------------------------------------------
  Updates:
   - v2.0 -> Script Created (changes from v1.3 noted in script).
   - v2.1 -> (2025-11-09) Added print-out formatting: ACSBV3_print_info.
   - v2.2 -> (2025-11-18) Updated "Other" stat cost to 0 (ACSBV3_doc_cost).
   - v2.3 -> (2025-11-18) Added ACSBV3_doc_source.
                           - Drop Multiplier.
   - v2.4 -> (2025-11-18) Updated Slot Multipliers.
   - v2.5 -> (2025-11-24) Added ACSBV3_doc_armor.
                           - Armor Multiplier.

=============================================================================================================================================*/


SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';


/*=============================================================================================================================================
  0. Create and Populate Print Information Table: ACSBV3_print_info

      - v2.1 -> (2025-11-09) Added print-out formatting feature to script.

=============================================================================================================================================*/

DROP TABLE IF EXISTS ACSBV3_print_info;

CREATE TABLE ACSBV3_print_info
(

  `auto`   INT AUTO_INCREMENT PRIMARY KEY,
  `part`   INT,
  `print`  INT,
  `output` VARCHAR(255),
  `script` VARCHAR(10)

);

INSERT INTO ACSBV3_print_info ( `script`, `part`, `print`, `output` ) VALUES
( "ANY",   1, 0, "                                                                                                                           " ),
( "ANY",   1, 0, "                                                                                                                           " ),
( "ANY",   1, 0, "###########################################################################################################################" ),
( "ANY",   1, 0, "##                                                                                                                       ##" ),

( "ANY",   7, 0, "##                                                                                                                       ##" ),
( "ANY",   7, 0, "###########################################################################################################################" ),
( "ANY",   7, 0, "                                                                                                                           " ),

( "ANY",   8, 0, "                                                                                                                           " ),
( "ANY",   8, 0, "                                                                                                                           " ),

( "ANY",   9, 0, "###########################################################################################################################" ),
( "ANY",   9, 0, "##  END PRINT OUT                                                                                                        ##" ),
( "ANY",   9, 0, "###########################################################################################################################" ),
( "ANY",   9, 0, "                                                                                                                           " ),
( "ANY",   9, 0, "                                                                                                                           " ),
( "ANY",   9, 0, "                                                                                                                           " ),

( "0400A", 2, 1, "##  1. Stat to Cost Table:                                                                                       (v2.4)  ##" ),
( "0400A", 2, 2, "##  2. Socket Cost Table:                                                                                        (v2.4)  ##" ),
( "0400A", 2, 3, "##  3. Drop Modifier Table:                                                                                      (v2.4)  ##" ),
( "0400A", 2, 4, "##  4. Source Modifier Table:                                                                                    (v2.4)  ##" ),
( "0400A", 2, 5, "##  5. Slot Modifier Table: Equipment                                                                            (v2.4)  ##" ),
( "0400A", 2, 6, "##  6. Slot Modifier Table: Weapons                                                                              (v2.4)  ##" ),
( "0400A", 2, 7, "##  7. Armor Multiplier Table:                                                                                   (v2.5)  ##" );



/*=============================================================================================================================================
  1. Create Table and Populate: ACSBV3_doc_cost

      - v2.0 -> This merges the budget costs for equipment and weapons into one chart.
                It was discovered in Phase 04 v1 that slot modifiers and budget costs were inaccurately calculated in Phase 01.
                After recalculating slot budgets, it was found that equipment and weapons use shared budget costs.
      - v2.1 -> (2025-11-09) Added print-out formatting feature to table output.
      - v2.2 -> (2025-11-18) Updated "Other" stat cost to 0.

=============================================================================================================================================*/

DROP TABLE IF EXISTS ACSBV3_doc_cost;

CREATE TABLE ACSBV3_doc_cost
(

  `stat_type` INT PRIMARY KEY COMMENT "stat_type value from item_template (ACSBV3_ref_items OR ACSBV3_doc_item_template).",
  `stat_name` VARCHAR(64)     COMMENT "Human readable stat_type name.",
  `cost`      DECIMAL(8,2)    COMMENT "Multiply by stat_value to get cost (Normalized to Stamina and DPS = 100%).",
  `role`      VARCHAR(64)     COMMENT "Notes on in-game role.",
  `notes`     VARCHAR(255)    COMMENT "Notes on in-game usage."

);

INSERT INTO ACSBV3_doc_cost ( `stat_type`, `stat_name`, `cost`, `role`, `notes` ) VALUES
(  -2, "Armor",                             0.20, "ANY",            "1 Budget Per 5 Armor." ),
(  -1, "DPS",                               1.00, "ANY",            "1 Budget Per 1 DPS." ),
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
( 100, "Other",                             0.00, "UNKNOWN",        "All Other Stats." );    -- 0.25



SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0400A" AND `print` = 1 ) ORDER BY `part`, `auto`;    -- Print Header



SELECT * FROM ACSBV3_doc_cost;    -- Print Table



/*=============================================================================================================================================
  2. Create Table and Populate: ACSBV3_doc_socket

      - v2.0 -> Recalculated new costs. Table renamed to match new standards.
                It was discovered in Phase 04 v1 that slot modifiers and budget costs were inaccurately calculated in Phase 01.
                After recalculating slot budgets, it was found that equipment and weapons use shared budget costs.
      - v2.1 -> (2025-11-09) Added print-out formatting feature to table output.

=============================================================================================================================================*/

DROP TABLE IF EXISTS ACSBV3_doc_socket;

CREATE TABLE ACSBV3_doc_socket
(

  `socketBonus`      INT PRIMARY KEY COMMENT "socketBonus value from item_template (ACSBV3_ref_items OR ACSBV3_doc_item_template).",
  `socketBonus_name` VARCHAR(64)     COMMENT "Human readable socketBonus name.",
  `cost`             DECIMAL(8,2)    COMMENT "Fixed cost of socketBonus."

);

INSERT INTO ACSBV3_doc_socket ( `socketBonus`, `socketBonus_name`, `cost` ) VALUES
( 3015, "+2 Strength",               0.85 ),
( 2879, "+3 Strength",               1.27 ),
( 2927, "+4 Strength",               1.70 ),
( 3357, "+6 Strength",               2.55 ),
( 3312, "+8 Strength",               3.40 ),

( 3149, "+2 Agility",                1.10 ),
( 2893, "+3 Agility",                1.65 ),
( 2877, "+4 Agility",                2.20 ),
( 3355, "+6 Agility",                3.30 ),
( 3313, "+8 Agility",                4.40 ),

( 3164, "+3 Stamina",                1.50 ),
( 2895, "+4 Stamina",                2.00 ),
( 2882, "+6 Stamina",                3.00 ),
( 3307, "+9 Stamina",                4.50 ),
( 3766, "+12 Stamina",               6.00 ),

( 3016, "+2 Intellect",              0.90 ),
( 2863, "+3 Intellect",              1.35 ),
( 2869, "+4 Intellect",              1.80 ),
( 3310, "+6 Intellect",              2.70 ),
( 3353, "+8 Intellect",              3.60 ),

( 3097, "+2 Spirit",                 0.80 ),
( 2866, "+3 Spirit",                 1.20 ),
( 2890, "+4 Spirit",                 1.60 ),
( 3311, "+6 Spirit",                 2.40 ),
( 3352, "+8 Spirit",                 3.20 ),

( 3114, "+4 Attack Power",           0.80 ),
( 2973, "+6 Attack Power",           1.20 ),
( 2936, "+8 Attack Power",           1.60 ),
( 3764, "+12 Attack Power",          2.40 ),
( 3877, "+16 Attack Power",          3.20 ),
( 1597, "+32 Attack Power",          6.40 ),

( 3153, "+2 Spell Power",            0.90 ),
( 2974, "+4 Spell Power",            1.80 ),
( 3752, "+5 Spell Power",            2.25 ),
( 3602, "+7 Spell Power",            3.15 ),
( 3753, "+9 Spell Power",            4.05 ),

( 2941, "+2 Hit Rating",             0.85 ),
( 2880, "+3 Hit Rating",             1.27 ),
( 2908, "+4 Hit Rating",             1.70 ),
( 3351, "+6 Hit Rating",             2.55 ),
( 2844, "+8 Hit Rating",             3.40 ),

( 3152, "+2 Critical Strike Rating", 0.90 ),
( 3205, "+3 Critical Strike Rating", 1.35 ),
( 3263, "+4 Critical Strike Rating", 1.80 ),
( 3316, "+6 Critical Strike Rating", 2.70 ),
( 3314, "+8 Critical Strike Rating", 3.60 ),

( 3308, "+4 Haste Rating",           1.80 ),
( 3309, "+6 Haste Rating",           2.70 ),
( 3303, "+8 Haste Rating",           3.60 ),

( 3094, "+4 Expertise Rating",       2.20 ),
( 3362, "+6 Expertise Rating",       3.30 ),
( 3778, "+8 Expertise Rating",       4.40 ),

( 3765, "+4 Armor Penetration",      1.80 ),
( 3880, "+6 Armor Penetration",      2.70 ),
( 3882, "+8 Armor Penetration",      3.60 ),

( 2976, "+2 Defense Rating",         0.80 ),
( 2861, "+3 Defense Rating",         1.20 ),
( 2932, "+4 Defense Rating",         1.60 ),
( 3857, "+6 Defense Rating",         2.40 ),
( 3302, "+8 Defense Rating",         3.20 ),

( 2926, "+2 Dodge Rating",           0.85 ),
( 2876, "+3 Dodge Rating",           1.27 ),
( 2871, "+4 Dodge Rating",           1.70 ),
( 3358, "+6 Dodge Rating",           2.55 ),
( 3304, "+8 Dodge Rating",           3.40 ),

( 2907, "+2 Parry Rating",           0.25 ),
( 2870, "+3 Parry Rating",           0.37 ),
( 3359, "+4 Parry Rating",           0.50 ),
( 3871, "+6 Parry Rating",           0.75 ),
( 3360, "+8 Parry Rating",           1.00 ),

( 3017, "+3 Block Rating",           0.82 ),
( 2972, "+4 Block Rating",           1.10 ),
( 3361, "+6 Block Rating",           1.65 ),

( 2975, "+5 Block Value",            1.37 ),
( 2888, "+6 Block Value",            1.65 ),
( 3363, "+9 Block Value",            2.47 ),

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



SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0400A" AND `print` = 2 ) ORDER BY `part`, `auto`;    -- Print Header



SELECT * FROM ACSBV3_doc_socket;    -- Print Table



/*=============================================================================================================================================
  3. Create Table and Populate: ACSBV3_doc_drop

      - v2.0 -> Table renamed to match new standards.
      - v2.1 -> (2025-11-09) Added print-out formatting feature to table output.

=============================================================================================================================================*/

DROP TABLE IF EXISTS ACSBV3_doc_drop;

CREATE TABLE ACSBV3_doc_drop
(

  `drop_environment` VARCHAR(64)     COMMENT "drop_environment value from ACSBV3_ref_items (OR ACSBV3_doc_item_template).",
  `multiplier`       DECIMAL(8,2)    COMMENT "Drop Multiplier (Normalized to World = 100%)."

);

INSERT INTO ACSBV3_doc_drop ( `drop_environment`, `multiplier` ) VALUES
( "Dungeon", 1.04 ),    -- 0.75, 1.04
( "Raid",    1.10 ),    -- 1.25, 1.10
( "World",   1.00 );    -- 1.00 -> DO NOT CHANGE



SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0400A" AND `print` = 3 ) ORDER BY `part`, `auto`;    -- Print Header



SELECT * FROM ACSBV3_doc_drop;    -- Print Table



/*=============================================================================================================================================
  4. Create Table and Populate: ACSBV3_doc_source

      - v2.3 -> Table created.

=============================================================================================================================================*/

DROP TABLE IF EXISTS ACSBV3_doc_source;

CREATE TABLE ACSBV3_doc_source
(

  `source_type`    VARCHAR(64)  COMMENT "source_type value from ACSBV3_ref_items (OR ACSBV3_doc_item_template).",
  `multiplier`     DECIMAL(8,2) COMMENT "Source Multiplier (Normalized to Item_Loot = 100%).",
  `ItemLevel_Low`  SMALLINT     COMMENT "Low iLvl to trigger multiplier.",
  `ItemLevel_High` SMALLINT     COMMENT "High iLvl to trigger multiplier."

);

INSERT INTO ACSBV3_doc_source ( `source_type`, `multiplier`, `ItemLevel_Low`, `ItemLevel_High` ) VALUES
( "Conjured",   0.66,   0, 400 ),
( "Crafted",    0.97,   0, 400 ),
( "Creature",   0.97,   0, 400 ),
( "Gameobject", 1.05,   0, 400 ),
( "Item_Loot",  1.00,   0, 400 ),
( "Quest",      0.88,   0, 400 ),
( "Vendor",     1.17,   0, 400 );



SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0400A" AND `print` = 4 ) ORDER BY `part`, `auto`;    -- Print Header



SELECT * FROM ACSBV3_doc_source;    -- Print Table



/*=============================================================================================================================================
  5. Create Table and Populate: ACSBV3_doc_slot_equipment

      - v2.0 -> Table renamed to match new standards.
      - v2.1 -> (2025-11-09) Added print-out formatting feature to table output.
      - v2.4 -> (2025-11-18) Updated Slot Multipliers.

=============================================================================================================================================*/

DROP TABLE IF EXISTS ACSBV3_doc_slot_equipment;

CREATE TABLE ACSBV3_doc_slot_equipment
(

  `InventoryType` INT PRIMARY KEY COMMENT "InventoryType value from item_template (ACSBV3_ref_items OR ACSBV3_doc_item_template).",
  `InventoryName` VARCHAR(64)     COMMENT "Human readable InventoryType name.",
  `multiplier`    DECIMAL(8,2)    COMMENT "Slot Multiplier."

);

INSERT INTO ACSBV3_doc_slot_equipment ( `InventoryType`, `InventoryName`, `multiplier` ) VALUES
(  1, "Head",             1.32 ),    -- 1.21
(  2, "Neck",             0.45 ),    -- 0.97
(  3, "Shoulder",         1.13 ),    -- 1.09
(  5, "Chest",            1.68 ),    -- 1.21
(  6, "Waist",            1.00 ),    -- 0.97
(  7, "Legs",             1.40 ),    -- 1.21
(  8, "Feet",             1.12 ),    -- 0.97
(  9, "Wrists",           0.76 ),    -- 0.79
( 10, "Hands",            1.03 ),    -- 0.97
( 11, "Finger",           0.44 ),    -- 0.97
( 14, "Shield",           6.53 ),    -- 4.24
( 16, "Back",             0.49 ),    -- 0.91
( 20, "Robe",             0.99 ),    -- 1.21
( 23, "Held in Off-Hand", 0.38 );    -- 0.97



SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0400A" AND `print` = 5 ) ORDER BY `part`, `auto`;    -- Print Header



SELECT * FROM ACSBV3_doc_slot_equipment;    -- Print Table



/*=============================================================================================================================================
  6. Create Table and Populate: ACSBV3_doc_slot_weapons

      - v2.0 -> Table renamed to match new standards.
      - v2.1 -> (2025-11-09) Added print-out formatting feature to table output.
      - v2.4 -> (2025-11-18) Updated Slot Multipliers.

=============================================================================================================================================*/

DROP TABLE IF EXISTS ACSBV3_doc_slot_weapons;

CREATE TABLE ACSBV3_doc_slot_weapons
(

  `subclass`      INT PRIMARY KEY COMMENT "subclass value from item_template (ACSBV3_ref_items OR ACSBV3_doc_item_template).",
  `subclass_name` VARCHAR(64)     COMMENT "Human readable subclass name.",
  `multiplier`    DECIMAL(8,2)    COMMENT "Slot Multiplier."

);

INSERT INTO ACSBV3_doc_slot_weapons ( `subclass`, `subclass_name`, `multiplier` ) VALUES
(  0, "1H Axe",      0.86 ),    -- 0.80
(  1, "2H Axe",      1.31 ),    -- 1.16
(  2, "Bow",         0.75 ),    -- 1.04
(  3, "Gun",         0.76 ),    -- 1.04
(  4, "1H Mace",     0.96 ),    -- 1.25
(  5, "2H Mace",     1.41 ),    -- 0.96
(  6, "Polearm",     1.38 ),    -- 0.92
(  7, "1H Sword",    0.94 ),    -- 1.32
(  8, "2H Sword",    1.34 ),    -- 1.16
( 10, "Staff",       1.67 ),    -- 1.36
( 13, "Fist Weapon", 0.82 ),    -- 1.12
( 15, "Dagger",      0.97 ),    -- 1.00
( 16, "Thrown",      1.00 ),    -- 0.80
( 18, "Crossbow",    0.78 ),    -- 1.04
( 19, "Wand",        1.20 );    -- 1.20



SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0400A" AND `print` = 6 ) ORDER BY `part`, `auto`;    -- Print Header



SELECT * FROM ACSBV3_doc_slot_weapons;    -- Print Table



/*=============================================================================================================================================
  7. Armor Multiplier Table: ACSBV3_doc_armor

      - v2.5 -> Table created.

=============================================================================================================================================*/

DROP TABLE IF EXISTS ACSBV3_doc_armor;

CREATE TABLE ACSBV3_doc_armor
(

  `InventoryType` INT PRIMARY KEY COMMENT "InventoryType value from item_template (ACSBV3_ref_items OR ACSBV3_doc_item_template).",
  `InventoryName` VARCHAR(64)     COMMENT "Human readable InventoryType name.",
  `cloth`         DECIMAL(8,2)    COMMENT "Cloth Multiplier.",
  `leather`       DECIMAL(8,2)    COMMENT "Leather Multiplier.",
  `mail`          DECIMAL(8,2)    COMMENT "Mail Multiplier.",
  `plate`         DECIMAL(8,2)    COMMENT "Plate Multiplier."

);

INSERT INTO ACSBV3_doc_armor ( `InventoryType`, `InventoryName`, `cloth`, `leather`, `mail`, `plate` ) VALUES
(  1, "Head",             1.56, 1.32, 1.01, 0.79 ),
(  3, "Shoulder",         1.66, 1.37, 1.03, 0.80 ),
(  5, "Chest",            2.63, 1.53, 1.13, 0.89 ),
(  6, "Waist",            1.57, 1.32, 0.99, 0.75 ),
(  7, "Legs",             1.59, 1.34, 1.02, 0.80 ),
(  8, "Feet",             1.70, 1.38, 1.00, 0.74 ),
(  9, "Wrists",           1.56, 1.32, 0.97, 0.74 ),
( 10, "Hands",            1.56, 1.34, 1.03, 0.80 ),
( 16, "Back",             0.95, 1.00, 1.00, 1.00 ),
( 20, "Robe",             1.09, 0.94, 0.73, 1.00 );



SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0400A" AND `print` = 7 ) ORDER BY `part`, `auto`;    -- Print Header



SELECT * FROM ACSBV3_doc_armor;    -- Print Table



SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` >= 8 ) ORDER BY `part`, `auto`;    -- Print Footer



/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
