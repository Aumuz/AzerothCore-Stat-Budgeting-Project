/*=============================================================================================================================================
  Filename:       ACSBV3-06-01A.sql
  Title:          Update Dataset to Include Slot Meta-Groups.
  Author:         Aumuz Messick
  Version:        1.0
  Created:        2025-12-05
  Description:    Update ACSBV3_0600A_dataset to include slot meta-groups.

-----------------------------------------------------------------------------------------------------------------------------------------------
  Updates:
   - v1.0 -> Script Created.

=============================================================================================================================================*/



/*=============================================================================================================================================
  0.1 - Update MYSQL Collation for AzerothCore:
=============================================================================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';



/*=============================================================================================================================================
  0.2 - Set Script Variables:
=============================================================================================================================================*/

SET @SCRIPT  := "0601A",
    @VERSION := "1.0";



/*=============================================================================================================================================
  1. Update ACSBV3_0600A_dataset to Include Slot Meta-Groups: slot_group
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "1. Update ACSBV3_0600A_dataset to Include Slot Meta-Groups: slot_group" );



ALTER TABLE ACSBV3_0600A_dataset ADD `slot_group` VARCHAR(25) NOT NULL;

UPDATE ACSBV3_0600A_dataset
SET `slot_group` = ( CASE WHEN `class` = 2 AND `subclass`      =  0 THEN "1H-Weapon      "
                          WHEN `class` = 2 AND `subclass`      =  1 THEN "2H-Weapon      "
                          WHEN `class` = 2 AND `subclass`      =  2 THEN "Ranged-Physical"
                          WHEN `class` = 2 AND `subclass`      =  3 THEN "Ranged-Physical"
                          WHEN `class` = 2 AND `subclass`      =  4 THEN "1H-Weapon      "
                          WHEN `class` = 2 AND `subclass`      =  5 THEN "2H-Weapon      "
                          WHEN `class` = 2 AND `subclass`      =  6 THEN "2H-Weapon      "
                          WHEN `class` = 2 AND `subclass`      =  7 THEN "1H-Weapon      "
                          WHEN `class` = 2 AND `subclass`      =  8 THEN "2H-Weapon      "
                          WHEN `class` = 2 AND `subclass`      = 10 THEN "Staff          "
                          WHEN `class` = 2 AND `subclass`      = 13 THEN "1H-Weapon      "
                          WHEN `class` = 2 AND `subclass`      = 15 THEN "Dagger         "
                          WHEN `class` = 2 AND `subclass`      = 16 THEN "Thrown         "
                          WHEN `class` = 2 AND `subclass`      = 18 THEN "Ranged-Physical"
                          WHEN `class` = 2 AND `subclass`      = 19 THEN "Wand           "

                          WHEN `class` = 4 AND `InventoryType` =  2 THEN "Accessory      "
                          WHEN `class` = 4 AND `InventoryType` = 11 THEN "Accessory      "
                          WHEN `class` = 4 AND `InventoryType` = 23 THEN "Accessory      "
                          WHEN `class` = 4 AND `InventoryType` =  1 THEN "Moderate-Armor "
                          WHEN `class` = 4 AND `InventoryType` =  3 THEN "Moderate-Armor "
                          WHEN `class` = 4 AND `InventoryType` =  5 THEN "Major-Armor    "
                          WHEN `class` = 4 AND `InventoryType` =  6 THEN "Minor-Armor    "
                          WHEN `class` = 4 AND `InventoryType` =  7 THEN "Major-Armor    "
                          WHEN `class` = 4 AND `InventoryType` =  8 THEN "Minor-Armor    "
                          WHEN `class` = 4 AND `InventoryType` =  9 THEN "Minor-Armor    "
                          WHEN `class` = 4 AND `InventoryType` = 10 THEN "Minor-Armor    "
                          WHEN `class` = 4 AND `InventoryType` = 16 THEN "Cloak          "
                          WHEN `class` = 4 AND `InventoryType` = 20 THEN "Major-Armor    "
                          WHEN `class` = 4 AND `InventoryType` = 14 THEN "Shield         "

                                                                    ELSE "Unknown        " END );

SELECT COUNT(*) AS `item_count`, RPAD ( `class_name`, 10, " " ), RPAD ( `subclass_name`, 15, " " ), RPAD ( `InventoryTypeName`, 15, " " ), `slot_group`
FROM ACSBV3_0600A_dataset
GROUP BY `class_name`, `subclass_name`, `InventoryTypeName`, `slot_group`;



SELECT "" AS ``;
SELECT COUNT(*) AS `unknown_items` FROM ACSBV3_0600A_dataset WHERE `slot_group` = "Unknown        ";



SELECT "" AS ``;
SELECT `slot_group`, COUNT(*) AS `item_count` FROM ACSBV3_0600A_dataset GROUP BY `slot_group`;



CALL ACSBV3_print_footer ();

/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
