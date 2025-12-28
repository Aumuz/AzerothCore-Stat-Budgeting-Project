/*=============================================================================================================================================
  Filename:       ACSBV3-04-05A.sql
  Title:          Collect Required Information.
  Author:         Aumuz Messick
  Version:        1.0
  Created:        2025-11-21
  Description:    This script will collect, format and print all required information required for documentation.

                  The following information will be printed:

                   - 1. Stat to Cost Table:              v2.4
                   - 2. Socket Cost Table:               v2.4
                   - 3. Drop Multiplier Table:           v2.4
                   - 4. Source Multiplier Table:         v2.4
                   - 5. Common Multiplier Table:         v1.0
                   - 6. Slot Multiplier Tables:          v2.4
                   - 7. Base Budget Table: master        v1.0
                   - 8. Base Budget Table: developer     v4.3

-----------------------------------------------------------------------------------------------------------------------------------------------
  Updates:
   - v1.0 -> Script Created.

=============================================================================================================================================*/


SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';


/*=============================================================================================================================================
  0. Update Print Information Table: ACSBV3_print_info
=============================================================================================================================================*/

DELETE FROM ACSBV3_print_info WHERE `script` = "0405A";

INSERT INTO ACSBV3_print_info ( `script`, `part`, `print`, `output` ) VALUES
( "0405A", 2, 1, "##  1. Stat to Cost Table:                                                                                       (v2.4)  ##" ),
( "0405A", 2, 2, "##  2. Socket Cost Table:                                                                                        (v2.4)  ##" ),
( "0405A", 2, 3, "##  3. Drop Multiplier Table:                                                                                    (v2.4)  ##" ),
( "0405A", 2, 4, "##  4. Source Multiplier Table:                                                                                  (v2.4)  ##" ),
( "0405A", 2, 5, "##  5. Common Multiplier Table:                                                                                  (v1.0)  ##" ),
( "0405A", 2, 6, "##  6. Slot Multiplier Tables:                                                                                   (v2.4)  ##" ),
( "0405A", 2, 7, "##  7. Base Budget Table: master                                                                                 (v1.0)  ##" ),
( "0405A", 2, 8, "##  8. Base Budget Table: developer                                                                              (v4.3)  ##" ),
( "0405A", 2, 8, "##     - Note to Editor: Check for monotonic progression in all tiers. Correct as needed.                                ##" );



/*=============================================================================================================================================
  1. Print - Stat to Cost Table: v2.4
=============================================================================================================================================*/

SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0405A" AND `print` = 1 ) ORDER BY `part`, `auto`;    -- Print Header

SELECT "  Stat to Cost Table: v2.4  " AS ``;

SELECT "  +-------------+------------------------------------+--------+------------------+---------------------------------------------------------------------------------------------------------+  " AS `` UNION ALL
SELECT "  |  stat_type  |  Stat Name                         |  Cost  |  Role            |  Notes                                                                                                  |  " AS `` UNION ALL
SELECT "  +-------------+------------------------------------+--------+------------------+---------------------------------------------------------------------------------------------------------+  " AS `` UNION ALL
SELECT "  |             |                                    |        |                  |                                                                                                         |  " AS `` UNION ALL
SELECT "  |          -  |  Armor                             |  0.20  |  ONLY EQUIPMENT  |  1 Budget Per 5 Armor.                                                                                  |  " AS `` UNION ALL
SELECT "  |          -  |  DPS                               |  1.00  |  ONLY WEAPON     |  1 Budget Per 1 DPS.                                                                                    |  " AS `` UNION ALL
SELECT "  |             |                                    |        |                  |                                                                                                         |  " AS `` UNION ALL

SELECT

  CONCAT ( "  |  ", LPAD ( `stat_type`,   9, " " ), "  |  ",
                    RPAD ( `stat_name`,  32, " " ), "  |  ",
                    LPAD ( `cost`,        4, " " ), "  |  ",
                    RPAD ( `role`,       14, " " ), "  |  ",
                    RPAD ( `notes`,     101, " " ), "  |  ")

FROM ACSBV3_doc_cost WHERE `stat_type` BETWEEN 1 AND 45 UNION ALL

SELECT "  |             |                                    |        |                  |                                                                                                         |  " AS `` UNION ALL
SELECT "  |         --  |  Other                             |  0.25  |  UNKNOWN         |  All Other Stats.                                                                                       |  " AS `` UNION ALL
SELECT "  |             |                                    |        |                  |                                                                                                         |  " AS `` UNION ALL
SELECT "  |         --  |  socketBonus                       |   50%  |  UNKNOWN         |  Socket Bonus is 50% of Equivalent stat_value Cost.                                                     |  " AS `` UNION ALL
SELECT "  |             |                                    |        |                  |                                                                                                         |  " AS `` UNION ALL
SELECT "  +-------------+------------------------------------+--------+------------------+---------------------------------------------------------------------------------------------------------+  " AS ``;

SELECT "                                                                                                             * Negative stat_values should consume the same cost as positive stat_values.     " AS ``;



/*=============================================================================================================================================
  2. Print - Socket Cost Table: v2.4
=============================================================================================================================================*/

SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0405A" AND `print` = 2 ) ORDER BY `part`, `auto`;    -- Print Header

SELECT "  Socket Cost Table: v2.4  " AS ``;

SELECT "  +---------------+-----------------------------+--------+  " AS `` UNION ALL
SELECT "  |  socketBonus  |  Socket Bonus Name          |  Cost  |  " AS `` UNION ALL
SELECT "  +---------------+-----------------------------+--------+  " AS `` UNION ALL
SELECT "  |               |                             |        |  " AS `` UNION ALL

SELECT

  CONCAT ( "  |  ", LPAD ( `socketBonus`,       11, " " ), "  |  ",
                    RPAD ( `socketBonus_name`,  25, " " ), "  |  ",
                    LPAD ( `cost`,               4, " " ), "  |  ")

FROM ACSBV3_doc_socket UNION ALL

SELECT "  |               |                             |        |  " AS `` UNION ALL
SELECT "  +---------------+-----------------------------+--------+  " AS ``;



/*=============================================================================================================================================
  3. Print - Drop Multiplier Table: v2.4
=============================================================================================================================================*/

SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0405A" AND `print` = 3 ) ORDER BY `part`, `auto`;    -- Print Header

SELECT "  Drop Multiplier Table: v2.4  " AS ``;

SELECT "  +--------------------+--------------+  " AS `` UNION ALL
SELECT "  |  Drop Environment  |  Multiplier  |  " AS `` UNION ALL
SELECT "  +--------------------+--------------+  " AS `` UNION ALL
SELECT "  |                    |              |  " AS `` UNION ALL

SELECT

  CONCAT ( "  |  ", RPAD ( `drop_environment`, 16, " " ), "  |  ",
                    LPAD ( `multiplier`,       10, " " ), "  |  ")

FROM ACSBV3_doc_drop UNION ALL

SELECT "  |                    |              |  " AS `` UNION ALL
SELECT "  +--------------------+--------------+  " AS ``;



/*=============================================================================================================================================
  4. Print - Source Multiplier Table: v2.4
=============================================================================================================================================*/

SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0405A" AND `print` = 4 ) ORDER BY `part`, `auto`;    -- Print Header

SELECT "  Source Multiplier Table: v2.4  " AS ``;

SELECT "  +--------------------+--------------+  " AS `` UNION ALL
SELECT "  |  Source Type       |  Multiplier  |  " AS `` UNION ALL
SELECT "  +--------------------+--------------+  " AS `` UNION ALL
SELECT "  |                    |              |  " AS `` UNION ALL

SELECT

  CONCAT ( "  |  ", RPAD ( `source_type`, 16, " " ), "  |  ",
                    LPAD ( `multiplier`,  10, " " ), "  |  ")

FROM ACSBV3_doc_source UNION ALL

SELECT "  |                    |              |  " AS `` UNION ALL
SELECT "  +--------------------+--------------+  " AS ``;



/*=============================================================================================================================================
  5. Print - Common Multiplier Table: v1.0
=============================================================================================================================================*/

SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0405A" AND `print` = 5 ) ORDER BY `part`, `auto`;    -- Print Header

SELECT "  Common Multiplier Table: v1.0  " AS ``;

SELECT "  +---------------------------+--------------+  " AS `` UNION ALL
SELECT "  |  Type                     |  Multiplier  |  " AS `` UNION ALL
SELECT "  +---------------------------+--------------+  " AS `` UNION ALL
SELECT "  |                           |              |  " AS `` UNION ALL
SELECT "  |  Creature Drop - Raid     |        1.10  |  " AS `` UNION ALL
SELECT "  |  Creature Drop - Dungeon  |        1.05  |  " AS `` UNION ALL
SELECT "  |  Creature Drop - World    |        1.00  |  " AS `` UNION ALL
SELECT "  |                           |              |  " AS `` UNION ALL
SELECT "  |  Quest Reward             |        0.85  |  " AS `` UNION ALL
SELECT "  |                           |              |  " AS `` UNION ALL
SELECT "  +---------------------------+--------------+  " AS ``;

SELECT "            * All other not listed as 1.00.     " AS ``;



/*=============================================================================================================================================
  6. Print - Slot Multiplier Tables: v2.4
=============================================================================================================================================*/

SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0405A" AND `print` = 6 ) ORDER BY `part`, `auto`;    -- Print Header

SELECT "  Slot Multiplier Table: v2.4  " AS ``;

SELECT "  +---------+------------+-----------------+--------------------+--------------+  " AS `` UNION ALL
SELECT "  |  class  |  subclass  |  InventoryType  |  Slot Name         |  Multiplier  |  " AS `` UNION ALL
SELECT "  +---------+------------+-----------------+--------------------+--------------+  " AS `` UNION ALL
SELECT "  |         |            |                 |                    |              |  " AS `` UNION ALL

SELECT

  CONCAT ( "  |      2  |  ", LPAD ( `subclass`,       8, " " ), "  |              *  |  ",
                              RPAD ( `subclass_name`, 16, " " ), "  |  ",
                              LPAD ( `multiplier`,    10, " " ), "  |  ")

FROM ACSBV3_doc_slot_weapons UNION ALL

SELECT "  |         |            |                 |                    |              |  " AS `` UNION ALL

SELECT

  CONCAT ( "  |      4  |         *  |  ", LPAD ( `InventoryType`,  13, " " ), "  |  ",
                                           RPAD ( `InventoryName`,  16, " " ), "  |  ",
                                           LPAD ( `multiplier`,     10, " " ), "  |  ")

FROM ACSBV3_doc_slot_equipment UNION ALL

SELECT "  |         |            |                 |                    |              |  " AS `` UNION ALL
SELECT "  +---------+------------+-----------------+--------------------+--------------+  " AS ``;



/*=============================================================================================================================================
  7. Print - Base Budget Table: master v1.0
=============================================================================================================================================*/

SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0405A" AND `print` = 7 ) ORDER BY `part`, `auto`;    -- Print Header

SELECT "  Base Budget Table: master v1.0  " AS ``;

SELECT "  +--------------+--------------+--------------+--------------+--------------+--------------+--------------+  " AS `` UNION ALL
SELECT "  |   ItemLevel  |        Poor  |      Common  |    Uncommon  |        Rare  |        Epic  |   Legendary  |  " AS `` UNION ALL
SELECT "  +--------------+--------------+--------------+--------------+--------------+--------------+--------------+  " AS `` UNION ALL
SELECT "  |              |              |              |              |              |              |              |  " AS `` UNION ALL

SELECT

  CONCAT ( "  |  ", LPAD (            `ItemLevel`,            10, " " ), "  |  ",
                              LPAD ( COALESCE ( `Poor`,      0.00000 ), 10, " " ), "  |  ",
                              LPAD ( COALESCE ( `Common`,    0.00000 ), 10, " " ), "  |  ",
                              LPAD ( COALESCE ( `Uncommon`,  0.00000 ), 10, " " ), "  |  ",
                              LPAD ( COALESCE ( `Rare`,      0.00000 ), 10, " " ), "  |  ",
                              LPAD ( COALESCE ( `Epic`,      0.00000 ), 10, " " ), "  |  ",
                              LPAD ( COALESCE ( `Legendary`, 0.00000 ), 10, " " ), "  |  ")

FROM ACSBV3_0404A_master_chart WHERE GREATEST ( COALESCE ( `Poor`, 0 ), COALESCE ( `Common`, 0 ), COALESCE ( `Uncommon`,  0 ),
                                                COALESCE ( `Rare`, 0 ), COALESCE ( `Epic`,   0 ), COALESCE ( `Legendary`, 0 ) ) > 0 UNION ALL

SELECT "  |              |              |              |              |              |              |              |  " AS `` UNION ALL
SELECT "  +--------------+--------------+--------------+--------------+--------------+--------------+--------------+  " AS ``;

SELECT LPAD ( ( CONCAT ( "* All values derived from ", COUNT(*), " items in Azerothcore (ACDB 335.14-dev).     " ) ), 110, " " ) AS ``
FROM ACSBV3_doc_item_template UNION ALL

SELECT LPAD ( ( CONCAT ( "(", COUNT(*), " equipment)      " ) ), 110, " " ) AS ``
FROM ACSBV3_doc_item_template WHERE `FamilyID` = "Equipment" UNION ALL

SELECT LPAD ( ( CONCAT ( "( ", COUNT(*), "   weapons)      " ) ), 110, " " ) AS ``
FROM ACSBV3_doc_item_template WHERE `FamilyID` = "Weapon";



/*=============================================================================================================================================
  8. Print - Base Budget Table: developer v4.3
=============================================================================================================================================*/

SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0405A" AND `print` = 8 ) ORDER BY `part`, `auto`;    -- Print Header

SELECT "  Base Budget Table: developer v4.3  " AS ``;

SELECT "  +-------------+-------------+-------------+-------------+-------------+-------------+-------------+  " AS `` UNION ALL
SELECT "  |  ItemLevel  |       Poor  |     Common  |   Uncommon  |       Rare  |       Epic  |  Legendary  |  " AS `` UNION ALL
SELECT "  +-------------+-------------+-------------+-------------+-------------+-------------+-------------+  " AS `` UNION ALL
SELECT "  |             |             |             |             |             |             |             |  " AS `` UNION ALL

SELECT

  CONCAT ( "  |  ", LPAD ( `ItemLevel`, 9, " " ), "  |  ",

                    LPAD ( ( CASE WHEN `ItemLevel` BETWEEN  10 AND  39 THEN ROUND ( ( `Common` * 0.75 ), 0 )
                                  WHEN `ItemLevel` BETWEEN  40 AND  99 THEN ROUND ( ( `Common` * 0.70 ), 0 )
                                  WHEN `ItemLevel` BETWEEN 100 AND 159 THEN ROUND ( ( `Common` * 0.65 ), 0 )
                                  WHEN `ItemLevel` BETWEEN 160 AND 239 THEN ROUND ( ( `Common` * 0.60 ), 0 )
                                  WHEN `ItemLevel` BETWEEN 240 AND 300 THEN ROUND ( ( `Common` * 0.55 ), 0 )

                             ELSE 0 END ), 9, " " ), "  |  ",

                    LPAD ( ROUND ( `Common`,    0 ), 9, " " ), "  |  ",
                    LPAD ( ROUND ( `Uncommon`,  0 ), 9, " " ), "  |  ",
                    LPAD ( ROUND ( `Rare`,      0 ), 9, " " ), "  |  ",
                    LPAD ( ROUND ( `Epic`,      0 ), 9, " " ), "  |  ",
                    LPAD ( ROUND ( `Legendary`, 0 ), 9, " " ), "  |  ")

FROM ACSBV3_doc_curve_bands UNION ALL

SELECT "  |             |             |             |             |             |             |             |  " AS `` UNION ALL
SELECT "  +-------------+-------------+-------------+-------------+-------------+-------------+-------------+  " AS ``;

SELECT LPAD ( ( CONCAT ( "* All values derived from ", COUNT(*), " items in Azerothcore (ACDB 335.14-dev).     " ) ), 103, " " ) AS ``
FROM ACSBV3_doc_item_template UNION ALL

SELECT LPAD ( ( CONCAT ( "(", COUNT(*), " equipment)      " ) ), 103, " " ) AS ``
FROM ACSBV3_doc_item_template WHERE `FamilyID` = "Equipment" UNION ALL

SELECT LPAD ( ( CONCAT ( "( ", COUNT(*), "   weapons)      " ) ), 103, " " ) AS ``
FROM ACSBV3_doc_item_template WHERE `FamilyID` = "Weapon";



SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` >= 8 ) ORDER BY `part`, `auto`;    -- Print Footer



/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
