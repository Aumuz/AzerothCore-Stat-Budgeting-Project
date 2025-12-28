/*=============================================================================================================================================
  Filename:       ACSBV3-06-00C.sql
  Title:          Generate Armor Curves.
  Author:         Aumuz Messick
  Version:        2.0
  Created:        2025-12-09
  Description:    This script will generate DPS to iLvl curves for each armor meta-group.

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

SET @SCRIPT  := "0600C",
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

     ( ( ( AVG ( `armor` ) * 0.20 ) / AVG ( `budget_actual` ) ) * 100 ) AS `curve_raw`

FROM ACSBV3_ref_dataset AS d WHERE d.`class` = 4 AND `subclass` > 0 GROUP BY `slot_group`, `ItemLevelBracket`;



SELECT COUNT(*) FROM ACSBV3_temp_curve;



/*=============================================================================================================================================
  2. Create and Populate Table: ACSBV3_0600C_armor_curve FROM ACSBV3_temp_curve ORDER BY slot_group, ItemLevelBracket
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "2. Create and Populate Table: ACSBV3_0600C_armor_curve FROM ACSBV3_temp_curve ORDER BY slot_group, ItemLevelBracket" );



DROP   TABLE IF EXISTS ACSBV3_0600C_armor_curve;
CREATE TABLE           ACSBV3_0600C_armor_curve          LIKE ACSBV3_temp_curve;
INSERT INTO            ACSBV3_0600C_armor_curve SELECT * FROM ACSBV3_temp_curve ORDER BY `slot_group` ASC, `ItemLevelBracket` ASC;



SELECT * FROM ACSBV3_0600C_armor_curve;



/*=============================================================================================================================================
  3. Apply 3-Point Smoothing Window to Table: ACSBV3_0600C_armor_curve
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "3. Apply 3-Point Smoothing Window to Table: ACSBV3_0600C_armor_curve" );



WITH cte AS ( SELECT `slot_group`, `ItemLevelBracket`, AVG ( `curve_raw` ) OVER ( PARTITION BY `slot_group`
                                                                                  ORDER BY `ItemLevelBracket` ASC
                                                                                  ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING ) AS `curve_3pnt`
              FROM ACSBV3_0600C_armor_curve )

UPDATE ACSBV3_0600C_armor_curve AS curve
  JOIN                    cte AS cte
    ON curve.`slot_group`       = cte.`slot_group`
   AND curve.`ItemLevelBracket` = cte.`ItemLevelBracket`
   SET curve.`curve_3pnt`       = cte.`curve_3pnt`;



SELECT * FROM ACSBV3_0600C_armor_curve;



/*=============================================================================================================================================
  4. Create and Populate Table: ACSBV3_aux_armor_curve
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "4. Create and Populate Table: ACSBV3_aux_armor_curve" );



DROP   TABLE IF EXISTS ACSBV3_aux_armor_curve;

CREATE TABLE           ACSBV3_aux_armor_curve
(

  `ItemLevelBracket` SMALLINT      NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `Major-Armor`      DECIMAL(12,5)          COMMENT "Armor Meta Group:    Major-Armor",
  `Moderate-Armor`   DECIMAL(12,5)          COMMENT "Armor Meta Group: Moderate-Armor",
  `Minor-Armor`      DECIMAL(12,5)          COMMENT "Armor Meta Group:    Minor-Armor",
  `Accessory`        DECIMAL(12,5)          COMMENT "Armor Meta Group:      Accessory",
  `Shield`           DECIMAL(12,5)          COMMENT "Armor Meta Group:         Shield",
  `Back`             DECIMAL(12,5)          COMMENT "Armor Meta Group:           Back"

);

INSERT INTO ACSBV3_aux_armor_curve

WITH RECURSIVE seq AS ( SELECT                      10 AS `ItemLevelBracket` UNION ALL
                        SELECT `ItemLevelBracket` + 10 AS `ItemLevelBracket`
                          FROM                  seq WHERE `ItemLevelBracket` < 300 )

SELECT    seq.`ItemLevelBracket` AS `ItemLevelBracket`,

          c1.`curve_3pnt`        AS      `Major-Armor`,
          c2.`curve_3pnt`        AS   `Moderate-Armor`,
          c3.`curve_3pnt`        AS      `Minor-Armor`,
          c4.`curve_3pnt`        AS        `Accessory`,
          c5.`curve_3pnt`        AS           `Shield`,
          c6.`curve_3pnt`        AS             `Back`

FROM seq
LEFT JOIN ACSBV3_0600C_armor_curve AS c1 ON c1.`ItemLevelBracket` = seq.`ItemLevelBracket` AND c1.`slot_group` = "Major-Armor"
LEFT JOIN ACSBV3_0600C_armor_curve AS c2 ON c2.`ItemLevelBracket` = seq.`ItemLevelBracket` AND c2.`slot_group` = "Moderate-Armor"
LEFT JOIN ACSBV3_0600C_armor_curve AS c3 ON c3.`ItemLevelBracket` = seq.`ItemLevelBracket` AND c3.`slot_group` = "Minor-Armor"
LEFT JOIN ACSBV3_0600C_armor_curve AS c4 ON c4.`ItemLevelBracket` = seq.`ItemLevelBracket` AND c4.`slot_group` = "Accessory"
LEFT JOIN ACSBV3_0600C_armor_curve AS c5 ON c5.`ItemLevelBracket` = seq.`ItemLevelBracket` AND c5.`slot_group` = "Shield"
LEFT JOIN ACSBV3_0600C_armor_curve AS c6 ON c6.`ItemLevelBracket` = seq.`ItemLevelBracket` AND c6.`slot_group` = "Back";



SELECT * FROM ACSBV3_aux_armor_curve;



/*=============================================================================================================================================
  5. Apply Monotonic Enforcement to Table: ACSBV3_aux_armor_curve
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "5. Apply Monotonic Enforcement to Table: ACSBV3_aux_armor_curve" );



UPDATE ACSBV3_aux_armor_curve
   SET `Major-Armor`    := ( SELECT MIN( `curve_3pnt` ) FROM ACSBV3_0600C_armor_curve WHERE `slot_group` = "Major-Armor"    ),
       `Moderate-Armor` := ( SELECT MIN( `curve_3pnt` ) FROM ACSBV3_0600C_armor_curve WHERE `slot_group` = "Moderate-Armor" ),
       `Minor-Armor`    := ( SELECT MIN( `curve_3pnt` ) FROM ACSBV3_0600C_armor_curve WHERE `slot_group` = "Minor-Armor"    ),
       `Accessory`      := ( SELECT MIN( `curve_3pnt` ) FROM ACSBV3_0600C_armor_curve WHERE `slot_group` = "Accessory"      ),
       `Shield`         := ( SELECT MIN( `curve_3pnt` ) FROM ACSBV3_0600C_armor_curve WHERE `slot_group` = "Shield"         ),
       `Back`           := ( SELECT MIN( `curve_3pnt` ) FROM ACSBV3_0600C_armor_curve WHERE `slot_group` = "Back"           )
 WHERE `ItemLevelBracket` = 300;

SET @PREV_MA := 0.00,
    @PREV_MO := 0.00,
    @PREV_MI := 0.00,
    @PREV_AC := 0.00,
    @PREV_SH := 0.00,
    @PREV_BK := 0.00;

UPDATE ACSBV3_aux_armor_curve
  JOIN ( SELECT `ItemLevelBracket`, @PREV_MA := GREATEST( @PREV_MA, COALESCE (    `Major-Armor`, 0.00 ) ) AS    `Major-Armor`,
                                    @PREV_MO := GREATEST( @PREV_MO, COALESCE ( `Moderate-Armor`, 0.00 ) ) AS `Moderate-Armor`,
                                    @PREV_MI := GREATEST( @PREV_MI, COALESCE (    `Minor-Armor`, 0.00 ) ) AS    `Minor-Armor`,
                                    @PREV_AC := GREATEST( @PREV_AC, COALESCE (      `Accessory`, 0.00 ) ) AS      `Accessory`,
                                    @PREV_SH := GREATEST( @PREV_SH, COALESCE (         `Shield`, 0.00 ) ) AS         `Shield`,
                                    @PREV_BK := GREATEST( @PREV_BK, COALESCE (           `Back`, 0.00 ) ) AS           `Back`

           FROM ACSBV3_aux_armor_curve ORDER BY `ItemLevelBracket` DESC ) AS mono USING ( `ItemLevelBracket` )

SET ACSBV3_aux_armor_curve.`Major-Armor`    = mono.`Major-Armor`,
    ACSBV3_aux_armor_curve.`Moderate-Armor` = mono.`Moderate-Armor`,
    ACSBV3_aux_armor_curve.`Minor-Armor`    = mono.`Minor-Armor`,
    ACSBV3_aux_armor_curve.`Accessory`      = mono.`Accessory`,
    ACSBV3_aux_armor_curve.`Shield`         = mono.`Shield`,
    ACSBV3_aux_armor_curve.`Back`           = mono.`Back`;



SELECT * FROM ACSBV3_aux_armor_curve;



CALL ACSBV3_print_footer ();

/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
