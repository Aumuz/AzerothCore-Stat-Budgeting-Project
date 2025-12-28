/*=============================================================================================================================================
  Filename:       ACSBV3-06-02C.sql
  Title:          Create Recommended Armor Table (part 3 of 6).
  Author:         Aumuz Messick
  Version:        1.0
  Created:        2025-12-10
  Description:    This script will generate armor, and armor_cost curves for use in creating "Recommended Armor Table" (ACSBV3-06-02F.sql).
                  This script is part 3 of 6. We will focus on slot_group and `subclass` = 2 (Leather).

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

  `slot_group`       VARCHAR(25)   NOT NULL,
  `ItemLevelBracket` SMALLINT      NOT NULL,

  `armor_raw`        DECIMAL(12,5) NOT NULL,
  `armor_3pnt`       DECIMAL(12,5) NOT NULL,
  `armor_mono`       DECIMAL(12,5) NOT NULL,

  `budget_raw`       DECIMAL(12,5) NOT NULL,
  `budget_3pnt`      DECIMAL(12,5) NOT NULL,
  `budget_mono`      DECIMAL(12,5) NOT NULL

);

INSERT INTO ACSBV3_temp_curve SELECT

  d.`slot_group`            AS       `slot_group`,
  d.`ItemLevelBracket`      AS `ItemLevelBracket`,
  AVG ( d.`armor` )         AS        `armor_raw`,
  0                         AS       `armor_3pnt`,
  0                         AS       `armor_mono`,
  AVG ( d.`budget_actual` ) AS       `budget_raw`,
  0                         AS      `budget_3pnt`,
  0                         AS      `budget_mono`

FROM ACSBV3_ref_dataset AS d WHERE d.`class` = 4 AND `subclass` = 2 AND d.`armor` > 0 GROUP BY `slot_group`, `ItemLevelBracket`;



SELECT COUNT(*) FROM ACSBV3_temp_curve;



/*=============================================================================================================================================
  2. Create and Populate Table: ACSBV3_0602C_curve FROM ACSBV3_temp_curve ORDER BY slot_group, ItemLevelBracket
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "2. Create and Populate Table: ACSBV3_0602C_curve FROM ACSBV3_temp_curve ORDER BY slot_group, ItemLevelBracket" );



DROP   TABLE IF EXISTS ACSBV3_0602C_curve;
CREATE TABLE           ACSBV3_0602C_curve          LIKE ACSBV3_temp_curve;
INSERT INTO            ACSBV3_0602C_curve SELECT * FROM ACSBV3_temp_curve ORDER BY `slot_group` ASC, `ItemLevelBracket` ASC;



SELECT * FROM ACSBV3_0602C_curve;



/*=============================================================================================================================================
  3. Apply 3-Point Smoothing Window to Table: ACSBV3_0602C_curve
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "3. Apply 3-Point Smoothing Window to Table: ACSBV3_0602C_curve" );



WITH cte AS ( SELECT `slot_group`, `ItemLevelBracket`, AVG ( `armor_raw` ) OVER ( PARTITION BY `slot_group`
                                                                                  ORDER BY `ItemLevelBracket` ASC
                                                                                  ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING ) AS `armor_3pnt`
              FROM ACSBV3_0602C_curve )

UPDATE ACSBV3_0602C_curve AS curve
  JOIN                cte AS cte
    ON curve.`slot_group`       = cte.`slot_group`
   AND curve.`ItemLevelBracket` = cte.`ItemLevelBracket`
   SET curve.`armor_3pnt`       = cte.`armor_3pnt`;



WITH cte AS ( SELECT `slot_group`, `ItemLevelBracket`, AVG ( `budget_raw` ) OVER ( PARTITION BY `slot_group`
                                                                                   ORDER BY `ItemLevelBracket` ASC
                                                                                   ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING ) AS `budget_3pnt`
              FROM ACSBV3_0602C_curve )

UPDATE ACSBV3_0602C_curve AS curve
  JOIN                cte AS cte
    ON curve.`slot_group`       = cte.`slot_group`
   AND curve.`ItemLevelBracket` = cte.`ItemLevelBracket`
   SET curve.`budget_3pnt`      = cte.`budget_3pnt`;



SELECT * FROM ACSBV3_0602C_curve;



/*=============================================================================================================================================
  4. Apply Monotonic Enforcement to Table: ACSBV3_0602C_curve
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "4. Apply Monotonic Enforcement to Table: ACSBV3_0602C_curve" );



SET @SLOT := "", @PREV := 0;

UPDATE ACSBV3_0602C_curve
  JOIN ( SELECT `slot_group`, `ItemLevelBracket`, @PREV := ( CASE WHEN @SLOT = `slot_group` THEN GREATEST ( @PREV, `armor_3pnt` )
                                                                                            ELSE                   `armor_3pnt`   END) AS `armor_mono`, ( @SLOT := `slot_group` )
         FROM ACSBV3_0602C_curve ORDER BY `slot_group`, `ItemLevelBracket` ) AS mono USING ( `slot_group`, `ItemLevelBracket` )
SET ACSBV3_0602C_curve.`armor_mono` = mono.`armor_mono`;



SET @SLOT := "", @PREV := 0;

UPDATE ACSBV3_0602C_curve
  JOIN ( SELECT `slot_group`, `ItemLevelBracket`, @PREV := ( CASE WHEN @SLOT = `slot_group` THEN GREATEST ( @PREV, `budget_3pnt` )
                                                                                            ELSE                   `budget_3pnt`   END) AS `budget_mono`, ( @SLOT := `slot_group` )
         FROM ACSBV3_0602C_curve ORDER BY `slot_group`, `ItemLevelBracket` ) AS mono USING ( `slot_group`, `ItemLevelBracket` )
SET ACSBV3_0602C_curve.`budget_mono` = mono.`budget_mono`;



SELECT * FROM ACSBV3_0602C_curve;



SELECT "ACSBV3-06-02C.sql Complete: Part 3 of 6. Please run ACSBV3-06-02D.sql next..." AS ``;

CALL ACSBV3_print_footer ();

/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
