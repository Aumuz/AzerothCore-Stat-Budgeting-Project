/*=============================================================================================================================================
  Filename:       ACSBV3-06-02F.sql
  Title:          Create Recommended Armor Table (part 6 of 6).
  Author:         Aumuz Messick
  Version:        1.0
  Created:        2025-12-11
  Description:    This script will assemble the final "Recommended Armor Table".

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

SET @SCRIPT  := "0602F",
    @VERSION := "1.0";



/*=============================================================================================================================================
  1. Create Generate Chart Procedure: ACSBV3_generate_chart
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "1. Create Generate Chart Procedure: ACSBV3_generate_chart" );



DELIMITER $$

DROP PROCEDURE IF EXISTS ACSBV3_generate_chart $$

CREATE PROCEDURE ACSBV3_generate_chart ( IN `ARG_Table1` VARCHAR(50), IN `ARG_Table2` VARCHAR(50), IN `ARG_Slot` VARCHAR(35) )



BEGIN

  SET @QUERY0 := CONCAT ( ' DROP   TABLE IF EXISTS ', `ARG_Table1` );

  PREPARE stmt FROM @QUERY0;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;



  SET @QUERY1 := CONCAT ( ' CREATE TABLE           ', `ARG_Table1`, '
                            (

                              `slot_group`       VARCHAR(35)   NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
                              `ItemLevelBracket` SMALLINT      NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
                              `armor`            DECIMAL(12,5) NOT NULL COMMENT "Average armor.",
                              `armorCost`        DECIMAL(12,5) NOT NULL COMMENT "armorCost = ( armor * 0.20 )",
                              `budget_avg`       DECIMAL(12,5) NOT NULL COMMENT "Average Actual Budget.",
                              `budget_ratio`     DECIMAL(12,5) NOT NULL COMMENT "budget_ratio = ( armorCost / budget_avg )"

                            ) ' );

  PREPARE stmt FROM @QUERY1;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;



  -- This curve assumes monotonic smoothing has already been applied in 06-02A/B/C/D/E.

  SET @PREV_ARMOR  := 0.00,
      @PREV_BUDGET := 0.00;

  SET @QUERY2 := CONCAT ( ' INSERT INTO ', `ARG_Table1`, '

                            WITH RECURSIVE seq AS ( SELECT                      10 AS `ItemLevelBracket` UNION ALL
                                                    SELECT `ItemLevelBracket` + 10 AS `ItemLevelBracket`
                                                      FROM                  seq WHERE `ItemLevelBracket` < 300 )

                            SELECT                                    "', `ARG_Slot`, '" AS       `slot_group`,
                                                                  seq.`ItemLevelBracket` AS `ItemLevelBracket`,
                              @PREV_ARMOR  := COALESCE ( c.`armor_mono`,  @PREV_ARMOR  ) AS            `armor`,
                                                                                       0 AS        `armorCost`,
                              @PREV_BUDGET := COALESCE ( c.`budget_mono`, @PREV_BUDGET ) AS       `budget_avg`,
                                                                                       0 AS     `budget_ratio`
                            FROM seq
                            LEFT JOIN ', `ARG_Table2`, ' AS c ON c.`ItemLevelBracket` = seq.`ItemLevelBracket` AND c.`slot_group` = "', `ARG_Slot`, '"' );

  PREPARE stmt FROM @QUERY2;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;



  SET @QUERY5 := CONCAT ( ' UPDATE ', `ARG_Table1`, ' SET `armorCost` = ( CASE WHEN `armor` > 0 THEN ( `armor` * 0.20 ) ELSE 0 END ) ' );

  PREPARE stmt FROM @QUERY5;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;



  SET @QUERY6 := CONCAT ( ' UPDATE ', `ARG_Table1`, ' SET `budget_ratio` = ( CASE WHEN `budget_avg` > 0 THEN ( `armorCost` / `budget_avg` ) * 100 ELSE 0 END ) ' );

  PREPARE stmt FROM @QUERY6;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;



END $$

DELIMITER ;



SELECT "Procedure Created: ACSBV3_generate_chart" AS ``;



/*=============================================================================================================================================
  2. Create and Populate Table: ACSBV3_aux_armor_general
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "2. Create and Populate Table: ACSBV3_aux_armor_general" );



DROP   TABLE IF EXISTS ACSBV3_aux_armor_general;

CREATE TABLE           ACSBV3_aux_armor_general
(

  `slot_group`       VARCHAR(35)   NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `ItemLevelBracket` SMALLINT      NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `armor`            DECIMAL(12,5) NOT NULL COMMENT "Average armor.",
  `armorCost`        DECIMAL(12,5) NOT NULL COMMENT "armorCost = ( armor * 0.20 )",
  `budget_avg`       DECIMAL(12,5) NOT NULL COMMENT "Average Actual Budget.",
  `budget_ratio`     DECIMAL(12,5) NOT NULL COMMENT "budget_ratio = ( armorCost / budget_avg )"

);



CALL ACSBV3_generate_chart ( "ACSBV3_0602F_20", "ACSBV3_0602A_curve", "Major-Armor"    );  SELECT COUNT(*) FROM ACSBV3_0602F_20;
CALL ACSBV3_generate_chart ( "ACSBV3_0602F_21", "ACSBV3_0602A_curve", "Moderate-Armor" );  SELECT COUNT(*) FROM ACSBV3_0602F_21;
CALL ACSBV3_generate_chart ( "ACSBV3_0602F_22", "ACSBV3_0602A_curve", "Minor-Armor"    );  SELECT COUNT(*) FROM ACSBV3_0602F_22;
CALL ACSBV3_generate_chart ( "ACSBV3_0602F_23", "ACSBV3_0602A_curve", "Shield"         );  SELECT COUNT(*) FROM ACSBV3_0602F_23;
CALL ACSBV3_generate_chart ( "ACSBV3_0602F_24", "ACSBV3_0602A_curve", "Back"           );  SELECT COUNT(*) FROM ACSBV3_0602F_24;



INSERT INTO ACSBV3_aux_armor_general

SELECT * FROM ACSBV3_0602F_20 UNION ALL
SELECT * FROM ACSBV3_0602F_21 UNION ALL
SELECT * FROM ACSBV3_0602F_22 UNION ALL
SELECT * FROM ACSBV3_0602F_23 UNION ALL
SELECT * FROM ACSBV3_0602F_24;



SELECT * FROM ACSBV3_aux_armor_general;



/*=============================================================================================================================================
  3. Create and Populate Table: ACSBV3_aux_armor_cloth
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "3. Create and Populate Table: ACSBV3_aux_armor_cloth" );



DROP   TABLE IF EXISTS ACSBV3_aux_armor_cloth;

CREATE TABLE           ACSBV3_aux_armor_cloth
(

  `slot_group`       VARCHAR(35)   NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `ItemLevelBracket` SMALLINT      NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `armor`            DECIMAL(12,5) NOT NULL COMMENT "Average armor.",
  `armorCost`        DECIMAL(12,5) NOT NULL COMMENT "armorCost = ( armor * 0.20 )",
  `budget_avg`       DECIMAL(12,5) NOT NULL COMMENT "Average Actual Budget.",
  `budget_ratio`     DECIMAL(12,5) NOT NULL COMMENT "budget_ratio = ( armorCost / budget_avg )"

);



CALL ACSBV3_generate_chart ( "ACSBV3_0602F_30", "ACSBV3_0602B_curve", "Major-Armor"    );  SELECT COUNT(*) FROM ACSBV3_0602F_30;
CALL ACSBV3_generate_chart ( "ACSBV3_0602F_31", "ACSBV3_0602B_curve", "Moderate-Armor" );  SELECT COUNT(*) FROM ACSBV3_0602F_31;
CALL ACSBV3_generate_chart ( "ACSBV3_0602F_32", "ACSBV3_0602B_curve", "Minor-Armor"    );  SELECT COUNT(*) FROM ACSBV3_0602F_32;



INSERT INTO ACSBV3_aux_armor_cloth

SELECT * FROM ACSBV3_0602F_30 UNION ALL
SELECT * FROM ACSBV3_0602F_31 UNION ALL
SELECT * FROM ACSBV3_0602F_32;

UPDATE ACSBV3_aux_armor_cloth SET `slot_group` = CONCAT ( `slot_group`, " (Cloth)" );



SELECT * FROM ACSBV3_aux_armor_cloth;



/*=============================================================================================================================================
  4. Create and Populate Table: ACSBV3_aux_armor_leather
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "4. Create and Populate Table: ACSBV3_aux_armor_leather" );



DROP   TABLE IF EXISTS ACSBV3_aux_armor_leather;

CREATE TABLE           ACSBV3_aux_armor_leather
(

  `slot_group`       VARCHAR(35)   NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `ItemLevelBracket` SMALLINT      NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `armor`            DECIMAL(12,5) NOT NULL COMMENT "Average armor.",
  `armorCost`        DECIMAL(12,5) NOT NULL COMMENT "armorCost = ( armor * 0.20 )",
  `budget_avg`       DECIMAL(12,5) NOT NULL COMMENT "Average Actual Budget.",
  `budget_ratio`     DECIMAL(12,5) NOT NULL COMMENT "budget_ratio = ( armorCost / budget_avg )"

);



CALL ACSBV3_generate_chart ( "ACSBV3_0602F_40", "ACSBV3_0602C_curve", "Major-Armor"    );  SELECT COUNT(*) FROM ACSBV3_0602F_40;
CALL ACSBV3_generate_chart ( "ACSBV3_0602F_41", "ACSBV3_0602C_curve", "Moderate-Armor" );  SELECT COUNT(*) FROM ACSBV3_0602F_41;
CALL ACSBV3_generate_chart ( "ACSBV3_0602F_42", "ACSBV3_0602C_curve", "Minor-Armor"    );  SELECT COUNT(*) FROM ACSBV3_0602F_42;



INSERT INTO ACSBV3_aux_armor_leather

SELECT * FROM ACSBV3_0602F_40 UNION ALL
SELECT * FROM ACSBV3_0602F_41 UNION ALL
SELECT * FROM ACSBV3_0602F_42;

UPDATE ACSBV3_aux_armor_leather SET `slot_group` = CONCAT ( `slot_group`, " (Leather)" );



SELECT * FROM ACSBV3_aux_armor_leather;



/*=============================================================================================================================================
  5. Create and Populate Table: ACSBV3_aux_armor_mail
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "5. Create and Populate Table: ACSBV3_aux_armor_mail" );



DROP   TABLE IF EXISTS ACSBV3_aux_armor_mail;

CREATE TABLE           ACSBV3_aux_armor_mail
(

  `slot_group`       VARCHAR(35)   NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `ItemLevelBracket` SMALLINT      NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `armor`            DECIMAL(12,5) NOT NULL COMMENT "Average armor.",
  `armorCost`        DECIMAL(12,5) NOT NULL COMMENT "armorCost = ( armor * 0.20 )",
  `budget_avg`       DECIMAL(12,5) NOT NULL COMMENT "Average Actual Budget.",
  `budget_ratio`     DECIMAL(12,5) NOT NULL COMMENT "budget_ratio = ( armorCost / budget_avg )"

);



CALL ACSBV3_generate_chart ( "ACSBV3_0602F_50", "ACSBV3_0602D_curve", "Major-Armor"    );  SELECT COUNT(*) FROM ACSBV3_0602F_50;
CALL ACSBV3_generate_chart ( "ACSBV3_0602F_51", "ACSBV3_0602D_curve", "Moderate-Armor" );  SELECT COUNT(*) FROM ACSBV3_0602F_51;
CALL ACSBV3_generate_chart ( "ACSBV3_0602F_52", "ACSBV3_0602D_curve", "Minor-Armor"    );  SELECT COUNT(*) FROM ACSBV3_0602F_52;



INSERT INTO ACSBV3_aux_armor_mail

SELECT * FROM ACSBV3_0602F_50 UNION ALL
SELECT * FROM ACSBV3_0602F_51 UNION ALL
SELECT * FROM ACSBV3_0602F_52;

UPDATE ACSBV3_aux_armor_mail SET `slot_group` = CONCAT ( `slot_group`, " (Mail)" );



SELECT * FROM ACSBV3_aux_armor_mail;



/*=============================================================================================================================================
  6. Create and Populate Table: ACSBV3_aux_armor_plate
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "6. Create and Populate Table: ACSBV3_aux_armor_plate" );



DROP   TABLE IF EXISTS ACSBV3_aux_armor_plate;

CREATE TABLE           ACSBV3_aux_armor_plate
(

  `slot_group`       VARCHAR(35)   NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `ItemLevelBracket` SMALLINT      NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `armor`            DECIMAL(12,5) NOT NULL COMMENT "Average armor.",
  `armorCost`        DECIMAL(12,5) NOT NULL COMMENT "armorCost = ( armor * 0.20 )",
  `budget_avg`       DECIMAL(12,5) NOT NULL COMMENT "Average Actual Budget.",
  `budget_ratio`     DECIMAL(12,5) NOT NULL COMMENT "budget_ratio = ( armorCost / budget_avg )"

);



CALL ACSBV3_generate_chart ( "ACSBV3_0602F_60", "ACSBV3_0602E_curve", "Major-Armor"    );  SELECT COUNT(*) FROM ACSBV3_0602F_60;
CALL ACSBV3_generate_chart ( "ACSBV3_0602F_61", "ACSBV3_0602E_curve", "Moderate-Armor" );  SELECT COUNT(*) FROM ACSBV3_0602F_61;
CALL ACSBV3_generate_chart ( "ACSBV3_0602F_62", "ACSBV3_0602E_curve", "Minor-Armor"    );  SELECT COUNT(*) FROM ACSBV3_0602F_62;



INSERT INTO ACSBV3_aux_armor_plate

SELECT * FROM ACSBV3_0602F_60 UNION ALL
SELECT * FROM ACSBV3_0602F_61 UNION ALL
SELECT * FROM ACSBV3_0602F_62;

UPDATE ACSBV3_aux_armor_plate SET `slot_group` = CONCAT ( `slot_group`, " (Plate)" );



SELECT * FROM ACSBV3_aux_armor_plate;



/*=============================================================================================================================================
  7. Create and Populate Table: ACSBV3_aux_armor_all
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "7. Create and Populate Table: ACSBV3_aux_armor_all" );



DROP   TABLE IF EXISTS ACSBV3_aux_armor_all;

CREATE TABLE           ACSBV3_aux_armor_all
(

  `slot_group`       VARCHAR(35)   NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `ItemLevelBracket` SMALLINT      NOT NULL COMMENT "ItemLevel in 10 Level Brackets.",
  `armor`            DECIMAL(12,5) NOT NULL COMMENT "Average armor.",
  `armorCost`        DECIMAL(12,5) NOT NULL COMMENT "armorCost = ( armor * 0.20 )",
  `budget_avg`       DECIMAL(12,5) NOT NULL COMMENT "Average Actual Budget.",
  `budget_ratio`     DECIMAL(12,5) NOT NULL COMMENT "budget_ratio = ( armorCost / budget_avg )"

);



INSERT INTO ACSBV3_aux_armor_all

SELECT * FROM ACSBV3_aux_armor_general UNION ALL
SELECT * FROM ACSBV3_aux_armor_cloth   UNION ALL
SELECT * FROM ACSBV3_aux_armor_leather UNION ALL
SELECT * FROM ACSBV3_aux_armor_mail    UNION ALL
SELECT * FROM ACSBV3_aux_armor_plate;



SELECT * FROM ACSBV3_aux_armor_all;



/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
