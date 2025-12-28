/*=============================================================================================================================================
  Filename:       ACSBV3-07-00A.sql
  Title:          Buy/Sell Price Research (Part 1 of 4).
  Author:         Aumuz Messick
  Version:        1.0
  Created:        2025-12-13
  Description:    These script will generate information related to Buy/Sell Price.
                  This  script will create the required tables and procedures for this four script pipeline.

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

SET @SCRIPT  := "0700A",
    @VERSION := "1.0";



/*=============================================================================================================================================
  1. Create Report Table: ACSBV3_0700A_report_table
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "1. Create Report Table: ACSBV3_0700A_report_table" );



DROP   TABLE IF EXISTS ACSBV3_0700A_report_table;

CREATE TABLE           ACSBV3_0700A_report_table
(

  `Script`             VARCHAR(5)     NOT NULL,
  `Version`            VARCHAR(5)     NOT NULL,

  `Report`             SMALLINT       NOT NULL,
  `Group`              VARCHAR(75)    NOT NULL,

  `class`              TINYINT        NOT NULL,
  `class_name`         VARCHAR(10)    NOT NULL,

  `subclass`           TINYINT        NOT NULL,
  `subclass_name`      VARCHAR(15)    NOT NULL,

  `InventoryType`      TINYINT        NOT NULL,
  `InventoryTypeName`  VARCHAR(20)    NOT NULL,

  `Quality`            TINYINT        NOT NULL,
  `QualityName`        VARCHAR(10)    NOT NULL,

  `slot_group`         VARCHAR(25)    NOT NULL,

  `ItemLevel`          SMALLINT       NOT NULL,
  `ItemLevelBracket`   SMALLINT       NOT NULL,

  `budget_actual`      DECIMAL(12,5)  NOT NULL,

  `Count_Group`        INT            NOT NULL,
  `Count_Total`        INT            NOT NULL,
  `Count_Ratio`        DECIMAL( 7,3)  NOT NULL,

  `BuyRatio_ilvl2`     DECIMAL(12,5)  NOT NULL,
  `BuyRatio_ilvl1`     DECIMAL(12,5)  NOT NULL,
  `BuyRatio_budget2`   DECIMAL(12,5)  NOT NULL,
  `BuyRatio_budget1`   DECIMAL(12,5)  NOT NULL,
  `BuyRatio`           DECIMAL(12,5)  NOT NULL,
  `BuyPrice`           DECIMAL(15,3)  NOT NULL,

  `SellPrice`          DECIMAL(15,3)  NOT NULL,
  `SellRatio`          DECIMAL(12,5)  NOT NULL,
  `SellRatio_budget1`  DECIMAL(12,5)  NOT NULL,
  `SellRatio_budget2`  DECIMAL(12,5)  NOT NULL,
  `SellRatio_ilvl1`    DECIMAL(12,5)  NOT NULL,
  `SellRatio_ilvl2`    DECIMAL(12,5)  NOT NULL

);



SELECT "Table Created: ACSBV3_0700A_report_table" AS ``;



/*=============================================================================================================================================
  2. Create Generate Report Procedure: ACSBV3_0700A_report
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "2. Create Generate Report Procedure: ACSBV3_0700A_report" );



DELIMITER $$

DROP   PROCEDURE IF EXISTS ACSBV3_0700A_report $$

CREATE PROCEDURE           ACSBV3_0700A_report ( IN `ARG_Report` SMALLINT, IN `ARG_Group` VARCHAR(75), IN `ARG_Where`  VARCHAR(50) )



BEGIN



  DROP   TEMPORARY TABLE IF EXISTS ACSBV3_temp_report_table;
  CREATE TEMPORARY TABLE           ACSBV3_temp_report_table  LIKE ACSBV3_0700A_report_table;



  SET @QUERY1 := CONCAT ( ' INSERT INTO ACSBV3_temp_report_table SELECT

                              "',    @SCRIPT,         '"              AS             `Script`,
                              "',    @VERSION,        '"              AS            `Version`,

                               ',    `ARG_Report`,    '               AS             `Report`,
                              "',    `ARG_Group`,     '"              AS              `Group`,

                              ROUND ( AVG( d.`class`  ),         0 )  AS              `class`,
                              MIN( d.`class_name` )                   AS         `class_name`,

                              ROUND ( AVG( d.`subclass`  ),      0 )  AS           `subclass`,
                              MIN( d.`subclass_name` )                AS      `subclass_name`,

                              ROUND ( AVG( d.`InventoryType`  ), 0 )  AS      `InventoryType`,
                              MIN( d.`InventoryTypeName` )            AS  `InventoryTypeName`,

                              ROUND ( AVG( d.`Quality`   ),      0 )  AS            `Quality`,
                              "NONE"                                  AS        `QualityName`,

                              MIN( d.`slot_group` )                   AS         `slot_group`,

                              ROUND ( AVG( d.`ItemLevel`     ),  0 )  AS          `ItemLevel`,
                              0                                       AS   `ItemLevelBracket`,

                              ROUND ( AVG( d.`budget_actual` ),  5 )  AS      `budget_actual`,

                               COUNT(*)                               AS        `Count_Group`,
                              @COUNT_Both                             AS        `Count_Total`,
                              0.000                                   AS        `Count_Ratio`,

                              0.00000                                 AS     `BuyRatio_ilvl2`,
                              0.00000                                 AS     `BuyRatio_ilvl1`,
                              0.00000                                 AS   `BuyRatio_budget2`,
                              0.00000                                 AS   `BuyRatio_budget1`,
                              0.000                                   AS           `BuyRatio`,
                              ROUND ( AVG( d.`BuyPrice`  ),      5 )  AS           `BuyPrice`,

                              ROUND ( AVG( d.`SellPrice` ),      5 )  AS          `SellPrice`,
                              0.000                                   AS          `SellRatio`,
                              0.00000                                 AS  `SellRatio_budget1`,
                              0.00000                                 AS  `SellRatio_budget2`,
                              0.00000                                 AS    `SellRatio_ilvl1`,
                              0.00000                                 AS    `SellRatio_ilvl2`

                            FROM ACSBV3_ref_dataset AS d
                            WHERE `BuyPrice` > 0 AND `SellPrice` > 0
                          ',    ( CASE WHEN `ARG_Where` = "ALL" THEN "" ELSE CONCAT ( " AND ",      `ARG_Where` ) END ),    '
                          ',    ( CASE WHEN `ARG_Group` = "ALL" THEN "" ELSE CONCAT ( " GROUP BY ", `ARG_Group` ) END ),    '; ' );

  PREPARE stmt FROM @QUERY1;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;



  UPDATE ACSBV3_temp_report_table SET `slot_group`        = ( CASE WHEN `ARG_Group` LIKE "%InventoryType%" THEN `InventoryTypeName`
                                                                   WHEN `ARG_Group` LIKE "%subclass%"      THEN `subclass_name`
                                                                                                           ELSE `slot_group`         END ) WHERE `Report` = `ARG_Report` AND `Group` = `ARG_Group` AND `Version` = @VERSION AND `Script` = @SCRIPT;

  UPDATE ACSBV3_temp_report_table SET `Count_Ratio`       = ROUND ( ( `Count_Group` / `Count_Total` ) * 100, 3 )                           WHERE `Report` = `ARG_Report` AND `Group` = `ARG_Group` AND `Version` = @VERSION AND `Script` = @SCRIPT;

  UPDATE ACSBV3_temp_report_table SET `QualityName`       = ( CASE WHEN `Quality` = 1 THEN    "Common"
                                                                   WHEN `Quality` = 2 THEN  "Uncommon"
                                                                   WHEN `Quality` = 3 THEN      "Rare"
                                                                   WHEN `Quality` = 4 THEN      "Epic"
                                                                   WHEN `Quality` = 5 THEN "Legendary"
                                                                                      ELSE   "Unknown" END )                               WHERE `Report` = `ARG_Report` AND `Group` = `ARG_Group` AND `Version` = @VERSION AND `Script` = @SCRIPT;

  UPDATE ACSBV3_temp_report_table SET `ItemLevelBracket`  = ( FLOOR ( `ItemLevel` / 10 ) * 10 )                                            WHERE `Report` = `ARG_Report` AND `Group` = `ARG_Group` AND `Version` = @VERSION AND `Script` = @SCRIPT;

  UPDATE ACSBV3_temp_report_table SET `slot_group`        = ( CASE WHEN `ARG_Group` LIKE "%slot_group%" THEN `slot_group` ELSE "ANY" END ) WHERE `Report` = `ARG_Report` AND `Group` = `ARG_Group` AND `Version` = @VERSION AND `Script` = @SCRIPT;

  UPDATE ACSBV3_temp_report_table SET `BuyRatio_ilvl2`    = ROUND ( ( `BuyPrice`      / `ItemLevel`     ) * 100, 5 )                       WHERE `Report` = `ARG_Report` AND `Group` = `ARG_Group` AND `Version` = @VERSION AND `Script` = @SCRIPT;
  UPDATE ACSBV3_temp_report_table SET `BuyRatio_ilvl1`    = ROUND ( ( `ItemLevel`     / `BuyPrice`      ) * 100, 5 )                       WHERE `Report` = `ARG_Report` AND `Group` = `ARG_Group` AND `Version` = @VERSION AND `Script` = @SCRIPT;
  UPDATE ACSBV3_temp_report_table SET `BuyRatio_budget2`  = ROUND ( ( `BuyPrice`      / `budget_actual` ) * 100, 5 )                       WHERE `Report` = `ARG_Report` AND `Group` = `ARG_Group` AND `Version` = @VERSION AND `Script` = @SCRIPT;
  UPDATE ACSBV3_temp_report_table SET `BuyRatio_budget1`  = ROUND ( ( `budget_actual` / `BuyPrice`      ) * 100, 5 )                       WHERE `Report` = `ARG_Report` AND `Group` = `ARG_Group` AND `Version` = @VERSION AND `Script` = @SCRIPT;
  UPDATE ACSBV3_temp_report_table SET `BuyRatio`          = ROUND ( ( `SellPrice`     / `BuyPrice`      ) * 100, 3 )                       WHERE `Report` = `ARG_Report` AND `Group` = `ARG_Group` AND `Version` = @VERSION AND `Script` = @SCRIPT;

  UPDATE ACSBV3_temp_report_table SET `SellRatio`         = ROUND ( ( `BuyPrice`      / `SellPrice`     ) * 100, 3 )                       WHERE `Report` = `ARG_Report` AND `Group` = `ARG_Group` AND `Version` = @VERSION AND `Script` = @SCRIPT;
  UPDATE ACSBV3_temp_report_table SET `SellRatio_budget1` = ROUND ( ( `budget_actual` / `SellPrice`     ) * 100, 5 )                       WHERE `Report` = `ARG_Report` AND `Group` = `ARG_Group` AND `Version` = @VERSION AND `Script` = @SCRIPT;
  UPDATE ACSBV3_temp_report_table SET `SellRatio_budget2` = ROUND ( ( `SellPrice`     / `budget_actual` ) * 100, 5 )                       WHERE `Report` = `ARG_Report` AND `Group` = `ARG_Group` AND `Version` = @VERSION AND `Script` = @SCRIPT;
  UPDATE ACSBV3_temp_report_table SET `SellRatio_ilvl1`   = ROUND ( ( `ItemLevel`     / `SellPrice`     ) * 100, 5 )                       WHERE `Report` = `ARG_Report` AND `Group` = `ARG_Group` AND `Version` = @VERSION AND `Script` = @SCRIPT;
  UPDATE ACSBV3_temp_report_table SET `SellRatio_ilvl2`   = ROUND ( ( `SellPrice`     / `ItemLevel`     ) * 100, 5 )                       WHERE `Report` = `ARG_Report` AND `Group` = `ARG_Group` AND `Version` = @VERSION AND `Script` = @SCRIPT;



  INSERT INTO ACSBV3_0700A_report_table SELECT * FROM ACSBV3_temp_report_table ORDER BY `Quality`, `class`, `slot_group`, `ItemLevel`;



  SELECT "<-------------------------------------------------------------------------------+-----------------------------------------------------+----------------+---------------------------------------------------->" AS `` UNION ALL
  SELECT " Group Information:                                                             | Buy Information:                                    |                | Sell Information:                                   " AS `` UNION ALL
  SELECT " +-----------+----------------+------+------+--------------+-------+----------+ | +---------------+---------------+-----------------+ |:--------------:| +-----------------+---------------+---------------+ " AS `` UNION ALL
  SELECT " | Quality   | Slot Group     | iLvl | {lv} |   AVG Budget | Items |  Ratio % | | |  iLvl Ratio % |  Budget Ratio |       Buy Price | |     Ratio %    | |   Sell Price    |  Budget Ratio |  iLvl Ratio % | " AS `` UNION ALL
  SELECT " +-----------+----------------+------+------+--------------+-------+----------+ | +---------------+---------------+-----------------+ |:--------------:| +-----------------+---------------+---------------+ " AS `` UNION ALL
  SELECT " |           |                |      |      |              |       |          | | |               |               |                 | |                | |                 |               |               | " AS `` UNION ALL

  SELECT CONCAT ( ' | ',  RPAD ( `QualityName`,        9, " " ),        ' | ',
                          RPAD ( `slot_group`,        14, " " ),        ' | ',
                          LPAD ( `ItemLevel`,          4, " " ),        ' | ',
                          LPAD ( `ItemLevelBracket`,   4, " " ),        ' | ',
                          LPAD ( `budget_actual`,     12, " " ),        ' | ',
                          LPAD ( `Count_Group`,        5, " " ),        ' | ',
                          LPAD ( `Count_Ratio`,        7, " " ),  '%',  ' | ',  '|',

                  ' | ',  LPAD ( `BuyRatio_ilvl1`,    12, " " ),  '%'   ' | ',
                          LPAD ( `BuyRatio_budget1`,  12, " " ),  '%'   ' | ',
                          LPAD ( `BuyPrice`,          15, " " ),        ' | ',  '|',

                  '  ',   LPAD ( `BuyRatio`,          11, " " ),  '%',  '  ',   '|',

                  ' | ',  LPAD ( `SellPrice`,         15, " " ),        ' | ',
                          LPAD ( `SellRatio_budget1`, 12, " " ),  '%',  ' | ',
                          LPAD ( `SellRatio_ilvl1`,   12, " " ),  '%',  ' | '        ) AS ``

  FROM ACSBV3_0700A_report_table
  WHERE `Report` = `ARG_Report` AND `Group` = `ARG_Group` AND `Version` = @VERSION AND `Script` = @SCRIPT UNION ALL

  SELECT " |           |                |      |      |              |       |          | | |               |               |                 | |                | |                 |               |               | " AS `` UNION ALL
  SELECT " +-----------+----------------+------+------+--------------+-------+----------+ | +---------------+---------------+-----------------+ |:--------------:| +-----------------+---------------+---------------+ " AS `` UNION ALL
  SELECT "                                                                                |                                                     |                |                                                     " AS `` UNION ALL
  SELECT "<-------------------------------------------------------------------------------+-----------------------------------------------------+----------------+---------------------------------------------------->" AS ``;



END $$

DELIMITER ;



SELECT "Procedure Created: ACSBV3_0700A_report" AS ``;



CALL ACSBV3_print_footer ();

/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
