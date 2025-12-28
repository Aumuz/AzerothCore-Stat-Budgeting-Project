/*=============================================================================================================================================
  Filename:       ACSBV3-06-02B.sql
  Title:          Update Dataset to Include DPS Meta-Groups.
  Author:         Aumuz Messick
  Version:        1.0
  Created:        2025-12-07
  Description:    Update ACSBV3_0600A_dataset to include DPS meta-groups.

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

SET @SCRIPT  := "0602B",
    @VERSION := "1.0";



/*=============================================================================================================================================
  1. Update ACSBV3_0600A_dataset to Include DPS Meta-Groups: dps_group
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "1. Update ACSBV3_0600A_dataset to Include DPS Meta-Groups: dps_group" );



ALTER TABLE ACSBV3_0600A_dataset ADD `dps_group` VARCHAR(25) NOT NULL;

UPDATE ACSBV3_0600A_dataset
SET `dps_group` = ( CASE WHEN `class` = 2 AND `subclass` =  0 THEN "1H-Weapon      "
                         WHEN `class` = 2 AND `subclass` =  1 THEN "2H-Weapon      "
                         WHEN `class` = 2 AND `subclass` =  2 THEN "Ranged-Physical"
                         WHEN `class` = 2 AND `subclass` =  3 THEN "Ranged-Physical"
                         WHEN `class` = 2 AND `subclass` =  4 THEN "1H-Weapon      "
                         WHEN `class` = 2 AND `subclass` =  5 THEN "2H-Weapon      "
                         WHEN `class` = 2 AND `subclass` =  6 THEN "2H-Weapon      "
                         WHEN `class` = 2 AND `subclass` =  7 THEN "1H-Weapon      "
                         WHEN `class` = 2 AND `subclass` =  8 THEN "2H-Weapon      "
                         WHEN `class` = 2 AND `subclass` = 10 THEN "2H-Weapon      "
                         WHEN `class` = 2 AND `subclass` = 13 THEN "1H-Weapon      "
                         WHEN `class` = 2 AND `subclass` = 15 THEN "1H-Weapon      "
                         WHEN `class` = 2 AND `subclass` = 16 THEN "Ranged-Physical"
                         WHEN `class` = 2 AND `subclass` = 18 THEN "Ranged-Physical"
                         WHEN `class` = 2 AND `subclass` = 19 THEN "Wand           "
                         WHEN `class` = 4                     THEN "None           "
                                                              ELSE "Unknown        " END );

SELECT COUNT(*) AS `item_count`, RPAD ( `class_name`, 10, " " ), RPAD ( `subclass_name`, 15, " " ), RPAD ( `InventoryTypeName`, 15, " " ), `dps_group`
FROM ACSBV3_0600A_dataset
GROUP BY `class_name`, `subclass_name`, `InventoryTypeName`, `dps_group`;



SELECT "" AS ``;
SELECT COUNT(*) AS `unknown_items` FROM ACSBV3_0600A_dataset WHERE `dps_group` = "Unknown        ";



SELECT "" AS ``;
SELECT `dps_group`, COUNT(*) AS `item_count` FROM ACSBV3_0600A_dataset GROUP BY `dps_group`;



CALL ACSBV3_print_footer ();

/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
