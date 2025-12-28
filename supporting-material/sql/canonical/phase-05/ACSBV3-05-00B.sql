/*=============================================================================================================================================
  Filename:       ACSBV3-05-00B.sql
  Title:          Slot Report.
  Author:         Aumuz Messick
  Version:        1.0
  Created:        2025-11-26
  Description:    This script generates a series of reports displaying all possible slot combinations.
                  Combine report 6 and 12 to see all possible slot combinations.

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

SET @SCRIPT  := "0500B",
    @VERSION := "1.0";



/*=============================================================================================================================================
  01. Dataset Diagnostic: Display all possible Weapon subclass.
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "01. Dataset Diagnostic: Display all possible Weapon subclass." );

SELECT

  CONCAT ( RPAD ( `class`,         2, " " ), " | ",
           RPAD ( `subclass`,      2, " " ), " | ", COUNT(*) ) AS ``

FROM ACSBV3_ref_items
WHERE `class` = 2
GROUP BY `class`, `subclass`
ORDER BY `class`, `subclass`;



/*=============================================================================================================================================
  02. Dataset Diagnostic: Display all possible Weapon InventoryType.
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "02. Dataset Diagnostic: Display all possible Weapon InventoryType." );

SELECT

  CONCAT ( RPAD ( `class`,         2, " " ), " | ",
           RPAD ( `InventoryType`, 2, " " ), " | ", COUNT(*) ) AS ``

FROM ACSBV3_ref_items
WHERE `class` = 2
GROUP BY `class`, `InventoryType`
ORDER BY `class`, `InventoryType`;



/*=============================================================================================================================================
  03. Dataset Diagnostic: Display all possible Weapon subclass/InventoryType combinations.
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "03. Dataset Diagnostic: Display all possible Weapon subclass/InventoryType combinations." );

SELECT

  CONCAT ( RPAD ( `class`,         2, " " ), " | ",
           RPAD ( `subclass`,      2, " " ), " | ",
           RPAD ( `InventoryType`, 2, " " ), " | ", COUNT(*) ) AS ``

FROM ACSBV3_ref_items
WHERE `class` = 2
GROUP BY `class`, `subclass`, `InventoryType`
ORDER BY `class`, `subclass`, `InventoryType`;



/*=============================================================================================================================================
  04. Dataset Diagnostic: Map all possible Weapon subclass to human readable names.
                         This will be used (copy/paste) to build ACSBV3_doc_item_template.
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "04. Dataset Diagnostic: Map all possible Weapon subclass/InventoryType combinations to human readable names." );

SELECT

  CONCAT ( RPAD ( `class`,         2, " " ), " | ", LPAD ( ( CASE WHEN `class`         =  2 THEN "Weapon"
                                                                  WHEN `class`         =  4 THEN "Equipment"
                                                                                            ELSE "Unknown"
                                                             END ), 9, " " ), " | ",

           RPAD ( `subclass`,      2, " " ), " | ", LPAD ( ( CASE WHEN `subclass`      =  0 THEN "1H Axe"
                                                                  WHEN `subclass`      =  1 THEN "2H Axe"
                                                                  WHEN `subclass`      =  2 THEN "Bow"
                                                                  WHEN `subclass`      =  3 THEN "Gun"
                                                                  WHEN `subclass`      =  4 THEN "1H Mace"
                                                                  WHEN `subclass`      =  5 THEN "2H Mace"
                                                                  WHEN `subclass`      =  6 THEN "Polearm"
                                                                  WHEN `subclass`      =  7 THEN "1H Sword"
                                                                  WHEN `subclass`      =  8 THEN "2H Sword"
                                                                  WHEN `subclass`      = 10 THEN "Staff"
                                                                  WHEN `subclass`      = 13 THEN "Fist"
                                                                  WHEN `subclass`      = 15 THEN "Dagger"
                                                                  WHEN `subclass`      = 16 THEN "Thrown"
                                                                  WHEN `subclass`      = 18 THEN "Crossbow"
                                                                  WHEN `subclass`      = 19 THEN "Wand"
                                                                                            ELSE "Unknown"
                                                             END ), 12, " " ), " | ", COUNT(*) ) AS ``

FROM ACSBV3_ref_items
WHERE `class` = 2
GROUP BY `class`, `subclass`
ORDER BY `class`, `subclass`;



/*=============================================================================================================================================
  05. Dataset Diagnostic: Map all possible Weapon InventoryType to human readable names.
                         This will be used (copy/paste) to build ACSBV3_doc_item_template.
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "05. Dataset Diagnostic: Map all possible Weapon InventoryType to human readable names." );

SELECT

  CONCAT ( RPAD ( `class`,         2, " " ), " | ", LPAD ( ( CASE WHEN `class`         =  2 THEN "Weapon"
                                                                  WHEN `class`         =  4 THEN "Equipment"
                                                                                            ELSE "Unknown"
                                                             END ), 9, " " ), " | ",

           RPAD ( `InventoryType`, 2, " " ), " | ", LPAD ( ( CASE WHEN `InventoryType` = 13 THEN "1 Hand"
                                                                  WHEN `InventoryType` = 15 THEN "Ranged: Bow"
                                                                  WHEN `InventoryType` = 17 THEN "2 Hand"
                                                                  WHEN `InventoryType` = 21 THEN "Main Hand"
                                                                  WHEN `InventoryType` = 22 THEN "Off-Hand"
                                                                  WHEN `InventoryType` = 25 THEN "Ranged: Thrown"
                                                                  WHEN `InventoryType` = 26 THEN "Ranged: Wand or Gun"
                                                                                            ELSE "Unknown"
                                                             END ), 19, " " ), " | ", COUNT(*) ) AS ``

FROM ACSBV3_ref_items
WHERE `class` = 2
GROUP BY `class`, `InventoryType`
ORDER BY `class`, `InventoryType`;



/*=============================================================================================================================================
  06. Dataset Diagnostic: Map all possible Weapon subclass/InventoryType combinations to human readable names.
                         This will be used (copy/paste) to build ACSBV3_doc_item_template.
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "06. Dataset Diagnostic: Map all possible Weapon subclass/InventoryType combinations to human readable names." );

SELECT

  CONCAT ( RPAD ( `class`,         2, " " ), " | ", LPAD ( ( CASE WHEN `class`         =  2 THEN "Weapon"
                                                                  WHEN `class`         =  4 THEN "Equipment"
                                                                                            ELSE "Unknown"
                                                             END ), 9, " " ), " | ",

           RPAD ( `subclass`,      2, " " ), " | ", LPAD ( ( CASE WHEN `subclass`      =  0 THEN "1H Axe"
                                                                  WHEN `subclass`      =  1 THEN "2H Axe"
                                                                  WHEN `subclass`      =  2 THEN "Bow"
                                                                  WHEN `subclass`      =  3 THEN "Gun"
                                                                  WHEN `subclass`      =  4 THEN "1H Mace"
                                                                  WHEN `subclass`      =  5 THEN "2H Mace"
                                                                  WHEN `subclass`      =  6 THEN "Polearm"
                                                                  WHEN `subclass`      =  7 THEN "1H Sword"
                                                                  WHEN `subclass`      =  8 THEN "2H Sword"
                                                                  WHEN `subclass`      = 10 THEN "Staff"
                                                                  WHEN `subclass`      = 13 THEN "Fist"
                                                                  WHEN `subclass`      = 15 THEN "Dagger"
                                                                  WHEN `subclass`      = 16 THEN "Thrown"
                                                                  WHEN `subclass`      = 18 THEN "Crossbow"
                                                                  WHEN `subclass`      = 19 THEN "Wand"
                                                                                            ELSE "Unknown"
                                                             END ), 12, " " ), " | ",

           RPAD ( `InventoryType`, 2, " " ), " | ", LPAD ( ( CASE WHEN `InventoryType` = 13 THEN "1 Hand"
                                                                  WHEN `InventoryType` = 15 THEN "Ranged: Bow"
                                                                  WHEN `InventoryType` = 17 THEN "2 Hand"
                                                                  WHEN `InventoryType` = 21 THEN "Main Hand"
                                                                  WHEN `InventoryType` = 22 THEN "Off-Hand"
                                                                  WHEN `InventoryType` = 25 THEN "Ranged: Thrown"
                                                                  WHEN `InventoryType` = 26 THEN "Ranged: Wand or Gun"
                                                                                            ELSE "Unknown"
                                                             END ), 19, " " ), " | ", COUNT(*) ) AS ``

FROM ACSBV3_ref_items
WHERE `class` = 2
GROUP BY `class`, `subclass`, `InventoryType`
ORDER BY `class`, `subclass`, `InventoryType`;



/*=============================================================================================================================================
  07. Dataset Diagnostic: Display all possible Equipment subclass.
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "07. Dataset Diagnostic: Display all possible Equipment subclass." );

SELECT

  CONCAT ( RPAD ( `class`,         2, " " ), " | ",
           RPAD ( `subclass`,      2, " " ), " | ", COUNT(*) ) AS ``

FROM ACSBV3_ref_items
WHERE `class` = 4
GROUP BY `class`, `subclass`
ORDER BY `class`, `subclass`;



/*=============================================================================================================================================
  08. Dataset Diagnostic: Display all possible Equipment InventoryType.
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "08. Dataset Diagnostic: Display all possible Equipment InventoryType." );

SELECT

  CONCAT ( RPAD ( `class`,         2, " " ), " | ",
           RPAD ( `InventoryType`, 2, " " ), " | ", COUNT(*) ) AS ``

FROM ACSBV3_ref_items
WHERE `class` = 4
GROUP BY `class`, `InventoryType`
ORDER BY `class`, `InventoryType`;



/*=============================================================================================================================================
  09. Dataset Diagnostic: Display all possible Equipment subclass/InventoryType combinations.
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "09. Dataset Diagnostic: Display all possible Equipment subclass/InventoryType combinations." );

SELECT

  CONCAT ( RPAD ( `class`,         2, " " ), " | ",
           RPAD ( `subclass`,      2, " " ), " | ",
           RPAD ( `InventoryType`, 2, " " ), " | ", COUNT(*) ) AS ``

FROM ACSBV3_ref_items
WHERE `class` = 4
GROUP BY `class`, `subclass`, `InventoryType`
ORDER BY `class`, `subclass`, `InventoryType`;



/*=============================================================================================================================================
  10. Dataset Diagnostic: Map all possible Equipment subclass to human readable names.
                         This will be used (copy/paste) to build ACSBV3_doc_item_template.
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "10. Dataset Diagnostic: Map all possible Equipment subclass/InventoryType combinations to human readable names." );

SELECT

  CONCAT ( RPAD ( `class`,         2, " " ), " | ", LPAD ( ( CASE WHEN `class`         =  2 THEN "Weapon"
                                                                  WHEN `class`         =  4 THEN "Equipment"
                                                                                            ELSE "Unknown"
                                                             END ), 9, " " ), " | ",

           RPAD ( `subclass`,      2, " " ), " | ", LPAD ( ( CASE WHEN `subclass`      =  0 THEN "Miscellaneous"
                                                                  WHEN `subclass`      =  1 THEN "Cloth"
                                                                  WHEN `subclass`      =  2 THEN "Leather"
                                                                  WHEN `subclass`      =  3 THEN "Mail"
                                                                  WHEN `subclass`      =  4 THEN "Plate"
                                                                  WHEN `subclass`      =  6 THEN "Shield"
                                                                                            ELSE "Unknown"
                                                             END ), 12, " " ), " | ", COUNT(*) ) AS ``

FROM ACSBV3_ref_items
WHERE `class` = 4
GROUP BY `class`, `subclass`
ORDER BY `class`, `subclass`;



/*=============================================================================================================================================
  11. Dataset Diagnostic: Map all possible Equipment InventoryType to human readable names.
                         This will be used (copy/paste) to build ACSBV3_doc_item_template.
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "11. Dataset Diagnostic: Map all possible Equipment InventoryType to human readable names." );

SELECT

  CONCAT ( RPAD ( `class`,         2, " " ), " | ", LPAD ( ( CASE WHEN `class`         =  2 THEN "Weapon"
                                                                  WHEN `class`         =  4 THEN "Equipment"
                                                                                            ELSE "Unknown"
                                                             END ), 9, " " ), " | ",

           RPAD ( `InventoryType`, 2, " " ), " | ", LPAD ( ( CASE WHEN `InventoryType` =  1 THEN "Head"
                                                                  WHEN `InventoryType` =  2 THEN "Neck"
                                                                  WHEN `InventoryType` =  3 THEN "Shoulder"
                                                                  WHEN `InventoryType` =  5 THEN "Chest"
                                                                  WHEN `InventoryType` =  6 THEN "Waist"
                                                                  WHEN `InventoryType` =  7 THEN "Legs"
                                                                  WHEN `InventoryType` =  8 THEN "Feet"
                                                                  WHEN `InventoryType` =  9 THEN "Wrists"
                                                                  WHEN `InventoryType` = 10 THEN "Hands"
                                                                  WHEN `InventoryType` = 11 THEN "Finger"
                                                                  WHEN `InventoryType` = 14 THEN "Shield"
                                                                  WHEN `InventoryType` = 16 THEN "Back"
                                                                  WHEN `InventoryType` = 20 THEN "Robe"
                                                                  WHEN `InventoryType` = 23 THEN "In-Hand"
                                                                                            ELSE "Unknown"
                                                             END ), 19, " " ), " | ", COUNT(*) ) AS ``

FROM ACSBV3_ref_items
WHERE `class` = 4
GROUP BY `class`, `InventoryType`
ORDER BY `class`, `InventoryType`;



/*=============================================================================================================================================
  12. Dataset Diagnostic: Map all possible Equipment subclass/InventoryType combinations to human readable names.
                         This will be used (copy/paste) to build ACSBV3_doc_item_template.
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "12. Dataset Diagnostic: Map all possible Equipment subclass/InventoryType combinations to human readable names." );

SELECT

  CONCAT ( RPAD ( `class`,         2, " " ), " | ", LPAD ( ( CASE WHEN `class`         =  2 THEN "Weapon"
                                                                  WHEN `class`         =  4 THEN "Equipment"
                                                                                            ELSE "Unknown"
                                                             END ), 9, " " ), " | ",

           RPAD ( `subclass`,      2, " " ), " | ", LPAD ( ( CASE WHEN `subclass`      =  0 THEN "Miscellaneous"
                                                                  WHEN `subclass`      =  1 THEN "Cloth"
                                                                  WHEN `subclass`      =  2 THEN "Leather"
                                                                  WHEN `subclass`      =  3 THEN "Mail"
                                                                  WHEN `subclass`      =  4 THEN "Plate"
                                                                  WHEN `subclass`      =  6 THEN "Shield"
                                                                                            ELSE "Unknown"
                                                             END ), 12, " " ), " | ",

           RPAD ( `InventoryType`, 2, " " ), " | ", LPAD ( ( CASE WHEN `InventoryType` =  1 THEN "Head"
                                                                  WHEN `InventoryType` =  2 THEN "Neck"
                                                                  WHEN `InventoryType` =  3 THEN "Shoulder"
                                                                  WHEN `InventoryType` =  5 THEN "Chest"
                                                                  WHEN `InventoryType` =  6 THEN "Waist"
                                                                  WHEN `InventoryType` =  7 THEN "Legs"
                                                                  WHEN `InventoryType` =  8 THEN "Feet"
                                                                  WHEN `InventoryType` =  9 THEN "Wrists"
                                                                  WHEN `InventoryType` = 10 THEN "Hands"
                                                                  WHEN `InventoryType` = 11 THEN "Finger"
                                                                  WHEN `InventoryType` = 14 THEN "Shield"
                                                                  WHEN `InventoryType` = 16 THEN "Back"
                                                                  WHEN `InventoryType` = 20 THEN "Robe"
                                                                  WHEN `InventoryType` = 23 THEN "In-Hand"
                                                                                            ELSE "Unknown"
                                                             END ), 19, " " ), " | ", COUNT(*) ) AS ``

FROM ACSBV3_ref_items
WHERE `class` = 4
GROUP BY `class`, `subclass`, `InventoryType`
ORDER BY `class`, `subclass`, `InventoryType`;



CALL ACSBV3_print_footer ();



/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
