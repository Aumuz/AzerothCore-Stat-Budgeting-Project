/*=============================================================================================================================================
  Filename:       ACSBV3-06-02C.sql
  Title:          Generate DPS Curves.
  Author:         Aumuz Messick
  Version:        1.0
  Created:        2025-12-07
  Description:    This script will generate DPS to iLvl curves for each DPS meta-group.

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

SET @SCRIPT  := "0602C",
    @VERSION := "1.0";



/*=============================================================================================================================================
  1. Create and Populate Temporary Table: ACSBV3_temp_curve
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "1. Create and Populate Temporary Table: ACSBV3_temp_curve" );



DROP   TEMPORARY TABLE IF EXISTS ACSBV3_temp_curve;

CREATE TEMPORARY TABLE           ACSBV3_temp_curve
(

  `dps_group`        VARCHAR(25)   NOT NULL,
  `ItemLevelBracket` SMALLINT      NOT NULL,
  `curve_raw`        DECIMAL(12,5) NOT NULL,
  `curve_3pnt`       DECIMAL(12,5) NOT NULL

);

INSERT INTO ACSBV3_temp_curve ( `curve_3pnt`, `dps_group`, `ItemLevelBracket`, `curve_raw` ) SELECT

  0                    AS       `curve_3pnt`,
  d.`dps_group`        AS        `dps_group`,
  d.`ItemLevelBracket` AS `ItemLevelBracket`,

     ( ( ( AVG ( d.`dmg_min1` ) + AVG ( d.`dmg_max1` ) ) / 2 / ( AVG ( d.`delay` ) / 1000 ) / AVG ( d.`budget_actual` ) ) * 100 ) AS `curve_raw`

FROM ACSBV3_0600A_dataset AS d WHERE d.`class` = 2 GROUP BY `dps_group`, `ItemLevelBracket`;



SELECT COUNT(*) FROM ACSBV3_temp_curve;



/*=============================================================================================================================================
  2. Create and Populate Table: ACSBV3_0602C_dps_curve FROM ACSBV3_temp_curve ORDER BY dps_group, ItemLevelBracket
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "2. Create and Populate Table: ACSBV3_0602C_dps_curve FROM ACSBV3_temp_curve ORDER BY dps_group, ItemLevelBracket" );



DROP   TABLE IF EXISTS ACSBV3_0602C_dps_curve;
CREATE TABLE           ACSBV3_0602C_dps_curve          LIKE ACSBV3_temp_curve;
INSERT INTO            ACSBV3_0602C_dps_curve SELECT * FROM ACSBV3_temp_curve ORDER BY `dps_group` ASC, `ItemLevelBracket` ASC;



SELECT * FROM ACSBV3_0602C_dps_curve;



/*=============================================================================================================================================
  3. Apply 3-Point Smoothing Window to Table: ACSBV3_0602C_dps_curve
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "3. Apply 3-Point Smoothing Window to Table: ACSBV3_0602C_dps_curve" );



WITH cte AS ( SELECT `dps_group`, `ItemLevelBracket`, AVG ( `curve_raw` ) OVER ( PARTITION BY `dps_group`
                                                                                 ORDER BY `ItemLevelBracket` ASC
                                                                                 ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING ) AS `curve_3pnt`
              FROM ACSBV3_0602C_dps_curve )

UPDATE ACSBV3_0602C_dps_curve AS curve
  JOIN                    cte AS cte
    ON curve.`dps_group`        = cte.`dps_group`
   AND curve.`ItemLevelBracket` = cte.`ItemLevelBracket`
   SET curve.`curve_3pnt`       = cte.`curve_3pnt`;



SELECT * FROM ACSBV3_0602C_dps_curve;



/*=============================================================================================================================================
  4. Create and Populate Table: ACSBV3_ref_dps_curve
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "4. Create and Populate Table: ACSBV3_ref_dps_curve" );



DROP   TABLE IF EXISTS ACSBV3_ref_dps_curve;

CREATE TABLE           ACSBV3_ref_dps_curve
(

  `ItemLevelBracket` SMALLINT      NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `1H-Weapon`        DECIMAL(12,5)          COMMENT "DPS Meta Group:       1H-Weapon",
  `2H-Weapon`        DECIMAL(12,5)          COMMENT "DPS Meta Group:       2H-Weapon",
  `Ranged`           DECIMAL(12,5)          COMMENT "DPS Meta Group: Ranged-Physical",
  `Wand`             DECIMAL(12,5)          COMMENT "DPS Meta Group:            Wand"

);

INSERT INTO ACSBV3_ref_dps_curve

WITH RECURSIVE seq AS ( SELECT                      10 AS `ItemLevelBracket` UNION ALL
                        SELECT `ItemLevelBracket` + 10 AS `ItemLevelBracket`
                          FROM                  seq WHERE `ItemLevelBracket` < 300 )

SELECT    seq.`ItemLevelBracket` AS `ItemLevelBracket`,

          c1.`curve_3pnt`        AS        `1H-Weapon`,
          c2.`curve_3pnt`        AS        `2H-Weapon`,
          c3.`curve_3pnt`        AS           `Ranged`,
          c4.`curve_3pnt`        AS             `Wand`
FROM seq
LEFT JOIN ACSBV3_0602C_dps_curve AS c1 ON c1.`ItemLevelBracket` = seq.`ItemLevelBracket` AND c1.`dps_group` = "1H-Weapon      "
LEFT JOIN ACSBV3_0602C_dps_curve AS c2 ON c2.`ItemLevelBracket` = seq.`ItemLevelBracket` AND c2.`dps_group` = "2H-Weapon      "
LEFT JOIN ACSBV3_0602C_dps_curve AS c3 ON c3.`ItemLevelBracket` = seq.`ItemLevelBracket` AND c3.`dps_group` = "Ranged-Physical"
LEFT JOIN ACSBV3_0602C_dps_curve AS c4 ON c4.`ItemLevelBracket` = seq.`ItemLevelBracket` AND c4.`dps_group` = "Wand           ";



SELECT * FROM ACSBV3_ref_dps_curve;



/*=============================================================================================================================================
  5. Apply Monotonic Enforcement to Table: ACSBV3_ref_dps_curve
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "5. Apply Monotonic Enforcement to Table: ACSBV3_ref_dps_curve" );



UPDATE ACSBV3_ref_dps_curve
   SET `1H-Weapon` := ( SELECT MIN( `curve_3pnt` ) FROM ACSBV3_0602C_dps_curve WHERE `dps_group` = "1H-Weapon      " ),
       `2H-Weapon` := ( SELECT MIN( `curve_3pnt` ) FROM ACSBV3_0602C_dps_curve WHERE `dps_group` = "2H-Weapon      " ),
       `Ranged`    := ( SELECT MIN( `curve_3pnt` ) FROM ACSBV3_0602C_dps_curve WHERE `dps_group` = "Ranged-Physical" ),
       `Wand`      := ( SELECT MIN( `curve_3pnt` ) FROM ACSBV3_0602C_dps_curve WHERE `dps_group` = "Wand           " )
 WHERE `ItemLevelBracket` = 300;

SET @PREV_1H    := 0.00,
    @PREV_2H    := 0.00,
    @PREV_Range := 0.00,
    @PREV_Wand  := 0.00;

UPDATE ACSBV3_ref_dps_curve
  JOIN ( SELECT `ItemLevelBracket`, @PREV_1H    := GREATEST( @PREV_1H,    COALESCE ( `1H-Weapon`, 0.00 ) ) AS `1H-Weapon`,
                                    @PREV_2H    := GREATEST( @PREV_2H,    COALESCE ( `2H-Weapon`, 0.00 ) ) AS `2H-Weapon`,
                                    @PREV_Range := GREATEST( @PREV_Range, COALESCE (    `Ranged`, 0.00 ) ) AS    `Ranged`,
                                    @PREV_Wand  := GREATEST( @PREV_Wand,  COALESCE (      `Wand`, 0.00 ) ) AS      `Wand`

           FROM ACSBV3_ref_dps_curve ORDER BY `ItemLevelBracket` DESC ) AS mono USING ( `ItemLevelBracket` )

SET ACSBV3_ref_dps_curve.`1H-Weapon` = mono.`1H-Weapon`,
    ACSBV3_ref_dps_curve.`2H-Weapon` = mono.`2H-Weapon`,
    ACSBV3_ref_dps_curve.`Ranged`    = mono.`Ranged`,
    ACSBV3_ref_dps_curve.`Wand`      = mono.`Wand`;



SELECT * FROM ACSBV3_ref_dps_curve;



CALL ACSBV3_print_footer ();

/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
