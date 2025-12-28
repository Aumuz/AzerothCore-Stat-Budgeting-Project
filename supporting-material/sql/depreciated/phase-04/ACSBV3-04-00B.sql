/*=============================================================================================================================================
  Filename:       ACSBV3-04-00B.sql
  Title:          Create Documentation Ready Item Template.
  Author:         Aumuz Messick
  Version:        2.4
  Created:        2025-11-03
  Description:    This script creates a "Documentation Ready" item_template table (ACSBV3_doc_item_template).
                  This table combines canonical metadata with ACSBV3-specific fields and calculates each item's
                  actual budget and normalized budget.

                  The following tables will be created:

                   - ACSBV3_doc_item_template -> Replacing: ACSBV3_ref_items

                  All tables with the prefix ACSBV3_ref_ are now retired, and will no longer be in use.

-----------------------------------------------------------------------------------------------------------------------------------------------
  Updates:
   - v2.0 -> Script Created.
             This version combines equipment and weapons costs.
             Additional fields have also been added.
             Other changes from v1.0 have been noted in script.
   - v2.1 -> (2025-11-09) Added print-out formatting: ACSBV3_print_info.
   - v2.2 -> (2025-11-18) Skipped to sync version numbers with pipeline.
   - v2.3 -> (2025-11-18) Added `mod_source` support.
   - v2.4 -> (2025-11-18) Added `ItemBracket`.

=============================================================================================================================================*/


SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';


/*=============================================================================================================================================
  0. Update Print Information Table: ACSBV3_print_info

      - v2.1 -> (2025-11-09) Added print-out formatting feature to script.

=============================================================================================================================================*/

DELETE FROM ACSBV3_print_info WHERE `script` = "0400B";

INSERT INTO ACSBV3_print_info ( `script`, `part`, `print`, `output` ) VALUES
( "0400B", 2, 1, "##  Verification: ACSBV3_doc_item_template                                                                       (v2.4)  ##" );



/*=============================================================================================================================================
  1. Create Table: ACSBV3_doc_item_template

      - v2.0 -> Some column names have been changed.
      - v2.3 -> (2025-11-18) Added `mod_source` support.

=============================================================================================================================================*/

SELECT "The script is processing. Please wait..." AS ``;



DROP TABLE IF EXISTS ACSBV3_doc_item_template;

CREATE TABLE ACSBV3_doc_item_template
(

  /* Canonical Metadata */

     `entry`             INT PRIMARY KEY COMMENT "Canonical Metadata: Unique item ID (matches AzerothCore item_template).",
     `name`              VARCHAR(255)    COMMENT "Canonical Metadata: Item name (matches AzerothCore item_template).",
     `class`             TINYINT         COMMENT "Canonical Metadata: Used to find item family (2 = Weapon / 4 = Equipment).",
     `subclass`          TINYINT         COMMENT "Canonical Metadata: Used to find weapon type.",
     `Quality`           TINYINT         COMMENT "Canonical Metadata: 1-5 (Common to Legendary)",
     `BuyPrice`          BIGINT          COMMENT "Canonical Metadata: Vendor buy price in copper (used in Phase 06).",
     `SellPrice`         BIGINT          COMMENT "Canonical Metadata: Vendor sell price in copper (used in Phase 06).",
     `InventoryType`     TINYINT         COMMENT "Canonical Metadata: Used to find equipment slot type.",
     `ItemLevel`         SMALLINT        COMMENT "Canonical Metadata: Primary variable used for budget curve generation.",
     `RequiredLevel`     TINYINT         COMMENT "Canonical Metadata: Minimum player level to equip item (used in Phase 05).",



  /* ACSBV3 Metadata */

     `weight`            DOUBLE          COMMENT "ACSBV3 Metadata: Weighted importance base upon encounter frequency (used in Phase 05).",
     `drop_environment`  VARCHAR(16)     COMMENT "ACSBV3 Metadata: Drop category: Dungeon, Raid, or World.",
     `source_type`       VARCHAR(16)     COMMENT "ACSBV3 Metadata: Origin of item (ie: Creature, Quest, Vendor).",
     `FamilyID`          VARCHAR(16)     COMMENT "ACSBV3 Metadata: Human readable version of class (2 = Weapon / 4 = Equipment).",
     `ArmorID`           VARCHAR(16)     COMMENT "ACSBV3 Metadata: Human readable armor name (Equipment Only subclass).",
     `WeaponID`          VARCHAR(25)     COMMENT "ACSBV3 Metadata: Human readable weapon type (Weapons Only InventoryType).",
     `SlotID`            VARCHAR(16)     COMMENT "ACSBV3 Metadata: Human readable slot (InventoryType for Equipment / subclass for Weapon).",
     `QualityName`       VARCHAR(10)     COMMENT "ACSBV3 Metadata: Human readable quality tier (1 = Common, 2 = Uncommon, 3 = Rare, 4 = Epic, 5 = Legendary).",
     `ItemBracket`       SMALLINT        COMMENT "ACSBV3 Metadata: Item 10 Level Bracket.",



  /* Stat Metadata */

     `stat_type1`  TINYINT, `stat_value1`  INT, `stat_cost1`  DECIMAL(8,2), `stat_total1`  DECIMAL(12,5),
     `stat_type2`  TINYINT, `stat_value2`  INT, `stat_cost2`  DECIMAL(8,2), `stat_total2`  DECIMAL(12,5),
     `stat_type3`  TINYINT, `stat_value3`  INT, `stat_cost3`  DECIMAL(8,2), `stat_total3`  DECIMAL(12,5),
     `stat_type4`  TINYINT, `stat_value4`  INT, `stat_cost4`  DECIMAL(8,2), `stat_total4`  DECIMAL(12,5),
     `stat_type5`  TINYINT, `stat_value5`  INT, `stat_cost5`  DECIMAL(8,2), `stat_total5`  DECIMAL(12,5),
     `stat_type6`  TINYINT, `stat_value6`  INT, `stat_cost6`  DECIMAL(8,2), `stat_total6`  DECIMAL(12,5),
     `stat_type7`  TINYINT, `stat_value7`  INT, `stat_cost7`  DECIMAL(8,2), `stat_total7`  DECIMAL(12,5),
     `stat_type8`  TINYINT, `stat_value8`  INT, `stat_cost8`  DECIMAL(8,2), `stat_total8`  DECIMAL(12,5),
     `stat_type9`  TINYINT, `stat_value9`  INT, `stat_cost9`  DECIMAL(8,2), `stat_total9`  DECIMAL(12,5),
     `stat_type10` TINYINT, `stat_value10` INT, `stat_cost10` DECIMAL(8,2), `stat_total10` DECIMAL(12,5),

     `stat_sum`          DECIMAL(12,5)   COMMENT "ACSBV3 Stat Calculation: Total of all stats multiplied by stat cost (found in ACSBV3_doc_cost).",

     `dmg_min1`          FLOAT           COMMENT "Canonical Stat Metadata: Weapon minimum damage (used to calculate DPS).",
     `dmg_max1`          FLOAT           COMMENT "Canonical Stat Metadata: Weapon maximum damage (used to calculate DPS).",
     `delay`             SMALLINT        COMMENT "Canonical Stat Metadata: Weapon delay in milliseconds (used to calculate DPS).",
     `DPS`               DECIMAL(10,5)   COMMENT "ACSBV3 Stat Calculation: CASE class = 2 THEN = [(dmg_min1 + dmg_max1)/2/(delay/1000)] ELSE = 0.",

     `armor`             INT             COMMENT "Canonical Stat Metadata: Base armor value used in budget calculations.",
     `armorCost`         DECIMAL(10,5)   COMMENT "ACSBV3 Stat Calculation: Final armor value used in budget calculations (armor * 0.20).",

     `RandomProperty`    INT             COMMENT "Canonical Stat Metadata: Defines if an item uses the item_enchantment_template.",
     `RandomSuffix`      INT             COMMENT "Canonical Stat Metadata: Defines if an item uses the item_enchantment_template suffix.",

     `socketBonus`       INT             COMMENT "Canonical Stat Metadata: Socket bonus ID (joins to ACSBV3_doc_socket).",
     `socketCost`        DECIMAL(10,5)   COMMENT "ACSBV3 Stat Metadata: Socket bonus cost (found in ACSBV3_doc_socket).",



  /* Budget Information */

     `budget_actual`     DECIMAL(12,5)   COMMENT "ACSBV3 Stat Calculation: Items actual stat budget (stat_sum + DPS + armorCost + socketCost).",
     `mod_drop`          DECIMAL(8,2)    COMMENT "ACSBV3 Stat Modifier: Multiplier from ACSBV3_doc_drop.",
     `mod_source`        DECIMAL(8,2)    COMMENT "ACSBV3 Stat Modifier: Multiplier from ACSBV3_doc_source.",
     `mod_misc`          DECIMAL(8,2)    COMMENT "ACSBV3 Stat Modifier: CASE RandomProperty OR RandomSuffix != 0 THEN = 0.65 ELSE = 1.00.",
     `mod_slot`          DECIMAL(8,2)    COMMENT "ACSBV3 Stat Modifier: Multiplier from ACSBV3_doc_slot_equipment or ACSBV3_doc_slot_weapons.",
     `mod_armor`         DECIMAL(8,2)    COMMENT "ACSBV3 Stat Modifier: Multiplier from ACSBV3_doc_armor (Equipment Only, otherwise 1).",
     `budget_normalized` DECIMAL(12,5)   COMMENT "ACSBV3 Stat Calculation: Items normalized stat budget (budget_actual / (mod_drop * mod_misc * mod_slot)).",



  /* Curve Information */

     `budget_target1`    DECIMAL(12,5)   COMMENT "ACSBV3 Stat Calculation: Raw  Target Budget.",
     `budget_diff1`      DECIMAL(12,5)   COMMENT "ACSBV3 Stat Calculation: Raw  Target Budget to budget_normalized Budget Difference.",
     `budget_perc1`      DECIMAL(12,5)   COMMENT "ACSBV3 Stat Calculation: Raw  Target Budget to budget_normalized Budget Difference (as percentage).",

     `budget_target2`    DECIMAL(12,5)   COMMENT "ACSBV3 Stat Calculation: 3pnt Target Budget.",
     `budget_diff2`      DECIMAL(12,5)   COMMENT "ACSBV3 Stat Calculation: 3pnt Target Budget to budget_normalized Budget Difference.",
     `budget_perc2`      DECIMAL(12,5)   COMMENT "ACSBV3 Stat Calculation: 3pnt Target Budget to budget_normalized Budget Difference (as percentage).",

     `budget_target3`    DECIMAL(12,5)   COMMENT "ACSBV3 Stat Calculation: (Primary Value) Mono Target Budget.",
     `budget_diff3`      DECIMAL(12,5)   COMMENT "ACSBV3 Stat Calculation: (Primary Value) Mono Target Budget to budget_normalized Budget Difference.",
     `budget_perc3`      DECIMAL(12,5)   COMMENT "ACSBV3 Stat Calculation: (Primary Value) Mono Target Budget to budget_normalized Budget Difference (as percentage)."

);



/*=============================================================================================================================================
  2. Populate Table: ACSBV3_doc_item_template

      - v2.0 -> Some column names have been changed.
      - v2.3 -> (2025-11-18) Added `mod_source` support.

=============================================================================================================================================*/

INSERT INTO ACSBV3_doc_item_template

(

     `entry`, `name`, `class`, `subclass`, `Quality`, `BuyPrice`, `SellPrice`, `InventoryType`, `ItemLevel`, `RequiredLevel`,
     `weight`, `drop_environment`, `source_type`,
     `stat_type1`, `stat_value1`, `stat_type2`, `stat_value2`, `stat_type3`, `stat_value3`, `stat_type4`, `stat_value4`, `stat_type5`,  `stat_value5`,
     `stat_type6`, `stat_value6`, `stat_type7`, `stat_value7`, `stat_type8`, `stat_value8`, `stat_type9`, `stat_value9`, `stat_type10`, `stat_value10`,
     `dmg_min1`, `dmg_max1`, `delay`, `armor`, `RandomProperty`, `RandomSuffix`, `socketBonus`,

     `budget_actual`, `budget_normalized`, `stat_sum`,

     `FamilyID`, `ArmorID`, `WeaponID`, `SlotID`, `QualityName`, `ItemBracket`,
     `stat_cost1`, `stat_total1`, `stat_cost2`, `stat_total2`, `stat_cost3`, `stat_total3`, `stat_cost4`, `stat_total4`, `stat_cost5`,  `stat_total5`,
     `stat_cost6`, `stat_total6`, `stat_cost7`, `stat_total7`, `stat_cost8`, `stat_total8`, `stat_cost9`, `stat_total9`, `stat_cost10`, `stat_total10`,
     `DPS`, `armorCost`, `socketCost`, `mod_drop`, `mod_source`, `mod_misc`, `mod_slot`, `mod_armor`

)

SELECT

  /* Direct Copy From ACSBV3_ref_items */

     r.`entry`, r.`name`, r.`class`, r.`subclass`, r.`Quality`, r.`BuyPrice`, r.`SellPrice`, r.`InventoryType`, r.`ItemLevel`, r.`RequiredLevel`,
     r.`weight`, r.`drop_environment`, r.`source_type`,
     r.`stat_type1`, r.`stat_value1`, r.`stat_type2`, r.`stat_value2`, r.`stat_type3`, r.`stat_value3`, r.`stat_type4`, r.`stat_value4`, r.`stat_type5`, r.`stat_value5`,
     r.`stat_type6`, r.`stat_value6`, r.`stat_type7`, r.`stat_value7`, r.`stat_type8`, r.`stat_value8`, r.`stat_type9`, r.`stat_value9`, r.`stat_type10`, r.`stat_value10`,
     r.`dmg_min1`, r.`dmg_max1`, r.`delay`, r.`armor`, r.`RandomProperty`, r.`RandomSuffix`, r.`socketBonus`,



  /* Placeholder Columns, Used in Step 3 and 4 */

     0.00 AS `budget_actual`,
     0.00 AS `budget_normalized`,
     0.00 AS `stat_sum`,



  /* ACSBV3 Metadata: FamilyID */

     CASE
       WHEN r.`class` = 2 THEN "Weapon"
       WHEN r.`class` = 4 THEN "Equipment"
                          ELSE "Unknown"
     END AS `FamilyID`,



  /* ACSBV3 Metadata: ArmorID */

     CASE
       WHEN r.`class` = 4 AND r.`subclass` =  1 THEN "Cloth"
       WHEN r.`class` = 4 AND r.`subclass` =  2 THEN "Leather"
       WHEN r.`class` = 4 AND r.`subclass` =  3 THEN "Mail"
       WHEN r.`class` = 4 AND r.`subclass` =  4 THEN "Plate"
       WHEN r.`class` = 4 AND r.`subclass` =  6 THEN "Shield"
                                                ELSE "None"
     END AS `ArmorID`,



  /* ACSBV3 Metadata: WeaponID */

     CASE
       WHEN r.`class` = 2 AND r.`InventoryType` =  21 THEN "Main Hand"
       WHEN r.`class` = 2 AND r.`InventoryType` =  22 THEN "Off Hand"
       WHEN r.`class` = 2 AND r.`InventoryType` =  13 THEN "1 Hand"
       WHEN r.`class` = 2 AND r.`InventoryType` =  17 THEN "2 Hand"
       WHEN r.`class` = 2 AND r.`InventoryType` =  15 THEN "Range - Bow"
       WHEN r.`class` = 2 AND r.`InventoryType` =  25 THEN "Range - Thrown"
       WHEN r.`class` = 2 AND r.`InventoryType` =  17 THEN "Range - Wand or Gun"
                                                      ELSE "None"
     END AS `WeaponID`,



  /* ACSBV3 Metadata: SlotID */

     CASE
       WHEN r.`class` = 2 AND r.`subclass`      =  0 THEN "1H Axe"
       WHEN r.`class` = 2 AND r.`subclass`      =  1 THEN "2H Axe"
       WHEN r.`class` = 2 AND r.`subclass`      =  2 THEN "Bow"
       WHEN r.`class` = 2 AND r.`subclass`      =  3 THEN "Gun"
       WHEN r.`class` = 2 AND r.`subclass`      =  4 THEN "1H Mace"
       WHEN r.`class` = 2 AND r.`subclass`      =  5 THEN "2H Mace"
       WHEN r.`class` = 2 AND r.`subclass`      =  6 THEN "Polearm"
       WHEN r.`class` = 2 AND r.`subclass`      =  7 THEN "1H Sword"
       WHEN r.`class` = 2 AND r.`subclass`      =  8 THEN "2H Sword"
       WHEN r.`class` = 2 AND r.`subclass`      = 10 THEN "Staff"
       WHEN r.`class` = 2 AND r.`subclass`      = 13 THEN "Fist Weapon"
       WHEN r.`class` = 2 AND r.`subclass`      = 15 THEN "Dagger"
       WHEN r.`class` = 2 AND r.`subclass`      = 16 THEN "Thrown"
       WHEN r.`class` = 2 AND r.`subclass`      = 18 THEN "Crossbow"
       WHEN r.`class` = 2 AND r.`subclass`      = 19 THEN "Wand"
       WHEN r.`class` = 4 AND r.`InventoryType` =  1 THEN "Head"
       WHEN r.`class` = 4 AND r.`InventoryType` =  2 THEN "Neck"
       WHEN r.`class` = 4 AND r.`InventoryType` =  3 THEN "Shoulder"
       WHEN r.`class` = 4 AND r.`InventoryType` =  5 THEN "Chest"
       WHEN r.`class` = 4 AND r.`InventoryType` =  6 THEN "Waist"
       WHEN r.`class` = 4 AND r.`InventoryType` =  7 THEN "Legs"
       WHEN r.`class` = 4 AND r.`InventoryType` =  8 THEN "Feet"
       WHEN r.`class` = 4 AND r.`InventoryType` =  9 THEN "Wrists"
       WHEN r.`class` = 4 AND r.`InventoryType` = 10 THEN "Hands"
       WHEN r.`class` = 4 AND r.`InventoryType` = 11 THEN "Finger"
       WHEN r.`class` = 4 AND r.`InventoryType` = 14 THEN "Shield"
       WHEN r.`class` = 4 AND r.`InventoryType` = 16 THEN "Back"
       WHEN r.`class` = 4 AND r.`InventoryType` = 20 THEN "Robe"
       WHEN r.`class` = 4 AND r.`InventoryType` = 23 THEN "Off-Hand"
                                                     ELSE "Unknown"
     END AS `SlotID`,



  /* ACSBV3 Metadata: QualityName */

     CASE
       WHEN r.`Quality` = 0 THEN "Poor"
       WHEN r.`Quality` = 1 THEN "Common"
       WHEN r.`Quality` = 2 THEN "Uncommon"
       WHEN r.`Quality` = 3 THEN "Rare"
       WHEN r.`Quality` = 4 THEN "Epic"
       WHEN r.`Quality` = 5 THEN "Legendary"
       WHEN r.`Quality` = 6 THEN "Artifact"
       WHEN r.`Quality` = 7 THEN "Heirloom"
                            ELSE "Unknown"
     END AS `QualityName`,



  /* ACSBV3 Metadata: ItemBracket */

     CASE
       WHEN r.`RequiredLevel` BETWEEN  0 AND 10 THEN 10
       WHEN r.`RequiredLevel` BETWEEN 11 AND 20 THEN 20
       WHEN r.`RequiredLevel` BETWEEN 21 AND 30 THEN 30
       WHEN r.`RequiredLevel` BETWEEN 31 AND 40 THEN 40
       WHEN r.`RequiredLevel` BETWEEN 41 AND 50 THEN 50
       WHEN r.`RequiredLevel` BETWEEN 51 AND 60 THEN 60
       WHEN r.`RequiredLevel` BETWEEN 61 AND 70 THEN 70
       WHEN r.`RequiredLevel` BETWEEN 71 AND 80 THEN 80
     END AS `ItemBracket`,



  /* Stat Metadata: stat_cost stat_value */

     COALESCE ( ( SELECT `cost` FROM ACSBV3_doc_cost WHERE `stat_type` = r.`stat_type1` ), c.`cost` ) AS `stat_cost1`,  0.00 AS `stat_total1`,
     COALESCE ( ( SELECT `cost` FROM ACSBV3_doc_cost WHERE `stat_type` = r.`stat_type2` ), c.`cost` ) AS `stat_cost2`,  0.00 AS `stat_total2`,
     COALESCE ( ( SELECT `cost` FROM ACSBV3_doc_cost WHERE `stat_type` = r.`stat_type3` ), c.`cost` ) AS `stat_cost3`,  0.00 AS `stat_total3`,
     COALESCE ( ( SELECT `cost` FROM ACSBV3_doc_cost WHERE `stat_type` = r.`stat_type4` ), c.`cost` ) AS `stat_cost4`,  0.00 AS `stat_total4`,
     COALESCE ( ( SELECT `cost` FROM ACSBV3_doc_cost WHERE `stat_type` = r.`stat_type5` ), c.`cost` ) AS `stat_cost5`,  0.00 AS `stat_total5`,
     COALESCE ( ( SELECT `cost` FROM ACSBV3_doc_cost WHERE `stat_type` = r.`stat_type6` ), c.`cost` ) AS `stat_cost6`,  0.00 AS `stat_total6`,
     COALESCE ( ( SELECT `cost` FROM ACSBV3_doc_cost WHERE `stat_type` = r.`stat_type7` ), c.`cost` ) AS `stat_cost7`,  0.00 AS `stat_total7`,
     COALESCE ( ( SELECT `cost` FROM ACSBV3_doc_cost WHERE `stat_type` = r.`stat_type8` ), c.`cost` ) AS `stat_cost8`,  0.00 AS `stat_total8`,
     COALESCE ( ( SELECT `cost` FROM ACSBV3_doc_cost WHERE `stat_type` = r.`stat_type9` ), c.`cost` ) AS `stat_cost9`,  0.00 AS `stat_total9`,
     COALESCE ( ( SELECT `cost` FROM ACSBV3_doc_cost WHERE `stat_type` = r.`stat_type10`), c.`cost` ) AS `stat_cost10`, 0.00 AS `stat_total10`,



  /* Stat Metadata: DPS */

     CASE
       WHEN r.`dmg_min1` > 0 AND
            r.`dmg_max1` > 0 AND
            r.`delay`    > 0 THEN ( (r.`dmg_min1` + r.`dmg_max1`) / 2 / (r.`delay`/1000) )
       ELSE 0
     END AS `DPS`,



  /* Stat Metadata: armorCost */

     (r.`armor` * 0.20) AS `armorCost`,



  /* Stat Metadata: socketCost */

     COALESCE (s.`cost`, 0.00) AS `socketCost`,



  /* Budget Information: mod_drop */

     COALESCE (d.`multiplier`, 0.00) AS `mod_drop`,



  /* Budget Information: mod_drop */

     COALESCE (sc.`multiplier`, 1.00) AS `mod_source`,



  /* Budget Information: mod_misc */

     CASE
       WHEN r.`RandomProperty` > 0
         OR r.`RandomSuffix`   > 0 THEN 0.65
                                   ELSE 1.00
     END AS `mod_misc`,



  /* Budget Information: mod_slot */

     CASE
       WHEN r.`class` = 2 THEN w.`multiplier`
       WHEN r.`class` = 4 THEN e.`multiplier`
                          ELSE 0
     END AS `mod_slot`,



  /* Budget Information: mod_armor */

     CASE
       WHEN r.`class` = 4 AND r.`subclass` = 1 THEN a.`cloth`
       WHEN r.`class` = 4 AND r.`subclass` = 2 THEN a.`leather`
       WHEN r.`class` = 4 AND r.`subclass` = 3 THEN a.`mail`
       WHEN r.`class` = 4 AND r.`subclass` = 4 THEN a.`plate`
                                               ELSE 1.00
     END AS `mod_armor`



FROM ACSBV3_ref_items AS r

LEFT JOIN ACSBV3_doc_cost           AS c  ON `stat_type` = 100
LEFT JOIN ACSBV3_doc_drop           AS d  ON r.`drop_environment` =  d.`drop_environment`
LEFT JOIN ACSBV3_doc_source         AS sc ON r.`source_type`      = sc.`source_type`      AND r.`ItemLevel` BETWEEN sc.`ItemLevel_Low` AND sc.`ItemLevel_High`
LEFT JOIN ACSBV3_doc_slot_equipment AS e  ON r.`InventoryType`    =  e.`InventoryType`
LEFT JOIN ACSBV3_doc_slot_weapons   AS w  ON r.`subclass`         =  w.`subclass`
LEFT JOIN ACSBV3_doc_socket         AS s  ON r.`socketBonus`      =  s.`socketBonus`
LEFT JOIN ACSBV3_doc_armor          AS a  ON r.`InventoryType`    =  a.`InventoryType`;



/*=============================================================================================================================================
  3. Calculate Stat Values: ACSBV3_doc_item_template
=============================================================================================================================================*/

UPDATE ACSBV3_doc_item_template
SET `stat_total1`  = COALESCE ( ( `stat_value1`  * `stat_cost1` ), 0.00 ),
    `stat_total2`  = COALESCE ( ( `stat_value2`  * `stat_cost2` ), 0.00 ),
    `stat_total3`  = COALESCE ( ( `stat_value3`  * `stat_cost3` ), 0.00 ),
    `stat_total4`  = COALESCE ( ( `stat_value4`  * `stat_cost4` ), 0.00 ),
    `stat_total5`  = COALESCE ( ( `stat_value5`  * `stat_cost5` ), 0.00 ),
    `stat_total6`  = COALESCE ( ( `stat_value6`  * `stat_cost6` ), 0.00 ),
    `stat_total7`  = COALESCE ( ( `stat_value7`  * `stat_cost7` ), 0.00 ),
    `stat_total8`  = COALESCE ( ( `stat_value8`  * `stat_cost8` ), 0.00 ),
    `stat_total9`  = COALESCE ( ( `stat_value9`  * `stat_cost9` ), 0.00 ),
    `stat_total10` = COALESCE ( ( `stat_value10` * `stat_cost10`), 0.00 );

UPDATE ACSBV3_doc_item_template
SET `stat_sum` = (   `stat_total1` + `stat_total2` + `stat_total3` + `stat_total4` + `stat_total5`
                   + `stat_total6` + `stat_total7` + `stat_total8` + `stat_total9` + `stat_total10`  );



/*=============================================================================================================================================
  4. Calculate Actual Budget Values: ACSBV3_doc_item_template
=============================================================================================================================================*/

UPDATE ACSBV3_doc_item_template
SET `budget_actual` = (`stat_sum` + `DPS` + `armorCost` + `socketCost`);



/*=============================================================================================================================================
  5. Calculate Normalized Budget Values: ACSBV3_doc_item_template
=============================================================================================================================================*/

UPDATE ACSBV3_doc_item_template
SET `budget_normalized` = ( `budget_actual` / (`mod_drop` * `mod_source` * `mod_misc` * `mod_slot` * `mod_armor`) );



/*=============================================================================================================================================
  6. Verification: ACSBV3_doc_item_template
=============================================================================================================================================*/

SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0400B" AND `print` = 1 ) ORDER BY `part`, `auto`;    -- Print Header



SELECT `entry`, `name`, `QualityName`, `FamilyID`, `SlotID`, `stat_sum`, `DPS`, `armorCost`, `socketCost`, `budget_actual`, `mod_drop`, `mod_source`, `mod_misc`, `mod_slot`, `budget_normalized`
FROM ACSBV3_doc_item_template
ORDER BY RAND()
LIMIT 5;    -- Print Sample Output



SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 8 ) ORDER BY `part`, `auto`;    -- Print 3-Line Break



SELECT

  COUNT(*)                 AS `total_rows`,
  AVG(`budget_actual`)     AS `AVG_budget_actual`,
  AVG(`budget_normalized`) AS `AVG_budget_normalized`

FROM ACSBV3_doc_item_template;    -- Print Verification Output



SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` >= 8 ) ORDER BY `part`, `auto`;    -- Print Footer



/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
