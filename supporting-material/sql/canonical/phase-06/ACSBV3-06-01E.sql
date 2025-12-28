/*=============================================================================================================================================
  Filename:       ACSBV3-06-01E.sql
  Title:          Create Recommended Weapon Damage Table (part 5 of 5).
  Author:         Aumuz Messick
  Version:        1.0
  Created:        2025-12-10
  Description:    This script will assemble the final "Recommended Weapon Damage Tables".

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

SET @SCRIPT  := "0601E",
    @VERSION := "1.0";



/*=============================================================================================================================================
  1.0 - Create and Populate Table: ACSBV3_aux_damage_1hand_general
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "1.0 - Create and Populate Table: ACSBV3_aux_damage_1hand_general" );



DROP   TABLE IF EXISTS ACSBV3_aux_damage_1hand_general;

CREATE TABLE           ACSBV3_aux_damage_1hand_general
(

  `slot_group`       VARCHAR(35)   NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `ItemLevelBracket` SMALLINT      NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `dmg_min1`         DECIMAL(12,5) NOT NULL COMMENT "Average Minimum Weapon Damage.",
  `dmg_max1`         DECIMAL(12,5) NOT NULL COMMENT "Average Maximum Weapon Damage.",
  `delay`            DECIMAL(12,5) NOT NULL COMMENT "Average Weapon Delay.",
  `DPS`              DECIMAL(12,5) NOT NULL COMMENT "DPS = ( dmg_min1 + dmg_max1 ) / 2 / ( delay / 1000 )",
  `budget_avg`       DECIMAL(12,5) NOT NULL COMMENT "Average Actual Budget.",
  `budget_ratio`     DECIMAL(12,5) NOT NULL COMMENT "budget_ratio = ( ( ( dmg_min1 + dmg_max1 ) / 2 / ( delay / 1000 ) ) / budget_avg ) * 100"

);

-- This curve assumes monotonic smoothing has already been applied in 06-01A/B/C/D.

SET @PREV_MIN    := 0.00,
    @PREV_MAX    := 0.00,
    @PREV_DELAY  := 0.00,
    @PREV_BUDGET := 0.00;

INSERT INTO ACSBV3_aux_damage_1hand_general

WITH RECURSIVE seq AS ( SELECT                      10 AS `ItemLevelBracket` UNION ALL
                        SELECT `ItemLevelBracket` + 10 AS `ItemLevelBracket`
                          FROM                  seq WHERE `ItemLevelBracket` < 300 )

SELECT                                           "1H-Weapon" AS       `slot_group`,
                                      seq.`ItemLevelBracket` AS `ItemLevelBracket`,
  @PREV_MIN    := COALESCE ( c.`min_mono`,    @PREV_MIN    ) AS         `dmg_min1`,
  @PREV_MAX    := COALESCE ( c.`max_mono`,    @PREV_MAX    ) AS         `dmg_max1`,
  @PREV_DELAY  := COALESCE ( c.`delay_mono`,  @PREV_DELAY  ) AS            `delay`,
                                                       0.00  AS              `DPS`,
  @PREV_BUDGET := COALESCE ( c.`budget_mono`, @PREV_BUDGET ) AS       `budget_avg`,
                                                       0.00  AS     `budget_ratio`
FROM seq
LEFT JOIN ACSBV3_0601A_curve AS c ON c.`ItemLevelBracket` = seq.`ItemLevelBracket` AND c.`slot_group` = "1H-Weapon";

UPDATE ACSBV3_aux_damage_1hand_general
SET `DPS`          =   ( ( `dmg_min1` + `dmg_max1` ) / 2 / ( `delay` / 1000 ) ),
    `budget_ratio` = ( ( ( `dmg_min1` + `dmg_max1` ) / 2 / ( `delay` / 1000 ) ) / `budget_avg` ) * 100;



SELECT COUNT(*) FROM ACSBV3_aux_damage_1hand_general;



/*=============================================================================================================================================
  1.1 - Create and Populate Table: ACSBV3_aux_damage_1hand_1hand
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "1.1 - Create and Populate Table: ACSBV3_aux_damage_1hand_1hand" );



DROP   TABLE IF EXISTS ACSBV3_aux_damage_1hand_1hand;

CREATE TABLE           ACSBV3_aux_damage_1hand_1hand
(

  `slot_group`       VARCHAR(35)   NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `ItemLevelBracket` SMALLINT      NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `dmg_min1`         DECIMAL(12,5) NOT NULL COMMENT "Average Minimum Weapon Damage.",
  `dmg_max1`         DECIMAL(12,5) NOT NULL COMMENT "Average Maximum Weapon Damage.",
  `delay`            DECIMAL(12,5) NOT NULL COMMENT "Average Weapon Delay.",
  `DPS`              DECIMAL(12,5) NOT NULL COMMENT "DPS = ( dmg_min1 + dmg_max1 ) / 2 / ( delay / 1000 )",
  `budget_avg`       DECIMAL(12,5) NOT NULL COMMENT "Average Actual Budget.",
  `budget_ratio`     DECIMAL(12,5) NOT NULL COMMENT "budget_ratio = ( ( ( dmg_min1 + dmg_max1 ) / 2 / ( delay / 1000 ) ) / budget_avg ) * 100"

);

-- This curve assumes monotonic smoothing has already been applied in 06-01A/B/C/D.

SET @PREV_MIN    := 0.00,
    @PREV_MAX    := 0.00,
    @PREV_DELAY  := 0.00,
    @PREV_BUDGET := 0.00;

INSERT INTO ACSBV3_aux_damage_1hand_1hand

WITH RECURSIVE seq AS ( SELECT                      10 AS `ItemLevelBracket` UNION ALL
                        SELECT `ItemLevelBracket` + 10 AS `ItemLevelBracket`
                          FROM                  seq WHERE `ItemLevelBracket` < 300 )

SELECT                      "1H-Weapon ( InventoryType 13 )" AS       `slot_group`,
                                      seq.`ItemLevelBracket` AS `ItemLevelBracket`,
  @PREV_MIN    := COALESCE ( c.`min_mono`,    @PREV_MIN    ) AS         `dmg_min1`,
  @PREV_MAX    := COALESCE ( c.`max_mono`,    @PREV_MAX    ) AS         `dmg_max1`,
  @PREV_DELAY  := COALESCE ( c.`delay_mono`,  @PREV_DELAY  ) AS            `delay`,
                                                       0.00  AS              `DPS`,
  @PREV_BUDGET := COALESCE ( c.`budget_mono`, @PREV_BUDGET ) AS       `budget_avg`,
                                                       0.00  AS     `budget_ratio`
FROM seq
LEFT JOIN ACSBV3_0601B_curve AS c ON c.`ItemLevelBracket` = seq.`ItemLevelBracket` AND c.`slot_group` = "1H-Weapon";

UPDATE ACSBV3_aux_damage_1hand_1hand
SET `DPS`          =   ( ( `dmg_min1` + `dmg_max1` ) / 2 / ( `delay` / 1000 ) ),
    `budget_ratio` = ( ( ( `dmg_min1` + `dmg_max1` ) / 2 / ( `delay` / 1000 ) ) / `budget_avg` ) * 100;



SELECT COUNT(*) FROM ACSBV3_aux_damage_1hand_1hand;



/*=============================================================================================================================================
  1.2 - Create and Populate Table: ACSBV3_aux_damage_1hand_main
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "1.2 - Create and Populate Table: ACSBV3_aux_damage_1hand_main" );



DROP   TABLE IF EXISTS ACSBV3_aux_damage_1hand_main;

CREATE TABLE           ACSBV3_aux_damage_1hand_main
(

  `slot_group`       VARCHAR(35)   NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `ItemLevelBracket` SMALLINT      NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `dmg_min1`         DECIMAL(12,5) NOT NULL COMMENT "Average Minimum Weapon Damage.",
  `dmg_max1`         DECIMAL(12,5) NOT NULL COMMENT "Average Maximum Weapon Damage.",
  `delay`            DECIMAL(12,5) NOT NULL COMMENT "Average Weapon Delay.",
  `DPS`              DECIMAL(12,5) NOT NULL COMMENT "DPS = ( dmg_min1 + dmg_max1 ) / 2 / ( delay / 1000 )",
  `budget_avg`       DECIMAL(12,5) NOT NULL COMMENT "Average Actual Budget.",
  `budget_ratio`     DECIMAL(12,5) NOT NULL COMMENT "budget_ratio = ( ( ( dmg_min1 + dmg_max1 ) / 2 / ( delay / 1000 ) ) / budget_avg ) * 100"

);

-- This curve assumes monotonic smoothing has already been applied in 06-01A/B/C/D.

SET @PREV_MIN    := 0.00,
    @PREV_MAX    := 0.00,
    @PREV_DELAY  := 0.00,
    @PREV_BUDGET := 0.00;

INSERT INTO ACSBV3_aux_damage_1hand_main

WITH RECURSIVE seq AS ( SELECT                      10 AS `ItemLevelBracket` UNION ALL
                        SELECT `ItemLevelBracket` + 10 AS `ItemLevelBracket`
                          FROM                  seq WHERE `ItemLevelBracket` < 300 )

SELECT                      "1H-Weapon ( InventoryType 21 )" AS       `slot_group`,
                                      seq.`ItemLevelBracket` AS `ItemLevelBracket`,
  @PREV_MIN    := COALESCE ( c.`min_mono`,    @PREV_MIN    ) AS         `dmg_min1`,
  @PREV_MAX    := COALESCE ( c.`max_mono`,    @PREV_MAX    ) AS         `dmg_max1`,
  @PREV_DELAY  := COALESCE ( c.`delay_mono`,  @PREV_DELAY  ) AS            `delay`,
                                                       0.00  AS              `DPS`,
  @PREV_BUDGET := COALESCE ( c.`budget_mono`, @PREV_BUDGET ) AS       `budget_avg`,
                                                       0.00  AS     `budget_ratio`
FROM seq
LEFT JOIN ACSBV3_0601C_curve AS c ON c.`ItemLevelBracket` = seq.`ItemLevelBracket` AND c.`slot_group` = "1H-Weapon";

UPDATE ACSBV3_aux_damage_1hand_main
SET `DPS`          =   ( ( `dmg_min1` + `dmg_max1` ) / 2 / ( `delay` / 1000 ) ),
    `budget_ratio` = ( ( ( `dmg_min1` + `dmg_max1` ) / 2 / ( `delay` / 1000 ) ) / `budget_avg` ) * 100;



SELECT COUNT(*) FROM ACSBV3_aux_damage_1hand_main;



/*=============================================================================================================================================
  1.3 - Create and Populate Table: ACSBV3_aux_damage_1hand_off
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "1.3 - Create and Populate Table: ACSBV3_aux_damage_1hand_off" );



DROP   TABLE IF EXISTS ACSBV3_aux_damage_1hand_off;

CREATE TABLE           ACSBV3_aux_damage_1hand_off
(

  `slot_group`       VARCHAR(35)   NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `ItemLevelBracket` SMALLINT      NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `dmg_min1`         DECIMAL(12,5) NOT NULL COMMENT "Average Minimum Weapon Damage.",
  `dmg_max1`         DECIMAL(12,5) NOT NULL COMMENT "Average Maximum Weapon Damage.",
  `delay`            DECIMAL(12,5) NOT NULL COMMENT "Average Weapon Delay.",
  `DPS`              DECIMAL(12,5) NOT NULL COMMENT "DPS = ( dmg_min1 + dmg_max1 ) / 2 / ( delay / 1000 )",
  `budget_avg`       DECIMAL(12,5) NOT NULL COMMENT "Average Actual Budget.",
  `budget_ratio`     DECIMAL(12,5) NOT NULL COMMENT "budget_ratio = ( ( ( dmg_min1 + dmg_max1 ) / 2 / ( delay / 1000 ) ) / budget_avg ) * 100"

);

-- This curve assumes monotonic smoothing has already been applied in 06-01A/B/C/D.

SET @PREV_MIN    := 0.00,
    @PREV_MAX    := 0.00,
    @PREV_DELAY  := 0.00,
    @PREV_BUDGET := 0.00;

INSERT INTO ACSBV3_aux_damage_1hand_off

WITH RECURSIVE seq AS ( SELECT                      10 AS `ItemLevelBracket` UNION ALL
                        SELECT `ItemLevelBracket` + 10 AS `ItemLevelBracket`
                          FROM                  seq WHERE `ItemLevelBracket` < 300 )

SELECT                      "1H-Weapon ( InventoryType 22 )" AS       `slot_group`,
                                      seq.`ItemLevelBracket` AS `ItemLevelBracket`,
  @PREV_MIN    := COALESCE ( c.`min_mono`,    @PREV_MIN    ) AS         `dmg_min1`,
  @PREV_MAX    := COALESCE ( c.`max_mono`,    @PREV_MAX    ) AS         `dmg_max1`,
  @PREV_DELAY  := COALESCE ( c.`delay_mono`,  @PREV_DELAY  ) AS            `delay`,
                                                       0.00  AS              `DPS`,
  @PREV_BUDGET := COALESCE ( c.`budget_mono`, @PREV_BUDGET ) AS       `budget_avg`,
                                                       0.00  AS     `budget_ratio`
FROM seq
LEFT JOIN ACSBV3_0601D_curve AS c ON c.`ItemLevelBracket` = seq.`ItemLevelBracket` AND c.`slot_group` = "1H-Weapon";

UPDATE ACSBV3_aux_damage_1hand_off
SET `DPS`          =   ( ( `dmg_min1` + `dmg_max1` ) / 2 / ( `delay` / 1000 ) ),
    `budget_ratio` = ( ( ( `dmg_min1` + `dmg_max1` ) / 2 / ( `delay` / 1000 ) ) / `budget_avg` ) * 100;



SELECT COUNT(*) FROM ACSBV3_aux_damage_1hand_off;



/*=============================================================================================================================================
  2. Create and Populate Table: ACSBV3_aux_damage_2hand
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "2. Create and Populate Table: ACSBV3_aux_damage_2hand" );



DROP   TABLE IF EXISTS ACSBV3_aux_damage_2hand;

CREATE TABLE           ACSBV3_aux_damage_2hand
(

  `slot_group`       VARCHAR(35)   NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `ItemLevelBracket` SMALLINT      NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `dmg_min1`         DECIMAL(12,5) NOT NULL COMMENT "Average Minimum Weapon Damage.",
  `dmg_max1`         DECIMAL(12,5) NOT NULL COMMENT "Average Maximum Weapon Damage.",
  `delay`            DECIMAL(12,5) NOT NULL COMMENT "Average Weapon Delay.",
  `DPS`              DECIMAL(12,5) NOT NULL COMMENT "DPS = ( dmg_min1 + dmg_max1 ) / 2 / ( delay / 1000 )",
  `budget_avg`       DECIMAL(12,5) NOT NULL COMMENT "Average Actual Budget.",
  `budget_ratio`     DECIMAL(12,5) NOT NULL COMMENT "budget_ratio = ( ( ( dmg_min1 + dmg_max1 ) / 2 / ( delay / 1000 ) ) / budget_avg ) * 100"

);

-- This curve assumes monotonic smoothing has already been applied in 06-01A/B/C/D.

SET @PREV_MIN    := 0.00,
    @PREV_MAX    := 0.00,
    @PREV_DELAY  := 0.00,
    @PREV_BUDGET := 0.00;

INSERT INTO ACSBV3_aux_damage_2hand

WITH RECURSIVE seq AS ( SELECT                      10 AS `ItemLevelBracket` UNION ALL
                        SELECT `ItemLevelBracket` + 10 AS `ItemLevelBracket`
                          FROM                  seq WHERE `ItemLevelBracket` < 300 )

SELECT                                           "2H-Weapon" AS       `slot_group`,
                                      seq.`ItemLevelBracket` AS `ItemLevelBracket`,
  @PREV_MIN    := COALESCE ( c.`min_mono`,    @PREV_MIN    ) AS         `dmg_min1`,
  @PREV_MAX    := COALESCE ( c.`max_mono`,    @PREV_MAX    ) AS         `dmg_max1`,
  @PREV_DELAY  := COALESCE ( c.`delay_mono`,  @PREV_DELAY  ) AS            `delay`,
                                                       0.00  AS              `DPS`,
  @PREV_BUDGET := COALESCE ( c.`budget_mono`, @PREV_BUDGET ) AS       `budget_avg`,
                                                       0.00  AS     `budget_ratio`
FROM seq
LEFT JOIN ACSBV3_0601A_curve AS c ON c.`ItemLevelBracket` = seq.`ItemLevelBracket` AND c.`slot_group` = "2H-Weapon";

UPDATE ACSBV3_aux_damage_2hand
SET `DPS`          =   ( ( `dmg_min1` + `dmg_max1` ) / 2 / ( `delay` / 1000 ) ),
    `budget_ratio` = ( ( ( `dmg_min1` + `dmg_max1` ) / 2 / ( `delay` / 1000 ) ) / `budget_avg` ) * 100;



SELECT COUNT(*) FROM ACSBV3_aux_damage_2hand;



/*=============================================================================================================================================
  3. Create and Populate Table: ACSBV3_aux_damage_staff
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "3. Create and Populate Table: ACSBV3_aux_damage_staff" );



DROP   TABLE IF EXISTS ACSBV3_aux_damage_staff;

CREATE TABLE           ACSBV3_aux_damage_staff
(

  `slot_group`       VARCHAR(35)   NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `ItemLevelBracket` SMALLINT      NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `dmg_min1`         DECIMAL(12,5) NOT NULL COMMENT "Average Minimum Weapon Damage.",
  `dmg_max1`         DECIMAL(12,5) NOT NULL COMMENT "Average Maximum Weapon Damage.",
  `delay`            DECIMAL(12,5) NOT NULL COMMENT "Average Weapon Delay.",
  `DPS`              DECIMAL(12,5) NOT NULL COMMENT "DPS = ( dmg_min1 + dmg_max1 ) / 2 / ( delay / 1000 )",
  `budget_avg`       DECIMAL(12,5) NOT NULL COMMENT "Average Actual Budget.",
  `budget_ratio`     DECIMAL(12,5) NOT NULL COMMENT "budget_ratio = ( ( ( dmg_min1 + dmg_max1 ) / 2 / ( delay / 1000 ) ) / budget_avg ) * 100"

);

-- This curve assumes monotonic smoothing has already been applied in 06-01A/B/C/D.

SET @PREV_MIN    := 0.00,
    @PREV_MAX    := 0.00,
    @PREV_DELAY  := 0.00,
    @PREV_BUDGET := 0.00;

INSERT INTO ACSBV3_aux_damage_staff

WITH RECURSIVE seq AS ( SELECT                      10 AS `ItemLevelBracket` UNION ALL
                        SELECT `ItemLevelBracket` + 10 AS `ItemLevelBracket`
                          FROM                  seq WHERE `ItemLevelBracket` < 300 )

SELECT                                        "Staff-Weapon" AS       `slot_group`,
                                      seq.`ItemLevelBracket` AS `ItemLevelBracket`,
  @PREV_MIN    := COALESCE ( c.`min_mono`,    @PREV_MIN    ) AS         `dmg_min1`,
  @PREV_MAX    := COALESCE ( c.`max_mono`,    @PREV_MAX    ) AS         `dmg_max1`,
  @PREV_DELAY  := COALESCE ( c.`delay_mono`,  @PREV_DELAY  ) AS            `delay`,
                                                       0.00  AS              `DPS`,
  @PREV_BUDGET := COALESCE ( c.`budget_mono`, @PREV_BUDGET ) AS       `budget_avg`,
                                                       0.00  AS     `budget_ratio`
FROM seq
LEFT JOIN ACSBV3_0601A_curve AS c ON c.`ItemLevelBracket` = seq.`ItemLevelBracket` AND c.`slot_group` = "Staff-Weapon";

UPDATE ACSBV3_aux_damage_staff
SET `DPS`          =   ( ( `dmg_min1` + `dmg_max1` ) / 2 / ( `delay` / 1000 ) ),
    `budget_ratio` = ( ( ( `dmg_min1` + `dmg_max1` ) / 2 / ( `delay` / 1000 ) ) / `budget_avg` ) * 100;



SELECT COUNT(*) FROM ACSBV3_aux_damage_staff;



/*=============================================================================================================================================
  4. Create and Populate Table: ACSBV3_aux_damage_ranged
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "4. Create and Populate Table: ACSBV3_aux_damage_ranged" );



DROP   TABLE IF EXISTS ACSBV3_aux_damage_ranged;

CREATE TABLE           ACSBV3_aux_damage_ranged
(

  `slot_group`       VARCHAR(35)   NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `ItemLevelBracket` SMALLINT      NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `dmg_min1`         DECIMAL(12,5) NOT NULL COMMENT "Average Minimum Weapon Damage.",
  `dmg_max1`         DECIMAL(12,5) NOT NULL COMMENT "Average Maximum Weapon Damage.",
  `delay`            DECIMAL(12,5) NOT NULL COMMENT "Average Weapon Delay.",
  `DPS`              DECIMAL(12,5) NOT NULL COMMENT "DPS = ( dmg_min1 + dmg_max1 ) / 2 / ( delay / 1000 )",
  `budget_avg`       DECIMAL(12,5) NOT NULL COMMENT "Average Actual Budget.",
  `budget_ratio`     DECIMAL(12,5) NOT NULL COMMENT "budget_ratio = ( ( ( dmg_min1 + dmg_max1 ) / 2 / ( delay / 1000 ) ) / budget_avg ) * 100"

);

-- This curve assumes monotonic smoothing has already been applied in 06-01A/B/C/D.

SET @PREV_MIN    := 0.00,
    @PREV_MAX    := 0.00,
    @PREV_DELAY  := 0.00,
    @PREV_BUDGET := 0.00;

INSERT INTO ACSBV3_aux_damage_ranged

WITH RECURSIVE seq AS ( SELECT                      10 AS `ItemLevelBracket` UNION ALL
                        SELECT `ItemLevelBracket` + 10 AS `ItemLevelBracket`
                          FROM                  seq WHERE `ItemLevelBracket` < 300 )

SELECT                                       "Ranged-Weapon" AS       `slot_group`,
                                      seq.`ItemLevelBracket` AS `ItemLevelBracket`,
  @PREV_MIN    := COALESCE ( c.`min_mono`,    @PREV_MIN    ) AS         `dmg_min1`,
  @PREV_MAX    := COALESCE ( c.`max_mono`,    @PREV_MAX    ) AS         `dmg_max1`,
  @PREV_DELAY  := COALESCE ( c.`delay_mono`,  @PREV_DELAY  ) AS            `delay`,
                                                       0.00  AS              `DPS`,
  @PREV_BUDGET := COALESCE ( c.`budget_mono`, @PREV_BUDGET ) AS       `budget_avg`,
                                                       0.00  AS     `budget_ratio`
FROM seq
LEFT JOIN ACSBV3_0601A_curve AS c ON c.`ItemLevelBracket` = seq.`ItemLevelBracket` AND c.`slot_group` = "Ranged-Weapon";

UPDATE ACSBV3_aux_damage_ranged
SET `DPS`          =   ( ( `dmg_min1` + `dmg_max1` ) / 2 / ( `delay` / 1000 ) ),
    `budget_ratio` = ( ( ( `dmg_min1` + `dmg_max1` ) / 2 / ( `delay` / 1000 ) ) / `budget_avg` ) * 100;



SELECT COUNT(*) FROM ACSBV3_aux_damage_ranged;



/*=============================================================================================================================================
  5. Create and Populate Table: ACSBV3_aux_damage_thrown
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "5. Create and Populate Table: ACSBV3_aux_damage_thrown" );



DROP   TABLE IF EXISTS ACSBV3_aux_damage_thrown;

CREATE TABLE           ACSBV3_aux_damage_thrown
(

  `slot_group`       VARCHAR(35)   NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `ItemLevelBracket` SMALLINT      NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `dmg_min1`         DECIMAL(12,5) NOT NULL COMMENT "Average Minimum Weapon Damage.",
  `dmg_max1`         DECIMAL(12,5) NOT NULL COMMENT "Average Maximum Weapon Damage.",
  `delay`            DECIMAL(12,5) NOT NULL COMMENT "Average Weapon Delay.",
  `DPS`              DECIMAL(12,5) NOT NULL COMMENT "DPS = ( dmg_min1 + dmg_max1 ) / 2 / ( delay / 1000 )",
  `budget_avg`       DECIMAL(12,5) NOT NULL COMMENT "Average Actual Budget.",
  `budget_ratio`     DECIMAL(12,5) NOT NULL COMMENT "budget_ratio = ( ( ( dmg_min1 + dmg_max1 ) / 2 / ( delay / 1000 ) ) / budget_avg ) * 100"

);

-- This curve assumes monotonic smoothing has already been applied in 06-01A/B/C/D.

SET @PREV_MIN    := 0.00,
    @PREV_MAX    := 0.00,
    @PREV_DELAY  := 0.00,
    @PREV_BUDGET := 0.00;

INSERT INTO ACSBV3_aux_damage_thrown

WITH RECURSIVE seq AS ( SELECT                      10 AS `ItemLevelBracket` UNION ALL
                        SELECT `ItemLevelBracket` + 10 AS `ItemLevelBracket`
                          FROM                  seq WHERE `ItemLevelBracket` < 300 )

SELECT                                       "Ranged-Thrown" AS       `slot_group`,
                                      seq.`ItemLevelBracket` AS `ItemLevelBracket`,
  @PREV_MIN    := COALESCE ( c.`min_mono`,    @PREV_MIN    ) AS         `dmg_min1`,
  @PREV_MAX    := COALESCE ( c.`max_mono`,    @PREV_MAX    ) AS         `dmg_max1`,
  @PREV_DELAY  := COALESCE ( c.`delay_mono`,  @PREV_DELAY  ) AS            `delay`,
                                                       0.00  AS              `DPS`,
  @PREV_BUDGET := COALESCE ( c.`budget_mono`, @PREV_BUDGET ) AS       `budget_avg`,
                                                       0.00  AS     `budget_ratio`
FROM seq
LEFT JOIN ACSBV3_0601A_curve AS c ON c.`ItemLevelBracket` = seq.`ItemLevelBracket` AND c.`slot_group` = "Ranged-Thrown";

UPDATE ACSBV3_aux_damage_thrown
SET `DPS`          =   ( ( `dmg_min1` + `dmg_max1` ) / 2 / ( `delay` / 1000 ) ),
    `budget_ratio` = ( ( ( `dmg_min1` + `dmg_max1` ) / 2 / ( `delay` / 1000 ) ) / `budget_avg` ) * 100;



SELECT COUNT(*) FROM ACSBV3_aux_damage_thrown;



/*=============================================================================================================================================
  6. Create and Populate Table: ACSBV3_aux_damage_wand
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "6. Create and Populate Table: ACSBV3_aux_damage_wand" );



DROP   TABLE IF EXISTS ACSBV3_aux_damage_wand;

CREATE TABLE           ACSBV3_aux_damage_wand
(

  `slot_group`       VARCHAR(35)   NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `ItemLevelBracket` SMALLINT      NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `dmg_min1`         DECIMAL(12,5) NOT NULL COMMENT "Average Minimum Weapon Damage.",
  `dmg_max1`         DECIMAL(12,5) NOT NULL COMMENT "Average Maximum Weapon Damage.",
  `delay`            DECIMAL(12,5) NOT NULL COMMENT "Average Weapon Delay.",
  `DPS`              DECIMAL(12,5) NOT NULL COMMENT "DPS = ( dmg_min1 + dmg_max1 ) / 2 / ( delay / 1000 )",
  `budget_avg`       DECIMAL(12,5) NOT NULL COMMENT "Average Actual Budget.",
  `budget_ratio`     DECIMAL(12,5) NOT NULL COMMENT "budget_ratio = ( ( ( dmg_min1 + dmg_max1 ) / 2 / ( delay / 1000 ) ) / budget_avg ) * 100"

);

-- This curve assumes monotonic smoothing has already been applied in 06-01A/B/C/D.

SET @PREV_MIN    := 0.00,
    @PREV_MAX    := 0.00,
    @PREV_DELAY  := 0.00,
    @PREV_BUDGET := 0.00;

INSERT INTO ACSBV3_aux_damage_wand

WITH RECURSIVE seq AS ( SELECT                      10 AS `ItemLevelBracket` UNION ALL
                        SELECT `ItemLevelBracket` + 10 AS `ItemLevelBracket`
                          FROM                  seq WHERE `ItemLevelBracket` < 300 )

SELECT                                         "Ranged-Wand" AS       `slot_group`,
                                      seq.`ItemLevelBracket` AS `ItemLevelBracket`,
  @PREV_MIN    := COALESCE ( c.`min_mono`,    @PREV_MIN    ) AS         `dmg_min1`,
  @PREV_MAX    := COALESCE ( c.`max_mono`,    @PREV_MAX    ) AS         `dmg_max1`,
  @PREV_DELAY  := COALESCE ( c.`delay_mono`,  @PREV_DELAY  ) AS            `delay`,
                                                       0.00  AS              `DPS`,
  @PREV_BUDGET := COALESCE ( c.`budget_mono`, @PREV_BUDGET ) AS       `budget_avg`,
                                                       0.00  AS     `budget_ratio`
FROM seq
LEFT JOIN ACSBV3_0601A_curve AS c ON c.`ItemLevelBracket` = seq.`ItemLevelBracket` AND c.`slot_group` = "Ranged-Wand";

UPDATE ACSBV3_aux_damage_wand
SET `DPS`          =   ( ( `dmg_min1` + `dmg_max1` ) / 2 / ( `delay` / 1000 ) ),
    `budget_ratio` = ( ( ( `dmg_min1` + `dmg_max1` ) / 2 / ( `delay` / 1000 ) ) / `budget_avg` ) * 100;



SELECT COUNT(*) FROM ACSBV3_aux_damage_wand;



/*=============================================================================================================================================
  7. Create and Populate Table: ACSBV3_aux_weapon_damage
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "7. Create and Populate Table: ACSBV3_aux_weapon_damage" );



DROP   TABLE IF EXISTS ACSBV3_aux_weapon_damage;

CREATE TABLE           ACSBV3_aux_weapon_damage
(

  `slot_group`       VARCHAR(35)   NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `ItemLevelBracket` SMALLINT      NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `dmg_min1`         DECIMAL(12,5) NOT NULL COMMENT "Average Minimum Weapon Damage.",
  `dmg_max1`         DECIMAL(12,5) NOT NULL COMMENT "Average Maximum Weapon Damage.",
  `delay`            DECIMAL(12,5) NOT NULL COMMENT "Average Weapon Delay.",
  `DPS`              DECIMAL(12,5) NOT NULL COMMENT "DPS = ( dmg_min1 + dmg_max1 ) / 2 / ( delay / 1000 )",
  `budget_avg`       DECIMAL(12,5) NOT NULL COMMENT "Average Actual Budget.",
  `budget_ratio`     DECIMAL(12,5) NOT NULL COMMENT "budget_ratio = ( ( ( dmg_min1 + dmg_max1 ) / 2 / ( delay / 1000 ) ) / budget_avg ) * 100"

);

INSERT INTO ACSBV3_aux_weapon_damage

SELECT * FROM ACSBV3_aux_damage_1hand_general UNION ALL
SELECT * FROM ACSBV3_aux_damage_1hand_1hand   UNION ALL
SELECT * FROM ACSBV3_aux_damage_1hand_main    UNION ALL
SELECT * FROM ACSBV3_aux_damage_1hand_off     UNION ALL
SELECT * FROM ACSBV3_aux_damage_2hand         UNION ALL
SELECT * FROM ACSBV3_aux_damage_staff         UNION ALL
SELECT * FROM ACSBV3_aux_damage_ranged        UNION ALL
SELECT * FROM ACSBV3_aux_damage_thrown        UNION ALL
SELECT * FROM ACSBV3_aux_damage_wand;



SELECT * FROM ACSBV3_aux_weapon_damage;



CALL ACSBV3_print_footer ();

/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
