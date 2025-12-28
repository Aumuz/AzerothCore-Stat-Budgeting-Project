/*=============================================================================================================================================
  Filename:       ACSBV3-06-00B.sql
  Title:          Generate DPS Curves.
  Author:         Aumuz Messick
  Version:        2.0
  Created:        2025-12-09
  Description:    This script will generate DPS to iLvl curves for each DPS meta-group.

-----------------------------------------------------------------------------------------------------------------------------------------------
  Updates:
   - v2.0 -> Script Created.

=============================================================================================================================================*/



/*=============================================================================================================================================
  0.1 - Update MYSQL Collation for AzerothCore:
=============================================================================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';



/*=============================================================================================================================================
  0.2 - Set Script Variables:
=============================================================================================================================================*/

SET @SCRIPT  := "0600B",
    @VERSION := "2.0";



/*=============================================================================================================================================
  1. Create and Populate Temporary Table: ACSBV3_temp_curve
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "1. Create and Populate Temporary Table: ACSBV3_temp_curve" );



DROP   TEMPORARY TABLE IF EXISTS ACSBV3_temp_curve;

CREATE TEMPORARY TABLE           ACSBV3_temp_curve
(

  `slot_group`       VARCHAR(25)   NOT NULL,
  `ItemLevelBracket` SMALLINT      NOT NULL,
  `curve_raw`        DECIMAL(12,5) NOT NULL,
  `curve_3pnt`       DECIMAL(12,5) NOT NULL

);

INSERT INTO ACSBV3_temp_curve ( `curve_3pnt`, `slot_group`, `ItemLevelBracket`, `curve_raw` ) SELECT

  0                    AS       `curve_3pnt`,
  d.`slot_group`       AS       `slot_group`,
  d.`ItemLevelBracket` AS `ItemLevelBracket`,

     ( ( ( AVG ( d.`dmg_min1` ) + AVG ( d.`dmg_max1` ) ) / 2 / ( AVG ( d.`delay` ) / 1000 ) / AVG ( d.`budget_actual` ) ) * 100 ) AS `curve_raw`

FROM ACSBV3_ref_dataset AS d WHERE d.`class` = 2 GROUP BY `slot_group`, `ItemLevelBracket`;



SELECT COUNT(*) FROM ACSBV3_temp_curve;



/*=============================================================================================================================================
  2. Create and Populate Table: ACSBV3_0600B_dps_curve FROM ACSBV3_temp_curve ORDER BY slot_group, ItemLevelBracket
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "2. Create and Populate Table: ACSBV3_0600B_dps_curve FROM ACSBV3_temp_curve ORDER BY slot_group, ItemLevelBracket" );



DROP   TABLE IF EXISTS ACSBV3_0600B_dps_curve;
CREATE TABLE           ACSBV3_0600B_dps_curve          LIKE ACSBV3_temp_curve;
INSERT INTO            ACSBV3_0600B_dps_curve SELECT * FROM ACSBV3_temp_curve ORDER BY `slot_group` ASC, `ItemLevelBracket` ASC;



SELECT * FROM ACSBV3_0600B_dps_curve;



/*=============================================================================================================================================
  3. Apply 3-Point Smoothing Window to Table: ACSBV3_0600B_dps_curve
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "3. Apply 3-Point Smoothing Window to Table: ACSBV3_0600B_dps_curve" );



WITH cte AS ( SELECT `slot_group`, `ItemLevelBracket`, AVG ( `curve_raw` ) OVER ( PARTITION BY `slot_group`
                                                                                  ORDER BY `ItemLevelBracket` ASC
                                                                                  ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING ) AS `curve_3pnt`
              FROM ACSBV3_0600B_dps_curve )

UPDATE ACSBV3_0600B_dps_curve AS curve
  JOIN                    cte AS cte
    ON curve.`slot_group`       = cte.`slot_group`
   AND curve.`ItemLevelBracket` = cte.`ItemLevelBracket`
   SET curve.`curve_3pnt`       = cte.`curve_3pnt`;



SELECT * FROM ACSBV3_0600B_dps_curve;



/*=============================================================================================================================================
  4. Create and Populate Table: ACSBV3_aux_dps_curve
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "4. Create and Populate Table: ACSBV3_aux_dps_curve" );



DROP   TABLE IF EXISTS ACSBV3_aux_dps_curve;

CREATE TABLE           ACSBV3_aux_dps_curve
(

  `ItemLevelBracket` SMALLINT      NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `1H-Weapon`        DECIMAL(12,5)          COMMENT "DPS Meta Group:       1H-Weapon",
  `2H-Weapon`        DECIMAL(12,5)          COMMENT "DPS Meta Group:       2H-Weapon",
  `Staff-Weapon`     DECIMAL(12,5)          COMMENT "DPS Meta Group:    Staff-Weapon",
  `Ranged-Weapon`    DECIMAL(12,5)          COMMENT "DPS Meta Group:   Ranged-Weapon",
  `Ranged-Thrown`    DECIMAL(12,5)          COMMENT "DPS Meta Group:   Ranged-Thrown",
  `Ranged-Wand`      DECIMAL(12,5)          COMMENT "DPS Meta Group:     Ranged-Wand"

);

INSERT INTO ACSBV3_aux_dps_curve

WITH RECURSIVE seq AS ( SELECT                      10 AS `ItemLevelBracket` UNION ALL
                        SELECT `ItemLevelBracket` + 10 AS `ItemLevelBracket`
                          FROM                  seq WHERE `ItemLevelBracket` < 300 )

SELECT    seq.`ItemLevelBracket` AS `ItemLevelBracket`,

          c1.`curve_3pnt`        AS        `1H-Weapon`,
          c2.`curve_3pnt`        AS        `2H-Weapon`,
          c3.`curve_3pnt`        AS     `Staff-Weapon`,
          c4.`curve_3pnt`        AS    `Ranged-Weapon`,
          c5.`curve_3pnt`        AS    `Ranged-Thrown`,
          c6.`curve_3pnt`        AS      `Ranged-Wand`

FROM seq
LEFT JOIN ACSBV3_0600B_dps_curve AS c1 ON c1.`ItemLevelBracket` = seq.`ItemLevelBracket` AND c1.`slot_group` = "1H-Weapon"
LEFT JOIN ACSBV3_0600B_dps_curve AS c2 ON c2.`ItemLevelBracket` = seq.`ItemLevelBracket` AND c2.`slot_group` = "2H-Weapon"
LEFT JOIN ACSBV3_0600B_dps_curve AS c3 ON c3.`ItemLevelBracket` = seq.`ItemLevelBracket` AND c3.`slot_group` = "Staff-Weapon"
LEFT JOIN ACSBV3_0600B_dps_curve AS c4 ON c4.`ItemLevelBracket` = seq.`ItemLevelBracket` AND c4.`slot_group` = "Ranged-Weapon"
LEFT JOIN ACSBV3_0600B_dps_curve AS c5 ON c5.`ItemLevelBracket` = seq.`ItemLevelBracket` AND c5.`slot_group` = "Ranged-Thrown"
LEFT JOIN ACSBV3_0600B_dps_curve AS c6 ON c6.`ItemLevelBracket` = seq.`ItemLevelBracket` AND c6.`slot_group` = "Ranged-Wand";



SELECT * FROM ACSBV3_aux_dps_curve;



/*=============================================================================================================================================
  5. Apply Monotonic Enforcement to Table: ACSBV3_aux_dps_curve
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "5. Apply Monotonic Enforcement to Table: ACSBV3_aux_dps_curve" );



UPDATE ACSBV3_aux_dps_curve
   SET `1H-Weapon`     := ( SELECT MIN( `curve_3pnt` ) FROM ACSBV3_0600B_dps_curve WHERE `slot_group` = "1H-Weapon"     ),
       `2H-Weapon`     := ( SELECT MIN( `curve_3pnt` ) FROM ACSBV3_0600B_dps_curve WHERE `slot_group` = "2H-Weapon"     ),
       `Staff-Weapon`  := ( SELECT MIN( `curve_3pnt` ) FROM ACSBV3_0600B_dps_curve WHERE `slot_group` = "Staff-Weapon"  ),
       `Ranged-Weapon` := ( SELECT MIN( `curve_3pnt` ) FROM ACSBV3_0600B_dps_curve WHERE `slot_group` = "Ranged-Weapon" ),
       `Ranged-Thrown` := ( SELECT MIN( `curve_3pnt` ) FROM ACSBV3_0600B_dps_curve WHERE `slot_group` = "Ranged-Thrown" ),
       `Ranged-Wand`   := ( SELECT MIN( `curve_3pnt` ) FROM ACSBV3_0600B_dps_curve WHERE `slot_group` = "Ranged-Wand"   )
 WHERE `ItemLevelBracket` = 300;

SET @PREV_1H     := 0.00,
    @PREV_2H     := 0.00,
    @PREV_Staff  := 0.00,
    @PREV_Range  := 0.00,
    @PREV_Thrown := 0.00,
    @PREV_Wand   := 0.00;

UPDATE ACSBV3_aux_dps_curve
  JOIN ( SELECT `ItemLevelBracket`, @PREV_1H     := GREATEST( @PREV_1H,     COALESCE (     `1H-Weapon`, 0.00 ) ) AS     `1H-Weapon`,
                                    @PREV_2H     := GREATEST( @PREV_2H,     COALESCE (     `2H-Weapon`, 0.00 ) ) AS     `2H-Weapon`,
                                    @PREV_Staff  := GREATEST( @PREV_Staff,  COALESCE (  `Staff-Weapon`, 0.00 ) ) AS  `Staff-Weapon`,
                                    @PREV_Range  := GREATEST( @PREV_Range,  COALESCE ( `Ranged-Weapon`, 0.00 ) ) AS `Ranged-Weapon`,
                                    @PREV_Thrown := GREATEST( @PREV_Thrown, COALESCE ( `Ranged-Thrown`, 0.00 ) ) AS `Ranged-Thrown`,
                                    @PREV_Wand   := GREATEST( @PREV_Wand,   COALESCE (   `Ranged-Wand`, 0.00 ) ) AS   `Ranged-Wand`

           FROM ACSBV3_aux_dps_curve ORDER BY `ItemLevelBracket` DESC ) AS mono USING ( `ItemLevelBracket` )

SET ACSBV3_aux_dps_curve.`1H-Weapon`     = mono.`1H-Weapon`,
    ACSBV3_aux_dps_curve.`2H-Weapon`     = mono.`2H-Weapon`,
    ACSBV3_aux_dps_curve.`Staff-Weapon`  = mono.`Staff-Weapon`,
    ACSBV3_aux_dps_curve.`Ranged-Weapon` = mono.`Ranged-Weapon`,
    ACSBV3_aux_dps_curve.`Ranged-Thrown` = mono.`Ranged-Thrown`,
    ACSBV3_aux_dps_curve.`Ranged-Wand`   = mono.`Ranged-Wand`;



SELECT * FROM ACSBV3_aux_dps_curve;



CALL ACSBV3_print_footer ();

/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
