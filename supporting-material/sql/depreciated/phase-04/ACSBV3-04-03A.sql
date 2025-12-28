/*=============================================================================================================================================
  Filename:       ACSBV3-04-03A.sql
  Title:          Create Reporting Procedures.
  Author:         Aumuz Messick
  Version:        2.4
  Created:        2025-11-08
  Description:    This script creates reusable procedures for curve reporting.

                  The following tables and procedures will be created:

                   - 1. ACSBV3_0403_report       -> Table to save reports.
                   - 2. ACSBV3_generate_report   -> Procedure to generate reports.
                   - 3. ACSBV3_print_report      -> Procedure to print and format reports.
                   - 4. ACSBV3_print_outlier     -> Procedure to print and format outlier reports (no header).
                   - 5. ACSBV3_print_item_report -> Procedure to print and format item reports.

-----------------------------------------------------------------------------------------------------------------------------------------------
  Updates:
   - v2.0 -> Script Created (completely reworked from v1.0).
   - v2.1 -> (2025-11-10) Added print-out formatting: ACSBV3_print_info.
   - v2.2 -> (2025-11-12) Script renamed from ACSBV3-04-02B to ACSBV3-04-03A, moved reports to ACSBV3-04-03B.
   - v2.3 -> (2025-11-15) Added item report procedure.
   - v2.4 -> (2025-11-18) Skipped to sync version numbers with pipeline (updated headers).

=============================================================================================================================================*/



/*=============================================================================================================================================
  0. Update MYSQL Collation for AzerothCore: utf8mb4_general_ci (needed to run procedures).
=============================================================================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';



/*=============================================================================================================================================
  1. Create Report Table: ACSBV3_0403_report
=============================================================================================================================================*/

SELECT "Creating Table: ACSBV3_0403_report" AS ``;

DROP TABLE IF EXISTS ACSBV3_0403_report;

CREATE TABLE ACSBV3_0403_report
(

  `Script`        VARCHAR(10),
  `Report`        INT,
  `Version`       DECIMAL(4,2),

  `Drop`          VARCHAR(16),
  `Source`        VARCHAR(16),
  `Curve`         VARCHAR(10),
  `Quality`       VARCHAR(10),
  `Family`        VARCHAR(16),
  `Slot`          VARCHAR(16),
  `iLvl`          SMALLINT,

  `Point_Count`   INT,
  `Total_Items`   INT,

  `Raw_Average`   DECIMAL(12,5),
  `3pnt_Average`  DECIMAL(12,5),
  `Mono_Average`  DECIMAL(12,5),

  `Raw_Result`    VARCHAR(10),
  `3pnt_Result`   VARCHAR(10),
  `Mono_Result`   VARCHAR(10),

  `Fail_Count`    INT,
  `Total_Count`   INT,

  `Raw_Minimum`   DECIMAL(12,5),
  `3pnt_Minimum`  DECIMAL(12,5),
  `Mono_Minimum`  DECIMAL(12,5),

  `Raw_Maximum`   DECIMAL(12,5),
  `3pnt_Maximum`  DECIMAL(12,5),
  `Mono_Maximum`  DECIMAL(12,5),

  `Outlier_Count` INT,

  `Focal_Point`   INT

);



/*=============================================================================================================================================
  2. Create Generate Report Procedure: ACSBV3_generate_report
=============================================================================================================================================*/

SELECT "Creating Procedure: ACSBV3_generate_report" AS ``;

DELIMITER $$

DROP PROCEDURE IF EXISTS ACSBV3_generate_report $$

CREATE PROCEDURE ACSBV3_generate_report ( IN `ARG_Report` INT, IN `ARG_Group` TEXT, IN `ARG_Variable` TEXT )

BEGIN

  CASE

    WHEN `ARG_Group` LIKE "%ALL%"  THEN SET `ARG_Group` := "`drop_environment`, `source_type`, `CurveName`, `QualityName`, `FamilyID`, `SlotID`, `ItemLevel`";
    WHEN `ARG_Group` LIKE "%NONE%" THEN SET `ARG_Group` := "1";
                                   ELSE SET `ARG_Group` := `ARG_Group`;

  END CASE;

    CASE WHEN `ARG_Group` LIKE "%DROP%"      THEN SET @VAR_Drop    := "d.`drop_environment`"; ELSE SET @VAR_Drop    := '"ALL"'; END CASE;
    CASE WHEN `ARG_Group` LIKE "%SOURCE%"    THEN SET @VAR_Source  := "d.`source_type`";      ELSE SET @VAR_Source  := '"ALL"'; END CASE;
    CASE WHEN `ARG_Group` LIKE "%CURVE%"     THEN SET @VAR_Curve   := "d.`CurveName`";        ELSE SET @VAR_Curve   := '"ALL"'; END CASE;
    CASE WHEN `ARG_Group` LIKE "%QUALITY%"   THEN SET @VAR_Quality := "d.`QualityName`";      ELSE SET @VAR_Quality := '"ALL"'; END CASE;
    CASE WHEN `ARG_Group` LIKE "%FAMILY%"    THEN SET @VAR_Family  := "d.`FamilyID`";         ELSE SET @VAR_Family  := '"ALL"'; END CASE;
    CASE WHEN `ARG_Group` LIKE "%SLOT%"      THEN SET @VAR_Slot    := "d.`SlotID`";           ELSE SET @VAR_Slot    := '"ALL"'; END CASE;

    CASE WHEN `ARG_Group` LIKE "%ITEM%"
           OR `ARG_Group` LIKE "%ITEMLEVEL%" THEN SET @VAR_iLvl    := "d.`ItemLevel`";        ELSE SET @VAR_iLvl    :=       0; END CASE;

  DELETE FROM ACSBV3_0403_report WHERE `Script` = @Script AND `Report` = `ARG_Report` AND `Version` = @Version;

  SET @Query := CONCAT('

                         INSERT INTO ACSBV3_0403_report SELECT

                           "', @Script,     '" AS     `Script`,
                            ', `ARG_Report`,'  AS     `Report`,

                            ', @Version,    '  AS    `Version`,

                            ', @VAR_Drop,   '  AS       `Drop`,
                            ', @VAR_Source, '  AS     `Source`,
                            ', @VAR_Curve,  '  AS      `Curve`,
                            ', @VAR_Quality,'  AS    `Quality`,
                            ', @VAR_Family, '  AS     `Family`,
                            ', @VAR_Slot,   '  AS       `Slot`,
                            ', @VAR_iLvl,   '  AS       `iLvl`,

                                            COUNT(*) AS `Point_Count`,
                           COUNT( DISTINCT `entry` ) AS `Total_Items`,

                           AVG( d.`budget_normalized` / d.`budget_target1` ) AS `Raw_Average`,
                           AVG( d.`budget_normalized` / d.`budget_target2` ) AS `3pnt_Average`,
                           AVG( d.`budget_normalized` / d.`budget_target3` ) AS `Mono_Average`,

                              ( CASE WHEN AVG( d.`budget_normalized` / d.`budget_target1` ) BETWEEN @MinGoal AND @MaxGoal THEN "PASS" ELSE "FAIL" END ) AS `Raw_Result`,
                              ( CASE WHEN AVG( d.`budget_normalized` / d.`budget_target2` ) BETWEEN @MinGoal AND @MaxGoal THEN "PASS" ELSE "FAIL" END ) AS `3pnt_Result`,
                              ( CASE WHEN AVG( d.`budget_normalized` / d.`budget_target3` ) BETWEEN @MinGoal AND @MaxGoal THEN "PASS" ELSE "FAIL" END ) AS `Mono_Result`,

                                 ( ( CASE WHEN AVG( d.`budget_normalized` / d.`budget_target1` ) BETWEEN @MinGoal AND @MaxGoal THEN 0 ELSE 1 END )
                                 + ( CASE WHEN AVG( d.`budget_normalized` / d.`budget_target2` ) BETWEEN @MinGoal AND @MaxGoal THEN 0 ELSE 1 END )
                                 + ( CASE WHEN AVG( d.`budget_normalized` / d.`budget_target3` ) BETWEEN @MinGoal AND @MaxGoal THEN 0 ELSE 1 END ) ) AS `Fail_Count`,

                           3 AS `Total_Count`,

                           MIN(`budget_perc1`) AS `Raw_Minimum`,
                           MIN(`budget_perc2`) AS `3pnt_Minimum`,
                           MIN(`budget_perc3`) AS `Mono_Minimum`,

                           MAX(`budget_perc1`) AS `Raw_Maximum`,
                           MAX(`budget_perc2`) AS `3pnt_Maximum`,
                           MAX(`budget_perc3`) AS `Mono_Maximum`,

                           COUNT( CASE WHEN `budget_perc1` NOT BETWEEN @MinGoal AND @MaxGoal THEN 1
                                       WHEN `budget_perc2` NOT BETWEEN @MinGoal AND @MaxGoal THEN 1
                                       WHEN `budget_perc3` NOT BETWEEN @MinGoal AND @MaxGoal THEN 1 END ) AS `Outlier_Count`,

                           ( ( CASE WHEN ', @VAR_Drop,   ' = @FocalPoint0 THEN 1 ELSE 0 END ) +
                             ( CASE WHEN ', @VAR_Quality,' = @FocalPoint1 THEN 1 ELSE 0 END ) +
                             ( CASE WHEN ', @VAR_Slot,   ' = @FocalPoint2 THEN 1 ELSE 0 END ) +
                             ( CASE WHEN ', @VAR_iLvl,   ' = @FocalPoint3 THEN 1 ELSE 0 END ) ) AS `Focal_Point`

                         FROM ACSBV3_0402A_diagnostic_dataset AS d ', `ARG_Variable`,'
                         GROUP BY ', `ARG_Group`,'

                       ');

  PREPARE stmt FROM @Query;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;

END $$

DELIMITER ;



/*=============================================================================================================================================
  3. Create Print Report Procedure: ACSBV3_print_report
=============================================================================================================================================*/

SELECT "Creating Procedure: ACSBV3_print_report" AS ``;

DELIMITER $$

DROP PROCEDURE IF EXISTS ACSBV3_print_report $$

CREATE PROCEDURE ACSBV3_print_report ( IN `ARG_Report` INT, IN `ARG_Group` VARCHAR(255), IN `ARG_First` TEXT, IN `ARG_Last` TEXT, IN `ARG_Order` VARCHAR(255) )

BEGIN

  /* Set Report Order */

     CASE

       WHEN `ARG_Order` NOT LIKE "%DEFAULT%" THEN SET `ARG_Order` := `ARG_Order`;
                                             ELSE SET `ARG_Order` := "`Mono_Average` DESC, `3pnt_Average` DESC, `Raw_Average` DESC";

     END CASE;



  /* Print Report Header */

     SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part`   = 1        OR `part` = 7 )
                                                     OR ( `script` = @Script AND `part` = 3 )
                                                     OR ( `script` = @Script AND `print` = `ARG_Report` )
     ORDER BY `part`, `auto`;



  /* Print Report Body */

     SET @Query_Limit := ( SELECT

                             CASE WHEN COUNT(*) > 30 THEN " LIMIT 20" ELSE "" END

                           FROM ACSBV3_0403_report WHERE `Script` = @Script AND `Report` = `ARG_Report` AND `Version` = @Version );    -- Yes, allow up to 30, or limit to 20.

     SET @Query := CONCAT('

                            SELECT

                              CONCAT ( " | ", ', `ARG_Group`,', " |" )AS `Group`,

                              ', `ARG_First`,'

                              CONCAT ( "| ", `Raw_Average`,  " ",  `Raw_Result`, " |" ) AS `Raw_Average`,
                              CONCAT ( "| ", `3pnt_Average`, " ", `3pnt_Result`, " |" ) AS `3pnt_Average`,
                              CONCAT ( "| ", `Mono_Average`, " ", `Mono_Result`, " |" ) AS `Mono_Average`,

                              ', `ARG_Last` ,'

                              CONCAT ( "| ", ( CASE WHEN `Fail_Count` = 0             THEN "ALL PASSED:       "
                                                    WHEN `Fail_Count` = `Total_Count` THEN "ALL FAILED:       "
                                                                                      ELSE CONCAT( "    FAILED: ", `Fail_Count`, " of ", `Total_Count` ) END ), " | ",

                                             ( CASE WHEN `Focal_Point` =  0 THEN "               "
                                                    WHEN `Focal_Point` >= 1 THEN "<- Focal Point " END ) ) AS `Row_Result`

                            FROM ACSBV3_0403_report WHERE `Script` = "', @Script, '" AND `Report` = ', `ARG_Report`, ' AND `Version` = ', @Version, '
                            ORDER BY ', `ARG_Order`, @Query_Limit,';

                          ');

     PREPARE stmt FROM @Query;
     EXECUTE stmt;
     DEALLOCATE PREPARE stmt;



  /* Print Report Item Count */

     SELECT

       CONCAT ( " - Total Row Count: ",

                ( SELECT

                    CONCAT ( COUNT(*), CASE WHEN COUNT(*) > 30 THEN " (report view limited to 20 rows.)" ELSE "" END )    -- Yes, allow up to 30, or limit to 20.

                  FROM ACSBV3_0403_report
                  WHERE ( `Script` = @Script AND `Report` = `ARG_Report` AND `Version` = @Version ) ),

                " | ",

                ( SELECT SUM( `Total_Items` )
                  FROM ACSBV3_0403_report
                  WHERE ( `Script` = @Script AND `Report` = `ARG_Report` AND `Version` = @Version ) AND `Curve` NOT IN ( "Q4E", "Q4W" ) ),

                " Distinct Items of ",

                ( SELECT SUM( `Point_Count` )
                  FROM ACSBV3_0403_report
                  WHERE ( `Script` = @Script AND `Report` = `ARG_Report` AND `Version` = @Version ) ),

                " Total Points."

              ) AS ``;



  /* Print Report Summary: Header */

     SELECT "Report Summary:" AS ``;



  /* Print Report Summary: Curve */

     SELECT

       CONCAT (

                " - 1. Curve | ",

                ( CASE WHEN SUM( `Fail_Count` ) = 0                    THEN "ALL PASSED | "
                       WHEN SUM( `Fail_Count` ) = SUM( `Total_Count` ) THEN "ALL FAILED | "
                                                                       ELSE

                                                                         CONCAT ( ROUND ( ( SUM( `Fail_Count` ) / SUM( `Total_Count` ) ) * 100, 0 ), "% FAILED | " )

                                                                       END ),

                  CONCAT ( "Raw Failure: ",   COUNT( CASE WHEN `Raw_Result`  = "FAIL" THEN 1 END ), " | " ),
                  CONCAT ( "3pnt Failure: ",  COUNT( CASE WHEN `3pnt_Result` = "FAIL" THEN 1 END ), " | " ),
                  CONCAT ( "Mono Failure: ",  COUNT( CASE WHEN `Mono_Result` = "FAIL" THEN 1 END ), " | " ),

                  CONCAT ( "Total Failure: ", SUM( `Fail_Count` ), " of ", SUM( `Total_Count` ), " points checked." )

              ) AS ``

     FROM ACSBV3_0403_report WHERE `Script` = @Script AND `Report` = `ARG_Report` AND `Version` = @Version;



  /* Print Report Summary: Outlier */

     SELECT

       CONCAT (

                " - 2. Outlier | ",

                ( CASE WHEN SUM( `Outlier_Count` ) = 0                    THEN "ALL PASSED | "
                       WHEN SUM( `Outlier_Count` ) = SUM( `Point_Count` ) THEN "ALL FAILED | "
                                                                          ELSE

                                                                            CONCAT ( ROUND ( ( SUM( `Outlier_Count` ) / SUM( `Point_Count` ) ) * 100, 0 ), "% FAILED | " )

                                                                          END ),

                SUM( `Outlier_Count` ), " Significant budget outliers detected, in ", SUM( `Point_Count` ), " points checked. | ",

                "Least: ",    ROUND ( LEAST    ( MIN( `Raw_Minimum` ), MIN( `3pnt_Minimum` ), MIN( `Mono_Minimum` ) ) * 100, 2 ), "% | ",
                "Greatest: ", ROUND ( GREATEST ( MAX( `Raw_Maximum` ), MAX( `3pnt_Maximum` ), MAX( `Mono_Maximum` ) ) * 100, 2 ), "%"

              ) AS ``

     FROM ACSBV3_0403_report WHERE `Script` = @Script AND `Report` = `ARG_Report` AND `Version` = @Version;



  /* Print Report Summary: Focal-Point */

     SELECT

       CONCAT (

                " - 3. Focal-Point | ",

                CASE WHEN COUNT(*) = 0 THEN "No Focal-Point found in report."
                                       ELSE

                                         CONCAT (

                                                  ( CASE WHEN SUM( `Fail_Count` ) = 0                    THEN "ALL PASSED | "
                                                         WHEN SUM( `Fail_Count` ) = SUM( `Total_Count` ) THEN "ALL FAILED | "
                                                                                                         ELSE

                                                                                                           CONCAT ( ROUND ( ( SUM( `Fail_Count` ) / SUM( `Total_Count` ) ) * 100, 0 ), "% FAILED | " )

                                                                                                         END ),

                                                  CONCAT ( "Raw Failure: ",   COUNT( CASE WHEN `Raw_Result`  = "FAIL" THEN 1 END ), " | " ),
                                                  CONCAT ( "3pnt Failure: ",  COUNT( CASE WHEN `3pnt_Result` = "FAIL" THEN 1 END ), " | " ),
                                                  CONCAT ( "Mono Failure: ",  COUNT( CASE WHEN `Mono_Result` = "FAIL" THEN 1 END ), " | " ),

                                                  CONCAT ( "Total Failure: ", SUM( `Fail_Count` ), " of ", SUM( `Total_Count` ), " points checked." )

                                                )

                                       END

              ) AS ``

     FROM ACSBV3_0403_report WHERE `Script` = @Script AND `Report` = `ARG_Report` AND `Version` = @Version AND `Focal_Point` > 0

     UNION ALL

     SELECT

       CONCAT (

                "                    ",

                CASE WHEN COUNT(*) = 0 THEN ""
                                       ELSE

                                         CONCAT (

                                                  "           | ",

                                                  ( CASE WHEN COUNT(*) = 1 THEN "One Focal-Point with "
                                                         WHEN COUNT(*) > 1 THEN CONCAT ( COUNT(*), " Focal-Points with " ) END ),

                                                  ( CASE WHEN SUM( `Focal_Point` ) = 1 THEN "one point of contact found in report. | "
                                                         WHEN SUM( `Focal_Point` ) > 1 THEN CONCAT ( SUM( `Focal_Point` ), " points of contact (", ROUND( AVG( `Focal_Point` ), 0 )," avg per point) found in report. " ) END )

                                                )

                                       END

              ) AS ``

     FROM ACSBV3_0403_report WHERE `Script` = @Script AND `Report` = `ARG_Report` AND `Version` = @Version AND `Focal_Point` > 0;

END $$

DELIMITER ;



/*=============================================================================================================================================
  4. Create Print Outlier Procedure: ACSBV3_print_outlier
=============================================================================================================================================*/

SELECT "Creating Procedure: ACSBV3_print_outlier" AS ``;

DELIMITER $$

DROP PROCEDURE IF EXISTS ACSBV3_print_outlier $$

CREATE PROCEDURE ACSBV3_print_outlier ( IN `ARG_Report` INT, IN `ARG_Group` VARCHAR(255), IN `ARG_Limit` INT, IN `ARG_Order` VARCHAR(255) )

BEGIN

  /* Set Report Order */

     CASE

       WHEN `ARG_Order` NOT LIKE "%DEFAULT%" THEN SET `ARG_Order` := `ARG_Order`;
                                             ELSE SET `ARG_Order` := "`Mono_Average` DESC, `3pnt_Average` DESC, `Raw_Average` DESC";

     END CASE;



  /* Print Outlier Report */

     SET @Query := CONCAT('

                            SELECT

                              CONCAT ( " | ", RPAD ( ', `ARG_Group`, ', 12, " " ), " ", LPAD ( CONCAT ( `Total_Items`, " items" ), 11, " " ), " |" ) AS `Group_Information`,

                              CONCAT (  "| ", `Raw_Minimum`,  " - ", `Raw_Maximum`,  " |" ) AS `Raw_Outliers`,
                              CONCAT (  "| ", `3pnt_Minimum`, " - ", `3pnt_Maximum`, " |" ) AS `3pnt_Outliers`,
                              CONCAT (  "| ", `Mono_Minimum`, " - ", `Mono_Maximum`, " |" ) AS `Mono_Outliers`,

                              CONCAT (  "| ", RPAD ( `Outlier_Count`, 5, " " ), " |", ( CASE WHEN `Focal_Point` =  0 THEN "                "
                                                                                             WHEN `Focal_Point` >= 1 THEN " <- Focal Point " END ) ) AS `Total_Outliers`

                            FROM ACSBV3_0403_report WHERE `Script` = "', @Script, '" AND `Report` = ', `ARG_Report`, ' AND `Version` = ', @Version, '
                            ORDER BY ', `ARG_Order`, ' LIMIT ', `ARG_Limit`, ';

                          ');

     PREPARE stmt FROM @Query;
     EXECUTE stmt;
     DEALLOCATE PREPARE stmt;

END $$

DELIMITER ;



/*=============================================================================================================================================
  5. Create Print Item Report Procedure: ACSBV3_print_item_report
=============================================================================================================================================*/

SELECT "Creating Procedure: ACSBV3_print_item_report" AS ``;

DELIMITER $$

DROP PROCEDURE IF EXISTS ACSBV3_print_item_report $$

CREATE PROCEDURE ACSBV3_print_item_report ( IN `ARG_Entry` INT, IN `ARG_Width` INT )

BEGIN

  /* Collect Required Information */

     SELECT

       `entry`, `name`, `ItemLevel`,
       `drop_environment`, `source_type`, `FamilyID`, `SlotID`, `QualityName`

     INTO

       @VAR_Entry, @VAR_Name, @VAR_iLvl,
       @VAR_Drop, @VAR_Source, @VAR_Family, @VAR_Slot, @VAR_Quality

     FROM ACSBV3_doc_item_template WHERE `entry` = `ARG_Entry`;



  /* Print Report Header */

     SELECT "" AS `` UNION ALL

     SELECT CONCAT ( "    +--", RPAD (             "", `ARG_Width`, "-" ), "--+    " ) AS `` UNION ALL
     SELECT CONCAT ( "    |  ", RPAD ( "Item Report:", `ARG_Width`, " " ), "  |    " ) AS `` UNION ALL
     SELECT CONCAT ( "    +--", RPAD (             "", `ARG_Width`, "-" ), "--+    " ) AS `` UNION ALL
     SELECT CONCAT ( "    |  ", RPAD (             "", `ARG_Width`, " " ), "  |    " ) AS `` UNION ALL



  /* Print Basic Information */

     SELECT CONCAT ( "    |  ", RPAD ( CONCAT ( "Entry:    ", @VAR_Entry, " - ", @VAR_Name ), `ARG_Width`, " " ), "  |    " ) AS `` UNION ALL

     SELECT CONCAT ( "    |  ", RPAD ( "", `ARG_Width`, " " ), "  |    " ) AS `` UNION ALL

     SELECT CONCAT ( "    |  ", RPAD ( CONCAT ( "Metadata: ",    @VAR_Drop,
                                                       " - ",  @VAR_Source,
                                                       " - ",  @VAR_Family,
                                                       " - ",    @VAR_Slot,
                                                       " - ", @VAR_Quality,
                                                       " - ",    @VAR_iLvl ), `ARG_Width`, " " ), "  |    " ) AS `` UNION ALL

     SELECT CONCAT ( "    |  ", RPAD ( "", `ARG_Width`, " " ), "  |    " ) AS `` UNION ALL
     SELECT CONCAT ( "    |  ", RPAD ( "", `ARG_Width`, "." ), "  |    " ) AS `` UNION ALL



  /* Print Stat Information */

     SELECT CONCAT ( "    |  ", RPAD (                  "", `ARG_Width`, " " ), "  |    " ) AS `` UNION ALL
     SELECT CONCAT ( "    |  ", RPAD ( "Stat Information:", `ARG_Width`, " " ), "  |    " ) AS `` UNION ALL
     SELECT CONCAT ( "    |  ", RPAD (                  "", `ARG_Width`, " " ), "  |    " ) AS `` UNION ALL



     SELECT CONCAT ( "    |  ", RPAD ( CONCAT ( " - Stats:  ",

                                                ( CASE WHEN `stat_value1`  > 0 THEN CONCAT (   "( ", `stat_type1`,  " | ", `stat_value1`,  " * ", `stat_cost1`,  " = ", ROUND ( `stat_total1`,  0 ), " ) " ) ELSE "" END ),
                                                ( CASE WHEN `stat_value2`  > 0 THEN CONCAT ( "+ ( ", `stat_type2`,  " | ", `stat_value2`,  " * ", `stat_cost2`,  " = ", ROUND ( `stat_total2`,  0 ), " ) " ) ELSE ( CASE WHEN `stat_value1` > 0 THEN "= " ELSE "" END ) END ),
                                                ( CASE WHEN `stat_value3`  > 0 THEN CONCAT ( "+ ( ", `stat_type3`,  " | ", `stat_value3`,  " * ", `stat_cost3`,  " = ", ROUND ( `stat_total3`,  0 ), " ) " ) ELSE ( CASE WHEN `stat_value2` > 0 THEN "= " ELSE "" END ) END ),
                                                ( CASE WHEN `stat_value4`  > 0 THEN CONCAT ( "+ ( ", `stat_type4`,  " | ", `stat_value4`,  " * ", `stat_cost4`,  " = ", ROUND ( `stat_total4`,  0 ), " ) " ) ELSE ( CASE WHEN `stat_value3` > 0 THEN "= " ELSE "" END ) END ),
                                                ( CASE WHEN `stat_value5`  > 0 THEN CONCAT ( "+ ( ", `stat_type5`,  " | ", `stat_value5`,  " * ", `stat_cost5`,  " = ", ROUND ( `stat_total5`,  0 ), " ) " ) ELSE ( CASE WHEN `stat_value4` > 0 THEN "= " ELSE "" END ) END ),
                                                ( CASE WHEN `stat_value6`  > 0 THEN CONCAT ( "+ ( ", `stat_type6`,  " | ", `stat_value6`,  " * ", `stat_cost6`,  " = ", ROUND ( `stat_total6`,  0 ), " ) " ) ELSE ( CASE WHEN `stat_value5` > 0 THEN "= " ELSE "" END ) END ),
                                                ( CASE WHEN `stat_value7`  > 0 THEN CONCAT ( "+ ( ", `stat_type7`,  " | ", `stat_value7`,  " * ", `stat_cost7`,  " = ", ROUND ( `stat_total7`,  0 ), " ) " ) ELSE ( CASE WHEN `stat_value6` > 0 THEN "= " ELSE "" END ) END ),
                                                ( CASE WHEN `stat_value8`  > 0 THEN CONCAT ( "+ ( ", `stat_type8`,  " | ", `stat_value8`,  " * ", `stat_cost8`,  " = ", ROUND ( `stat_total8`,  0 ), " ) " ) ELSE ( CASE WHEN `stat_value7` > 0 THEN "= " ELSE "" END ) END ),
                                                ( CASE WHEN `stat_value9`  > 0 THEN CONCAT ( "+ ( ", `stat_type9`,  " | ", `stat_value9`,  " * ", `stat_cost9`,  " = ", ROUND ( `stat_total9`,  0 ), " ) " ) ELSE ( CASE WHEN `stat_value8` > 0 THEN "= " ELSE "" END ) END ),
                                                ( CASE WHEN `stat_value10` > 0 THEN CONCAT ( "+ ( ", `stat_type10`, " | ", `stat_value10`, " * ", `stat_cost10`, " = ", ROUND ( `stat_total10`, 0 ), " ) " ) ELSE ( CASE WHEN `stat_value9` > 0 THEN "= " ELSE "" END ) END ),

                                                ( CASE WHEN `stat_value1` > 0 AND `stat_value2` = 0 THEN "= " ELSE "" END ),

                                                `stat_sum` ), `ARG_Width`, " " ), "  |    " ) AS ``

     FROM ACSBV3_doc_item_template WHERE `entry` = `ARG_Entry` UNION ALL



     SELECT CONCAT ( "    |  ", RPAD ( "", `ARG_Width`, " " ), "  |    " ) AS `` UNION ALL

     SELECT CONCAT ( "    |  ", RPAD ( ( CASE WHEN `DPS` = 0 THEN          " - DPS:    0"
                                                             ELSE CONCAT ( " - DPS:    (", `dmg_min1`, " + ", `dmg_max1`, ") / 2 / (", `delay`, " * 1000) = ", `DPS` )
                                         END ), `ARG_Width`, " " ), "  |    " ) AS ``
     FROM ACSBV3_doc_item_template WHERE `entry` = `ARG_Entry` UNION ALL



     SELECT CONCAT ( "    |  ", RPAD ( "", `ARG_Width`, " " ), "  |    " ) AS `` UNION ALL

     SELECT CONCAT ( "    |  ", RPAD ( ( CASE WHEN `armor` = 0 THEN          " - Armor:  0"
                                                               ELSE CONCAT ( " - Armor:  ", `armor`, " * 0.20 = ", `armorCost` )
                                         END ), `ARG_Width`, " " ), "  |    " ) AS ``
     FROM ACSBV3_doc_item_template WHERE `entry` = `ARG_Entry` UNION ALL



     SELECT CONCAT ( "    |  ", RPAD ( "", `ARG_Width`, " " ), "  |    " ) AS `` UNION ALL

     SELECT CONCAT ( "    |  ", RPAD ( ( CASE WHEN `socketBonus` = 0 THEN          " - Socket: 0"
                                                                     ELSE CONCAT ( " - Socket: ", `socketBonus`, " = ", `socketCost` )
                                         END ), `ARG_Width`, " " ), "  |    " ) AS ``
     FROM ACSBV3_doc_item_template WHERE `entry` = `ARG_Entry` UNION ALL



     SELECT CONCAT ( "    |  ", RPAD ( "", `ARG_Width`, " " ), "  |    " ) AS `` UNION ALL

     SELECT CONCAT ( "    |  ", RPAD ( CONCAT ( " - Budget: ",
                                                    "Stats (",      `stat_sum`, ") + ",
                                                      "DPS (",           `DPS`, ") + ",
                                                    "Armor (",     `armorCost`, ") + ",
                                                   "Socket (",    `socketCost`, ") = ", `budget_actual` ), `ARG_Width`, " " ), "  |    " ) AS ``
     FROM ACSBV3_doc_item_template WHERE `entry` = `ARG_Entry` UNION ALL



     SELECT CONCAT ( "    |  ", RPAD ( "", `ARG_Width`, " " ), "  |    " ) AS `` UNION ALL
     SELECT CONCAT ( "    |  ", RPAD ( "", `ARG_Width`, "." ), "  |    " ) AS `` UNION ALL



  /* Print Budget Information */

     SELECT CONCAT ( "    |  ", RPAD (                    "", `ARG_Width`, " " ), "  |    " ) AS `` UNION ALL
     SELECT CONCAT ( "    |  ", RPAD ( "Budget Information:", `ARG_Width`, " " ), "  |    " ) AS `` UNION ALL
     SELECT CONCAT ( "    |  ", RPAD (                    "", `ARG_Width`, " " ), "  |    " ) AS `` UNION ALL



     SELECT CONCAT ( "    |  ", RPAD ( CONCAT ( " - Budget: ", `budget_actual`, " / (", `mod_drop`, " * ", `mod_source`, " * ", `mod_misc`, " * ", `mod_slot`, ") = ",
                                                               `budget_normalized` ), `ARG_Width`, " " ), "  |    " ) AS ``
     FROM ACSBV3_doc_item_template WHERE `entry` = `ARG_Entry` UNION ALL



     SELECT CONCAT ( "    |  ", RPAD ( "", `ARG_Width`, " " ), "  |    " ) AS `` UNION ALL

     SELECT CONCAT ( "    |  ", RPAD ( CONCAT ( " - ", `CurveName`, " Target (Raw):  ", `budget_target1`,    " - ",
                                                                                        `budget_normalized`, " = ",
                                                                                        `budget_diff1`,      " (", ROUND ( `budget_perc1` * 100, 2 ), "%)" ), `ARG_Width`, " " ), "  |    " ) AS ``
     FROM ACSBV3_0402A_diagnostic_dataset WHERE `entry` = `ARG_Entry` UNION ALL

     SELECT CONCAT ( "    |  ", RPAD ( CONCAT ( " - ", `CurveName`, " Target (3pnt): ", `budget_target2`,    " - ",
                                                                                        `budget_normalized`, " = ",
                                                                                        `budget_diff2`,      " (", ROUND ( `budget_perc2` * 100, 2 ), "%)" ), `ARG_Width`, " " ), "  |    " ) AS ``
     FROM ACSBV3_0402A_diagnostic_dataset WHERE `entry` = `ARG_Entry` UNION ALL

     SELECT CONCAT ( "    |  ", RPAD ( CONCAT ( " - ", `CurveName`, " Target (Mono): ", `budget_target3`,    " - ",
                                                                                        `budget_normalized`, " = ",
                                                                                        `budget_diff3`,      " (", ROUND ( `budget_perc3` * 100, 2 ), "%)" ), `ARG_Width`, " " ), "  |    " ) AS ``
     FROM ACSBV3_0402A_diagnostic_dataset WHERE `entry` = `ARG_Entry` UNION ALL



     SELECT CONCAT ( "    |  ", RPAD ( "", `ARG_Width`, " " ), "  |    " ) AS `` UNION ALL
     SELECT CONCAT ( "    |  ", RPAD ( "", `ARG_Width`, "." ), "  |    " ) AS `` UNION ALL



  /* Print Group Information */

     SELECT CONCAT ( "    |  ", RPAD (                   "", `ARG_Width`, " " ), "  |    " ) AS `` UNION ALL
     SELECT CONCAT ( "    |  ", RPAD ( "Group Information:", `ARG_Width`, " " ), "  |    " ) AS `` UNION ALL
     SELECT CONCAT ( "    |  ", RPAD (                   "", `ARG_Width`, " " ), "  |    " ) AS `` UNION ALL

     SELECT CONCAT ( "    |  ", RPAD ( "  +-------+---------+------------+-----------+-------------+-----------+------+ ", `ARG_Width`, " " ), "  |    " ) AS `` UNION ALL
     SELECT CONCAT ( "    |  ", RPAD ( "  |       |    Drop |     Source |    Family |        Slot |   Quality | iLvl | ", `ARG_Width`, " " ), "  |    " ) AS `` UNION ALL
     SELECT CONCAT ( "    |  ", RPAD ( "  +-------+---------+------------+-----------+-------------+-----------+------+ ", `ARG_Width`, " " ), "  |    " ) AS `` UNION ALL

     SELECT CONCAT ( "    |  ", RPAD ( CONCAT ( "  | Info  | ", LPAD ( @VAR_Drop,     7, " " ), " | ",
                                                                LPAD ( @VAR_Source,  10, " " ), " | ",
                                                                LPAD ( @VAR_Family,   9, " " ), " | ",
                                                                LPAD ( @VAR_Slot,    11, " " ), " | ",
                                                                LPAD ( @VAR_Quality,  9, " " ), " | ",
                                                                LPAD ( @VAR_iLvl,     4, " " ), " | " ), `ARG_Width`, " " ), "  |    " ) AS `` UNION ALL

     SELECT CONCAT ( "    |  ", RPAD ( CONCAT ( "  | Total | ", LPAD ( COUNT( CASE WHEN `drop_environment` = @VAR_Drop    THEN 1 END ),  7, " " ), " | ",
                                                                LPAD ( COUNT( CASE WHEN `source_type`      = @VAR_Source  THEN 1 END ), 10, " " ), " | ",
                                                                LPAD ( COUNT( CASE WHEN `FamilyID`         = @VAR_Family  THEN 1 END ),  9, " " ), " | ",
                                                                LPAD ( COUNT( CASE WHEN `SlotID`           = @VAR_Slot    THEN 1 END ), 11, " " ), " | ",
                                                                LPAD ( COUNT( CASE WHEN `QualityName`      = @VAR_Quality THEN 1 END ),  9, " " ), " | ",
                                                                LPAD ( COUNT( CASE WHEN `ItemLevel`        = @VAR_iLvl    THEN 1 END ),  4, " " ), " | " ), `ARG_Width`, " " ), "  |    " ) AS ``
     FROM ACSBV3_doc_item_template UNION ALL



     SELECT CONCAT ( "    |  ", RPAD ( "  +-------+---------+------------+-----------+-------------+-----------+------+ ", `ARG_Width`, " " ), "  |    " ) AS `` UNION ALL



  /* Print Report Footer */

     SELECT CONCAT ( "    |  ", RPAD ( "", `ARG_Width`, " " ), "  |    " ) AS `` UNION ALL
     SELECT CONCAT ( "    +--", RPAD ( "", `ARG_Width`, "-" ), "--+    " ) AS `` UNION ALL

     SELECT "" AS ``;

END $$

DELIMITER ;



SELECT "Script Complete: Run script \"ACSBV3-04-03B\" to start generating reports." AS ``;



/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
