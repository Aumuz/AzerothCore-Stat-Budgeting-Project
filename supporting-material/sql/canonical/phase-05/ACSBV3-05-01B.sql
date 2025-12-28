/*=============================================================================================================================================
  Filename:       ACSBV3-05-01B.sql
  Title:          Create Final Dataset Table.
  Author:         Aumuz Messick
  Version:        1.2
  Created:        2025-11-30
  Description:    This script creates a final version of the ACSBV3 dataset table.
                  This table combines canonical metadata with ACSBV3 specific fields and calculates each item's
                  actual budget and normalized budget.

-----------------------------------------------------------------------------------------------------------------------------------------------
  Updates:
   - v1.0 -> Script Created.
   - v1.1 -> (2025-12-08) Fixed "RequiredLevelBracket" - FROM: FLOOR ( `RequiredLevel` / 10 ) * 10
                                                             TO: CASE WHEN `RequiredLevel` BETWEEN  1 AND 10 THEN 10 ...
   - v1.2 -> (2025-12-08) Added "slot_group" and "slot_group_desc"

=============================================================================================================================================*/



/*=============================================================================================================================================
  0.1 - Update MYSQL Collation for AzerothCore:
=============================================================================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';



/*=============================================================================================================================================
  0.2 - Set Script Variables:
=============================================================================================================================================*/

SET @SCRIPT  := "0501B",
    @VERSION := "1.2";



/*=============================================================================================================================================
  1. Create Temporary Table: ACSBV3_temp_dataset
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "1. Create Temporary Table: ACSBV3_temp_dataset" );



DROP   TEMPORARY TABLE IF EXISTS ACSBV3_temp_dataset;

CREATE TEMPORARY TABLE           ACSBV3_temp_dataset
(

  /* General Metadata */

     `entry`                INT           NOT NULL,
     `name`                 VARCHAR(255)  NOT NULL,
     `Quality`              TINYINT       NOT NULL,
     `QualityName`          VARCHAR(10)   NOT NULL,
     `ItemLevel`            SMALLINT      NOT NULL,
     `ItemLevelBracket`     SMALLINT      NOT NULL,
     `slot_group`           VARCHAR(25)   NOT NULL,
     `slot_group_desc`      VARCHAR(50)   NOT NULL,
     `slot`                 INT           NOT NULL,
     `slot_name`            VARCHAR(50)   NOT NULL,
     `class`                TINYINT       NOT NULL,
     `class_name`           VARCHAR(10)   NOT NULL,
     `subclass`             TINYINT       NOT NULL,
     `subclass_name`        VARCHAR(15)   NOT NULL,
     `InventoryType`        TINYINT       NOT NULL,
     `InventoryTypeName`    VARCHAR(20)   NOT NULL,
     `RequiredLevel`        TINYINT       NOT NULL,
     `RequiredLevelBracket` TINYINT       NOT NULL,
     `BuyPrice`             BIGINT        NOT NULL,
     `SellPrice`            BIGINT        NOT NULL,
     `weight`               DOUBLE        NOT NULL,
     `drop_environment`     VARCHAR(16)   NOT NULL,
     `source_type`          VARCHAR(16)   NOT NULL,



  /* Stat Metadata */

     `stat_type1`  TINYINT NOT NULL, `stat_value1`  INT NOT NULL, `stat_cost1`  DECIMAL(8,2) NOT NULL, `stat_total1`  DECIMAL(12,5) NOT NULL,
     `stat_type2`  TINYINT NOT NULL, `stat_value2`  INT NOT NULL, `stat_cost2`  DECIMAL(8,2) NOT NULL, `stat_total2`  DECIMAL(12,5) NOT NULL,
     `stat_type3`  TINYINT NOT NULL, `stat_value3`  INT NOT NULL, `stat_cost3`  DECIMAL(8,2) NOT NULL, `stat_total3`  DECIMAL(12,5) NOT NULL,
     `stat_type4`  TINYINT NOT NULL, `stat_value4`  INT NOT NULL, `stat_cost4`  DECIMAL(8,2) NOT NULL, `stat_total4`  DECIMAL(12,5) NOT NULL,
     `stat_type5`  TINYINT NOT NULL, `stat_value5`  INT NOT NULL, `stat_cost5`  DECIMAL(8,2) NOT NULL, `stat_total5`  DECIMAL(12,5) NOT NULL,
     `stat_type6`  TINYINT NOT NULL, `stat_value6`  INT NOT NULL, `stat_cost6`  DECIMAL(8,2) NOT NULL, `stat_total6`  DECIMAL(12,5) NOT NULL,
     `stat_type7`  TINYINT NOT NULL, `stat_value7`  INT NOT NULL, `stat_cost7`  DECIMAL(8,2) NOT NULL, `stat_total7`  DECIMAL(12,5) NOT NULL,
     `stat_type8`  TINYINT NOT NULL, `stat_value8`  INT NOT NULL, `stat_cost8`  DECIMAL(8,2) NOT NULL, `stat_total8`  DECIMAL(12,5) NOT NULL,
     `stat_type9`  TINYINT NOT NULL, `stat_value9`  INT NOT NULL, `stat_cost9`  DECIMAL(8,2) NOT NULL, `stat_total9`  DECIMAL(12,5) NOT NULL,
     `stat_type10` TINYINT NOT NULL, `stat_value10` INT NOT NULL, `stat_cost10` DECIMAL(8,2) NOT NULL, `stat_total10` DECIMAL(12,5) NOT NULL,

     `stat_sum`             DECIMAL(12,5) NOT NULL,

     `dmg_min1`             FLOAT         NOT NULL,
     `dmg_max1`             FLOAT         NOT NULL,
     `delay`                SMALLINT      NOT NULL,
     `DPS`                  DECIMAL(10,5) NOT NULL,
     `armor`                INT           NOT NULL,
     `armorCost`            DECIMAL(10,5) NOT NULL,
     `RandomProperty`       INT           NOT NULL,
     `RandomSuffix`         INT           NOT NULL,
     `socketBonus`          INT           NOT NULL,
     `socketCost`           DECIMAL(10,5) NOT NULL,



  /* Budget Information */

     `budget_actual`        DECIMAL(12,5) NOT NULL,
     `mod_drop`             DECIMAL(8,2)  NOT NULL,
     `mod_misc`             DECIMAL(8,2)  NOT NULL,
     `mod_slot`             DECIMAL(8,2)  NOT NULL,
     `mod_source`           DECIMAL(8,2)  NOT NULL,
     `budget_normalized`    DECIMAL(12,5) NOT NULL,



  /* Curve Information */

     `budget_target_raw`    DECIMAL(12,5) NOT NULL, `budget_diff_raw`  DECIMAL(12,5) NOT NULL, `budget_perc_raw`  DECIMAL(12,5) NOT NULL,
     `budget_target_3pnt`   DECIMAL(12,5) NOT NULL, `budget_diff_3pnt` DECIMAL(12,5) NOT NULL, `budget_perc_3pnt` DECIMAL(12,5) NOT NULL,
     `budget_target_mono`   DECIMAL(12,5) NOT NULL, `budget_diff_mono` DECIMAL(12,5) NOT NULL, `budget_perc_mono` DECIMAL(12,5) NOT NULL

);



SELECT "Temporary Table Created: ACSBV3_temp_dataset" AS ``;



/*=============================================================================================================================================
  2. Populate Temporary Table: ACSBV3_temp_dataset
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "2. Populate Temporary Table: ACSBV3_temp_dataset" );



INSERT INTO ACSBV3_temp_dataset
(

  `entry`, `name`, `Quality`, `ItemLevel`, `class`, `subclass`, `InventoryType`,
  `RequiredLevel`, `BuyPrice`, `SellPrice`, `weight`, `drop_environment`, `source_type`,
  `stat_type1`, `stat_value1`, `stat_type2`, `stat_value2`, `stat_type3`, `stat_value3`, `stat_type4`, `stat_value4`, `stat_type5`,  `stat_value5`,
  `stat_type6`, `stat_value6`, `stat_type7`, `stat_value7`, `stat_type8`, `stat_value8`, `stat_type9`, `stat_value9`, `stat_type10`, `stat_value10`,
  `dmg_min1`, `dmg_max1`, `delay`, `armor`, `RandomProperty`, `RandomSuffix`, `socketBonus`,

  `slot_group`, `slot_group_desc`, `slot`, `slot_name`, `class_name`, `subclass_name`, `InventoryTypeName`, `mod_slot`,

  `stat_cost1`, `stat_total1`, `stat_cost2`, `stat_total2`, `stat_cost3`, `stat_total3`, `stat_cost4`, `stat_total4`, `stat_cost5`,  `stat_total5`,
  `stat_cost6`, `stat_total6`, `stat_cost7`, `stat_total7`, `stat_cost8`, `stat_total8`, `stat_cost9`, `stat_total9`, `stat_cost10`, `stat_total10`,

  `socketCost`, `mod_drop`, `mod_source`,

  `QualityName`, `ItemLevelBracket`, `RequiredLevelBracket`, `DPS`, `armorCost`, `mod_misc`,

  `stat_sum`, `budget_actual`, `budget_normalized`, `budget_target_raw`, `budget_diff_raw`, `budget_perc_raw`,
  `budget_target_3pnt`, `budget_diff_3pnt`, `budget_perc_3pnt`, `budget_target_mono`, `budget_diff_mono`, `budget_perc_mono`

)

SELECT



  /* Direct Copy From ACSBV3_ref_items */

     r.`entry`, r.`name`, r.`Quality`, r.`ItemLevel`, r.`class`, r.`subclass`, r.`InventoryType`,
     r.`RequiredLevel`, r.`BuyPrice`, r.`SellPrice`, r.`weight`, r.`drop_environment`, r.`source_type`,
     r.`stat_type1`, r.`stat_value1`, r.`stat_type2`, r.`stat_value2`, r.`stat_type3`, r.`stat_value3`, r.`stat_type4`, r.`stat_value4`, r.`stat_type5`,  r.`stat_value5`,
     r.`stat_type6`, r.`stat_value6`, r.`stat_type7`, r.`stat_value7`, r.`stat_type8`, r.`stat_value8`, r.`stat_type9`, r.`stat_value9`, r.`stat_type10`, r.`stat_value10`,
     r.`dmg_min1`, r.`dmg_max1`, r.`delay`, r.`armor`, r.`RandomProperty`, r.`RandomSuffix`, r.`socketBonus`,



  /* Direct Copy From ACSBV3_ref_slot */

     slot.`slot_group`, slot.`slot_group_desc`, slot.`slot`, slot.`slot_name`, slot.`class_name`, slot.`subclass_name`, slot.`InventoryTypeName`, slot.`modifier`,



  /* Stat Metadata: stat_cost stat_value */

     COALESCE ( ( SELECT `cost` FROM ACSBV3_ref_cost WHERE `stat_type` = r.`stat_type1` ), 0.00 ) AS `stat_cost1`,  0.00 AS `stat_total1`,
     COALESCE ( ( SELECT `cost` FROM ACSBV3_ref_cost WHERE `stat_type` = r.`stat_type2` ), 0.00 ) AS `stat_cost2`,  0.00 AS `stat_total2`,
     COALESCE ( ( SELECT `cost` FROM ACSBV3_ref_cost WHERE `stat_type` = r.`stat_type3` ), 0.00 ) AS `stat_cost3`,  0.00 AS `stat_total3`,
     COALESCE ( ( SELECT `cost` FROM ACSBV3_ref_cost WHERE `stat_type` = r.`stat_type4` ), 0.00 ) AS `stat_cost4`,  0.00 AS `stat_total4`,
     COALESCE ( ( SELECT `cost` FROM ACSBV3_ref_cost WHERE `stat_type` = r.`stat_type5` ), 0.00 ) AS `stat_cost5`,  0.00 AS `stat_total5`,
     COALESCE ( ( SELECT `cost` FROM ACSBV3_ref_cost WHERE `stat_type` = r.`stat_type6` ), 0.00 ) AS `stat_cost6`,  0.00 AS `stat_total6`,
     COALESCE ( ( SELECT `cost` FROM ACSBV3_ref_cost WHERE `stat_type` = r.`stat_type7` ), 0.00 ) AS `stat_cost7`,  0.00 AS `stat_total7`,
     COALESCE ( ( SELECT `cost` FROM ACSBV3_ref_cost WHERE `stat_type` = r.`stat_type8` ), 0.00 ) AS `stat_cost8`,  0.00 AS `stat_total8`,
     COALESCE ( ( SELECT `cost` FROM ACSBV3_ref_cost WHERE `stat_type` = r.`stat_type9` ), 0.00 ) AS `stat_cost9`,  0.00 AS `stat_total9`,
     COALESCE ( ( SELECT `cost` FROM ACSBV3_ref_cost WHERE `stat_type` = r.`stat_type10`), 0.00 ) AS `stat_cost10`, 0.00 AS `stat_total10`,



  /* Stat Metadata: socketCost */

     COALESCE (socket.`cost`, 0.00) AS `socketCost`,



  /* Budget Information: modifiers */

     COALESCE (d.`modifier`, 0.00) AS `mod_drop`,
     COALESCE (s.`modifier`, 0.00) AS `mod_source`,



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



  /* ACSBV3 Metadata: Brackets */
     FLOOR ( `ItemLevel`     / 10 ) * 10 AS `ItemLevelBracket`,

           ( CASE WHEN `RequiredLevel` BETWEEN  1 AND 10 THEN 10
                  WHEN `RequiredLevel` BETWEEN 11 AND 20 THEN 20
                  WHEN `RequiredLevel` BETWEEN 21 AND 30 THEN 30
                  WHEN `RequiredLevel` BETWEEN 31 AND 40 THEN 40
                  WHEN `RequiredLevel` BETWEEN 41 AND 50 THEN 50
                  WHEN `RequiredLevel` BETWEEN 51 AND 60 THEN 60
                  WHEN `RequiredLevel` BETWEEN 61 AND 70 THEN 70
                  WHEN `RequiredLevel` BETWEEN 71 AND 80 THEN 80 ELSE 0 END  ) AS `RequiredLevelBracket`,



  /* Stat Metadata: DPS */

     CASE
       WHEN r.`dmg_min1` > 0 AND
            r.`dmg_max1` > 0 AND
            r.`delay`    > 0 THEN ( (r.`dmg_min1` + r.`dmg_max1`) / 2 / (r.`delay`/1000) )
       ELSE 0
     END AS `DPS`,



  /* Stat Metadata: armorCost */

     (r.`armor` * 0.20) AS `armorCost`,



  /* Budget Information: mod_misc */

     CASE
       WHEN r.`RandomProperty` > 0
         OR r.`RandomSuffix`   > 0 THEN 0.65
                                   ELSE 1.00
     END AS `mod_misc`,



  /* Placeholder Values */

     0 AS `stat_sum`,
     0 AS `budget_actual`,
     0 AS `budget_normalized`,
     0 AS `budget_target_raw`,
     0 AS `budget_diff_raw`,
     0 AS `budget_perc_raw`,
     0 AS `budget_target_3pnt`,
     0 AS `budget_diff_3pnt`,
     0 AS `budget_perc_3pnt`,
     0 AS `budget_target_mono`,
     0 AS `budget_diff_mono`,
     0 AS `budget_perc_mono`



FROM      ACSBV3_ref_items  AS r
LEFT JOIN ACSBV3_ref_drop   AS d      ON r.`drop_environment` = d.`drop_environment`
LEFT JOIN ACSBV3_ref_source AS s      ON r.`source_type`      = s.`source_type`
LEFT JOIN ACSBV3_ref_socket AS socket ON r.`socketBonus`      = socket.`socketBonus`
LEFT JOIN ACSBV3_ref_slot   AS slot   ON r.`class` = slot.`class` AND r.`subclass` = slot.`subclass` AND r.`InventoryType` = slot.`InventoryType`;



SELECT CONCAT ( "Temporary Table Populated: ", COUNT(*), " items" ) AS `` FROM ACSBV3_temp_dataset;



/*=============================================================================================================================================
  3. Calculate Stat Values: ACSBV3_temp_dataset
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "3. Calculate Stat Values: ACSBV3_temp_dataset" );

UPDATE ACSBV3_temp_dataset
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

UPDATE ACSBV3_temp_dataset
SET `stat_sum` = (   `stat_total1` + `stat_total2` + `stat_total3` + `stat_total4` + `stat_total5`
                   + `stat_total6` + `stat_total7` + `stat_total8` + `stat_total9` + `stat_total10` );

SELECT "Finished Calculating Stat Values: ACSBV3_temp_dataset" AS ``;



/*=============================================================================================================================================
  4. Calculate Actual Budget Values: ACSBV3_temp_dataset
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "4. Calculate Actual Budget Values: ACSBV3_temp_dataset" );

UPDATE ACSBV3_temp_dataset
SET `budget_actual` = (`stat_sum` + `DPS` + `armorCost` + `socketCost`);

SELECT "Finished Calculating Actual Budget Values: ACSBV3_temp_dataset" AS ``;



/*=============================================================================================================================================
  5.0 - ACSBV3 Dataset Verification Check: class_name
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "5.0 - ACSBV3 Dataset Verification Check: class_name" );

SELECT CONCAT ( COUNT(*), " | ", `class_name` ) AS ``
FROM ACSBV3_temp_dataset
GROUP BY `class_name`
ORDER BY `class_name`;



/*=============================================================================================================================================
  5.1 - ACSBV3 Dataset Verification Check: subclass_name
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "5.1 - ACSBV3 Dataset Verification Check: subclass_name" );

SELECT CONCAT ( COUNT(*), " | ", `subclass_name` ) AS ``
FROM ACSBV3_temp_dataset
GROUP BY `subclass_name`
ORDER BY `subclass_name`;



/*=============================================================================================================================================
  5.2 - ACSBV3 Dataset Verification Check: InventoryTypeName
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "5.2 - ACSBV3 Dataset Verification Check: InventoryTypeName" );

SELECT CONCAT ( COUNT(*), " | ", `InventoryTypeName` ) AS ``
FROM ACSBV3_temp_dataset
GROUP BY `InventoryTypeName`
ORDER BY `InventoryTypeName`;



/*=============================================================================================================================================
  5.3 - ACSBV3 Dataset Verification Check: slot, slot_name
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "5.3 - ACSBV3 Dataset Verification Check: slot, slot_name" );

SELECT CONCAT ( COUNT(*), " | ", `slot`, " | ", `slot_name` ) AS ``
FROM ACSBV3_temp_dataset
GROUP BY `slot`, `slot_name`
ORDER BY `slot`, `slot_name`;



/*=============================================================================================================================================
  5.4 - ACSBV3 Dataset Verification Check: ItemLevelBracket
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "5.4 - ACSBV3 Dataset Verification Check: ItemLevelBracket" );

SELECT CONCAT ( COUNT(*), " | ", `ItemLevelBracket` ) AS ``
FROM ACSBV3_temp_dataset
GROUP BY `ItemLevelBracket`
ORDER BY `ItemLevelBracket`;



/*=============================================================================================================================================
  5.5 - ACSBV3 Dataset Verification Check: RequiredLevelBracket
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "5.5 - ACSBV3 Dataset Verification Check: RequiredLevelBracket" );

SELECT CONCAT ( COUNT(*), " | ", `RequiredLevelBracket` ) AS ``
FROM ACSBV3_temp_dataset
GROUP BY `RequiredLevelBracket`
ORDER BY `RequiredLevelBracket`;



/*=============================================================================================================================================
  5.6 - ACSBV3 Dataset Verification Check: mod_drop
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "5.6 - ACSBV3 Dataset Verification Check: mod_drop" );

SELECT CONCAT ( COUNT(*), " | ", `drop_environment`, " | ", `mod_drop` ) AS ``
FROM ACSBV3_temp_dataset
GROUP BY `drop_environment`, `mod_drop`
ORDER BY `drop_environment`, `mod_drop`;



/*=============================================================================================================================================
  5.7 - ACSBV3 Dataset Verification Check: mod_misc
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "5.7 - ACSBV3 Dataset Verification Check: mod_misc" );

SELECT CONCAT ( COUNT(*), " | ", `mod_misc` ) AS ``
FROM ACSBV3_temp_dataset
GROUP BY `mod_misc`
ORDER BY `mod_misc`;



/*=============================================================================================================================================
  5.8 - ACSBV3 Dataset Verification Check: mod_slot
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "5.8 - ACSBV3 Dataset Verification Check: mod_slot" );

SELECT CONCAT ( COUNT(*), " | ", `slot`, " | ", `slot_name`, " | ", `mod_slot` ) AS ``
FROM ACSBV3_temp_dataset
GROUP BY `slot`, `slot_name`, `mod_slot`
ORDER BY `slot`, `slot_name`, `mod_slot`;



/*=============================================================================================================================================
  5.9 - ACSBV3 Dataset Verification Check: mod_source
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "5.9 - ACSBV3 Dataset Verification Check: mod_source" );

SELECT CONCAT ( COUNT(*), " | ", `source_type`, " | ", `mod_source` ) AS ``
FROM ACSBV3_temp_dataset
GROUP BY `source_type`, `mod_source`
ORDER BY `source_type`, `mod_source`;



/*=============================================================================================================================================
  6. Remove Low Budget Items: ACSBV3_temp_dataset
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "6. Remove Low Budget Items: ACSBV3_temp_dataset" );



SET @Count := ( SELECT COUNT(*) FROM ACSBV3_temp_dataset );



SELECT CONCAT ( COUNT(*), " Low Budget Items." ) AS ``
FROM ACSBV3_temp_dataset
WHERE `budget_actual` < 0.20;

DELETE
FROM ACSBV3_temp_dataset
WHERE `budget_actual` < 0.20;



SELECT CONCAT ( COUNT(*), " Low DPS Items." ) AS ``
FROM ACSBV3_temp_dataset
WHERE `class` = 2
  AND `DPS`   < 1.00;

DELETE
FROM ACSBV3_temp_dataset
WHERE `class` = 2
  AND `DPS`   < 1.00;



SELECT CONCAT ( ( @Count - COUNT(*) ), " Total Items Removed." ) AS `` FROM ACSBV3_temp_dataset;



/*=============================================================================================================================================
  7. Calculate Normalized Budget Values: ACSBV3_temp_dataset
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "7. Calculate Normalized Budget Values: ACSBV3_temp_dataset" );

UPDATE ACSBV3_temp_dataset
SET `budget_normalized` = ( `budget_actual` / (`mod_drop` * `mod_misc` * `mod_slot` * `mod_source`) );

SELECT "Finished Calculating Normalized Budget Values: ACSBV3_temp_dataset" AS ``;



/*=============================================================================================================================================
  8. Create Final Dataset Table: ACSBV3_ref_dataset
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "8. Create Table: ACSBV3_ref_dataset" );



DROP   TABLE IF EXISTS ACSBV3_ref_dataset;

CREATE TABLE           ACSBV3_ref_dataset
(

  /* General Metadata */

     `entry`                INT           NOT NULL COMMENT "Canonical Metadata: Unique item ID. (matches AzerothCore item_template)",
     `name`                 VARCHAR(255)  NOT NULL COMMENT "Canonical Metadata: Item name.      (matches AzerothCore item_template)",

     `Quality`              TINYINT       NOT NULL COMMENT "Canonical Metadata: 1-5 (Common to Legendary)",
     `QualityName`          VARCHAR(10)   NOT NULL COMMENT "ACSBV3    Metadata: Human readable Quality. (1 = Common, 2 = Uncommon, 3 = Rare, 4 = Epic, 5 = Legendary)",

     `ItemLevel`            SMALLINT      NOT NULL COMMENT "Canonical Metadata: Primary variable used for budget curve generation.",
     `ItemLevelBracket`     SMALLINT      NOT NULL COMMENT "ACSBV3    Metadata: ItemLevel in 10 Level Bracket.",

     `slot_group`           VARCHAR(25)   NOT NULL COMMENT "ACSBV3    Metadata: Slot groups for recommendation charts in Phase 06.",
     `slot_group_desc`      VARCHAR(50)   NOT NULL COMMENT "ACSBV3    Metadata: Description of slot groups for recommendation charts in Phase 06. (lists what items these groups contain)",

     `slot`                 INT           NOT NULL COMMENT "ACSBV3    Metadata: Slot identifier value. (slot = class subclass InventoryType OR CSSII)",
     `slot_name`            VARCHAR(50)   NOT NULL COMMENT "ACSBV3    Metadata: Human readable version of slot.",

     `class`                TINYINT       NOT NULL COMMENT "Canonical Metadata: Critical slot identifier. (2 = Weapon, 4 = Equipment)",
     `class_name`           VARCHAR(10)   NOT NULL COMMENT "ACSBV3    Metadata: Human readable version of class.",

     `subclass`             TINYINT       NOT NULL COMMENT "Canonical Metadata: Critical slot identifier. (WHEN class = 2 THEN Weapon Type    ELSE Armor Type )",
     `subclass_name`        VARCHAR(15)   NOT NULL COMMENT "ACSBV3    Metadata: Human readable version of subclass.",

     `InventoryType`        TINYINT       NOT NULL COMMENT "Canonical Metadata: Critical slot identifier. (WHEN class = 4 THEN Equipment Type ELSE Weapon Hand)",
     `InventoryTypeName`    VARCHAR(20)   NOT NULL COMMENT "ACSBV3    Metadata: Human readable version of InventoryType.",

     `RequiredLevel`        TINYINT       NOT NULL COMMENT "Canonical Metadata: Minimum player level to equip item (used in Phase 05).",
     `RequiredLevelBracket` TINYINT       NOT NULL COMMENT "ACSBV3    Metadata: RequiredLevel in 10 Level Bracket.",

     `BuyPrice`             BIGINT        NOT NULL COMMENT "Canonical Metadata: Vendor buy  price in copper. (used in Phase 07)",
     `SellPrice`            BIGINT        NOT NULL COMMENT "Canonical Metadata: Vendor sell price in copper. (used in Phase 07)",

     `weight`               DOUBLE        NOT NULL COMMENT "ACSBV3    Metadata: Weighted importance base upon encounter frequency. (used in Phase 06)",
     `drop_environment`     VARCHAR(16)   NOT NULL COMMENT "ACSBV3    Metadata: Drop category: Dungeon, Raid, or World.",
     `source_type`          VARCHAR(16)   NOT NULL COMMENT "ACSBV3    Metadata: Origin of item. (ie: Creature, Quest, Vendor)",



  /* Stat Metadata */

     `stat_type1`  TINYINT NOT NULL, `stat_value1`  INT NOT NULL, `stat_cost1`  DECIMAL(8,2) NOT NULL, `stat_total1`  DECIMAL(12,5) NOT NULL,
     `stat_type2`  TINYINT NOT NULL, `stat_value2`  INT NOT NULL, `stat_cost2`  DECIMAL(8,2) NOT NULL, `stat_total2`  DECIMAL(12,5) NOT NULL,
     `stat_type3`  TINYINT NOT NULL, `stat_value3`  INT NOT NULL, `stat_cost3`  DECIMAL(8,2) NOT NULL, `stat_total3`  DECIMAL(12,5) NOT NULL,
     `stat_type4`  TINYINT NOT NULL, `stat_value4`  INT NOT NULL, `stat_cost4`  DECIMAL(8,2) NOT NULL, `stat_total4`  DECIMAL(12,5) NOT NULL,
     `stat_type5`  TINYINT NOT NULL, `stat_value5`  INT NOT NULL, `stat_cost5`  DECIMAL(8,2) NOT NULL, `stat_total5`  DECIMAL(12,5) NOT NULL,
     `stat_type6`  TINYINT NOT NULL, `stat_value6`  INT NOT NULL, `stat_cost6`  DECIMAL(8,2) NOT NULL, `stat_total6`  DECIMAL(12,5) NOT NULL,
     `stat_type7`  TINYINT NOT NULL, `stat_value7`  INT NOT NULL, `stat_cost7`  DECIMAL(8,2) NOT NULL, `stat_total7`  DECIMAL(12,5) NOT NULL,
     `stat_type8`  TINYINT NOT NULL, `stat_value8`  INT NOT NULL, `stat_cost8`  DECIMAL(8,2) NOT NULL, `stat_total8`  DECIMAL(12,5) NOT NULL,
     `stat_type9`  TINYINT NOT NULL, `stat_value9`  INT NOT NULL, `stat_cost9`  DECIMAL(8,2) NOT NULL, `stat_total9`  DECIMAL(12,5) NOT NULL,
     `stat_type10` TINYINT NOT NULL, `stat_value10` INT NOT NULL, `stat_cost10` DECIMAL(8,2) NOT NULL, `stat_total10` DECIMAL(12,5) NOT NULL,

     `stat_sum`             DECIMAL(12,5) NOT NULL COMMENT "ACSBV3 Stat Calculation: Total of all stats multiplied by stat cost. (found in ACSBV3_ref_cost)",

     `dmg_min1`             FLOAT         NOT NULL COMMENT "Canonical Stat Metadata: Weapon minimum damage.        (used to calculate DPS)",
     `dmg_max1`             FLOAT         NOT NULL COMMENT "Canonical Stat Metadata: Weapon maximum damage.        (used to calculate DPS)",
     `delay`                SMALLINT      NOT NULL COMMENT "Canonical Stat Metadata: Weapon delay in milliseconds. (used to calculate DPS)",
     `DPS`                  DECIMAL(10,5) NOT NULL COMMENT "ACSBV3 Stat Calculation: CASE class = 2 THEN = [(dmg_min1 + dmg_max1)/2/(delay/1000)] ELSE = 0.",

     `armor`                INT           NOT NULL COMMENT "Canonical Stat Metadata: Base  armor value used in budget calculations.",
     `armorCost`            DECIMAL(10,5) NOT NULL COMMENT "ACSBV3 Stat Calculation: Final armor value used in budget calculations. (armor * 0.20)",

     `RandomProperty`       INT           NOT NULL COMMENT "Canonical Stat Metadata: Defines if an item uses the item_enchantment_template.",
     `RandomSuffix`         INT           NOT NULL COMMENT "Canonical Stat Metadata: Defines if an item uses the item_enchantment_template suffix.",

     `socketBonus`          INT           NOT NULL COMMENT "Canonical Stat Metadata: Socket bonus ID   (joins to ACSBV3_ref_socket).",
     `socketCost`           DECIMAL(10,5) NOT NULL COMMENT "ACSBV3    Stat Metadata: Socket bonus cost (found in ACSBV3_ref_socket).",



  /* Budget Information */

     `budget_actual`        DECIMAL(12,5) NOT NULL COMMENT "ACSBV3 Stat Calculation: Items actual stat budget. (stat_sum + DPS + armorCost + socketCost)",
     `mod_drop`             DECIMAL(8,2)  NOT NULL COMMENT "ACSBV3 Stat Modifier: Multiplier from ACSBV3_ref_drop.",
     `mod_misc`             DECIMAL(8,2)  NOT NULL COMMENT "ACSBV3 Stat Modifier: CASE RandomProperty OR RandomSuffix != 0 THEN = 0.65 ELSE = 1.00.",
     `mod_slot`             DECIMAL(8,2)  NOT NULL COMMENT "ACSBV3 Stat Modifier: Multiplier from ACSBV3_ref_slot.",
     `mod_source`           DECIMAL(8,2)  NOT NULL COMMENT "ACSBV3 Stat Modifier: Multiplier from ACSBV3_ref_source.",
     `budget_normalized`    DECIMAL(12,5) NOT NULL COMMENT "ACSBV3 Stat Calculation: Items normalized stat budget (budget_actual / (mod_drop * mod_misc * mod_slot * mod_source)).",



  /* Curve Information */

     `budget_target_raw`    DECIMAL(12,5) NOT NULL COMMENT "ACSBV3 Stat Calculation: Raw  Target Budget.",
     `budget_diff_raw`      DECIMAL(12,5) NOT NULL COMMENT "ACSBV3 Stat Calculation: Raw  Target Budget to budget_normalized Budget Difference.",
     `budget_perc_raw`      DECIMAL(12,5) NOT NULL COMMENT "ACSBV3 Stat Calculation: Raw  Target Budget to budget_normalized Budget Difference (as percentage).",

     `budget_target_3pnt`   DECIMAL(12,5) NOT NULL COMMENT "ACSBV3 Stat Calculation: 3pnt Target Budget.",
     `budget_diff_3pnt`     DECIMAL(12,5) NOT NULL COMMENT "ACSBV3 Stat Calculation: 3pnt Target Budget to budget_normalized Budget Difference.",
     `budget_perc_3pnt`     DECIMAL(12,5) NOT NULL COMMENT "ACSBV3 Stat Calculation: 3pnt Target Budget to budget_normalized Budget Difference (as percentage).",

     `budget_target_mono`   DECIMAL(12,5) NOT NULL COMMENT "ACSBV3 Stat Calculation: (Primary Value) Mono Target Budget.",
     `budget_diff_mono`     DECIMAL(12,5) NOT NULL COMMENT "ACSBV3 Stat Calculation: (Primary Value) Mono Target Budget to budget_normalized Budget Difference.",
     `budget_perc_mono`     DECIMAL(12,5) NOT NULL COMMENT "ACSBV3 Stat Calculation: (Primary Value) Mono Target Budget to budget_normalized Budget Difference (as percentage)."

);



SELECT "Temporary Table Created: ACSBV3_ref_dataset" AS ``;



/*=============================================================================================================================================
  9. Populate Final Dataset Table: COPY FROM ACSBV3_temp_dataset INTO ACSBV3_ref_dataset
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "9. Populate Final Dataset Table: COPY FROM ACSBV3_temp_dataset INTO ACSBV3_ref_dataset" );

INSERT   INTO ACSBV3_ref_dataset
SELECT * FROM ACSBV3_temp_dataset
ORDER BY `Quality`           ASC,
         `ItemLevel`         ASC,
         `slot_group`        ASC,
         `slot`              ASC,
         `RequiredLevel`     ASC,
         `drop_environment`  ASC,
         `source_type`       ASC,
         `mod_misc`          ASC,
         `budget_normalized` ASC,
         `budget_actual`     ASC,
         `entry`             ASC;

SELECT CONCAT ( "Final Dataset Table Populated: ", COUNT(*), " items" ) AS `` FROM ACSBV3_ref_dataset;



/*=============================================================================================================================================
  10. Verification: ACSBV3_ref_dataset
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "10. Verification: ACSBV3_ref_dataset" );



SELECT

  CONCAT ( LPAD ( `entry`,                 8, " " ), " | ",
           RPAD ( `name`,                 30, " " ), " | ",
           RPAD ( `QualityName`,          10, " " ), " | ",
           LPAD ( `ItemLevelBracket`,      3, " " ), " | ",
           LPAD ( `RequiredLevelBracket`,  2, " " ), " | ",
           LPAD ( `slot`,                  5, " " ), " | ",
           RPAD ( `slot_name`,            50, " " )       ) AS ``

FROM ACSBV3_ref_dataset
ORDER BY RAND()
LIMIT 5;



SELECT

  CONCAT ( LPAD ( `entry`,              8, " " ), " | ",
           RPAD ( `name`,              30, " " ), " | ",
           LPAD ( `budget_actual`,     12, " " ), " | ",
           LPAD ( `mod_drop`,           4, " " ), " | ",
           LPAD ( `mod_misc`,           4, " " ), " | ",
           LPAD ( `mod_slot`,           4, " " ), " | ",
           LPAD ( `mod_source`,         4, " " ), " | ",
           LPAD ( `budget_normalized`, 12, " " )       ) AS ``

FROM ACSBV3_ref_dataset
ORDER BY RAND()
LIMIT 5;



SELECT "" AS ``;

SELECT

  COUNT(*)                  AS `total_rows`,
  COUNT( DISTINCT `entry` ) AS `total_items`,
  AVG(`budget_actual`)      AS `AVG_budget_actual`,
  AVG(`budget_normalized`)  AS `AVG_budget_normalized`

FROM ACSBV3_ref_dataset;



CALL ACSBV3_print_footer ();

/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
