/*=============================================================================================================================================
  Filename:       ACSBV3-04-00Z.sql
  Title:          Final Diagnostic View.
  Author:         Aumuz Messick
  Version:        2.4 (v1.0 does not exist)
  Created:        2025-11-06
  Description:    This script will produce a final diagnostic view of ACSBV3_doc_item_template.
                  This script is new to the "Phase 04-00 to 04-03 Pipeline". Retaining v2.0 for consistency with other pipeline scripts.

                  The follow views will be produced:

                   - 1. View - Index:   Group all items by (iLvl, Quality_Name, Family_Name, Slot_Name).
                   - 2. View - Quality: Show total number of items in each quality tier.
                   - 3. View - Slot:    Show total number of items in each equipment slot or weapon type category.
                   - 4. View - iLvl:    Show total number of items in each iLvl bracket.
                   - 5. Final Diagnostic Output: This defines the (theoretically) most common Quality/Slot/iLvl combo.

                  ( * This script should always be last in the "Phase 04-00 Pipeline" * )

                  This script is mostly depreciated as of v2.3.

-----------------------------------------------------------------------------------------------------------------------------------------------
  Updates:
   - v2.0 -> Script Created.
   - v2.1 -> (2025-11-09) Added print-out formatting: ACSBV3_print_info.
   - v2.2 -> (2025-11-18) Skipped to sync version numbers with pipeline (no change).
   - v2.3 -> (2025-11-18) Skipped to sync version numbers with pipeline (updated headers).
   - v2.4 -> (2025-11-18) Skipped to sync version numbers with pipeline (updated headers).

=============================================================================================================================================*/


SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';


/*=============================================================================================================================================
  0. Update Print Information Table: ACSBV3_print_info
=============================================================================================================================================*/

DELETE FROM ACSBV3_print_info WHERE `script` = "0400Z";

INSERT INTO ACSBV3_print_info ( `script`, `part`, `print`, `output` ) VALUES
( "0400Z", 2, 1, "##  1. View - Index: Group all items by (iLvl, Quality_Name, Family_Name, Slot_Name).                            (v2.4)  ##" ),
( "0400Z", 2, 2, "##  2. View - Quality: Show total number of items in each quality tier.                                          (v2.4)  ##" ),
( "0400Z", 2, 3, "##  3. View - Slot: Show total number of items in each equipment slot or weapon type category.                   (v2.4)  ##" ),
( "0400Z", 2, 4, "##  4. View - iLvl: Show total number of items in each iLvl bracket.                                             (v2.4)  ##" ),
( "0400Z", 2, 5, "##  5. Final Diagnostic Output: This defines the (theoretically) most common Quality/Slot/iLvl combo.            (v2.4)  ##" );



/*=============================================================================================================================================
  1. View - Index: Group all items by (iLvl, Quality_Name, Family_Name, Slot_Name).
                   This provides a "Road Map" to item importance, in regards to how much pull an item group will have on budgets.
=============================================================================================================================================*/

SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0400Z" AND `print` = 1 ) ORDER BY `part`, `auto`;    -- Print Header



DROP TEMPORARY TABLE IF EXISTS temp_index;

CREATE TEMPORARY TABLE temp_index
(

  `Item_Count`     INT,
  `iLvl`           SMALLINT,
  `Quality_Name`   VARCHAR(10),
  `Family_Name`    VARCHAR(16),
  `Slot_Name`      VARCHAR(16),
  `Average_Budget` DECIMAL(12,5),
  `Minimum_Budget` DECIMAL(12,5),
  `Maximum_Budget` DECIMAL(12,5)

);

INSERT INTO temp_index ( `Item_Count`, `iLvl`, `Quality_Name`, `Family_Name`, `Slot_Name`, `Average_Budget`, `Minimum_Budget`, `Maximum_Budget` )
SELECT

       COUNT(*) AS `Item_Count`,
    `ItemLevel` AS `iLvl`,
  `QualityName` AS `Quality_Name`,
     `FamilyID` AS `Family_Name`,
       `SlotID` AS `Slot_Name`,

  AVG(`budget_normalized`) AS `Average_Budget`,
  MIN(`budget_normalized`) AS `Minimum_Budget`,
  MAX(`budget_normalized`) AS `Maximum_Budget`

FROM ACSBV3_doc_item_template GROUP BY `ItemLevel`, `QualityName`, `FamilyID`, `SlotID`;



DROP TABLE IF EXISTS ACSBV3_0400Z_view_index;

CREATE TABLE ACSBV3_0400Z_view_index
(

  `Item_Count`     INT,
  `iLvl`           SMALLINT,
  `Quality_Name`   VARCHAR(10),
  `Family_Name`    VARCHAR(16),
  `Slot_Name`      VARCHAR(16),
  `Average_Budget` DECIMAL(12,5),
  `Minimum_Budget` DECIMAL(12,5),
  `Maximum_Budget` DECIMAL(12,5)

);

INSERT INTO ACSBV3_0400Z_view_index SELECT * FROM temp_index
ORDER BY `Item_Count` DESC, `iLvl` DESC, `Quality_Name` ASC, `Family_Name` ASC, `Slot_Name` ASC;



SELECT * FROM ACSBV3_0400Z_view_index LIMIT 10;

SELECT SUM(`Item_Count`) AS `count` FROM ACSBV3_0400Z_view_index;



/*=============================================================================================================================================
  2. View - Quality: Show total number of items in each quality tier.
=============================================================================================================================================*/

SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0400Z" AND `print` = 2 ) ORDER BY `part`, `auto`;    -- Print Header



DROP TEMPORARY TABLE IF EXISTS temp_quality;

CREATE TEMPORARY TABLE temp_quality
(

  `Item_Count`     INT,
  `Quality_Name`   VARCHAR(10),
  `Average_Budget` DECIMAL(12,5),
  `Minimum_Budget` DECIMAL(12,5),
  `Maximum_Budget` DECIMAL(12,5)

);

INSERT INTO temp_quality ( `Item_Count`, `Quality_Name`, `Average_Budget`, `Minimum_Budget`, `Maximum_Budget` )
SELECT

       COUNT(*) AS `Item_Count`,
  `QualityName` AS `Quality_Name`,

  AVG(`budget_normalized`) AS `Average_Budget`,
  MIN(`budget_normalized`) AS `Minimum_Budget`,
  MAX(`budget_normalized`) AS `Maximum_Budget`

FROM ACSBV3_doc_item_template GROUP BY `QualityName`;



DROP TABLE IF EXISTS ACSBV3_0400Z_view_quality;

CREATE TABLE ACSBV3_0400Z_view_quality
(

  `Item_Count`     INT,
  `Quality_Name`   VARCHAR(10),
  `Average_Budget` DECIMAL(12,5),
  `Minimum_Budget` DECIMAL(12,5),
  `Maximum_Budget` DECIMAL(12,5)

);

INSERT INTO ACSBV3_0400Z_view_quality SELECT * FROM temp_quality ORDER BY `Item_Count` DESC;



SELECT * FROM ACSBV3_0400Z_view_quality;

SELECT SUM(`Item_Count`) AS `count` FROM ACSBV3_0400Z_view_quality;

SET @Quality := ( SELECT `Quality_Name` FROM ACSBV3_0400Z_view_quality ORDER BY `Item_Count` DESC LIMIT 1 );



/*=============================================================================================================================================
  3. View - Slot: Show total number of items in each equipment slot or weapon type category.
=============================================================================================================================================*/

SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0400Z" AND `print` = 3 ) ORDER BY `part`, `auto`;    -- Print Header



DROP TEMPORARY TABLE IF EXISTS temp_slot;

CREATE TEMPORARY TABLE temp_slot
(

  `Item_Count`     INT,
  `Family_Name`    VARCHAR(16),
  `Slot_Name`      VARCHAR(16),
  `Average_Budget` DECIMAL(12,5),
  `Minimum_Budget` DECIMAL(12,5),
  `Maximum_Budget` DECIMAL(12,5)

);

INSERT INTO temp_slot ( `Item_Count`, `Family_Name`, `Slot_Name`, `Average_Budget`, `Minimum_Budget`, `Maximum_Budget` )
SELECT

       COUNT(*) AS `Item_Count`,
     `FamilyID` AS `Family_Name`,
       `SlotID` AS `Slot_Name`,

  AVG(`budget_normalized`) AS `Average_Budget`,
  MIN(`budget_normalized`) AS `Minimum_Budget`,
  MAX(`budget_normalized`) AS `Maximum_Budget`

FROM ACSBV3_doc_item_template GROUP BY `FamilyID`, `SlotID`;



DROP TABLE IF EXISTS ACSBV3_0400Z_view_slot;

CREATE TABLE ACSBV3_0400Z_view_slot
(

  `Item_Count`     INT,
  `Family_Name`    VARCHAR(16),
  `Slot_Name`      VARCHAR(16),
  `Average_Budget` DECIMAL(12,5),
  `Minimum_Budget` DECIMAL(12,5),
  `Maximum_Budget` DECIMAL(12,5)

);

INSERT INTO ACSBV3_0400Z_view_slot SELECT * FROM temp_slot ORDER BY `Item_Count` DESC, `Family_Name` ASC, `Slot_Name` ASC;



SELECT * FROM ACSBV3_0400Z_view_slot;

SELECT SUM(`Item_Count`) AS `count` FROM ACSBV3_0400Z_view_slot;

SET @Slot := ( SELECT `Slot_Name` FROM ACSBV3_0400Z_view_slot ORDER BY `Item_Count` DESC LIMIT 1 );



/*=============================================================================================================================================
  4. View - iLvl: Show total number of items in each iLvl bracket.
=============================================================================================================================================*/

SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0400Z" AND `print` = 4 ) ORDER BY `part`, `auto`;    -- Print Header



DROP TEMPORARY TABLE IF EXISTS temp_ilvl;

CREATE TEMPORARY TABLE temp_ilvl
(

  `Item_Count`     INT,
  `iLvl`           SMALLINT,
  `Average_Budget` DECIMAL(12,5),
  `Minimum_Budget` DECIMAL(12,5),
  `Maximum_Budget` DECIMAL(12,5)

);

INSERT INTO temp_ilvl ( `Item_Count`, `iLvl`, `Average_Budget`, `Minimum_Budget`, `Maximum_Budget` )
SELECT

       COUNT(*) AS `Item_Count`,
    `ItemLevel` AS `iLvl`,

  AVG(`budget_normalized`) AS `Average_Budget`,
  MIN(`budget_normalized`) AS `Minimum_Budget`,
  MAX(`budget_normalized`) AS `Maximum_Budget`

FROM ACSBV3_doc_item_template GROUP BY `ItemLevel`;



DROP TABLE IF EXISTS ACSBV3_0400Z_view_ilvl;

CREATE TABLE ACSBV3_0400Z_view_ilvl
(

  `Item_Count`     INT,
  `iLvl`           SMALLINT,
  `Average_Budget` DECIMAL(12,5),
  `Minimum_Budget` DECIMAL(12,5),
  `Maximum_Budget` DECIMAL(12,5)

);

INSERT INTO ACSBV3_0400Z_view_ilvl SELECT * FROM temp_ilvl ORDER BY `Item_Count` DESC, `iLvl` DESC;



SELECT * FROM ACSBV3_0400Z_view_ilvl LIMIT 10;

SELECT SUM(`Item_Count`) AS `count` FROM ACSBV3_0400Z_view_ilvl;

SET @iLvl := ( SELECT `iLvl` FROM ACSBV3_0400Z_view_ilvl ORDER BY `Item_Count` DESC LIMIT 1 );



/*=============================================================================================================================================
  5. Final Diagnostic Output: This defines the (theoretically) most common Quality/Slot/iLvl combo.
                              If the index is our "Road Map", and the other tables are our directions,
                              then the "Focal Point" is our starting location.
=============================================================================================================================================*/

SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0400Z" AND `print` = 5 ) ORDER BY `part`, `auto`;    -- Print Header



SELECT

"Focal Point: " AS `Note`,
       @Quality AS `Quality`,
          @Slot AS `Slot`,
          @iLvl AS `iLvl`,
       COUNT(*) AS `Item_Count`

FROM ACSBV3_doc_item_template
WHERE `QualityName` = @Quality AND `SlotID` = @Slot AND `ItemLevel` = @iLvl;



SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 8 ) ORDER BY `part`, `auto`;    -- Print 3-Line Break



SELECT

              `entry` AS `Entry`,
               `name` AS `Name`,
          `ItemLevel` AS `iLvl`,
        `QualityName` AS `Quality_Name`,
           `FamilyID` AS `Family_Name`,
             `SlotID` AS `Slot`,
  `budget_normalized` AS `Budget`

FROM ACSBV3_doc_item_template
WHERE `QualityName` = @Quality AND `SlotID` = @Slot AND `ItemLevel` = @iLvl
ORDER BY `budget_normalized` DESC, `entry` ASC
LIMIT 10;



SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` >= 8 ) ORDER BY `part`, `auto`;    -- Print Footer



/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
