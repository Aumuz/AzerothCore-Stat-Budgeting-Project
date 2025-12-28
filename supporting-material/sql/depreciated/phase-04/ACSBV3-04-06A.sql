/*=============================================================================================================================================
  Filename:       ACSBV3-04-06A.sql
  Title:          Update Report.
  Author:         Aumuz Messick
  Version:        1.0
  Created:        2025-11-25
  Description:    This script generates a series of reports making suggested updates to corresponding values.

-----------------------------------------------------------------------------------------------------------------------------------------------
  Updates:
   - v1.0 -> Script Created.

=============================================================================================================================================*/



/*=============================================================================================================================================
  0.1 - Update MYSQL Collation for AzerothCore: utf8mb4_general_ci (needed to run procedures).
=============================================================================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';



/*=============================================================================================================================================
  0.2 - Update Print Information Table: ACSBV3_print_info
=============================================================================================================================================*/

DELETE FROM ACSBV3_print_info WHERE `script` = "0406A";

INSERT INTO ACSBV3_print_info ( `script`, `part`, `print`, `output` ) VALUES
( "0406A", 2,  1, "##  1. Global Report:                                                                                            (v1.0)  ##" ),
( "0406A", 2,  2, "##  2. Drop Report:                                                                                              (v1.0)  ##" ),
( "0406A", 2,  3, "##  3. Source Report:                                                                                            (v1.0)  ##" ),
( "0406A", 2,  4, "##  4. Slot Report:                                                                                              (v1.0)  ##" ),
( "0406A", 2,  5, "##  5. Armor Report:                                                                                             (v1.0)  ##" ),
( "0406A", 2,  6, "##  6. Weapon Report:                                                                                            (v1.0)  ##" );



/*=============================================================================================================================================
  1. Global Report:
=============================================================================================================================================*/

SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0406A" AND `print` = 1 ) ORDER BY `part`, `auto`;    -- Print Header



SET @GlobalCount     := ( SELECT COUNT(*) FROM ACSBV3_doc_item_template ),
    @WeaponCount1    := ( SELECT COUNT(*) FROM ACSBV3_doc_item_template WHERE `class` = 2 ),
    @WeaponCount2    := ( SELECT COUNT(*) FROM ACSBV3_doc_item_template WHERE `class` = 2 ),
    @EquipmentCount1 := ( SELECT COUNT(*) FROM ACSBV3_doc_item_template WHERE `class` = 4 ),
    @EquipmentCount2 := ( SELECT COUNT(*) FROM ACSBV3_doc_item_template WHERE `class` = 4 AND `ArmorID` IN ( "Cloth", "Leather", "Mail", "Plate" ) );

SELECT

  CONCAT ( "Global Count: ", COUNT(*), " | Global Average: ", AVG( `budget_normalized` / `budget_target3` ) ) AS ``

FROM ACSBV3_doc_item_template;



/*=============================================================================================================================================
  2. Drop Report:
=============================================================================================================================================*/

SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0406A" AND `print` = 2 ) ORDER BY `part`, `auto`;    -- Print Header



DROP TABLE IF EXISTS ACSBV3_0406A_drop_report;

CREATE TABLE ACSBV3_0406A_drop_report
(

  `count`            INT,

  `drop_environment` VARCHAR(16),

  `Mod_Avg`          DECIMAL(12,5),
  `Mod_Old`          DECIMAL(8,2),
  `Mod_New`          DECIMAL(8,2)

);



INSERT INTO ACSBV3_0406A_drop_report ( `count`, `drop_environment`, `Mod_Old`, `Mod_Avg` )
SELECT

             COUNT(*)  AS            `count`,

  i.`drop_environment` AS `drop_environment`,
  i.`mod_drop`         AS          `Mod_Old`,

  AVG( i.`budget_normalized` / i.`budget_target3` ) AS `Mod_Avg`

FROM ACSBV3_doc_item_template AS i
GROUP BY i.`drop_environment`, i.`mod_drop`;



UPDATE ACSBV3_0406A_drop_report
SET `Mod_New` = ( CASE WHEN `Mod_Avg` BETWEEN 0.99 AND 1.01 THEN `Mod_Old` ELSE ( `Mod_Old` * ( 1 / `Mod_Avg` ) ) END );



SELECT

  CASE WHEN `drop_environment` = "World" THEN CONCAT ( RPAD ( `drop_environment`, 7, " " ), " | ", `Mod_Avg`, " | ", `Mod_Old`, " | No Change" )
                                         ELSE CONCAT ( RPAD ( `drop_environment`, 7, " " ), " | ", `Mod_Avg`, " | ", `Mod_Old`, " | ", ( CASE WHEN `Mod_Old` = `Mod_New` THEN "No Change" ELSE `Mod_New` END ) )
  END AS ``

FROM ACSBV3_0406A_drop_report
ORDER BY `drop_environment` ASC;

SELECT ( CASE WHEN SUM( `count` ) = @GlobalCount THEN " - all items accounted."
              WHEN SUM( `count` ) > @GlobalCount THEN CONCAT ( " ! ", ( SUM( `count` ) - @GlobalCount ), " extra items accounted." )
              WHEN SUM( `count` ) < @GlobalCount THEN CONCAT ( " ! ", ( @GlobalCount - SUM( `count` ) ), " less items accounted."  ) END ) AS `` FROM ACSBV3_0406A_drop_report;



/*=============================================================================================================================================
  3. Source Report:
=============================================================================================================================================*/

SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0406A" AND `print` = 3 ) ORDER BY `part`, `auto`;    -- Print Header



DROP TABLE IF EXISTS ACSBV3_0406A_source_report;

CREATE TABLE ACSBV3_0406A_source_report
(

  `count`       INT,

  `source_type` VARCHAR(16),

  `Mod_Avg`     DECIMAL(12,5),
  `Mod_Old`     DECIMAL(8,2),
  `Mod_New`     DECIMAL(8,2)

);



INSERT INTO ACSBV3_0406A_source_report ( `count`, `source_type`, `Mod_Old`, `Mod_Avg` )
SELECT

        COUNT(*)  AS       `count`,

  i.`source_type` AS `source_type`,
  i.`mod_source`  AS     `Mod_Old`,

  AVG( i.`budget_normalized` / i.`budget_target3` ) AS `Mod_Avg`

FROM ACSBV3_doc_item_template AS i
GROUP BY i.`source_type`, i.`mod_source`;



UPDATE ACSBV3_0406A_source_report
SET `Mod_New` = ( CASE WHEN `Mod_Avg` BETWEEN 0.99 AND 1.01 THEN `Mod_Old` ELSE ( `Mod_Old` * ( 1 / `Mod_Avg` ) ) END );



SELECT

  CONCAT ( RPAD ( `source_type`, 10, " " ), " | ", `Mod_Avg`, " | ", `Mod_Old`, " | ", ( CASE WHEN `Mod_Old` = `Mod_New` THEN "No Change" ELSE `Mod_New` END ) ) AS ``

FROM ACSBV3_0406A_source_report
ORDER BY `source_type` ASC;

SELECT ( CASE WHEN SUM( `count` ) = @GlobalCount THEN " - all items accounted."
              WHEN SUM( `count` ) > @GlobalCount THEN CONCAT ( " ! ", ( SUM( `count` ) - @GlobalCount ), " extra items accounted." )
              WHEN SUM( `count` ) < @GlobalCount THEN CONCAT ( " ! ", ( @GlobalCount - SUM( `count` ) ), " less items accounted."  ) END ) AS `` FROM ACSBV3_0406A_source_report;



/*=============================================================================================================================================
  4. Slot Report:
=============================================================================================================================================*/

SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0406A" AND `print` = 4 ) ORDER BY `part`, `auto`;    -- Print Header



DROP TABLE IF EXISTS ACSBV3_0406A_slot_report;

CREATE TABLE ACSBV3_0406A_slot_report
(

  `count`    INT,

  `FamilyID` VARCHAR(16),
  `SlotID`   VARCHAR(16),

  `Mod_Avg`  DECIMAL(12,5),
  `Mod_Old`  DECIMAL(8,2),
  `Mod_New`  DECIMAL(8,2)

);



INSERT INTO ACSBV3_0406A_slot_report ( `count`, `FamilyID`, `SlotID`, `Mod_Old`, `Mod_Avg` )
SELECT

       COUNT(*)  AS    `count`,

  i.`FamilyID` AS `FamilyID`,
  i.`SlotID`   AS   `SlotID`,
  i.`mod_slot` AS  `Mod_Old`,

  AVG( i.`budget_normalized` / i.`budget_target3` ) AS `Mod_Avg`

FROM ACSBV3_doc_item_template AS i
GROUP BY i.`FamilyID`, i.`SlotID`, i.`mod_slot`;



UPDATE ACSBV3_0406A_slot_report
SET `Mod_New` = ( CASE WHEN `Mod_Avg` BETWEEN 0.99 AND 1.01 THEN `Mod_Old` ELSE ( `Mod_Old` * ( 1 / `Mod_Avg` ) ) END );



SELECT

  CONCAT ( RPAD ( `FamilyID`, 9, " " ), " | ", RPAD ( `SlotID`, 11, " " ), " | ", `Mod_Avg`, " | ", `Mod_Old`, " | ", ( CASE WHEN `Mod_Old` = `Mod_New` THEN "No Change" ELSE `Mod_New` END ) ) AS ``

FROM ACSBV3_0406A_slot_report
ORDER BY `FamilyID` ASC, `SlotID` ASC;

SELECT ( CASE WHEN SUM( `count` ) = @GlobalCount THEN " - all items accounted."
              WHEN SUM( `count` ) > @GlobalCount THEN CONCAT ( " ! ", ( SUM( `count` ) - @GlobalCount ), " extra items accounted." )
              WHEN SUM( `count` ) < @GlobalCount THEN CONCAT ( " ! ", ( @GlobalCount - SUM( `count` ) ), " less items accounted."  ) END ) AS `` FROM ACSBV3_0406A_slot_report;



/*=============================================================================================================================================
  5. Armor Report:
=============================================================================================================================================*/

SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0406A" AND `print` = 5 ) ORDER BY `part`, `auto`;    -- Print Header



SELECT

  CONCAT ( ( CASE WHEN `subclass` = 1 THEN "Cloth  "
                  WHEN `subclass` = 2 THEN "Leather"
                  WHEN `subclass` = 3 THEN "Mail   "
                  WHEN `subclass` = 4 THEN "Plate  " END ), " | ", AVG( `budget_normalized` / `budget_target3` ) ) AS ``

FROM ACSBV3_doc_item_template
WHERE `class` = 4 AND `InventoryType` IN ( 1, 2, 3, 5, 6, 7, 8, 9, 10, 16, 20 ) AND `subclass` IN ( 1, 2, 3, 4 )
GROUP BY `subclass`
ORDER BY `subclass`;



DROP TABLE IF EXISTS ACSBV3_0406A_armor_report;

CREATE TABLE ACSBV3_0406A_armor_report
(

  `count`    INT,

  `FamilyID` VARCHAR(16),
  `SlotID`   VARCHAR(16),
  `ArmorID`  VARCHAR(16),

  `Mod_Avg`  DECIMAL(12,5),
  `Mod_Old`  DECIMAL(8,2),
  `Mod_New`  DECIMAL(8,2)

);



INSERT INTO ACSBV3_0406A_armor_report ( `count`, `FamilyID`, `SlotID`, `ArmorID`, `Mod_Old`, `Mod_Avg` )
SELECT

      COUNT(*)  AS    `count`,

  i.`FamilyID`  AS `FamilyID`,
  i.`SlotID`    AS   `SlotID`,
  i.`ArmorID`   AS  `ArmorID`,
  i.`mod_armor` AS  `Mod_Old`,

  AVG( i.`budget_normalized` / i.`budget_target3` ) AS `Mod_Avg`

FROM ACSBV3_doc_item_template AS i
WHERE i.`ArmorID` IN ( "Cloth", "Leather", "Mail", "Plate" )
GROUP BY i.`FamilyID`, i.`SlotID`, i.`ArmorID`, i.`mod_armor`;



UPDATE ACSBV3_0406A_armor_report
SET `Mod_New` = ( CASE WHEN `Mod_Avg` BETWEEN 0.99 AND 1.01 THEN `Mod_Old` ELSE ( `Mod_Old` * ( 1 / `Mod_Avg` ) ) END );



SELECT

  CONCAT ( RPAD ( `FamilyID`, 9, " " ), " | ", RPAD ( `SlotID`, 11, " " ), " | ", RPAD ( `ArmorID`, 7, " " ), " | ", `Mod_Avg`, " | ", `Mod_Old`, " | ", ( CASE WHEN `Mod_Old` = `Mod_New` THEN "No Change" ELSE `Mod_New` END ) ) AS ``

FROM ACSBV3_0406A_armor_report
ORDER BY `FamilyID` ASC, `SlotID` ASC, `ArmorID` ASC;

SELECT ( CASE WHEN SUM( `count` ) = @GlobalCount THEN " - all items accounted."
              WHEN SUM( `count` ) > @GlobalCount THEN CONCAT ( " ! ", ( SUM( `count` ) - @GlobalCount ), " extra items accounted." )
              WHEN SUM( `count` ) < @GlobalCount THEN CONCAT ( " ! ", ( @GlobalCount - SUM( `count` ) ), " less items accounted."  ) END ) AS `` FROM ACSBV3_0406A_armor_report

UNION ALL

SELECT ( CASE WHEN SUM( `count` ) = @EquipmentCount1 THEN " - all equipment items accounted."
              WHEN SUM( `count` ) > @EquipmentCount1 THEN CONCAT ( " ! ", ( SUM( `count` ) - @EquipmentCount1 ), " extra equipment items accounted." )
              WHEN SUM( `count` ) < @EquipmentCount1 THEN CONCAT ( " ! ", ( @EquipmentCount1 - SUM( `count` ) ), " less equipment items accounted."  ) END ) AS `` FROM ACSBV3_0406A_armor_report

UNION ALL

SELECT ( CASE WHEN SUM( `count` ) = @EquipmentCount2 THEN " - all armor items accounted."
              WHEN SUM( `count` ) > @EquipmentCount2 THEN CONCAT ( " ! ", ( SUM( `count` ) - @EquipmentCount2 ), " extra armor items accounted." )
              WHEN SUM( `count` ) < @EquipmentCount2 THEN CONCAT ( " ! ", ( @EquipmentCount2 - SUM( `count` ) ), " less armor items accounted."  ) END ) AS `` FROM ACSBV3_0406A_armor_report;



/*=============================================================================================================================================
  6. Weapon Report:
=============================================================================================================================================*/


SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0406A" AND `print` = 6 ) ORDER BY `part`, `auto`;    -- Print Header



SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` >= 8 ) ORDER BY `part`, `auto`;    -- Print Footer



/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
