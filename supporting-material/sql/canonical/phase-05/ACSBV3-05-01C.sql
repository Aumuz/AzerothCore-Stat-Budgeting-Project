/*=============================================================================================================================================
  Filename:       ACSBV3-05-01C.sql
  Title:          Generate Per-Quality Budget Curves.
  Author:         Aumuz Messick
  Version:        1.0
  Created:        2025-12-01
  Description:    This script generates per-quality budget curves.
                  Three curves will be produced for each quality tier (raw, 3-point smoothed, monotonic smoothed).

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

SET @SCRIPT  := "0501C",
    @VERSION := "1.0";



/*=============================================================================================================================================
  1. Create Temporary Curve Table: ACSBV3_temp_curve
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "1. Create Temporary Curve Table: ACSBV3_temp_curve" );

DROP   TEMPORARY TABLE IF EXISTS ACSBV3_temp_curve;

CREATE TEMPORARY TABLE           ACSBV3_temp_curve
(

  `Quality`    TINYINT       NOT NULL,
  `ItemLevel`  SMALLINT      NOT NULL,
  `curve_raw`  DECIMAL(12,5) NOT NULL,
  `curve_3pnt` DECIMAL(12,5) NOT NULL,
  `curve_mono` DECIMAL(12,5) NOT NULL,
  `min_budget` DECIMAL(12,5) NOT NULL,
  `max_budget` DECIMAL(12,5) NOT NULL,
  `ItemCount`  INT           NOT NULL

);

SELECT "Temporary Table Created: ACSBV3_temp_curve" AS ``;



/*=============================================================================================================================================
  2. Populate Temporary Curve Table: ACSBV3_temp_curve FROM ACSBV3_ref_dataset
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "2. Populate Temporary Curve Table: ACSBV3_temp_curve FROM ACSBV3_ref_dataset" );

INSERT INTO ACSBV3_temp_curve
SELECT

                 d.`Quality`   AS    `Quality`,
                 d.`ItemLevel` AS  `ItemLevel`,
  AVG( d.`budget_normalized` ) AS  `curve_raw`, 0 AS `curve_3pnt`, 0 AS `curve_mono`,
  MIN( d.`budget_normalized` ) AS `min_budget`,
  MAX( d.`budget_normalized` ) AS `max_budget`,
                      COUNT(*) AS  `ItemCount`

FROM ACSBV3_ref_dataset AS d
GROUP BY `Quality`, `ItemLevel`;

SELECT CONCAT ( "Temporary Table Populated: ", COUNT(*), " points" ) AS `` FROM ACSBV3_temp_curve;



/*=============================================================================================================================================
  3. Create and Populate Curve Table: ACSBV3_0501C_curve FROM ACSBV3_temp_curve
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "3. Create and Populate Curve Table: ACSBV3_0501C_curve FROM ACSBV3_temp_curve" );

DROP   TABLE IF EXISTS ACSBV3_0501C_curve;

CREATE TABLE           ACSBV3_0501C_curve
(

  `Quality`    TINYINT       NOT NULL,
  `ItemLevel`  SMALLINT      NOT NULL,
  `curve_raw`  DECIMAL(12,5) NOT NULL,
  `curve_3pnt` DECIMAL(12,5) NOT NULL,
  `curve_mono` DECIMAL(12,5) NOT NULL,
  `min_budget` DECIMAL(12,5) NOT NULL,
  `max_budget` DECIMAL(12,5) NOT NULL,
  `ItemCount`  INT           NOT NULL

);

SELECT "Table Created: ACSBV3_0501C_curve" AS ``;

INSERT INTO ACSBV3_0501C_curve SELECT * FROM ACSBV3_temp_curve ORDER BY `Quality` ASC, `ItemLevel` ASC;

SELECT CONCAT ( "Table Populated: ", COUNT(*), " points" ) AS `` FROM ACSBV3_0501C_curve;



/*=============================================================================================================================================
  4. Apply 3-Point Smoothing Window to Table: ACSBV3_0501C_curve
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "4. Apply 3-Point Smoothing Window to Table: ACSBV3_0501C_curve" );

WITH cte AS ( SELECT `Quality`, `ItemLevel`, AVG ( `curve_raw` ) OVER ( PARTITION BY `Quality`
                                                                        ORDER BY `ItemLevel` ASC
                                                                        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING ) AS `curve_3pnt`
              FROM ACSBV3_0501C_curve )

UPDATE ACSBV3_0501C_curve AS curve
  JOIN                cte AS cte
    ON curve.`Quality`    = cte.`Quality`
   AND curve.`ItemLevel`  = cte.`ItemLevel`
   SET curve.`curve_3pnt` = cte.`curve_3pnt`;

SELECT `ItemLevel`, `curve_raw`, `curve_3pnt` FROM ACSBV3_0501C_curve WHERE `Quality` = 1;



/*=============================================================================================================================================
  5. Apply Monotonic Enforcement to Table: ACSBV3_0501C_curve
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "5. Apply Monotonic Enforcement to Table: ACSBV3_0501C_curve" );

SET @QUALITY := 0, @PREV := 0;

UPDATE ACSBV3_0501C_curve
  JOIN ( SELECT `Quality`, `ItemLevel`, @PREV := ( CASE WHEN @QUALITY = `Quality` THEN GREATEST ( @PREV, `curve_3pnt` )
                                                                                  ELSE                   `curve_3pnt`   END) AS `curve_mono`, ( @QUALITY := `Quality` )
         FROM ACSBV3_0501C_curve ORDER BY `Quality` ASC, `ItemLevel` ASC ) AS mono USING ( `Quality`, `ItemLevel` )
SET ACSBV3_0501C_curve.`curve_mono` = mono.`curve_mono`;

SELECT * FROM ACSBV3_0501C_curve WHERE `Quality` = 1;



/*=============================================================================================================================================
  6. Verification: ACSBV3_0501C_curve
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "6. Verification: ACSBV3_0501C_curve" );

SELECT CONCAT ( LPAD ( `Quality`,     1,  0  ), " | ",
                LPAD ( `ItemLevel`,   3,  0  ), " | ",
                LPAD ( `curve_raw`,  12, " " ), " | ",
                LPAD ( `curve_3pnt`, 12, " " ), " | ",
                LPAD ( `curve_mono`, 12, " " ), " | ",
                LPAD ( `min_budget`, 12, " " ), " | ",
                LPAD ( `max_budget`, 12, " " ), " | ",
                LPAD ( `ItemCount`,   4, " " )) AS `` FROM ACSBV3_0501C_curve;

SELECT CONCAT ( COUNT(*), " zero points" ) AS `` FROM ACSBV3_0501C_curve WHERE `curve_raw` = 0 OR `curve_3pnt` = 0 OR `curve_mono` = 0;



CALL ACSBV3_print_footer ();

/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
