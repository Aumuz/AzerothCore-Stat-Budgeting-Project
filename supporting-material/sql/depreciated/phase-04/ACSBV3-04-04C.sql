/*=============================================================================================================================================
  Filename:       ACSBV3-04-04C.sql
  Title:          Overall Comparative Report.
  Author:         Aumuz Messick
  Version:        2.5
  Created:        2025-11-08
  Description:    This script generates a series of reports of broad groupings compared to each budget curve (curve_raw, curve_3pnt, curve_mono).

                  The following reports will be generated:

                   -  1. Overall Report: Compares all items and curves into one report (not generally useful).
                   -  2. Drop Report: Compares all items and curves, grouped by Drop Environment (not generally useful).
                   -  3. Source Report: Compares all items and curves, grouped by Item Source (not generally useful).
                   -  4. Curve Report: Compares all items within a curve.
                   -  5. Slot Report: Compares all items of similar FamilyID and SlotID to all curves.
                   -  6. iLvl Report: Compares all items of similar iLvl to all curves.
                   -  7. Focal-Point Report: Compares all Focal-Point items to relevant curve/s.
                   -  8. Outlier Report: Display highest and lowest percentage outliers for each report.

                  Reports with additional detail will be generated in upcoming scripts.

-----------------------------------------------------------------------------------------------------------------------------------------------
  Updates:
   - v2.0 -> Script Created (completely reworked from v1.0).
   - v2.1 -> (2025-11-10) Added print-out formatting: ACSBV3_print_info.
   - v2.2 -> (2025-11-10) Script renamed from ACSBV3-04-02B to ACSBV3-04-03B, moved procedures to ACSBV3-04-03A.
   - v2.3 -> (2025-11-18) Skipped to sync version numbers with pipeline (updated headers).
   - v2.4 -> (2025-11-18) Skipped to sync version numbers with pipeline (updated headers).
   - v2.5 -> (2025-11-24) Added ACSBV3_doc_armor support (unfinished).

=============================================================================================================================================*/



/*=============================================================================================================================================
  0.1 - Update MYSQL Collation for AzerothCore: utf8mb4_general_ci (needed to run procedures).
=============================================================================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';



DELETE FROM ACSBV3_0402A_diagnostic_dataset WHERE `CurveName` = "Q4E" OR `CurveName` = "Q4W";



/*=============================================================================================================================================
  0.2 - Set Diagnostic Variables:
=============================================================================================================================================*/

SET @Script      := "0404C",    -- Script Code.
    @Version     := 1.0;        -- Script Version.

SET @MinGoal     := 0.90,       -- Minimum Goal Value (v2.0 -> 0.90).
    @MaxGoal     := 1.10;       -- Maximum Goal Value (v2.0 -> 1.10).

                                -- v2.2 Values From ACSBV3-04-00Z Focal Point - Report.
SET @FocalPoint0 := "World",    -- Report Focus Drop Value    (v2.2 -> "World").
    @FocalPoint1 := "Rare",     -- Report Focus Quality Value (v2.2 -> "Epic").
    @FocalPoint2 := "Waist",    -- Report Focus Slot Value    (v2.2 -> "Legs").
    @FocalPoint3 := 115;        -- Report Focus iLvl Value    (v2.2 -> 200).



/*=============================================================================================================================================
  0.3 - Update Print Information Table: ACSBV3_print_info
=============================================================================================================================================*/

DELETE FROM ACSBV3_print_info WHERE `script` = @Script;

INSERT INTO ACSBV3_print_info ( `script`, `part`, `print`, `output` ) VALUES
( @Script, 2,  1, "##  1. Overall Report: Compares all items and curves into one report (not generally useful).                     (v2.4)  ##" ),
( @Script, 2,  2, "##  2. Drop Report: Compares all items and curves, grouped by Drop Environment (not generally useful).           (v2.4)  ##" ),
( @Script, 2,  3, "##  3. Source Report: Compares all items and curves, grouped by Item Source (not generally useful).              (v2.4)  ##" ),
( @Script, 2,  4, "##  4. Curve Report: Compares all items within a curve.                                                          (v2.4)  ##" ),
( @Script, 2,  5, "##  5. Slot Report: Compares all items of similar FamilyID and SlotID to all curves.                             (v2.4)  ##" ),
( @Script, 2,  6, "##  6. iLvl Report: Compares all items of similar iLvl to all curves.                                            (v2.4)  ##" ),
( @Script, 2,  7, "##  7. Focal-Point Report: Compares all Focal-Point items to relevant curve/s.                                   (v2.4)  ##" ),
( @Script, 2,  8, "##  8. Outlier Report: Display highest and lowest percentage outliers for each report.                           (v2.4)  ##" ),

( @Script, 3,  0, "##                                                                                                                       ##" ),
( @Script, 3,  0, "##      - PASS/FAIL Determined by 'value' BETWEEN 0.90 AND 1.10.                                                         ##" );



/*=============================================================================================================================================
  1. Overall Report: Compares all items and curves into one report (not generally useful).
=============================================================================================================================================*/

SET @VAR_Report1A := '',    -- unused
    @VAR_Report1B := '';    -- unused

CALL ACSBV3_generate_report ( 1, "NONE", "" );                         -- Generate Report
CALL ACSBV3_print_report    ( 1, ' "Global" ', "", "", "DEFAULT" );    -- Print Report



/*=============================================================================================================================================
  2. Drop Report: Compares all items and curves, grouped by Drop Environment (not generally useful).
=============================================================================================================================================*/

SET @VAR_Report2A := ' RPAD ( `Drop`, 7, " " ) ',
    @VAR_Report2B := ' CONCAT ( "| ", RPAD ( `Total_Items`, 5, " " ), " |" ) AS `Total_Items`, ';

CALL ACSBV3_generate_report ( 2, "`drop_environment`", "" );                       -- Generate Report
CALL ACSBV3_print_report    ( 2, @VAR_Report2A, @VAR_Report2B, "", "DEFAULT" );    -- Print Report



/*=============================================================================================================================================
  3. Source Report: Compares all items and curves, grouped by Item Source (not generally useful).
=============================================================================================================================================*/

SET @VAR_Report3A := ' RPAD ( `Source`, 10, " " ) ',
    @VAR_Report3B := ' CONCAT ( "| ", RPAD ( `Total_Items`, 5, " " ), " |" ) AS `Total_Items`, ';

CALL ACSBV3_generate_report ( 3, "`source_type`", "" );                            -- Generate Report
CALL ACSBV3_print_report    ( 3, @VAR_Report3A, @VAR_Report3B, "", "DEFAULT" );    -- Print Report



/*=============================================================================================================================================
  4. Curve Report: Compares all items within a curve.
=============================================================================================================================================*/

SET @VAR_Report4A := ' RPAD ( `Curve`, 3, " " ) ',
    @VAR_Report4B := ' CONCAT ( "| ", RPAD ( `Quality`, 9, " " ), " ", ( CASE WHEN `Curve` = "Q4E" THEN "Equipment |"
                                                                              WHEN `Curve` = "Q4W" THEN "Weapon    |"
                                                                                                   ELSE "ALL       |" END ) ) AS `Curve_Information`,

                       CONCAT ( "| ", RPAD ( `Total_Items`, 5, " " ), " |" ) AS `Total_Items`, ';

CALL ACSBV3_generate_report ( 4, "`CurveName`, `QualityName`", "" );               -- Generate Report
CALL ACSBV3_print_report    ( 4, @VAR_Report4A, @VAR_Report4B, "", "DEFAULT" );    -- Print Report



/*=============================================================================================================================================
  5. Slot Report: Compares all items of similar FamilyID and SlotID to all curves.
=============================================================================================================================================*/

SET @VAR_Report5A := ' RPAD ( `Slot`, 11, " " ) ',
    @VAR_Report5B := ' CONCAT ( "| ", RPAD ( `Family`,      9, " " ), " |" ) AS      `Family`,
                       CONCAT ( "| ", RPAD ( `Total_Items`, 5, " " ), " |" ) AS `Total_Items`, ';

CALL ACSBV3_generate_report ( 5, "`FamilyID`, `SlotID`", "" );                     -- Generate Report
CALL ACSBV3_print_report    ( 5, @VAR_Report5A, @VAR_Report5B, "", "DEFAULT" );    -- Print Report



/*=============================================================================================================================================
  6. iLvl Report: Compares all items of similar iLvl to all curves.
=============================================================================================================================================*/

SET @VAR_Report6A := ' RPAD ( `iLvl`, 3, " " ) ',
    @VAR_Report6B := ' CONCAT ( "| ", RPAD ( `Total_Items`, 5, " " ), " |" ) AS `Total_Items`, ';

CALL ACSBV3_generate_report ( 6, "`ItemLevel`", "" );    -- Generate Report
CALL ACSBV3_print_report    ( 6, @VAR_Report6A, @VAR_Report6B, "", "`Mono_Average` DESC, `3pnt_Average` DESC, `Raw_Average` DESC, `iLvl` ASC" );    -- Print Report



/*=============================================================================================================================================
  7. Focal-Point Report: Compares all Focal-Point items to relevant curve/s.
=============================================================================================================================================*/

SET @VAR_Report7A := "`drop_environment`, `CurveName`, `QualityName`, `FamilyID`, `SlotID`, `ItemLevel`",
    @VAR_Report7B := "WHERE `drop_environment` = @FocalPoint0 AND `QualityName` = @FocalPoint1 AND `SlotID` = @FocalPoint2 AND `ItemLevel` = @FocalPoint3";

SET @VAR_Report7C := ' RPAD ( `Curve`, 3, " " ) ',
    @VAR_Report7D := ' CONCAT ( "| ", RPAD ( `Quality`, 9, " " ), " ", ( CASE WHEN `Curve` = "Q4E" THEN "Equipment |"
                                                                              WHEN `Curve` = "Q4W" THEN "Weapon    |"
                                                                                                   ELSE "ALL       |" END ) ) AS `Curve_Information`,

                       CONCAT ( "| ", RPAD ( `Slot`, 11, " " ), " ", RPAD ( `iLvl`,    3, " " ), " |" ) AS `Item_Information`,
                       CONCAT ( "| ", RPAD ( `Drop`,  7, " " ), " ", RPAD ( `Source`, 10, " " ), " |" ) AS `Drop_Information`,

                       CONCAT ( "| ", RPAD ( `Total_Items`, 5, " " ), " |" ) AS `Total_Items`, ';

CALL ACSBV3_generate_report ( 7, @VAR_Report7A, @VAR_Report7B );                   -- Generate Report
CALL ACSBV3_print_report    ( 7, @VAR_Report7C, @VAR_Report7D, "", "DEFAULT" );    -- Print Report



SELECT " - 4.A - Focal-Point Detail: Highest Percentage Outliers." AS `` UNION ALL SELECT "" AS ``;

SELECT

  CONCAT ( " | ", RPAD ( `CurveName`, 3, " " ), " ", RPAD ( `source_type`, 10, " " ), " ", `entry`, " ", RPAD ( `name`, 25, " " ), " |" ) AS `Item_Info`,

  CONCAT ( "| ", `mod_drop`, " ", `mod_misc`, " ", `mod_slot`, " |" ) AS `Modifiers`,

  CONCAT ( "| Raw: ",  ROUND ( `budget_normalized`, 4 ), " - ", ROUND ( `budget_target1`, 4 ), " = ", RPAD ( `budget_diff1`, 9, " " ), " (", LPAD ( ROUND ( ( `budget_perc1` * 100 ), 2 ), 6, " " ), "%) ",
           "| 3pnt: ", ROUND ( `budget_normalized`, 4 ), " - ", ROUND ( `budget_target2`, 4 ), " = ", RPAD ( `budget_diff2`, 9, " " ), " (", LPAD ( ROUND ( ( `budget_perc2` * 100 ), 2 ), 6, " " ), "%) ",
           "| Mono: ", ROUND ( `budget_normalized`, 4 ), " - ", ROUND ( `budget_target3`, 4 ), " = ", RPAD ( `budget_diff3`, 9, " " ), " (", LPAD ( ROUND ( ( `budget_perc3` * 100 ), 2 ), 6, " " ), "%) |"  ) AS `Budget_Info`

FROM ACSBV3_0402A_diagnostic_dataset
  WHERE `drop_environment` = @FocalPoint0 AND `QualityName` = @FocalPoint1 AND `SlotID` = @FocalPoint2 AND `ItemLevel` = @FocalPoint3
  ORDER BY `budget_perc3` DESC, `budget_perc2` DESC, `budget_perc1` DESC, `entry` ASC LIMIT 5;



SELECT "" AS `` UNION ALL
SELECT " - 4.B - Focal-Point Detail: Lowest Percentage Outliers." AS `` UNION ALL SELECT "" AS ``;

SELECT

  CONCAT ( " | ", RPAD ( `CurveName`, 3, " " ), " ", RPAD ( `source_type`, 10, " " ), " ", `entry`, " ", RPAD ( `name`, 25, " " ), " |" ) AS `Item_Info`,

  CONCAT ( "| ", `mod_drop`, " ", `mod_misc`, " ", `mod_slot`, " |" ) AS `Modifiers`,

  CONCAT ( "| Raw: ",  LPAD ( ROUND ( `budget_normalized`, 4 ), 8, " " ), " - ", LPAD ( ROUND ( `budget_target1`, 4 ), 8, " " ), " = ", LPAD ( RPAD ( `budget_diff1`, 9, " " ), 8, " " ), " (", LPAD ( ROUND ( ( `budget_perc1` * 100 ), 2 ), 6, " " ), "%) ",
           "| 3pnt: ", LPAD ( ROUND ( `budget_normalized`, 4 ), 8, " " ), " - ", LPAD ( ROUND ( `budget_target2`, 4 ), 8, " " ), " = ", LPAD ( RPAD ( `budget_diff2`, 9, " " ), 8, " " ), " (", LPAD ( ROUND ( ( `budget_perc2` * 100 ), 2 ), 6, " " ), "%) ",
           "| Mono: ", LPAD ( ROUND ( `budget_normalized`, 4 ), 8, " " ), " - ", LPAD ( ROUND ( `budget_target3`, 4 ), 8, " " ), " = ", LPAD ( RPAD ( `budget_diff3`, 9, " " ), 8, " " ), " (", LPAD ( ROUND ( ( `budget_perc3` * 100 ), 2 ), 6, " " ), "%) |"  ) AS `Budget_Info`

FROM ACSBV3_0402A_diagnostic_dataset
  WHERE `drop_environment` = @FocalPoint0 AND `QualityName` = @FocalPoint1 AND `SlotID` = @FocalPoint2 AND `ItemLevel` = @FocalPoint3
  ORDER BY `budget_perc3` ASC, `budget_perc2` ASC, `budget_perc1` ASC, `entry` DESC LIMIT 5;



/*=============================================================================================================================================
  8. Outlier Report: Display highest and lowest percentage outliers for each report.
=============================================================================================================================================*/

SET @VAR_Report8A := '',    -- unused
    @VAR_Report8B := '';    -- unused

SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part`   = 1        OR `part`  = 7 )
                                                OR ( `script` = @Script AND `print` = 8 )
ORDER BY `part`, `auto`;



SELECT " - 1. Overall Report: Outliers" AS `` UNION ALL SELECT "" AS ``;

CALL ACSBV3_print_outlier ( 1, ' "Global" ', 1, "DEFAULT" );



SELECT " - 2. Drop Report: Outliers" AS `` UNION ALL SELECT "" AS ``;

CALL ACSBV3_print_outlier ( 2, "`Drop`", 3, "DEFAULT" );



SELECT " - 3. Source Report: Outliers" AS `` UNION ALL SELECT "" AS ``;

CALL ACSBV3_print_outlier ( 3, "`Source`", 7, "DEFAULT" );



SELECT " - 4. Curve Report: Outliers" AS `` UNION ALL SELECT "" AS ``;

CALL ACSBV3_print_outlier ( 4, "`Curve`", 7, "DEFAULT" );



SELECT " - 5. Slot Report: Outliers" AS `` UNION ALL SELECT "" AS ``;

CALL ACSBV3_print_outlier ( 5, "`Slot`", 29, "DEFAULT" );



SELECT " - 6. iLvl Report: Outliers (report view limited to 20 rows.)" AS `` UNION ALL SELECT "" AS ``;

CALL ACSBV3_print_outlier ( 6, "`iLvl`", 20, "`Mono_Average` DESC, `3pnt_Average` DESC, `Raw_Average` DESC, `iLvl` ASC" );



SELECT " - 7. Focal-Point Report: Outliers" AS `` UNION ALL SELECT "" AS ``;

CALL ACSBV3_print_outlier ( 7, ' "Focal-Point" ', 1, "DEFAULT" );



SELECT " - 8.A - Highest Percentage Outliers:" AS `` UNION ALL SELECT "" AS ``;

SELECT

  CONCAT ( " | ", RPAD ( `CurveName`, 3, " " ), " ", RPAD ( `ItemLevel`, 3, " " ), " ", `entry`, " ", RPAD ( `name`, 25, " " ), " |" ) AS `Item_Info`,

  CONCAT ( "| ", LPAD ( ROUND ( `budget_actual`, 2 ), 6, " " ), " / (", `mod_drop`, " * ", `mod_misc`, " * ", `mod_slot`, ") = ", LPAD ( ROUND ( `budget_normalized`, 2 ), 6, " " ), " |" ) AS `Budget_Calculation`,

  CONCAT ( "| Raw: ",  LPAD ( ROUND ( `budget_normalized`, 4 ), 8, " " ), " - ", LPAD ( ROUND ( `budget_target1`, 4 ), 8, " " ), " = ", LPAD ( RPAD ( `budget_diff1`, 9, " " ), 8, " " ), " (", LPAD ( ROUND ( ( `budget_perc1` * 100 ), 2 ), 6, " " ), "%) ",
           "| 3pnt: ", LPAD ( ROUND ( `budget_normalized`, 4 ), 8, " " ), " - ", LPAD ( ROUND ( `budget_target2`, 4 ), 8, " " ), " = ", LPAD ( RPAD ( `budget_diff2`, 9, " " ), 8, " " ), " (", LPAD ( ROUND ( ( `budget_perc2` * 100 ), 2 ), 6, " " ), "%) ",
           "| Mono: ", LPAD ( ROUND ( `budget_normalized`, 4 ), 8, " " ), " - ", LPAD ( ROUND ( `budget_target3`, 4 ), 8, " " ), " = ", LPAD ( RPAD ( `budget_diff3`, 9, " " ), 8, " " ), " (", LPAD ( ROUND ( ( `budget_perc3` * 100 ), 2 ), 6, " " ), "%) |"  ) AS `Budget_Info`

FROM ACSBV3_0402A_diagnostic_dataset ORDER BY `budget_perc3` DESC, `budget_perc2` DESC, `budget_perc1` DESC LIMIT 5;



SELECT "" AS `` UNION ALL
SELECT " - 8.B - Lowest Percentage Outliers:" AS `` UNION ALL SELECT "" AS ``;

SELECT

  CONCAT ( " | ", RPAD ( `CurveName`, 3, " " ), " ", RPAD ( `ItemLevel`, 3, " " ), " ", `entry`, " ", RPAD ( `name`, 25, " " ), " |" ) AS `Item_Info`,

  CONCAT ( "| ", LPAD ( ROUND ( `budget_actual`, 2 ), 6, " " ), " / (", `mod_drop`, " * ", `mod_misc`, " * ", `mod_slot`, ") = ", LPAD ( ROUND ( `budget_normalized`, 2 ), 6, " " ), " |" ) AS `Budget_Calculation`,

  CONCAT ( "| Raw: ",  LPAD ( ROUND ( `budget_normalized`, 4 ), 8, " " ), " - ", LPAD ( ROUND ( `budget_target1`, 4 ), 8, " " ), " = ", LPAD ( RPAD ( `budget_diff1`, 9, " " ), 8, " " ), " (", LPAD ( ROUND ( ( `budget_perc1` * 100 ), 2 ), 6, " " ), "%) ",
           "| 3pnt: ", LPAD ( ROUND ( `budget_normalized`, 4 ), 8, " " ), " - ", LPAD ( ROUND ( `budget_target2`, 4 ), 8, " " ), " = ", LPAD ( RPAD ( `budget_diff2`, 9, " " ), 8, " " ), " (", LPAD ( ROUND ( ( `budget_perc2` * 100 ), 2 ), 6, " " ), "%) ",
           "| Mono: ", LPAD ( ROUND ( `budget_normalized`, 4 ), 8, " " ), " - ", LPAD ( ROUND ( `budget_target3`, 4 ), 8, " " ), " = ", LPAD ( RPAD ( `budget_diff3`, 9, " " ), 8, " " ), " (", LPAD ( ROUND ( ( `budget_perc3` * 100 ), 2 ), 6, " " ), "%) |"  ) AS `Budget_Info`

FROM ACSBV3_0402A_diagnostic_dataset ORDER BY `budget_perc3` ASC, `budget_perc2` ASC, `budget_perc1` ASC LIMIT 5;



/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
