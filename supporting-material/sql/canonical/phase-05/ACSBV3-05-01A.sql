/*=============================================================================================================================================
  Filename:       ACSBV3-05-01A.sql
  Title:          Create Required Reference Tables.
  Author:         Aumuz Messick
  Version:        2.1
  Created:        2025-11-28
  Description:    This script will create all required reference tables for curve calculations.

                  The following tables will be created:

                   - 1. ACSBV3_ref_cost   -> Stat to Cost Table.
                   - 2. ACSBV3_ref_socket -> Socket Cost Table.
                   - 3. ACSBV3_ref_drop   -> Drop Environment Modifier Table.
                   - 4. ACSBV3_ref_source -> Item Source Modifier Table.
                   - 5. ACSBV3_ref_slot   -> Slot Modifier Table (also maps `class`, `subclass`, and `InventoryType` to human readable names).

-----------------------------------------------------------------------------------------------------------------------------------------------
  Notes:

   - Attempted to balance modifiers with a goal between 0.99 and 1.01 during v1.9+. This resulted in unstable numbers. Reverted back to v1.8 numbers.

   - During the failed v1.9+ attempts, it was discovered that most Drop Modifiers and Source Modifiers appear to be 1.00 (excluding conjured items at 0.50).
     Conjured Items only reflect one legendary item. Setting this value to 0.50 pulls the legendary curve off. This value was set to 1.00 to eliminate the modifier.
     These modifiers have been updated to reflect this.

-----------------------------------------------------------------------------------------------------------------------------------------------
  Updates:
   - v1.0 -> Script Created.
   - v1.1 -> (2025-12-02) Updated slot modifiers in ACSBV3_ref_slot.
   - v1.2 -> (2025-12-02) Updated source_type modifiers in ACSBV3_ref_source.
   - v1.3 -> (2025-12-02) Updated drop_environment modifiers in ACSBV3_ref_drop.
   - v1.4 -> (2025-12-02) Updated GoalMin from 0.90 to 0.95.                     (script: ACSBV3-05-02C.sql)
                          Updated GoalMax from 1.10 to 1.05.                     (script: ACSBV3-05-02C.sql)
   - v1.5 -> (2025-12-03) Updated slot modifiers in ACSBV3_ref_slot.
                          Updated source_type modifiers in ACSBV3_ref_source.
   - v1.6 -> (2025-12-03) Updated GoalMin from 0.95 to 0.97.                     (script: ACSBV3-05-02C.sql)
                          Updated GoalMax from 1.05 to 1.03.                     (script: ACSBV3-05-02C.sql)
   - v1.7 -> (2025-12-03) Updated drop_environment modifiers in ACSBV3_ref_drop.
                          Updated source_type modifiers in ACSBV3_ref_source.
                          DID NOT - Updated slot modifiers in ACSBV3_ref_slot.
   - v1.8 -> (2025-12-03) Updated slot modifiers in ACSBV3_ref_slot.

   - v1.9 -> (2025-12-03) Reverted GoalMin from 0.97 to 0.90.                    (script: ACSBV3-05-02C.sql)
                          Reverted GoalMax from 1.03 to 1.10.                    (script: ACSBV3-05-02C.sql)
                          Reverted modifiers to v1.8 values.
                          Updated drop_environment and source_type modifiers.

   - v2.0 -> (2025-12-03) Added mod_misc support to pipeline.                    (script: ACSBV3-05-02B.sql)
   - v2.1 -> (2025-12-08) Added "slot_group" and "slot_group_desc"

=============================================================================================================================================*/



/*=============================================================================================================================================
  0.1 - Update MYSQL Collation for AzerothCore:
=============================================================================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';



/*=============================================================================================================================================
  0.2 - Set Script Variables:
=============================================================================================================================================*/

SET @SCRIPT  := "0501A",
    @VERSION := "2.1";



/*=============================================================================================================================================
  1. Create and Populate Table: ACSBV3_ref_cost
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "1. Create and Populate Table: ACSBV3_ref_cost" );



DROP TABLE IF EXISTS ACSBV3_ref_cost;

CREATE TABLE ACSBV3_ref_cost
(

  `stat_type` INT          NOT NULL PRIMARY KEY COMMENT "stat_type value from item_template (ACSBV3_ref_items OR ACSBV3_ref_dataset).",
  `stat_name` VARCHAR(64)  NOT NULL             COMMENT "Human readable stat_type name.",
  `cost`      DECIMAL(8,2) NOT NULL             COMMENT "Multiply by stat_value to get cost (Normalized to Stamina and DPS = 100%).",
  `role`      VARCHAR(64)  NOT NULL             COMMENT "Notes on in-game role.",
  `notes`     VARCHAR(255) NOT NULL             COMMENT "Notes on in-game usage."

);

INSERT INTO ACSBV3_ref_cost ( `stat_type`, `stat_name`, `cost`, `role`, `notes` ) VALUES
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
( 100, "Other",                             0.00, "UNKNOWN",        "All Other Stats." );



SELECT * FROM ACSBV3_ref_cost;



/*=============================================================================================================================================
  2. Create and Populate Table: ACSBV3_ref_socket
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "2. Create and Populate Table: ACSBV3_ref_socket" );



DROP TABLE IF EXISTS ACSBV3_ref_socket;

CREATE TABLE ACSBV3_ref_socket
(

  `socketBonus`      INT          NOT NULL PRIMARY KEY COMMENT "socketBonus value from item_template (ACSBV3_ref_items OR ACSBV3_ref_dataset).",
  `socketBonus_name` VARCHAR(64)  NOT NULL             COMMENT "Human readable socketBonus name.",
  `cost`             DECIMAL(8,2) NOT NULL             COMMENT "Fixed cost of socketBonus."

);

INSERT INTO ACSBV3_ref_socket ( `socketBonus`, `socketBonus_name`, `cost` ) VALUES
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



SELECT * FROM ACSBV3_ref_socket;



/*=============================================================================================================================================
  3. Create and Populate Table: ACSBV3_ref_drop
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "3. Create and Populate Table: ACSBV3_ref_drop" );



DROP TABLE IF EXISTS ACSBV3_ref_drop;

CREATE TABLE ACSBV3_ref_drop
(

  `drop_environment` VARCHAR(64)  NOT NULL PRIMARY KEY COMMENT "drop_environment value from ACSBV3_ref_items (OR ACSBV3_ref_dataset).",
  `modifier`         DECIMAL(8,2) NOT NULL             COMMENT "Drop Modifier (Normalized to World = 100%)."

);

INSERT INTO ACSBV3_ref_drop ( `drop_environment`, `modifier` ) VALUES

                        -- v1.0  v1.5  v1.8

( "Dungeon", 1.00 ),    -- 1.05  1.05  1.00
( "Raid",    1.00 ),    -- 1.10  1.01  0.96
( "World",   1.00 );    -- 1.00  1.00  1.00  <- DO NOT CHANGE



SELECT * FROM ACSBV3_ref_drop;



/*=============================================================================================================================================
  4. Create and Populate Table: ACSBV3_ref_source
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "4. Create and Populate Table: ACSBV3_ref_source" );



DROP TABLE IF EXISTS ACSBV3_ref_source;

CREATE TABLE ACSBV3_ref_source
(

  `source_type` VARCHAR(64)  NOT NULL PRIMARY KEY COMMENT "source_type value from ACSBV3_ref_items (OR ACSBV3_ref_dataset).",
  `modifier`    DECIMAL(8,2) NOT NULL             COMMENT "Source Modifier (Normalized to Item_Loot = 100%)."

);

INSERT INTO ACSBV3_ref_source ( `source_type`, `modifier` ) VALUES

                           -- v1.2  v1.5  v1.8

( "Conjured",   1.00 ),    -- 0.57  0.53  0.51
( "Crafted",    1.00 ),    -- 0.97  0.97  0.94
( "Creature",   1.00 ),    -- 0.97  0.97  0.97
( "Gameobject", 1.00 ),    -- 1.05  1.05  1.00
( "Item_Loot",  1.00 ),    -- 1.00  1.00  1.00  <- DO NOT CHANGE
( "Quest",      1.00 ),    -- 0.98  0.98  0.98
( "Vendor",     1.00 );    -- 1.06  1.06  1.00



SELECT * FROM ACSBV3_ref_source;



/*=============================================================================================================================================
  5. Create and Populate Table: ACSBV3_ref_slot
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "5. Create and Populate Table: ACSBV3_ref_slot" );



DROP TABLE IF EXISTS ACSBV3_ref_slot;

CREATE TABLE ACSBV3_ref_slot
(

  `slot`              INT          NOT NULL PRIMARY KEY COMMENT "Slot Identifier (Slot = class subclass InventoryType OR CSSII).",
  `slot_name`         VARCHAR(50)  NOT NULL             COMMENT "Human Readable Slot.",

  `class`             TINYINT      NOT NULL             COMMENT "Critical Metadata Identifier: 2 = Weapon, 4 = Equipment.",
  `class_name`        VARCHAR(10)  NOT NULL             COMMENT "Human Readable class.",

  `subclass`          TINYINT      NOT NULL             COMMENT "Critical Metadata Identifier: WHEN class = 2 THEN Weapon Type ELSE Armor Type.",
  `subclass_name`     VARCHAR(15)  NOT NULL             COMMENT "Human Readable subclass.",

  `InventoryType`     TINYINT      NOT NULL             COMMENT "Critical Metadata Identifier: WHEN class = 4 THEN Equipment Type ELSE Weapon Hand.",
  `InventoryTypeName` VARCHAR(20)  NOT NULL             COMMENT "Human Readable InventoryType.",

  `slot_group`        VARCHAR(25)  NOT NULL             COMMENT "Slot groups for recommendation charts in Phase 06.",
  `slot_group_desc`   VARCHAR(50)  NOT NULL             COMMENT "Description of slot groups for recommendation charts in Phase 06. (lists what items these groups contain)",

  `modifier`          DECIMAL(8,2) NOT NULL             COMMENT "Slot Modifier."

);

INSERT INTO ACSBV3_ref_slot ( `class`, `subclass`, `InventoryType`, `slot`, `class_name`, `subclass_name`, `InventoryTypeName`, `slot_name`, `slot_group`, `slot_group_desc`, `modifier` ) VALUES

                                                                                                                                                                                                         -- v1.0  v1.2  v1.5  v1.8

( 2, 00, 13, 20013, "Weapon",    "1H-Axe",        "One-Hand",           "Weapon    | 1H-Axe        | One-Hand          ", "1H-Weapon",      "1H-Axe, 1H-Mace, 1H-Sword, Dagger, Fist-Weapon", 0.80 ),    -- 0.86  0.86  0.86  0.80
( 2, 00, 21, 20021, "Weapon",    "1H-Axe",        "Main-Hand",          "Weapon    | 1H-Axe        | Main-Hand         ", "1H-Weapon",      "1H-Axe, 1H-Mace, 1H-Sword, Dagger, Fist-Weapon", 0.84 ),    -- 0.86  0.97  0.90  0.84
( 2, 00, 22, 20022, "Weapon",    "1H-Axe",        "Off-Hand-Weapon",    "Weapon    | 1H-Axe        | Off-Hand-Weapon   ", "1H-Weapon",      "1H-Axe, 1H-Mace, 1H-Sword, Dagger, Fist-Weapon", 0.70 ),    -- 0.86  0.76  0.76  0.70

( 2, 01, 17, 20117, "Weapon",    "2H-Axe",        "Two-Hand",           "Weapon    | 2H-Axe        | Two-Hand          ", "2H-Weapon",      "2H-Axe, 2H-Mace, 2H-Sword, Polearm",             1.19 ),    -- 1.31  1.31  1.31  1.19

( 2, 02, 15, 20215, "Weapon",    "Bow",           "Ranged-Bow",         "Weapon    | Bow           | Ranged-Bow        ", "Ranged-Weapon",  "Bow, Crossbow, Gun",                             0.71 ),    -- 0.75  0.75  0.75  0.71

( 2, 03, 26, 20326, "Weapon",    "Gun",           "Ranged-Weapon",      "Weapon    | Gun           | Ranged-Weapon     ", "Ranged-Weapon",  "Bow, Crossbow, Gun",                             0.70 ),    -- 0.76  0.76  0.76  0.70

( 2, 04, 13, 20413, "Weapon",    "1H-Mace",       "One-Hand",           "Weapon    | 1H-Mace       | One-Hand          ", "1H-Weapon",      "1H-Axe, 1H-Mace, 1H-Sword, Dagger, Fist-Weapon", 0.79 ),    -- 0.96  0.85  0.85  0.79
( 2, 04, 21, 20421, "Weapon",    "1H-Mace",       "Main-Hand",          "Weapon    | 1H-Mace       | Main-Hand         ", "1H-Weapon",      "1H-Axe, 1H-Mace, 1H-Sword, Dagger, Fist-Weapon", 1.01 ),    -- 0.96  1.09  1.09  1.01
( 2, 04, 22, 20422, "Weapon",    "1H-Mace",       "Off-Hand-Weapon",    "Weapon    | 1H-Mace       | Off-Hand-Weapon   ", "1H-Weapon",      "1H-Axe, 1H-Mace, 1H-Sword, Dagger, Fist-Weapon", 0.71 ),    -- 0.96  0.79  0.79  0.71

( 2, 05, 17, 20517, "Weapon",    "2H-Mace",       "Two-Hand",           "Weapon    | 2H-Mace       | Two-Hand          ", "2H-Weapon",      "2H-Axe, 2H-Mace, 2H-Sword, Polearm",             1.26 ),    -- 1.41  1.41  1.34  1.26

( 2, 06, 17, 20617, "Weapon",    "Polearm",       "Two-Hand",           "Weapon    | Polearm       | Two-Hand          ", "2H-Weapon",      "2H-Axe, 2H-Mace, 2H-Sword, Polearm",             1.23 ),    -- 1.38  1.38  1.31  1.23

( 2, 07, 13, 20713, "Weapon",    "1H-Sword",      "One-Hand",           "Weapon    | 1H-Sword      | One-Hand          ", "1H-Weapon",      "1H-Axe, 1H-Mace, 1H-Sword, Dagger, Fist-Weapon", 0.79 ),    -- 0.94  0.84  0.84  0.79
( 2, 07, 21, 20721, "Weapon",    "1H-Sword",      "Main-Hand",          "Weapon    | 1H-Sword      | Main-Hand         ", "1H-Weapon",      "1H-Axe, 1H-Mace, 1H-Sword, Dagger, Fist-Weapon", 0.96 ),    -- 0.94  1.06  1.06  0.96
( 2, 07, 22, 20722, "Weapon",    "1H-Sword",      "Off-Hand-Weapon",    "Weapon    | 1H-Sword      | Off-Hand-Weapon   ", "1H-Weapon",      "1H-Axe, 1H-Mace, 1H-Sword, Dagger, Fist-Weapon", 0.73 ),    -- 0.94  0.79  0.79  0.73

( 2, 08, 17, 20817, "Weapon",    "2H-Sword",      "Two-Hand",           "Weapon    | 2H-Sword      | Two-Hand          ", "2H-Weapon",      "2H-Axe, 2H-Mace, 2H-Sword, Polearm",             1.20 ),    -- 1.34  1.34  1.34  1.20

( 2, 10, 17, 21017, "Weapon",    "Staff",         "Two-Hand",           "Weapon    | Staff         | Two-Hand          ", "Staff-Weapon",   "Staff",                                          1.39 ),    -- 1.67  1.49  1.49  1.39

( 2, 13, 13, 21313, "Weapon",    "Fist-Weapon",   "One-Hand",           "Weapon    | Fist-Weapon   | One-Hand          ", "1H-Weapon",      "1H-Axe, 1H-Mace, 1H-Sword, Dagger, Fist-Weapon", 0.88 ),    -- 0.82  0.97  0.97  0.88
( 2, 13, 21, 21321, "Weapon",    "Fist-Weapon",   "Main-Hand",          "Weapon    | Fist-Weapon   | Main-Hand         ", "1H-Weapon",      "1H-Axe, 1H-Mace, 1H-Sword, Dagger, Fist-Weapon", 0.73 ),    -- 0.82  0.82  0.77  0.73
( 2, 13, 22, 21322, "Weapon",    "Fist-Weapon",   "Off-Hand-Weapon",    "Weapon    | Fist-Weapon   | Off-Hand-Weapon   ", "1H-Weapon",      "1H-Axe, 1H-Mace, 1H-Sword, Dagger, Fist-Weapon", 0.73 ),    -- 0.82  0.82  0.77  0.73

( 2, 15, 13, 21513, "Weapon",    "Dagger",        "One-Hand",           "Weapon    | Dagger        | One-Hand          ", "1H-Weapon",      "1H-Axe, 1H-Mace, 1H-Sword, Dagger, Fist-Weapon", 0.75 ),    -- 0.97  0.85  0.85  0.75
( 2, 15, 21, 21521, "Weapon",    "Dagger",        "Main-Hand",          "Weapon    | Dagger        | Main-Hand         ", "1H-Weapon",      "1H-Axe, 1H-Mace, 1H-Sword, Dagger, Fist-Weapon", 1.15 ),    -- 0.97  1.27  1.27  1.15
( 2, 15, 22, 21522, "Weapon",    "Dagger",        "Off-Hand-Weapon",    "Weapon    | Dagger        | Off-Hand-Weapon   ", "1H-Weapon",      "1H-Axe, 1H-Mace, 1H-Sword, Dagger, Fist-Weapon", 0.70 ),    -- 0.97  0.77  0.77  0.70

( 2, 16, 25, 21625, "Weapon",    "Thrown",        "Ranged-Thrown",      "Weapon    | Thrown        | Ranged-Thrown     ", "Ranged-Thrown",  "Thrown",                                         0.99 ),    -- 1.00  1.00  1.05  0.99

( 2, 18, 26, 21826, "Weapon",    "Crossbow",      "Ranged-Weapon",      "Weapon    | Crossbow      | Ranged-Weapon     ", "Ranged-Weapon",  "Bow, Crossbow, Gun",                             0.73 ),    -- 0.78  0.78  0.78  0.73

( 2, 19, 26, 21926, "Weapon",    "Wand",          "Ranged-Weapon",      "Weapon    | Wand          | Ranged-Weapon     ", "Ranged-Wand",    "Wand",                                           1.12 ),    -- 1.20  1.20  1.20  1.12



                                                                                                                                                                                                         -- v1.0  v1.2  v1.5  v1.8

( 4, 00, 02, 40002, "Equipment", "Miscellaneous", "Neck",               "Equipment | Miscellaneous | Neck              ", "Accessory",      "Finger, Neck, Off-Hand-Equipment",               0.37 ),    -- 1.32  0.41  0.41  0.37
( 4, 00, 11, 40011, "Equipment", "Miscellaneous", "Finger",             "Equipment | Miscellaneous | Finger            ", "Accessory",      "Finger, Neck, Off-Hand-Equipment",               0.36 ),    -- 0.44  0.39  0.39  0.36
( 4, 00, 23, 40023, "Equipment", "Miscellaneous", "Off-Hand-Equipment", "Equipment | Miscellaneous | Off-Hand-Equipment", "Accessory",      "Finger, Neck, Off-Hand-Equipment",               0.32 ),    -- 0.38  0.34  0.34  0.32

( 4, 01, 01, 40101, "Equipment", "Cloth",         "Head",               "Equipment | Cloth         | Head              ", "Moderate-Armor", "Head, Shoulder",                                 0.71 ),    -- 1.32  0.78  0.78  0.71
( 4, 01, 03, 40103, "Equipment", "Cloth",         "Shoulder",           "Equipment | Cloth         | Shoulder          ", "Moderate-Armor", "Head, Shoulder",                                 0.58 ),    -- 1.13  0.64  0.64  0.58
( 4, 01, 05, 40105, "Equipment", "Cloth",         "Chest",              "Equipment | Cloth         | Chest             ", "Major-Armor",    "Chest, Legs, Robe",                              0.59 ),    -- 1.68  0.66  0.66  0.59
( 4, 01, 06, 40106, "Equipment", "Cloth",         "Waist",              "Equipment | Cloth         | Waist             ", "Minor-Armor",    "Feet, Hands, Waist, Wrists",                     0.49 ),    -- 1.00  0.55  0.55  0.49
( 4, 01, 07, 40107, "Equipment", "Cloth",         "Legs",               "Equipment | Cloth         | Legs              ", "Major-Armor",    "Chest, Legs, Robe",                              0.72 ),    -- 1.40  0.80  0.80  0.72
( 4, 01, 08, 40108, "Equipment", "Cloth",         "Feet",               "Equipment | Cloth         | Feet              ", "Minor-Armor",    "Feet, Hands, Waist, Wrists",                     0.53 ),    -- 1.12  0.59  0.59  0.53
( 4, 01, 09, 40109, "Equipment", "Cloth",         "Wrists",             "Equipment | Cloth         | Wrists            ", "Minor-Armor",    "Feet, Hands, Waist, Wrists",                     0.37 ),    -- 0.76  0.41  0.41  0.37
( 4, 01, 10, 40110, "Equipment", "Cloth",         "Hands",              "Equipment | Cloth         | Hands             ", "Minor-Armor",    "Feet, Hands, Waist, Wrists",                     0.53 ),    -- 1.03  0.59  0.59  0.53
( 4, 01, 16, 40116, "Equipment", "Cloth",         "Back",               "Equipment | Cloth         | Back              ", "Back",           "Back",                                           0.41 ),    -- 0.49  0.44  0.44  0.41
( 4, 01, 20, 40120, "Equipment", "Cloth",         "Robe",               "Equipment | Cloth         | Robe              ", "Major-Armor",    "Chest, Legs, Robe",                              0.76 ),    -- 0.99  0.85  0.85  0.76

( 4, 02, 01, 40201, "Equipment", "Leather",       "Head",               "Equipment | Leather       | Head              ", "Moderate-Armor", "Head, Shoulder",                                 0.93 ),    -- 1.32  1.03  1.03  0.93
( 4, 02, 03, 40203, "Equipment", "Leather",       "Shoulder",           "Equipment | Leather       | Shoulder          ", "Moderate-Armor", "Head, Shoulder",                                 0.79 ),    -- 1.13  0.88  0.88  0.79
( 4, 02, 05, 40205, "Equipment", "Leather",       "Chest",              "Equipment | Leather       | Chest             ", "Major-Armor",    "Chest, Legs, Robe",                              1.07 ),    -- 1.68  1.19  1.19  1.07
( 4, 02, 06, 40206, "Equipment", "Leather",       "Waist",              "Equipment | Leather       | Waist             ", "Minor-Armor",    "Feet, Hands, Waist, Wrists",                     0.70 ),    -- 1.00  0.77  0.77  0.70
( 4, 02, 07, 40207, "Equipment", "Leather",       "Legs",               "Equipment | Leather       | Legs              ", "Major-Armor",    "Chest, Legs, Robe",                              0.98 ),    -- 1.40  1.10  1.10  0.98
( 4, 02, 08, 40208, "Equipment", "Leather",       "Feet",               "Equipment | Leather       | Feet              ", "Minor-Armor",    "Feet, Hands, Waist, Wrists",                     0.77 ),    -- 1.12  0.86  0.86  0.77
( 4, 02, 09, 40209, "Equipment", "Leather",       "Wrists",             "Equipment | Leather       | Wrists            ", "Minor-Armor",    "Feet, Hands, Waist, Wrists",                     0.53 ),    -- 0.76  0.59  0.59  0.53
( 4, 02, 10, 40210, "Equipment", "Leather",       "Hands",              "Equipment | Leather       | Hands             ", "Minor-Armor",    "Feet, Hands, Waist, Wrists",                     0.71 ),    -- 1.03  0.80  0.80  0.71
( 4, 02, 20, 40220, "Equipment", "Leather",       "Robe",               "Equipment | Leather       | Robe              ", "Major-Armor",    "Chest, Legs, Robe",                              1.01 ),    -- 0.99  1.11  1.11  1.01

( 4, 03, 01, 40301, "Equipment", "Mail",          "Head",               "Equipment | Mail          | Head              ", "Moderate-Armor", "Head, Shoulder",                                 1.34 ),    -- 1.32  1.32  1.43  1.34
( 4, 03, 03, 40303, "Equipment", "Mail",          "Shoulder",           "Equipment | Mail          | Shoulder          ", "Moderate-Armor", "Head, Shoulder",                                 1.18 ),    -- 1.13  1.31  1.31  1.18
( 4, 03, 05, 40305, "Equipment", "Mail",          "Chest",              "Equipment | Mail          | Chest             ", "Major-Armor",    "Chest, Legs, Robe",                              1.65 ),    -- 1.68  1.68  1.77  1.65
( 4, 03, 06, 40306, "Equipment", "Mail",          "Waist",              "Equipment | Mail          | Waist             ", "Minor-Armor",    "Feet, Hands, Waist, Wrists",                     1.05 ),    -- 1.00  1.16  1.16  1.05
( 4, 03, 07, 40307, "Equipment", "Mail",          "Legs",               "Equipment | Mail          | Legs              ", "Major-Armor",    "Chest, Legs, Robe",                              1.48 ),    -- 1.40  1.65  1.65  1.48
( 4, 03, 08, 40308, "Equipment", "Mail",          "Feet",               "Equipment | Mail          | Feet              ", "Minor-Armor",    "Feet, Hands, Waist, Wrists",                     1.23 ),    -- 1.12  1.31  1.31  1.23
( 4, 03, 09, 40309, "Equipment", "Mail",          "Wrists",             "Equipment | Mail          | Wrists            ", "Minor-Armor",    "Feet, Hands, Waist, Wrists",                     0.82 ),    -- 0.76  0.91  0.91  0.82
( 4, 03, 10, 40310, "Equipment", "Mail",          "Hands",              "Equipment | Mail          | Hands             ", "Minor-Armor",    "Feet, Hands, Waist, Wrists",                     1.09 ),    -- 1.03  1.21  1.21  1.09
( 4, 03, 20, 40320, "Equipment", "Mail",          "Robe",               "Equipment | Mail          | Robe              ", "Major-Armor",    "Chest, Legs, Robe",                              1.40 ),    -- 0.99  1.41  1.41  1.40

( 4, 04, 01, 40401, "Equipment", "Plate",         "Head",               "Equipment | Plate         | Head              ", "Moderate-Armor", "Head, Shoulder",                                 1.85 ),    -- 1.32  1.98  1.98  1.85
( 4, 04, 03, 40403, "Equipment", "Plate",         "Shoulder",           "Equipment | Plate         | Shoulder          ", "Moderate-Armor", "Head, Shoulder",                                 1.60 ),    -- 1.13  1.72  1.72  1.60
( 4, 04, 05, 40405, "Equipment", "Plate",         "Chest",              "Equipment | Plate         | Chest             ", "Major-Armor",    "Chest, Legs, Robe",                              2.13 ),    -- 1.68  2.28  2.28  2.13
( 4, 04, 06, 40406, "Equipment", "Plate",         "Waist",              "Equipment | Plate         | Waist             ", "Minor-Armor",    "Feet, Hands, Waist, Wrists",                     1.43 ),    -- 1.00  1.53  1.53  1.43
( 4, 04, 07, 40407, "Equipment", "Plate",         "Legs",               "Equipment | Plate         | Legs              ", "Major-Armor",    "Chest, Legs, Robe",                              1.95 ),    -- 1.40  2.08  2.08  1.95
( 4, 04, 08, 40408, "Equipment", "Plate",         "Feet",               "Equipment | Plate         | Feet              ", "Minor-Armor",    "Feet, Hands, Waist, Wrists",                     1.67 ),    -- 1.12  1.79  1.79  1.67
( 4, 04, 09, 40409, "Equipment", "Plate",         "Wrists",             "Equipment | Plate         | Wrists            ", "Minor-Armor",    "Feet, Hands, Waist, Wrists",                     1.11 ),    -- 0.76  1.19  1.19  1.11
( 4, 04, 10, 40410, "Equipment", "Plate",         "Hands",              "Equipment | Plate         | Hands             ", "Minor-Armor",    "Feet, Hands, Waist, Wrists",                     1.43 ),    -- 1.03  1.53  1.53  1.43

( 4, 06, 14, 40614, "Equipment", "Shield",        "Shield",             "Equipment | Shield        | Shield            ", "Shield",         "Shield",                                         6.43 );    -- 6.53  7.19  7.19  6.43



SELECT * FROM ACSBV3_ref_slot;



CALL ACSBV3_print_footer ();

/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
