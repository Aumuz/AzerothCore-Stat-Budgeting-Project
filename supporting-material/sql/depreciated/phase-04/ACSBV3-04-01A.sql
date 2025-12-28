/*=============================================================================================================================================
  Filename:       ACSBV3-04-01A.sql
  Title:          Generate Per-Quality Budget Curves.
  Author:         Aumuz Messick
  Version:        2.4
  Created:        2025-11-07
  Description:    This script generates per-quality budget curves.
                  Three curves will be produced for each quality tier (raw, 3-point smoothed, monotonic smoothed).
                  Quality 4 (Epic) will be generated multiple times (combined equipment/weapons, equipment, weapons).

-----------------------------------------------------------------------------------------------------------------------------------------------
  Updates:
   - v2.0 -> Script Created (completely reworked from v1.0 to combine equipment and weapons).
   - v2.1 -> (2025-11-10) Added print-out formatting: ACSBV3_print_info.
   - v2.2 -> (2025-11-18) Skipped to sync version numbers with pipeline (no change).
   - v2.3 -> (2025-11-18) Skipped to sync version numbers with pipeline (updated headers).
   - v2.4 -> (2025-11-18) Skipped to sync version numbers with pipeline (updated headers).

=============================================================================================================================================*/



/*=============================================================================================================================================
  0.1 -  Update MYSQL Collation for AzerothCore: utf8mb4_general_ci
                                                 Needed for Section: 5. Apply Monotonic Enforcement to Table
=============================================================================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';



/*=============================================================================================================================================
  0.2 - Update Print Information Table: ACSBV3_print_info
=============================================================================================================================================*/

DELETE FROM ACSBV3_print_info WHERE `script` = "0401A";

INSERT INTO ACSBV3_print_info ( `script`, `part`, `print`, `output` ) VALUES
( "0401A", 2, 1, "##  Diagnostic Output:                                                                                           (v2.4)  ##" );



/*=============================================================================================================================================
  1. Create Temporary Curve Table: temp_curve
=============================================================================================================================================*/

SELECT "The script is processing. Please wait..." AS ``;



DROP TEMPORARY TABLE IF EXISTS temp_curve;

CREATE TEMPORARY TABLE temp_curve
(

  `CurveName`   VARCHAR(10),
  `QualityName` VARCHAR(10),
  `ItemLevel`   SMALLINT,
  `curve_raw`   DECIMAL(12,5),
  `curve_3pnt`  DECIMAL(12,5),
  `curve_mono`  DECIMAL(12,5),
  `min_budget`  DECIMAL(12,5),
  `max_budget`  DECIMAL(12,5),
  `ItemCount`   INT

);



/*=============================================================================================================================================
  2. Populate Temporary Curve Table: Q1 to Q4 temp_curve FROM ACSBV3_doc_item_template
=============================================================================================================================================*/

INSERT INTO temp_curve ( `CurveName`, `QualityName`, `ItemLevel`, `curve_raw`, `curve_3pnt`, `curve_mono`, `min_budget`, `max_budget`, `ItemCount` )
SELECT

  CASE
    WHEN `Quality` = 1 THEN "Q1"
    WHEN `Quality` = 2 THEN "Q2"
    WHEN `Quality` = 3 THEN "Q3"
    WHEN `Quality` = 4 THEN "Q4C"
    WHEN `Quality` = 5 THEN "Q5"
                       ELSE "Unknown"
  END AS `CurveName`,

 `QualityName`, `ItemLevel`,

  AVG(`budget_normalized`) AS `curve_raw`, 0 AS `curve_3pnt`, 0 AS `curve_mono`,
  MIN(`budget_normalized`) AS `min_budget`,
  MAX(`budget_normalized`) AS `max_budget`,

  COUNT(*) AS `ItemCount`

FROM ACSBV3_doc_item_template
WHERE `Quality` BETWEEN 1 AND 5
GROUP BY `ItemLevel`, `Quality`, `QualityName`;



INSERT INTO temp_curve ( `CurveName`, `QualityName`, `ItemLevel`, `curve_raw`, `curve_3pnt`, `curve_mono`, `min_budget`, `max_budget`, `ItemCount` )
SELECT

  CASE
    WHEN `class` = 2 THEN "Q4W"
    WHEN `class` = 4 THEN "Q4E"
                     ELSE "Unknown"
  END AS `CurveName`,

 `QualityName`, `ItemLevel`,

  AVG(`budget_normalized`) AS `curve_raw`, 0 AS `curve_3pnt`, 0 AS `curve_mono`,
  MIN(`budget_normalized`) AS `min_budget`,
  MAX(`budget_normalized`) AS `max_budget`,

  COUNT(*) AS `ItemCount`

FROM ACSBV3_doc_item_template
WHERE `Quality` = 4
GROUP BY `ItemLevel`, `class`, `QualityName`;



/*=============================================================================================================================================
  3. Create and Populate Curve Table: ACSBV3_0401A_curve FROM temp_curve
=============================================================================================================================================*/

DROP TABLE IF EXISTS ACSBV3_0401A_curve;

CREATE TABLE ACSBV3_0401A_curve
(

  `CurveName`   VARCHAR(10),
  `QualityName` VARCHAR(10),
  `ItemLevel`   SMALLINT,
  `curve_raw`   DECIMAL(12,5),
  `curve_3pnt`  DECIMAL(12,5),
  `curve_mono`  DECIMAL(12,5),
  `min_budget`  DECIMAL(12,5),
  `max_budget`  DECIMAL(12,5),
  `ItemCount`   INT

);

INSERT INTO ACSBV3_0401A_curve SELECT * FROM temp_curve ORDER BY `CurveName` ASC, `ItemLevel` ASC;



/*=============================================================================================================================================
  4. Apply 3-Point Smoothing Window to Table: ACSBV3_0401A_curve
=============================================================================================================================================*/

WITH CTE_3Point AS (

                     SELECT

                       `CurveName`,
                       `ItemLevel`,

                       AVG(`curve_raw`) OVER (

                                               PARTITION BY `CurveName`
                                               ORDER BY `ItemLevel` ASC
                                               ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING

                                             ) AS `curve_3pnt`

                     FROM ACSBV3_0401A_curve

                   )

UPDATE ACSBV3_0401A_curve AS c
  JOIN CTE_3Point AS cte
    ON c.`CurveName`  = cte.`CurveName`
   AND c.`ItemLevel`  = cte.`ItemLevel`
   SET c.`curve_3pnt` = cte.`curve_3pnt`;



/*=============================================================================================================================================
  5. Apply Monotonic Enforcement to Table: ACSBV3_0401A_curve
=============================================================================================================================================*/

SET @CurveName := "", @prev := 0.00;

UPDATE ACSBV3_0401A_curve
  JOIN (

         SELECT

           `CurveName`,
           `ItemLevel`,

                @prev := IF (

                              @CurveName = `CurveName`,
                              GREATEST(@prev, `curve_3pnt`),
                              `curve_3pnt`

                            ) AS `curve_mono`,

           (@CurveName := `CurveName`)

         FROM ACSBV3_0401A_curve
         ORDER BY `CurveName`, `ItemLevel`

       ) AS m USING ( `CurveName`, `ItemLevel` )

SET ACSBV3_0401A_curve.`curve_mono` = m.`curve_mono`;



/*=============================================================================================================================================
  6. Final Diagnostic Output:
=============================================================================================================================================*/

SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0401A" AND `print` = 1 ) ORDER BY `part`, `auto`;    -- Print Header



SELECT * FROM ACSBV3_0401A_curve WHERE `CurveName` = "Q1";



SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 8 ) ORDER BY `part`, `auto`;    -- Print 3-Line Break



SELECT SUM(`ItemCount`) AS `ItemCount`
FROM ACSBV3_0401A_curve
WHERE `CurveName` = "Q1"  OR
      `CurveName` = "Q2"  OR
      `CurveName` = "Q3"  OR
      `CurveName` = "Q4C" OR
      `CurveName` = "Q5";



SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 8 ) ORDER BY `part`, `auto`;    -- Print 3-Line Break



SELECT COUNT(*) AS `zero_points` FROM ACSBV3_0401A_curve WHERE `curve_raw` = 0 OR `curve_3pnt` = 0 OR `curve_mono` = 0;



SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` >= 8 ) ORDER BY `part`, `auto`;    -- Print Footer



/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
