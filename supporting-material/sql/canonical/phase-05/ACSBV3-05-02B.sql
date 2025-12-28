/*=============================================================================================================================================
  Filename:       ACSBV3-05-02B.sql
  Title:          Create Reporting Procedure.
  Author:         Aumuz Messick
  Version:        2.0
  Created:        2025-12-01
  Description:    This script will create a reusable procedure for curve reporting.

-----------------------------------------------------------------------------------------------------------------------------------------------
  Updates:
   - v1.0 -> Script Created.
   - v2.0 -> (2025-12-03) Added mod_misc support.

=============================================================================================================================================*/



/*=============================================================================================================================================
  0.1 - Update MYSQL Collation for AzerothCore:
=============================================================================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';



/*=============================================================================================================================================
  0.2 - Set Script Variables:
=============================================================================================================================================*/

SET @SCRIPT  := "0502B",
    @VERSION := "2.0";



/*=============================================================================================================================================
  1. Create Report Table: ACSBV3_0502B_report
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "1. Create Report Table: ACSBV3_0502B_report" );

DROP   TABLE IF EXISTS ACSBV3_0502B_report;

CREATE TABLE           ACSBV3_0502B_report
(

  `Script`         VARCHAR(5)    NOT NULL,
  `Version`        VARCHAR(5)    NOT NULL,
  `Report`         TINYINT       NOT NULL,

  `Group`          VARCHAR(25)   NOT NULL,
  `GroupName`      VARCHAR(50)   NOT NULL,

  `GoalMin`        DECIMAL(12,5) NOT NULL,
  `GoalMax`        DECIMAL(12,5) NOT NULL,

  `Average_Raw`    DECIMAL(12,5) NOT NULL, `RawMin`  DECIMAL(12,5) NOT NULL, `RawMax`  DECIMAL(12,5) NOT NULL,
  `Average_3pnt`   DECIMAL(12,5) NOT NULL, `3pntMin` DECIMAL(12,5) NOT NULL, `3pntMax` DECIMAL(12,5) NOT NULL,
  `Average_Mono`   DECIMAL(12,5) NOT NULL, `MonoMin` DECIMAL(12,5) NOT NULL, `MonoMax` DECIMAL(12,5) NOT NULL,

  `Result_Avg`     TINYINT       NOT NULL,
  `Result_Min`     TINYINT       NOT NULL,
  `Result_Max`     TINYINT       NOT NULL,

  `Count_Group`    INT           NOT NULL,
  `Count_Outlier`  INT           NOT NULL,

  `modifier_old`   DECIMAL(8,2)  NOT NULL,
  `modifier_new`   DECIMAL(8,2)  NOT NULL

);

SELECT "Table Created: ACSBV3_0502B_report" AS ``;



/*=============================================================================================================================================
  2. Create Generate Report Procedure: ACSBV3_generate_report
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "2. Create Generate Report Procedure: ACSBV3_generate_report" );



DELIMITER $$

DROP PROCEDURE IF EXISTS ACSBV3_generate_report $$

CREATE PROCEDURE ACSBV3_generate_report ( IN `ARG_Report` INT, IN `ARG_Group` VARCHAR(16) )



BEGIN



  /* Set Report Variables */

     SET @REPORT    := `ARG_Report`,
         @GROUP     := ( CASE WHEN `ARG_Group` = "Global"  THEN 1 ELSE CONCAT ( "d.", `ARG_Group` ) END ),
         @GROUPNAME := ( CASE WHEN `ARG_Group` = "Quality" THEN "d.QualityName"
                              WHEN `ARG_Group` = "slot"    THEN "d.slot_name"
                              WHEN `ARG_Group` = "Global"  THEN 1 ELSE CONCAT ( "d.", `ARG_Group` ) END );



  /* Collect Report Data */

     DELETE FROM ACSBV3_0502B_report WHERE `Script`  = @SCRIPT
                                       AND `Version` = @VERSION
                                       AND `Report`  = @REPORT;

     SET @QUERY := CONCAT ( ' INSERT INTO ACSBV3_0502B_report SELECT

                                "', @SCRIPT,    '" AS    `Script`,
                                "', @VERSION,   '" AS   `Version`,
                                 ', @REPORT,    '  AS    `Report`,

                                 ', @GROUP,     '  AS     `Group`,
                                 ', @GROUPNAME, '  AS `GroupName`,

                                 ', @GoalMin,   '  AS   `GoalMin`,
                                 ', @GoalMax,   '  AS   `GoalMax`,

                                   AVG( d.`budget_normalized` / d.`budget_target_raw`  ) AS `Average_Raw`,  MIN( d.`budget_perc_raw`  ) AS  `RawMin`, MAX( d.`budget_perc_raw`  ) AS  `RawMax`,
                                   AVG( d.`budget_normalized` / d.`budget_target_3pnt` ) AS `Average_3pnt`, MIN( d.`budget_perc_3pnt` ) AS `3pntMin`, MAX( d.`budget_perc_3pnt` ) AS `3pntMax`,
                                   AVG( d.`budget_normalized` / d.`budget_target_mono` ) AS `Average_Mono`, MIN( d.`budget_perc_mono` ) AS `MonoMin`, MAX( d.`budget_perc_mono` ) AS `MonoMax`,

                                      ( CASE WHEN AVG( d.`budget_normalized` / d.`budget_target_mono` ) BETWEEN ', @GoalMin, ' AND ', @GoalMax, ' THEN 1 ELSE 0 END ) AS `Result_Avg`,
                                      ( CASE WHEN MIN( d.`budget_perc_mono` )                           BETWEEN ', @GoalMin, ' AND ', @GoalMax, ' THEN 1 ELSE 0 END ) AS `Result_Min`,
                                      ( CASE WHEN MAX( d.`budget_perc_mono` )                           BETWEEN ', @GoalMin, ' AND ', @GoalMax, ' THEN 1 ELSE 0 END ) AS `Result_Max`,

                                   COUNT(*) AS `Count_Group`,
                                   COUNT( CASE WHEN d.`budget_perc_mono` NOT BETWEEN ', @GoalMin, ' AND ', @GoalMax, ' THEN 1 END ) AS `Count_Outlier`,

                                   0 AS `modifier_old`,
                                   0 AS `modifier_new`

                              FROM ACSBV3_ref_dataset AS d
                              GROUP BY ', ( CASE WHEN @GROUP != @GROUPNAME THEN CONCAT ( @GROUP, ", ", @GROUPNAME ) ELSE @GROUP END ) );

     PREPARE stmt FROM @QUERY;
     EXECUTE stmt;
     DEALLOCATE PREPARE stmt;



  /* Update Modifier Recommendations */

     UPDATE    ACSBV3_0502B_report AS r
     LEFT JOIN ACSBV3_ref_drop     AS d    ON r.`Group` =    d.`drop_environment`
     LEFT JOIN ACSBV3_ref_source   AS s    ON r.`Group` =    s.`source_type`
     LEFT JOIN ACSBV3_ref_slot     AS slot ON r.`Group` = slot.`slot`
     SET r.`modifier_old` = ( CASE WHEN `ARG_Group` = "mod_misc" THEN r.`Group` ELSE ( COALESCE ( d.`modifier`, s.`modifier`, slot.`modifier`, 0.00 ) ) END )
     WHERE r.`Script`  = @SCRIPT
       AND r.`Version` = @VERSION
       AND r.`Report`  = @REPORT;

     UPDATE ACSBV3_0502B_report
     SET `modifier_new` = ( CASE WHEN `modifier_old` = 0                             THEN              0 ELSE
                            CASE WHEN `Average_Mono` BETWEEN `GoalMin` AND `GoalMax` THEN `modifier_old` ELSE ( `modifier_old` * `Average_Mono` ) END END );



  /* Print Curve Report */

     SET @COUNT := ( SELECT COUNT(*) FROM ACSBV3_ref_dataset );

     SELECT CONCAT ( "Curve Report: ", `ARG_Group` ) AS ``;

     SELECT "  +----------------------------------------------------+-------+--------------+--------------+--------------+------------------+" AS `` UNION ALL
     SELECT "  | Group                                              | Count |  Raw Average | 3pnt Average | Mono Average |        PASS/FAIL |" AS `` UNION ALL
     SELECT "  +----------------------------------------------------+-------+--------------+--------------+--------------+------------------+" AS `` UNION ALL

     SELECT CONCAT ( "  | ", RPAD ( `GroupName`, 50, " " ), " | ", RPAD ( `Count_Group`,   5, " " ), " | ",
                                                                   LPAD ( `Average_Raw`,  12, " " ), " | ",
                                                                   LPAD ( `Average_3pnt`, 12, " " ), " | ",
                                                                   LPAD ( `Average_Mono`, 12, " " ), " | ",

                                                                        ( CASE WHEN ( `Result_Avg` + `Result_Min` + `Result_Max` ) = 0 THEN "ALL FAIL: 0 of 3 |"
                                                                               WHEN ( `Result_Avg` + `Result_Min` + `Result_Max` ) = 1 THEN "    PASS: 1 of 3 |"
                                                                               WHEN ( `Result_Avg` + `Result_Min` + `Result_Max` ) = 2 THEN "    PASS: 2 of 3 |"
                                                                               WHEN ( `Result_Avg` + `Result_Min` + `Result_Max` ) = 3 THEN "ALL PASS: 3 of 3 |" END ) ) AS ``

     FROM ACSBV3_0502B_report WHERE `Script`  = @SCRIPT
                                AND `Version` = @VERSION
                                AND `Report`  = @REPORT  UNION ALL

     SELECT "  +----------------------------------------------------+-------+--------------+--------------+--------------+------------------+" AS ``;

     SELECT CONCAT ( "    Report Summary: PASS/FAIL Condition between ", ROUND ( MIN( `GoalMin` ), 2 ), " and ", ROUND ( MAX( `GoalMax` ), 2 ), "." ) AS ``
     FROM ACSBV3_0502B_report WHERE `Script`  = @SCRIPT
                                AND `Version` = @VERSION
                                AND `Report`  = @REPORT;

     SELECT CONCAT ( "     - ", ( CASE WHEN ( SUM( `Result_Avg` ) / COUNT(*) ) BETWEEN MIN( `GoalMin` ) AND MAX( `GoalMax` ) THEN "PASS: " ELSE "FAIL: " END ),
                     SUM( `Result_Avg` ), " of ", COUNT(*), " (", ROUND ( ( SUM( `Result_Avg` ) / COUNT(*) ) * 100, 0 ), "%) groups align to their corresponding curves." ) AS ``
     FROM ACSBV3_0502B_report WHERE `Script`  = @SCRIPT
                                AND `Version` = @VERSION
                                AND `Report`  = @REPORT;

     SELECT CONCAT ( "     - ", ( CASE WHEN SUM( `Count_Group` ) = @COUNT THEN "PASS: " ELSE "FAIL: " END ),
                     "This script accounts for ", SUM( `Count_Group` ), " of ", @COUNT, " (", ROUND ( ( SUM( `Count_Group` ) / @COUNT ) * 100, 0 ), "%) dataset items." ) AS ``
     FROM ACSBV3_0502B_report WHERE `Script`  = @SCRIPT
                                AND `Version` = @VERSION
                                AND `Report`  = @REPORT;



  /* Print Outlier Report */

     SELECT "" AS `` UNION ALL
     SELECT "" AS `` UNION ALL
     SELECT CONCAT ( "Outlier Report: ", `ARG_Group` ) AS ``;

     SELECT "  +----------------------------------------------------+-------+--------------+--------------+--------------+------------------+" AS `` UNION ALL
     SELECT "  | Group                                              | Count | Mono Average |  Min Outlier |  Max Outlier |        PASS/FAIL |" AS `` UNION ALL
     SELECT "  +----------------------------------------------------+-------+--------------+--------------+--------------+------------------+" AS `` UNION ALL

     SELECT CONCAT ( "  | ", RPAD ( `GroupName`, 50, " " ), " | ", RPAD ( `Count_Group`,   5, " " ), " | ",
                                                                   LPAD ( `Average_Mono`, 12, " " ), " | ",
                                                                   LPAD ( `MonoMin`,      12, " " ), " | ",
                                                                   LPAD ( `MonoMax`,      12, " " ), " | ",

                                                                        ( CASE WHEN ( `Result_Avg` + `Result_Min` + `Result_Max` ) = 0 THEN "ALL FAIL: 0 of 3 |"
                                                                               WHEN ( `Result_Avg` + `Result_Min` + `Result_Max` ) = 1 THEN "    PASS: 1 of 3 |"
                                                                               WHEN ( `Result_Avg` + `Result_Min` + `Result_Max` ) = 2 THEN "    PASS: 2 of 3 |"
                                                                               WHEN ( `Result_Avg` + `Result_Min` + `Result_Max` ) = 3 THEN "ALL PASS: 3 of 3 |" END ) ) AS ``

     FROM ACSBV3_0502B_report WHERE `Script`  = @SCRIPT
                                AND `Version` = @VERSION
                                AND `Report`  = @REPORT  UNION ALL

     SELECT "  +----------------------------------------------------+-------+--------------+--------------+--------------+------------------+" AS ``;

     SELECT "  +----------------------------------------------------+-------+----------------+--------------+-----------+" AS `` UNION ALL
     SELECT "  | Group                                              | Count |  Outlier Count |    Outlier % | PASS/FAIL |" AS `` UNION ALL
     SELECT "  +----------------------------------------------------+-------+----------------+--------------+-----------+" AS `` UNION ALL

     SELECT CONCAT ( "  | ", RPAD ( `GroupName`, 50, " " ), " | ", RPAD ( `Count_Group`,    5, " " ), " | ",
                                                                   LPAD ( `Count_Outlier`, 14, " " ), " | ",

                                                                   LPAD ( ROUND ( ( `Count_Outlier` / `Count_Group` ) * 100, 0 ), 10, " " ), " % | ",

                                                                        ( CASE WHEN ( `Count_Outlier` / `Count_Group` ) BETWEEN 0.00 AND ( 1.00 - `GoalMin` ) THEN "PASS      |" ELSE "     FAIL |" END ) ) AS ``

     FROM ACSBV3_0502B_report WHERE `Script`  = @SCRIPT
                                AND `Version` = @VERSION
                                AND `Report`  = @REPORT  UNION ALL

     SELECT "  +----------------------------------------------------+-------+----------------+--------------+-----------+" AS ``;

     SELECT CONCAT ( "    Report Summary: PASS/FAIL Condition between ", ROUND ( MIN( `GoalMin` ), 2 ), " and ", ROUND ( MAX( `GoalMax` ), 2 ), ", or between 0% and ", ROUND ( ( 1.00 - MIN( `GoalMin` ) ) * 100, 0 ), "%." ) AS ``
     FROM ACSBV3_0502B_report WHERE `Script`  = @SCRIPT
                                AND `Version` = @VERSION
                                AND `Report`  = @REPORT;

     SELECT CONCAT ( "     - ", ( CASE WHEN ( SUM( `Count_Outlier` ) / SUM( `Count_Group` ) ) BETWEEN 0.00 AND ( 1.00 - MIN( `GoalMin` ) ) THEN "PASS: " ELSE "FAIL: " END ),
                     SUM( `Count_Outlier` ), " outliers of ", SUM( `Count_Group` ), " total items (", ROUND ( ( SUM( `Count_Outlier` ) / SUM( `Count_Group` ) ) * 100, 0 ), "%)." ) AS ``
     FROM ACSBV3_0502B_report WHERE `Script`  = @SCRIPT
                                AND `Version` = @VERSION
                                AND `Report`  = @REPORT;

     SELECT CONCAT ( "     - ", ( CASE WHEN SUM( `Count_Group` ) = @COUNT THEN "PASS: " ELSE "FAIL: " END ),
                     "This script accounts for ", SUM( `Count_Group` ), " of ", @COUNT, " (", ROUND ( ( SUM( `Count_Group` ) / @COUNT ) * 100, 0 ), "%) dataset items." ) AS ``
     FROM ACSBV3_0502B_report WHERE `Script`  = @SCRIPT
                                AND `Version` = @VERSION
                                AND `Report`  = @REPORT;



  /* Print Change Report */

     SELECT CONCAT ( "Change Report: ", `ARG_Group` ) AS ``;

     SELECT "  +----------------------------------------------------+-------+--------------+--------------+--------------+" AS `` UNION ALL
     SELECT "  | Group                                              | Count | Mono Average | Old Modifier | New Modifier |" AS `` UNION ALL
     SELECT "  +----------------------------------------------------+-------+--------------+--------------+--------------+" AS `` UNION ALL

     SELECT CONCAT ( "  | ", RPAD ( `GroupName`, 50, " " ), " | ", RPAD ( `Count_Group`,   5, " " ), " | ",
                                                                   LPAD ( `Average_Mono`, 12, " " ), " | ",
                                                                   LPAD ( `modifier_old`, 12, " " ), " | ",

                                                                   LPAD ( ( CASE WHEN `modifier_old` = `modifier_new` THEN "No Change" ELSE `modifier_new` END ), 12, " " ), " | ") AS ``

     FROM ACSBV3_0502B_report WHERE `Script`  = @SCRIPT
                                AND `Version` = @VERSION
                                AND `Report`  = @REPORT  UNION ALL

     SELECT "  +----------------------------------------------------+-------+--------------+--------------+--------------+" AS ``;



END $$

DELIMITER ;



SELECT "Procedure Created: ACSBV3_generate_report" AS ``;



CALL ACSBV3_print_footer ();

/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
