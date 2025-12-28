/*=============================================================================================================================================
  Filename:       ACSBV3-06-01A.sql
  Title:          Create Recommended Weapon Damage Table (part 1 of 5).
  Author:         Aumuz Messick
  Version:        1.0
  Created:        2025-12-09
  Description:    This script will generate dmg_min1, dmg_max1, and delay curves for use in creating "Recommended Weapon Damage Table" (ACSBV3-06-01E.sql).
                  This script is part 1 of 5. We will focus on slot_group alone (General Table).

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

SET @SCRIPT  := "0601A",
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

  `min_raw`          DECIMAL(12,5) NOT NULL,
  `min_3pnt`         DECIMAL(12,5) NOT NULL,
  `min_mono`         DECIMAL(12,5) NOT NULL,

  `max_raw`          DECIMAL(12,5) NOT NULL,
  `max_3pnt`         DECIMAL(12,5) NOT NULL,
  `max_mono`         DECIMAL(12,5) NOT NULL,

  `delay_raw`        DECIMAL(12,5) NOT NULL,
  `delay_3pnt`       DECIMAL(12,5) NOT NULL,
  `delay_mono`       DECIMAL(12,5) NOT NULL,

  `budget`           DECIMAL(12,5) NOT NULL,
  `budget_3pnt`      DECIMAL(12,5) NOT NULL,
  `budget_mono`      DECIMAL(12,5) NOT NULL

);

INSERT INTO ACSBV3_temp_curve ( `slot_group`, `ItemLevelBracket`, `min_raw`, `max_raw`, `delay_raw`, `budget`, `min_3pnt`, `max_3pnt`, `delay_3pnt`, `min_mono`, `max_mono`, `delay_mono`, `budget_3pnt`, `budget_mono` ) SELECT

  d.`slot_group`            AS       `slot_group`,
  d.`ItemLevelBracket`      AS `ItemLevelBracket`,
  AVG ( d.`dmg_min1` )      AS          `min_raw`,
  AVG ( d.`dmg_max1` )      AS          `max_raw`,
  AVG ( d.`delay`    )      AS        `delay_raw`,
  AVG ( d.`budget_actual` ) AS           `budget`,
  0                         AS         `min_3pnt`,
  0                         AS         `max_3pnt`,
  0                         AS       `delay_3pnt`,
  0                         AS         `min_mono`,
  0                         AS         `max_mono`,
  0                         AS       `delay_mono`,
  0                         AS      `budget_3pnt`,
  0                         AS      `budget_mono`

FROM ACSBV3_ref_dataset AS d WHERE d.`class` = 2 GROUP BY `slot_group`, `ItemLevelBracket`;



SELECT COUNT(*) FROM ACSBV3_temp_curve;



/*=============================================================================================================================================
  2. Create and Populate Table: ACSBV3_0601A_curve FROM ACSBV3_temp_curve ORDER BY slot_group, ItemLevelBracket
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "2. Create and Populate Table: ACSBV3_0601A_curve FROM ACSBV3_temp_curve ORDER BY slot_group, ItemLevelBracket" );



DROP   TABLE IF EXISTS ACSBV3_0601A_curve;
CREATE TABLE           ACSBV3_0601A_curve          LIKE ACSBV3_temp_curve;
INSERT INTO            ACSBV3_0601A_curve SELECT * FROM ACSBV3_temp_curve ORDER BY `slot_group` ASC, `ItemLevelBracket` ASC;



SELECT * FROM ACSBV3_0601A_curve;



/*=============================================================================================================================================
  3. Apply 3-Point Smoothing Window to Table: ACSBV3_0601A_curve
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "3. Apply 3-Point Smoothing Window to Table: ACSBV3_0601A_curve" );



WITH cte AS ( SELECT `slot_group`, `ItemLevelBracket`, AVG ( `min_raw` ) OVER ( PARTITION BY `slot_group`
                                                                                ORDER BY `ItemLevelBracket` ASC
                                                                                ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING ) AS `min_3pnt`
              FROM ACSBV3_0601A_curve )

UPDATE ACSBV3_0601A_curve AS curve
  JOIN                cte AS cte
    ON curve.`slot_group`       = cte.`slot_group`
   AND curve.`ItemLevelBracket` = cte.`ItemLevelBracket`
   SET curve.`min_3pnt`         = cte.`min_3pnt`;



WITH cte AS ( SELECT `slot_group`, `ItemLevelBracket`, AVG ( `max_raw` ) OVER ( PARTITION BY `slot_group`
                                                                                ORDER BY `ItemLevelBracket` ASC
                                                                                ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING ) AS `max_3pnt`
              FROM ACSBV3_0601A_curve )

UPDATE ACSBV3_0601A_curve AS curve
  JOIN                cte AS cte
    ON curve.`slot_group`       = cte.`slot_group`
   AND curve.`ItemLevelBracket` = cte.`ItemLevelBracket`
   SET curve.`max_3pnt`         = cte.`max_3pnt`;



WITH cte AS ( SELECT `slot_group`, `ItemLevelBracket`, AVG ( `delay_raw` ) OVER ( PARTITION BY `slot_group`
                                                                                  ORDER BY `ItemLevelBracket` ASC
                                                                                  ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING ) AS `delay_3pnt`
              FROM ACSBV3_0601A_curve )

UPDATE ACSBV3_0601A_curve AS curve
  JOIN                cte AS cte
    ON curve.`slot_group`       = cte.`slot_group`
   AND curve.`ItemLevelBracket` = cte.`ItemLevelBracket`
   SET curve.`delay_3pnt`       = cte.`delay_3pnt`;



WITH cte AS ( SELECT `slot_group`, `ItemLevelBracket`, AVG ( `budget` ) OVER ( PARTITION BY `slot_group`
                                                                               ORDER BY `ItemLevelBracket` ASC
                                                                               ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING ) AS `budget_3pnt`
              FROM ACSBV3_0601A_curve )

UPDATE ACSBV3_0601A_curve AS curve
  JOIN                cte AS cte
    ON curve.`slot_group`       = cte.`slot_group`
   AND curve.`ItemLevelBracket` = cte.`ItemLevelBracket`
   SET curve.`budget_3pnt`      = cte.`budget_3pnt`;



SELECT * FROM ACSBV3_0601A_curve;



/*=============================================================================================================================================
  4. Apply Monotonic Enforcement to Table: ACSBV3_0601A_curve
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "4. Apply Monotonic Enforcement to Table: ACSBV3_0601A_curve" );



SET @SLOT := "", @PREV := 0;

UPDATE ACSBV3_0601A_curve
  JOIN ( SELECT `slot_group`, `ItemLevelBracket`, @PREV := ( CASE WHEN @SLOT = `slot_group` THEN GREATEST ( @PREV, `min_3pnt` )
                                                                                            ELSE                   `min_3pnt`   END) AS `min_mono`, ( @SLOT := `slot_group` )
         FROM ACSBV3_0601A_curve ORDER BY `slot_group` ASC, `ItemLevelBracket` ASC ) AS mono USING ( `slot_group`, `ItemLevelBracket` )
SET ACSBV3_0601A_curve.`min_mono` = mono.`min_mono`;



SET @SLOT := "", @PREV := 0;

UPDATE ACSBV3_0601A_curve
  JOIN ( SELECT `slot_group`, `ItemLevelBracket`, @PREV := ( CASE WHEN @SLOT = `slot_group` THEN GREATEST ( @PREV, `max_3pnt` )
                                                                                            ELSE                   `max_3pnt`   END) AS `max_mono`, ( @SLOT := `slot_group` )
         FROM ACSBV3_0601A_curve ORDER BY `slot_group` ASC, `ItemLevelBracket` ASC ) AS mono USING ( `slot_group`, `ItemLevelBracket` )
SET ACSBV3_0601A_curve.`max_mono` = mono.`max_mono`;



/* Delay is not Monotonic: DO NOT APPLY
SET @SLOT := "", @PREV := 0;

UPDATE ACSBV3_0601A_curve
  JOIN ( SELECT `slot_group`, `ItemLevelBracket`, @PREV := ( CASE WHEN @SLOT = `slot_group` THEN GREATEST ( @PREV, `delay_3pnt` )
                                                                                            ELSE                   `delay_3pnt`   END) AS `delay_mono`, ( @SLOT := `slot_group` )
         FROM ACSBV3_0601A_curve ORDER BY `slot_group` ASC, `ItemLevelBracket` ASC ) AS mono USING ( `slot_group`, `ItemLevelBracket` )
SET ACSBV3_0601A_curve.`delay_mono` = mono.`delay_mono`;
*/

UPDATE ACSBV3_0601A_curve SET `delay_mono` = `delay_3pnt`;



SET @SLOT := "", @PREV := 0;

UPDATE ACSBV3_0601A_curve
  JOIN ( SELECT `slot_group`, `ItemLevelBracket`, @PREV := ( CASE WHEN @SLOT = `slot_group` THEN GREATEST ( @PREV, `budget_3pnt` )
                                                                                            ELSE                   `budget_3pnt`   END) AS `budget_mono`, ( @SLOT := `slot_group` )
         FROM ACSBV3_0601A_curve ORDER BY `slot_group` ASC, `ItemLevelBracket` ASC ) AS mono USING ( `slot_group`, `ItemLevelBracket` )
SET ACSBV3_0601A_curve.`budget_mono` = mono.`budget_mono`;



SELECT * FROM ACSBV3_0601A_curve;



SELECT "ACSBV3-06-01A.sql Complete: Part 1 of 5. Please run ACSBV3-06-01B.sql next..." AS ``;

CALL ACSBV3_print_footer ();

/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
