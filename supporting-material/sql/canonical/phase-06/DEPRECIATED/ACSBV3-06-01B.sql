/*=============================================================================================================================================
  Filename:       ACSBV3-06-01B.sql
  Title:          Create Recommended iLvl Chart:
  Author:         Aumuz Messick
  Version:        1.0
  Created:        2025-12-05
  Description:    This script creates the ACSBV3 auxiliary "Recommended iLvl/Quality to Player Level Chart".

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

SET @SCRIPT  := "0601B",
    @VERSION := "1.0";



/*=============================================================================================================================================
  1. Create and Populate Table: ACSBV3_0601B_quality
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "1. Create and Populate Table: ACSBV3_0601B_quality" );



DROP   TABLE IF EXISTS ACSBV3_0601B_quality;

CREATE TABLE           ACSBV3_0601B_quality
(

  `slot_group`           VARCHAR(25) NOT NULL,
  `RequiredLevelBracket` TINYINT     NOT NULL,
  `Quality`              TINYINT     NOT NULL,
  `QualityName`          VARCHAR(10) NOT NULL,
  `Score`                DOUBLE      NOT NULL

);

INSERT INTO ACSBV3_0601B_quality SELECT   `slot_group`, `RequiredLevelBracket`, `Quality`, MIN( `QualityName` ) AS `QualityName`, SUM( `weight` ) AS `Score`
       FROM ACSBV3_0600A_dataset GROUP BY `slot_group`, `RequiredLevelBracket`, `Quality`;



SELECT "Done." AS ``;



/*=============================================================================================================================================
  2. Create and Populate Temporary Table: ACSBV3_temp_quality
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "2. Create and Populate Temporary Table: ACSBV3_temp_quality" );



DROP   TEMPORARY TABLE IF EXISTS ACSBV3_temp_quality;

CREATE TEMPORARY TABLE           ACSBV3_temp_quality LIKE ACSBV3_0601B_quality;

INSERT INTO ACSBV3_temp_quality
SELECT * FROM ( SELECT q1.`slot_group`,
                       q1.`RequiredLevelBracket`,
                       q1.`Quality`,
                       q1.`QualityName`,
                       q1.`Score`
                  FROM ACSBV3_0601B_quality AS q1
                 WHERE q1.`Score` = ( SELECT MAX( `Score` )
                                        FROM ACSBV3_0601B_quality AS q2
                                       WHERE q1.`slot_group`           = q2.`slot_group`
                                         AND q1.`RequiredLevelBracket` = q2.`RequiredLevelBracket` ) ) AS winners

  WHERE `Quality` = ( SELECT MAX( `Quality` )
                        FROM ACSBV3_0601B_quality AS q3
                       WHERE winners.`slot_group`           = q3.`slot_group`
                         AND winners.`RequiredLevelBracket` = q3.`RequiredLevelBracket`
                         AND winners.`Score`                = q3.`Score` )

ORDER BY `slot_group`, `RequiredLevelBracket`;



SELECT * FROM ACSBV3_temp_quality;



/*=============================================================================================================================================
  3. Create and Populate Table: ACSBV3_0601B_itemlevel
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "3. Create and Populate Table: ACSBV3_0601B_itemlevel" );



DROP   TABLE IF EXISTS ACSBV3_0601B_itemlevel;

CREATE TABLE           ACSBV3_0601B_itemlevel
(

  `slot_group`           VARCHAR(25) NOT NULL,
  `RequiredLevelBracket` TINYINT     NOT NULL,
  `ItemLevel`            SMALLINT    NOT NULL,
  `Score`                DOUBLE      NOT NULL

);

INSERT INTO ACSBV3_0601B_itemlevel SELECT   `slot_group`, `RequiredLevelBracket`, `ItemLevel`, SUM( `weight` ) AS `Score`
       FROM ACSBV3_0600A_dataset   GROUP BY `slot_group`, `RequiredLevelBracket`, `ItemLevel`;



SELECT "Done." AS ``;



/*=============================================================================================================================================
  4. Create and Populate Temporary Table: ACSBV3_temp_itemlevel
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "4. Create and Populate Temporary Table: ACSBV3_temp_itemlevel" );



DROP   TEMPORARY TABLE IF EXISTS ACSBV3_temp_itemlevel;

CREATE TEMPORARY TABLE           ACSBV3_temp_itemlevel LIKE ACSBV3_0601B_itemlevel;

INSERT INTO ACSBV3_temp_itemlevel
SELECT * FROM ( SELECT i1.`slot_group`,
                       i1.`RequiredLevelBracket`,
                       i1.`ItemLevel`,
                       i1.`Score`
                  FROM ACSBV3_0601B_itemlevel AS i1
                 WHERE i1.`Score` = ( SELECT MAX( `Score` )
                                        FROM ACSBV3_0601B_itemlevel AS i2
                                       WHERE i1.`slot_group`           = i2.`slot_group`
                                         AND i1.`RequiredLevelBracket` = i2.`RequiredLevelBracket` ) ) AS winners

  WHERE `ItemLevel` = ( SELECT MAX( `ItemLevel` )
                          FROM ACSBV3_0601B_itemlevel AS i3
                         WHERE winners.`slot_group`           = i3.`slot_group`
                           AND winners.`RequiredLevelBracket` = i3.`RequiredLevelBracket`
                           AND winners.`Score`                = i3.`Score` )

ORDER BY `slot_group`, `RequiredLevelBracket`;



SELECT * FROM ACSBV3_temp_itemlevel;



/*=============================================================================================================================================
  5. Create and Populate Table: ACSBV3_0601B_recommend
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "5. Create and Populate Table: ACSBV3_0601B_recommend" );



DROP   TABLE IF EXISTS ACSBV3_0601B_recommend;

CREATE TABLE           ACSBV3_0601B_recommend
(

  `Order`                SMALLINT    NOT NULL,
  `slot_group`           VARCHAR(25) NOT NULL,
  `RequiredLevelBracket` TINYINT     NOT NULL,
  `QualityName`          VARCHAR(10) NOT NULL,
  `ItemLevel`            SMALLINT    NOT NULL

);

INSERT INTO ACSBV3_0601B_recommend
SELECT

  ( CASE WHEN q.`slot_group` = "2H-Weapon      " THEN  1
         WHEN q.`slot_group` = "1H-Weapon      " THEN  2
         WHEN q.`slot_group` = "Dagger         " THEN  3
         WHEN q.`slot_group` = "Staff          " THEN  4
         WHEN q.`slot_group` = "Ranged-Physical" THEN  5
         WHEN q.`slot_group` = "Thrown         " THEN  6
         WHEN q.`slot_group` = "Wand           " THEN  7
         WHEN q.`slot_group` = "Major-Armor    " THEN  8
         WHEN q.`slot_group` = "Moderate-Armor " THEN  9
         WHEN q.`slot_group` = "Minor-Armor    " THEN 10
         WHEN q.`slot_group` = "Cloak          " THEN 11
         WHEN q.`slot_group` = "Accessory      " THEN 12
         WHEN q.`slot_group` = "Shield         " THEN 13
                                                 ELSE  0 END ) AS `Order`,

  q.`slot_group`           AS           `slot_group`,
  q.`RequiredLevelBracket` AS `RequiredLevelBracket`,
  q.`QualityName`          AS          `QualityName`,
  i.`ItemLevel`            AS            `ItemLevel`

     FROM ACSBV3_temp_quality   AS q
LEFT JOIN ACSBV3_temp_itemlevel AS i ON q.`slot_group` = i.`slot_group` AND q.`RequiredLevelBracket` = i.`RequiredLevelBracket`;



SELECT * FROM ACSBV3_0601B_recommend ORDER BY `Order` ASC, `RequiredLevelBracket` ASC;



/*=============================================================================================================================================
  6. Create and Populate Final Table: ACSBV3_ref_recommend
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "6. Create and Populate Final Table: ACSBV3_ref_recommend" );



DROP   TABLE IF EXISTS ACSBV3_ref_recommend;

CREATE TABLE           ACSBV3_ref_recommend
(

  `slot_group` VARCHAR(25) NOT NULL COMMENT "Slot Meta Group.",
  `level_10`   VARCHAR(25) NOT NULL COMMENT "Player Level Bracket 10: includes player levels  1 to 10.",
  `level_20`   VARCHAR(25) NOT NULL COMMENT "Player Level Bracket 20: includes player levels 11 to 20.",
  `level_30`   VARCHAR(25) NOT NULL COMMENT "Player Level Bracket 30: includes player levels 21 to 30.",
  `level_40`   VARCHAR(25) NOT NULL COMMENT "Player Level Bracket 40: includes player levels 31 to 40.",
  `level_50`   VARCHAR(25) NOT NULL COMMENT "Player Level Bracket 50: includes player levels 41 to 50.",
  `level_60`   VARCHAR(25) NOT NULL COMMENT "Player Level Bracket 60: includes player levels 51 to 60.",
  `level_70`   VARCHAR(25) NOT NULL COMMENT "Player Level Bracket 70: includes player levels 61 to 70.",
  `level_80`   VARCHAR(25) NOT NULL COMMENT "Player Level Bracket 80: includes player levels 71 to 80."

);

INSERT INTO ACSBV3_ref_recommend VALUES
( "2H-Weapon      ", "  Not Yet Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available" ),
( "1H-Weapon      ", "  Not Yet Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available" ),
( "Dagger         ", "  Not Yet Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available" ),
( "Staff          ", "  Not Yet Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available" ),
( "Ranged-Physical", "  Not Yet Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available" ),
( "Thrown         ", "  Not Yet Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available" ),
( "Wand           ", "  Not Yet Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available" ),
( "Major-Armor    ", "  Not Yet Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available" ),
( "Moderate-Armor ", "  Not Yet Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available" ),
( "Minor-Armor    ", "  Not Yet Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available" ),
( "Cloak          ", "  Not Yet Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available" ),
( "Accessory      ", "  Not Yet Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available" ),
( "Shield         ", "  Not Yet Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available", "No Longer Available" );

UPDATE    ACSBV3_ref_recommend   AS ref
LEFT JOIN ACSBV3_0601B_recommend AS r10 ON ref.`slot_group` = r10.`slot_group` AND r10.`RequiredLevelBracket` = 10
LEFT JOIN ACSBV3_0601B_recommend AS r20 ON ref.`slot_group` = r20.`slot_group` AND r20.`RequiredLevelBracket` = 20
LEFT JOIN ACSBV3_0601B_recommend AS r30 ON ref.`slot_group` = r30.`slot_group` AND r30.`RequiredLevelBracket` = 30
LEFT JOIN ACSBV3_0601B_recommend AS r40 ON ref.`slot_group` = r40.`slot_group` AND r40.`RequiredLevelBracket` = 40
LEFT JOIN ACSBV3_0601B_recommend AS r50 ON ref.`slot_group` = r50.`slot_group` AND r50.`RequiredLevelBracket` = 50
LEFT JOIN ACSBV3_0601B_recommend AS r60 ON ref.`slot_group` = r60.`slot_group` AND r60.`RequiredLevelBracket` = 60
LEFT JOIN ACSBV3_0601B_recommend AS r70 ON ref.`slot_group` = r70.`slot_group` AND r70.`RequiredLevelBracket` = 70
LEFT JOIN ACSBV3_0601B_recommend AS r80 ON ref.`slot_group` = r80.`slot_group` AND r80.`RequiredLevelBracket` = 80
SET ref.`level_10` = ( CASE WHEN r10.`slot_group` IS NULL THEN ref.`level_10` ELSE ( LPAD ( CONCAT ( LPAD ( r10.`QualityName`, 9, " " ), LPAD ( r10.`ItemLevel`, 4, " " ) ), 19, " " ) ) END ),
    ref.`level_20` = ( CASE WHEN r20.`slot_group` IS NULL THEN ref.`level_20` ELSE ( LPAD ( CONCAT ( LPAD ( r20.`QualityName`, 9, " " ), LPAD ( r20.`ItemLevel`, 4, " " ) ), 19, " " ) ) END ),
    ref.`level_30` = ( CASE WHEN r30.`slot_group` IS NULL THEN ref.`level_30` ELSE ( LPAD ( CONCAT ( LPAD ( r30.`QualityName`, 9, " " ), LPAD ( r30.`ItemLevel`, 4, " " ) ), 19, " " ) ) END ),
    ref.`level_40` = ( CASE WHEN r40.`slot_group` IS NULL THEN ref.`level_40` ELSE ( LPAD ( CONCAT ( LPAD ( r40.`QualityName`, 9, " " ), LPAD ( r40.`ItemLevel`, 4, " " ) ), 19, " " ) ) END ),
    ref.`level_50` = ( CASE WHEN r50.`slot_group` IS NULL THEN ref.`level_50` ELSE ( LPAD ( CONCAT ( LPAD ( r50.`QualityName`, 9, " " ), LPAD ( r50.`ItemLevel`, 4, " " ) ), 19, " " ) ) END ),
    ref.`level_60` = ( CASE WHEN r60.`slot_group` IS NULL THEN ref.`level_60` ELSE ( LPAD ( CONCAT ( LPAD ( r60.`QualityName`, 9, " " ), LPAD ( r60.`ItemLevel`, 4, " " ) ), 19, " " ) ) END ),
    ref.`level_70` = ( CASE WHEN r70.`slot_group` IS NULL THEN ref.`level_70` ELSE ( LPAD ( CONCAT ( LPAD ( r70.`QualityName`, 9, " " ), LPAD ( r70.`ItemLevel`, 4, " " ) ), 19, " " ) ) END ),
    ref.`level_80` = ( CASE WHEN r80.`slot_group` IS NULL THEN ref.`level_80` ELSE ( LPAD ( CONCAT ( LPAD ( r80.`QualityName`, 9, " " ), LPAD ( r80.`ItemLevel`, 4, " " ) ), 19, " " ) ) END );



SELECT * FROM ACSBV3_ref_recommend;



CALL ACSBV3_print_footer ();

/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
