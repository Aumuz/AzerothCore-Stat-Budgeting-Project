/*=============================================================================================================================================
  Filename:       ACSBV3-06-02A.sql
  Title:          DPS Research.
  Author:         Aumuz Messick
  Version:        1.0
  Created:        2025-12-07
  Description:    This script will calculate raw DPS curves under a variety of conditions.
                  The goal of this script is to identify the best DPS Meta Groups.

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

SET @SCRIPT  := "0602A",
    @VERSION := "1.0";



/*=============================================================================================================================================
  1. Display Global Curve: DPS to iLvl Bracket
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "1. Display Global Curve: DPS to iLvl Bracket" );

SELECT

  LPAD (                  0, 2, " " ) AS `Group`,         -- LPAD is redundant, but makes copy/past easy for next reports.
  LPAD (           "Global", 6, " " ) AS `Group_Name`,    -- LPAD is redundant, but makes copy/past easy for next reports.
  LPAD (           COUNT(*), 5, " " ) AS `Items`,
  LPAD (    SUM( `weight` ), 5, " " ) AS `Score`,
  LPAD ( `ItemLevelBracket`, 3, " " ) AS `iLvl`,

  LPAD ( ( ( ( AVG ( `dmg_min1` ) + AVG ( `dmg_max1` ) ) / 2 / ( AVG ( `delay` ) / 1000 ) ) / AVG ( `budget_actual` ) ) * 100, 10, " " ) AS `AVG_DPS`

FROM ACSBV3_0600A_dataset WHERE `class` = 2
GROUP BY `ItemLevelBracket`
ORDER BY `ItemLevelBracket` ASC;



/*=============================================================================================================================================
  2. Display subclass Curve: DPS to iLvl Bracket
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "2. Display subclass Curve: DPS to iLvl Bracket" );

SELECT

  LPAD (             `subclass`,  2, " " ) AS `Group`,
  LPAD ( MIN( `subclass_name` ), 15, " " ) AS `Group_Name`,
  LPAD (               COUNT(*),  5, " " ) AS `Items`,
  LPAD (        SUM( `weight` ),  5, " " ) AS `Score`,
  LPAD (     `ItemLevelBracket`,  3, " " ) AS `iLvl`,

  LPAD ( ( ( ( AVG ( `dmg_min1` ) + AVG ( `dmg_max1` ) ) / 2 / ( AVG ( `delay` ) / 1000 ) ) / AVG ( `budget_actual` ) ) * 100, 10, " " ) AS `AVG_DPS`

FROM ACSBV3_0600A_dataset WHERE `class` = 2
GROUP BY `subclass`, `ItemLevelBracket`
ORDER BY `subclass` ASC, `ItemLevelBracket` ASC;



/*=============================================================================================================================================
  3. Display InventoryType Curve: DPS to iLvl Bracket
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "3. Display InventoryType Curve: DPS to iLvl Bracket" );

SELECT

  LPAD (            `InventoryType`,  2, " " ) AS `Group`,
  LPAD ( MIN( `InventoryTypeName` ), 18, " " ) AS `Group_Name`,
  LPAD (                   COUNT(*),  5, " " ) AS `Items`,
  LPAD (            SUM( `weight` ),  5, " " ) AS `Score`,
  LPAD (         `ItemLevelBracket`,  3, " " ) AS `iLvl`,

  LPAD ( ( ( ( AVG ( `dmg_min1` ) + AVG ( `dmg_max1` ) ) / 2 / ( AVG ( `delay` ) / 1000 ) ) / AVG ( `budget_actual` ) ) * 100, 10, " " ) AS `AVG_DPS`

FROM ACSBV3_0600A_dataset WHERE `class` = 2
GROUP BY `InventoryType`, `ItemLevelBracket`
ORDER BY `InventoryType` ASC, `ItemLevelBracket` ASC;



/*=============================================================================================================================================
  4. Display slot Curve: DPS to iLvl Bracket (slot = class, subclass, InventoryType)
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "4. Display slot Curve: DPS to iLvl Bracket (slot = class, subclass, InventoryType)" );

SELECT

  LPAD (             `slot`,  5, " " ) AS `Group`,
  LPAD ( MIN( `slot_name` ), 18, " " ) AS `Group_Name`,
  LPAD (           COUNT(*),  5, " " ) AS `Items`,
  LPAD (    SUM( `weight` ),  5, " " ) AS `Score`,
  LPAD ( `ItemLevelBracket`,  3, " " ) AS `iLvl`,

  LPAD ( ( ( ( AVG ( `dmg_min1` ) + AVG ( `dmg_max1` ) ) / 2 / ( AVG ( `delay` ) / 1000 ) ) / AVG ( `budget_actual` ) ) * 100, 10, " " ) AS `AVG_DPS`

FROM ACSBV3_0600A_dataset WHERE `class` = 2
GROUP BY `slot`, `ItemLevelBracket`
ORDER BY `slot` ASC, `ItemLevelBracket` ASC;



CALL ACSBV3_print_footer ();

/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
