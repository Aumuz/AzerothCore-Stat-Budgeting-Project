/*=============================================================================================================================================
  Filename:       ACSBV3-06-04A.sql
  Title:          Stat Count per Item Table.
  Author:         Aumuz Messick
  Version:        1.0
  Created:        2025-12-12
  Description:    This script will create the auxiliary chart "Stat Count per Item Table".

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

SET @SCRIPT  := "0604A",
    @VERSION := "1.0";



/*=============================================================================================================================================
  1. Research Stat Count per Item: Simple Groups
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "1. Research Stat Count per Item: Simple Groups" );



SELECT "Global" AS `Group_Name`,
       COUNT(*) AS `Item_Count`,
       SUM( ( CASE WHEN `stat_type1`  > 0 AND `stat_total1`  > 0 THEN 1 ELSE 0 END ) +
            ( CASE WHEN `stat_type2`  > 0 AND `stat_total2`  > 0 THEN 1 ELSE 0 END ) +
            ( CASE WHEN `stat_type3`  > 0 AND `stat_total3`  > 0 THEN 1 ELSE 0 END ) +
            ( CASE WHEN `stat_type4`  > 0 AND `stat_total4`  > 0 THEN 1 ELSE 0 END ) +
            ( CASE WHEN `stat_type5`  > 0 AND `stat_total5`  > 0 THEN 1 ELSE 0 END ) +
            ( CASE WHEN `stat_type6`  > 0 AND `stat_total6`  > 0 THEN 1 ELSE 0 END ) +
            ( CASE WHEN `stat_type7`  > 0 AND `stat_total7`  > 0 THEN 1 ELSE 0 END ) +
            ( CASE WHEN `stat_type8`  > 0 AND `stat_total8`  > 0 THEN 1 ELSE 0 END ) +
            ( CASE WHEN `stat_type9`  > 0 AND `stat_total9`  > 0 THEN 1 ELSE 0 END ) +
            ( CASE WHEN `stat_type10` > 0 AND `stat_total10` > 0 THEN 1 ELSE 0 END ) ) / COUNT(*) AS `AVG_Stat_Count`
FROM ACSBV3_ref_dataset WHERE `stat_sum` > 0; SELECT "" AS ``;



SELECT "GROUP BY Quality" AS ``;
SELECT RPAD ( MIN( `QualityName` ), 10, " " ) AS `Group_Name`,
       LPAD ( COUNT(*),              5, " " ) AS `Item_Count`,
       LPAD ( SUM( ( CASE WHEN `stat_type1`  > 0 AND `stat_total1`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type2`  > 0 AND `stat_total2`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type3`  > 0 AND `stat_total3`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type4`  > 0 AND `stat_total4`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type5`  > 0 AND `stat_total5`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type6`  > 0 AND `stat_total6`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type7`  > 0 AND `stat_total7`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type8`  > 0 AND `stat_total8`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type9`  > 0 AND `stat_total9`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type10` > 0 AND `stat_total10` > 0 THEN 1 ELSE 0 END ) ) / COUNT(*), 8, " " ) AS `AVG_Stat_Count`
FROM ACSBV3_ref_dataset WHERE `stat_sum` > 0
GROUP BY `Quality`; SELECT "" AS ``;



SELECT "GROUP BY ItemLevelBracket" AS ``;
SELECT RPAD ( `ItemLevelBracket`, 3, " " ) AS `Group_Name`,
       LPAD ( COUNT(*),           5, " " ) AS `Item_Count`,
       LPAD ( SUM( ( CASE WHEN `stat_type1`  > 0 AND `stat_total1`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type2`  > 0 AND `stat_total2`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type3`  > 0 AND `stat_total3`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type4`  > 0 AND `stat_total4`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type5`  > 0 AND `stat_total5`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type6`  > 0 AND `stat_total6`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type7`  > 0 AND `stat_total7`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type8`  > 0 AND `stat_total8`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type9`  > 0 AND `stat_total9`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type10` > 0 AND `stat_total10` > 0 THEN 1 ELSE 0 END ) ) / COUNT(*), 8, " " ) AS `AVG_Stat_Count`
FROM ACSBV3_ref_dataset WHERE `stat_sum` > 0
GROUP BY `ItemLevelBracket`; SELECT "" AS ``;



SELECT "GROUP BY slot_group" AS ``;
SELECT RPAD ( `slot_group`, 15, " " ) AS `Group_Name`,
       LPAD ( COUNT(*),      5, " " ) AS `Item_Count`,
       LPAD ( SUM( ( CASE WHEN `stat_type1`  > 0 AND `stat_total1`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type2`  > 0 AND `stat_total2`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type3`  > 0 AND `stat_total3`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type4`  > 0 AND `stat_total4`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type5`  > 0 AND `stat_total5`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type6`  > 0 AND `stat_total6`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type7`  > 0 AND `stat_total7`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type8`  > 0 AND `stat_total8`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type9`  > 0 AND `stat_total9`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type10` > 0 AND `stat_total10` > 0 THEN 1 ELSE 0 END ) ) / COUNT(*), 8, " " ) AS `AVG_Stat_Count`
FROM ACSBV3_ref_dataset WHERE `stat_sum` > 0
GROUP BY `slot_group`; SELECT "" AS ``;



/*=============================================================================================================================================
  2. Research Stat Count per Item: Two Groups
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "1. Research Stat Count per Item: Two Groups" );



SELECT "GROUP BY Quality, ItemLevelBracket" AS ``;
SELECT RPAD ( MIN( `QualityName` ), 10, " " ) AS `Quality`,
       RPAD ( `ItemLevelBracket`,    3, " " ) AS `ItemLevel`,
       LPAD ( COUNT(*),              5, " " ) AS `Item_Count`,
       LPAD ( SUM( ( CASE WHEN `stat_type1`  > 0 AND `stat_total1`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type2`  > 0 AND `stat_total2`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type3`  > 0 AND `stat_total3`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type4`  > 0 AND `stat_total4`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type5`  > 0 AND `stat_total5`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type6`  > 0 AND `stat_total6`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type7`  > 0 AND `stat_total7`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type8`  > 0 AND `stat_total8`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type9`  > 0 AND `stat_total9`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type10` > 0 AND `stat_total10` > 0 THEN 1 ELSE 0 END ) ) / COUNT(*), 8, " " ) AS `AVG_Stat_Count`
FROM ACSBV3_ref_dataset WHERE `stat_sum` > 0
GROUP BY `Quality`, `ItemLevelBracket`; SELECT "" AS ``;



SELECT "GROUP BY Quality, slot_group" AS ``;
SELECT RPAD ( MIN( `QualityName` ), 10, " " ) AS `Quality`,
       RPAD ( `slot_group`,         15, " " ) AS `Slot_Group`,
       LPAD ( COUNT(*),              5, " " ) AS `Item_Count`,
       LPAD ( SUM( ( CASE WHEN `stat_type1`  > 0 AND `stat_total1`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type2`  > 0 AND `stat_total2`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type3`  > 0 AND `stat_total3`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type4`  > 0 AND `stat_total4`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type5`  > 0 AND `stat_total5`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type6`  > 0 AND `stat_total6`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type7`  > 0 AND `stat_total7`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type8`  > 0 AND `stat_total8`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type9`  > 0 AND `stat_total9`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type10` > 0 AND `stat_total10` > 0 THEN 1 ELSE 0 END ) ) / COUNT(*), 8, " " ) AS `AVG_Stat_Count`
FROM ACSBV3_ref_dataset WHERE `stat_sum` > 0
GROUP BY `Quality`, `slot_group`; SELECT "" AS ``;



SELECT "GROUP BY slot_group, ItemLevelBracket" AS ``;
SELECT RPAD ( `slot_group`,       15, " " ) AS `Slot_Group`,
       RPAD ( `ItemLevelBracket`,  3, " " ) AS `ItemLevel`,
       LPAD ( COUNT(*),            5, " " ) AS `Item_Count`,
       LPAD ( SUM( ( CASE WHEN `stat_type1`  > 0 AND `stat_total1`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type2`  > 0 AND `stat_total2`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type3`  > 0 AND `stat_total3`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type4`  > 0 AND `stat_total4`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type5`  > 0 AND `stat_total5`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type6`  > 0 AND `stat_total6`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type7`  > 0 AND `stat_total7`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type8`  > 0 AND `stat_total8`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type9`  > 0 AND `stat_total9`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type10` > 0 AND `stat_total10` > 0 THEN 1 ELSE 0 END ) ) / COUNT(*), 8, " " ) AS `AVG_Stat_Count`
FROM ACSBV3_ref_dataset WHERE `stat_sum` > 0
GROUP BY `slot_group`, `ItemLevelBracket`; SELECT "" AS ``;



/*=============================================================================================================================================
  3. Research Stat Count per Item: Three Groups
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "3. Research Stat Count per Item: Three Groups" );



SELECT "GROUP BY Quality, slot_group, ItemLevelBracket" AS ``;
SELECT RPAD ( MIN( `QualityName` ), 10, " " ) AS `Quality`,
       RPAD ( `slot_group`,         15, " " ) AS `Slot_Group`,
       RPAD ( `ItemLevelBracket`,    3, " " ) AS `ItemLevel`,
       LPAD ( COUNT(*),              5, " " ) AS `Item_Count`,
       LPAD ( SUM( ( CASE WHEN `stat_type1`  > 0 AND `stat_total1`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type2`  > 0 AND `stat_total2`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type3`  > 0 AND `stat_total3`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type4`  > 0 AND `stat_total4`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type5`  > 0 AND `stat_total5`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type6`  > 0 AND `stat_total6`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type7`  > 0 AND `stat_total7`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type8`  > 0 AND `stat_total8`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type9`  > 0 AND `stat_total9`  > 0 THEN 1 ELSE 0 END ) +
                   ( CASE WHEN `stat_type10` > 0 AND `stat_total10` > 0 THEN 1 ELSE 0 END ) ) / COUNT(*), 8, " " ) AS `AVG_Stat_Count`
FROM ACSBV3_ref_dataset WHERE `stat_sum` > 0
GROUP BY `Quality`, `slot_group`, `ItemLevelBracket`; SELECT "" AS ``;



/*=============================================================================================================================================
  4. Create and Populate Table: ACSBV3_0604A_stat
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "4. Create and Populate Table: ACSBV3_0604A_stat" );



DROP   TEMPORARY TABLE IF EXISTS ACSBV3_temp_slot1;

CREATE TEMPORARY TABLE           ACSBV3_temp_slot1
(

  `Quality`          TINYINT       NOT NULL,
  `QualityName`      VARCHAR(10)   NOT NULL,
  `ItemLevel`        SMALLINT      NOT NULL,
  `ItemLevelBracket` SMALLINT      NOT NULL,
  `slot_group`       VARCHAR(25)   NOT NULL,
  `avg_raw`          DECIMAL(12,5) NOT NULL,
  `avg_3pnt`         DECIMAL(12,5) NOT NULL,
  `avg_mono`         DECIMAL(12,5) NOT NULL

);

INSERT INTO ACSBV3_temp_slot1 SELECT

  d.`Quality`    AS    `Quality`, MIN(    d.`QualityName`    )      AS      `QualityName`,
  d.`ItemLevel`  AS  `ItemLevel`, FLOOR ( d.`ItemLevel` / 20 ) * 20 AS `ItemLevelBracket`,

  d.`slot_group` AS `slot_group`, ( SUM( ( CASE WHEN d.`stat_type1`  > 0 AND d.`stat_total1`  > 0 THEN 1 ELSE 0 END ) + ( CASE WHEN d.`stat_type2`  > 0 AND d.`stat_total2`  > 0 THEN 1 ELSE 0 END ) +
                                         ( CASE WHEN d.`stat_type3`  > 0 AND d.`stat_total3`  > 0 THEN 1 ELSE 0 END ) + ( CASE WHEN d.`stat_type4`  > 0 AND d.`stat_total4`  > 0 THEN 1 ELSE 0 END ) +
                                         ( CASE WHEN d.`stat_type5`  > 0 AND d.`stat_total5`  > 0 THEN 1 ELSE 0 END ) + ( CASE WHEN d.`stat_type6`  > 0 AND d.`stat_total6`  > 0 THEN 1 ELSE 0 END ) +
                                         ( CASE WHEN d.`stat_type7`  > 0 AND d.`stat_total7`  > 0 THEN 1 ELSE 0 END ) + ( CASE WHEN d.`stat_type8`  > 0 AND d.`stat_total8`  > 0 THEN 1 ELSE 0 END ) +
                                         ( CASE WHEN d.`stat_type9`  > 0 AND d.`stat_total9`  > 0 THEN 1 ELSE 0 END ) + ( CASE WHEN d.`stat_type10` > 0 AND d.`stat_total10` > 0 THEN 1 ELSE 0 END ) ) / COUNT(*) ) AS `avg_raw`,

  0 AS `avg_3pnt`, 0 AS `avg_mono`

FROM ACSBV3_ref_dataset AS d WHERE d.`Quality` BETWEEN 2 AND 4 AND `stat_sum` > 0 GROUP BY d.`Quality`, d.`slot_group`, d.`ItemLevel`;
SELECT COUNT(*) AS `Slot1_Count` FROM ACSBV3_temp_slot1; SELECT "" AS ``;



DROP   TEMPORARY TABLE IF EXISTS ACSBV3_temp_slot2;
CREATE TEMPORARY TABLE           ACSBV3_temp_slot2  LIKE   ACSBV3_temp_slot1;
INSERT INTO                      ACSBV3_temp_slot2  SELECT

        s.`Quality`      AS    `Quality`, MIN( s.`QualityName`      ) AS      `QualityName`,
  AVG ( s.`ItemLevel`  ) AS  `ItemLevel`,      s.`ItemLevelBracket`   AS `ItemLevelBracket`,
        s.`slot_group`   AS `slot_group`, AVG( s.`avg_raw`          ) AS          `avg_raw`,
  AVG ( s.`avg_3pnt`   ) AS   `avg_3pnt`, AVG( s.`avg_mono`         ) AS         `avg_mono`

FROM ACSBV3_temp_slot1 AS s GROUP BY s.`Quality`, s.`slot_group`, s.`ItemLevelBracket`;
SELECT COUNT(*) AS `Slot2_Count` FROM ACSBV3_temp_slot2; SELECT "" AS ``;



DROP   TABLE IF EXISTS ACSBV3_0604A_stat;
CREATE TABLE           ACSBV3_0604A_stat  LIKE          ACSBV3_temp_slot1;
INSERT INTO            ACSBV3_0604A_stat  SELECT * FROM ACSBV3_temp_slot2
ORDER BY `Quality` ASC, `slot_group` ASC, `ItemLevelBracket` ASC;
SELECT COUNT(*) AS `Slot3_Count` FROM ACSBV3_0604A_stat; SELECT "" AS ``;
SELECT * FROM ACSBV3_0604A_stat WHERE `Quality` = 4;



/*=============================================================================================================================================
  5. Apply 3-Point Smoothing Window to Table: ACSBV3_0604A_stat
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "5. Apply 3-Point Smoothing Window to Table: ACSBV3_0604A_stat" );



WITH cte AS ( SELECT `Quality`, `slot_group`, `ItemLevelBracket`, AVG ( `avg_raw` ) OVER ( PARTITION BY `Quality`, `slot_group`
                                                                                           ORDER BY `ItemLevelBracket` ASC
                                                                                           ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING ) AS `avg_3pnt`
              FROM ACSBV3_0604A_stat )

UPDATE ACSBV3_0604A_stat AS slot
  JOIN               cte AS cte
    ON slot.`Quality`          = cte.`Quality`
   AND slot.`slot_group`       = cte.`slot_group`
   AND slot.`ItemLevelBracket` = cte.`ItemLevelBracket`
   SET slot.`avg_3pnt`         = cte.`avg_3pnt`;



SELECT * FROM ACSBV3_0604A_stat WHERE `Quality` = 4;



/*=============================================================================================================================================
  6. Apply Monotonic Enforcement to Table: ACSBV3_0604A_stat
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "6. Apply Monotonic Enforcement to Table: ACSBV3_0604A_stat" );



SET @QUALITY := 0, @SLOT := "", @PREV := 0;

UPDATE ACSBV3_0604A_stat
  JOIN ( SELECT `Quality`, `slot_group`, `ItemLevelBracket`, @PREV := ( CASE WHEN @QUALITY = `Quality` AND @SLOT = `slot_group` THEN GREATEST ( @PREV, `avg_3pnt` )
                                                                                                                                ELSE                   `avg_3pnt`   END) AS `avg_mono`, ( @QUALITY := `Quality` ), ( @SLOT := `slot_group` )
         FROM ACSBV3_0604A_stat ORDER BY `Quality`, `slot_group`, `ItemLevelBracket` ) AS mono USING ( `Quality`, `slot_group`, `ItemLevelBracket` )
SET ACSBV3_0604A_stat.`avg_mono` = mono.`avg_mono`;



SELECT * FROM ACSBV3_0604A_stat WHERE `Quality` = 4;



/*=============================================================================================================================================
  7. Create and Populate Table: ACSBV3_aux_stat_count_uncommon
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "7. Create and Populate Table: ACSBV3_aux_stat_count_uncommon" );



DROP   TABLE IF EXISTS ACSBV3_aux_stat_count_uncommon;

CREATE TABLE           ACSBV3_aux_stat_count_uncommon
(

  `ItemLevelBracket` SMALLINT    NOT NULL COMMENT "ItemLevel in 20 Level Brackets.",
  `QualityName`      VARCHAR(10) NOT NULL COMMENT "Group Quality",

  `1H`               TINYINT     NOT NULL COMMENT "Weapon    slot_group:      1H-Weapon",
  `2H`               TINYINT     NOT NULL COMMENT "Weapon    slot_group:      2H-Weapon",
  `Staff`            TINYINT     NOT NULL COMMENT "Weapon    slot_group:   Staff-Weapon",
  `Ranged`           TINYINT     NOT NULL COMMENT "Weapon    slot_group:  Ranged-Weapon",
  `Thrown`           TINYINT     NOT NULL COMMENT "Weapon    slot_group:  Ranged-Thrown",
  `Wand`             TINYINT     NOT NULL COMMENT "Weapon    slot_group:    Ranged-Wand",

  `Major`            TINYINT     NOT NULL COMMENT "Equipment slot_group:    Major-Armor",
  `Moderate`         TINYINT     NOT NULL COMMENT "Equipment slot_group: Moderate-Armor",
  `Minor`            TINYINT     NOT NULL COMMENT "Equipment slot_group:    Minor-Armor",
  `Back`             TINYINT     NOT NULL COMMENT "Equipment slot_group:           Back",
  `Shield`           TINYINT     NOT NULL COMMENT "Equipment slot_group:         Shield",
  `Accessory`        TINYINT     NOT NULL COMMENT "Equipment slot_group:      Accessory"

);

SET @PREV01 := 1, @PREV02 := 2, @PREV03 := 1,
    @PREV04 := 1, @PREV05 := 1, @PREV06 := 1,

    @PREV07 := 2, @PREV08 := 1, @PREV09 := 2,
    @PREV10 := 2, @PREV11 := 2, @PREV12 := 2;

INSERT INTO ACSBV3_aux_stat_count_uncommon

WITH RECURSIVE seq AS ( SELECT                       0 AS `ItemLevelBracket` UNION ALL
                        SELECT `ItemLevelBracket` + 20 AS `ItemLevelBracket`
                          FROM                  seq WHERE `ItemLevelBracket` < 300 )

SELECT seq.`ItemLevelBracket` AS `ItemLevelBracket`,
                  "Uncommon"  AS      `QualityName`,
       @PREV01 := COALESCE ( ROUND ( s01.`avg_mono`, 0 ), @PREV01 ) AS     `1H`, @PREV02 := COALESCE ( ROUND ( s02.`avg_mono`, 0 ), @PREV02 ) AS        `2H`,
       @PREV03 := COALESCE ( ROUND ( s03.`avg_mono`, 0 ), @PREV03 ) AS  `Staff`, @PREV04 := COALESCE ( ROUND ( s04.`avg_mono`, 0 ), @PREV04 ) AS    `Ranged`,
       @PREV05 := COALESCE ( ROUND ( s05.`avg_mono`, 0 ), @PREV05 ) AS `Thrown`, @PREV06 := COALESCE ( ROUND ( s06.`avg_mono`, 0 ), @PREV06 ) AS      `Wand`,
       @PREV07 := COALESCE ( ROUND ( s07.`avg_mono`, 0 ), @PREV07 ) AS  `Major`, @PREV08 := COALESCE ( ROUND ( s08.`avg_mono`, 0 ), @PREV08 ) AS  `Moderate`,
       @PREV09 := COALESCE ( ROUND ( s09.`avg_mono`, 0 ), @PREV09 ) AS  `Minor`, @PREV10 := COALESCE ( ROUND ( s10.`avg_mono`, 0 ), @PREV10 ) AS      `Back`,
       @PREV11 := COALESCE ( ROUND ( s11.`avg_mono`, 0 ), @PREV11 ) AS `Shield`, @PREV12 := COALESCE ( ROUND ( s12.`avg_mono`, 0 ), @PREV12 ) AS `Accessory`
FROM seq
LEFT JOIN ACSBV3_0604A_stat AS s01 ON s01.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s01.`slot_group` =      "1H-Weapon" AND s01.`Quality` = 2
LEFT JOIN ACSBV3_0604A_stat AS s02 ON s02.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s02.`slot_group` =      "2H-Weapon" AND s02.`Quality` = 2
LEFT JOIN ACSBV3_0604A_stat AS s03 ON s03.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s03.`slot_group` =   "Staff-Weapon" AND s03.`Quality` = 2
LEFT JOIN ACSBV3_0604A_stat AS s04 ON s04.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s04.`slot_group` =  "Ranged-Weapon" AND s04.`Quality` = 2
LEFT JOIN ACSBV3_0604A_stat AS s05 ON s05.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s05.`slot_group` =  "Ranged-Thrown" AND s05.`Quality` = 2
LEFT JOIN ACSBV3_0604A_stat AS s06 ON s06.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s06.`slot_group` =    "Ranged-Wand" AND s06.`Quality` = 2
LEFT JOIN ACSBV3_0604A_stat AS s07 ON s07.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s07.`slot_group` =    "Major-Armor" AND s07.`Quality` = 2
LEFT JOIN ACSBV3_0604A_stat AS s08 ON s08.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s08.`slot_group` = "Moderate-Armor" AND s08.`Quality` = 2
LEFT JOIN ACSBV3_0604A_stat AS s09 ON s09.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s09.`slot_group` =    "Minor-Armor" AND s09.`Quality` = 2
LEFT JOIN ACSBV3_0604A_stat AS s10 ON s10.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s10.`slot_group` =           "Back" AND s10.`Quality` = 2
LEFT JOIN ACSBV3_0604A_stat AS s11 ON s11.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s11.`slot_group` =         "Shield" AND s11.`Quality` = 2
LEFT JOIN ACSBV3_0604A_stat AS s12 ON s12.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s12.`slot_group` =      "Accessory" AND s12.`Quality` = 2;

SELECT COUNT(*) FROM ACSBV3_aux_stat_count_uncommon;



/*=============================================================================================================================================
  8. Create and Populate Table: ACSBV3_aux_stat_count_rare
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "8. Create and Populate Table: ACSBV3_aux_stat_count_rare" );



DROP   TABLE IF EXISTS ACSBV3_aux_stat_count_rare;

CREATE TABLE           ACSBV3_aux_stat_count_rare
(

  `ItemLevelBracket` SMALLINT    NOT NULL COMMENT "ItemLevel in 20 Level Brackets.",
  `QualityName`      VARCHAR(10) NOT NULL COMMENT "Group Quality",

  `1H`               TINYINT     NOT NULL COMMENT "Weapon    slot_group:      1H-Weapon",
  `2H`               TINYINT     NOT NULL COMMENT "Weapon    slot_group:      2H-Weapon",
  `Staff`            TINYINT     NOT NULL COMMENT "Weapon    slot_group:   Staff-Weapon",
  `Ranged`           TINYINT     NOT NULL COMMENT "Weapon    slot_group:  Ranged-Weapon",
  `Thrown`           TINYINT     NOT NULL COMMENT "Weapon    slot_group:  Ranged-Thrown",
  `Wand`             TINYINT     NOT NULL COMMENT "Weapon    slot_group:    Ranged-Wand",

  `Major`            TINYINT     NOT NULL COMMENT "Equipment slot_group:    Major-Armor",
  `Moderate`         TINYINT     NOT NULL COMMENT "Equipment slot_group: Moderate-Armor",
  `Minor`            TINYINT     NOT NULL COMMENT "Equipment slot_group:    Minor-Armor",
  `Back`             TINYINT     NOT NULL COMMENT "Equipment slot_group:           Back",
  `Shield`           TINYINT     NOT NULL COMMENT "Equipment slot_group:         Shield",
  `Accessory`        TINYINT     NOT NULL COMMENT "Equipment slot_group:      Accessory"

);

SET @PREV01 := 2, @PREV02 := 2, @PREV03 := 1,
    @PREV04 := 1, @PREV05 := 1, @PREV06 := 1,

    @PREV07 := 3, @PREV08 := 1, @PREV09 := 2,
    @PREV10 := 2, @PREV11 := 2, @PREV12 := 2;

INSERT INTO ACSBV3_aux_stat_count_rare

WITH RECURSIVE seq AS ( SELECT                       0 AS `ItemLevelBracket` UNION ALL
                        SELECT `ItemLevelBracket` + 20 AS `ItemLevelBracket`
                          FROM                  seq WHERE `ItemLevelBracket` < 300 )

SELECT seq.`ItemLevelBracket` AS `ItemLevelBracket`,
                      "Rare"  AS      `QualityName`,
       @PREV01 := COALESCE ( ROUND ( s01.`avg_mono`, 0 ), @PREV01 ) AS     `1H`, @PREV02 := COALESCE ( ROUND ( s02.`avg_mono`, 0 ), @PREV02 ) AS        `2H`,
       @PREV03 := COALESCE ( ROUND ( s03.`avg_mono`, 0 ), @PREV03 ) AS  `Staff`, @PREV04 := COALESCE ( ROUND ( s04.`avg_mono`, 0 ), @PREV04 ) AS    `Ranged`,
       @PREV05 := COALESCE ( ROUND ( s05.`avg_mono`, 0 ), @PREV05 ) AS `Thrown`, @PREV06 := COALESCE ( ROUND ( s06.`avg_mono`, 0 ), @PREV06 ) AS      `Wand`,
       @PREV07 := COALESCE ( ROUND ( s07.`avg_mono`, 0 ), @PREV07 ) AS  `Major`, @PREV08 := COALESCE ( ROUND ( s08.`avg_mono`, 0 ), @PREV08 ) AS  `Moderate`,
       @PREV09 := COALESCE ( ROUND ( s09.`avg_mono`, 0 ), @PREV09 ) AS  `Minor`, @PREV10 := COALESCE ( ROUND ( s10.`avg_mono`, 0 ), @PREV10 ) AS      `Back`,
       @PREV11 := COALESCE ( ROUND ( s11.`avg_mono`, 0 ), @PREV11 ) AS `Shield`, @PREV12 := COALESCE ( ROUND ( s12.`avg_mono`, 0 ), @PREV12 ) AS `Accessory`
FROM seq
LEFT JOIN ACSBV3_0604A_stat AS s01 ON s01.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s01.`slot_group` =      "1H-Weapon" AND s01.`Quality` = 3
LEFT JOIN ACSBV3_0604A_stat AS s02 ON s02.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s02.`slot_group` =      "2H-Weapon" AND s02.`Quality` = 3
LEFT JOIN ACSBV3_0604A_stat AS s03 ON s03.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s03.`slot_group` =   "Staff-Weapon" AND s03.`Quality` = 3
LEFT JOIN ACSBV3_0604A_stat AS s04 ON s04.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s04.`slot_group` =  "Ranged-Weapon" AND s04.`Quality` = 3
LEFT JOIN ACSBV3_0604A_stat AS s05 ON s05.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s05.`slot_group` =  "Ranged-Thrown" AND s05.`Quality` = 3
LEFT JOIN ACSBV3_0604A_stat AS s06 ON s06.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s06.`slot_group` =    "Ranged-Wand" AND s06.`Quality` = 3
LEFT JOIN ACSBV3_0604A_stat AS s07 ON s07.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s07.`slot_group` =    "Major-Armor" AND s07.`Quality` = 3
LEFT JOIN ACSBV3_0604A_stat AS s08 ON s08.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s08.`slot_group` = "Moderate-Armor" AND s08.`Quality` = 3
LEFT JOIN ACSBV3_0604A_stat AS s09 ON s09.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s09.`slot_group` =    "Minor-Armor" AND s09.`Quality` = 3
LEFT JOIN ACSBV3_0604A_stat AS s10 ON s10.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s10.`slot_group` =           "Back" AND s10.`Quality` = 3
LEFT JOIN ACSBV3_0604A_stat AS s11 ON s11.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s11.`slot_group` =         "Shield" AND s11.`Quality` = 3
LEFT JOIN ACSBV3_0604A_stat AS s12 ON s12.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s12.`slot_group` =      "Accessory" AND s12.`Quality` = 3;

SELECT COUNT(*) FROM ACSBV3_aux_stat_count_rare;



/*=============================================================================================================================================
  9. Create and Populate Table: ACSBV3_aux_stat_count_epic
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "9. Create and Populate Table: ACSBV3_aux_stat_count_epic" );



DROP   TABLE IF EXISTS ACSBV3_aux_stat_count_epic;

CREATE TABLE           ACSBV3_aux_stat_count_epic
(

  `ItemLevelBracket` SMALLINT    NOT NULL COMMENT "ItemLevel in 20 Level Brackets.",
  `QualityName`      VARCHAR(10) NOT NULL COMMENT "Group Quality",

  `1H`               TINYINT     NOT NULL COMMENT "Weapon    slot_group:      1H-Weapon",
  `2H`               TINYINT     NOT NULL COMMENT "Weapon    slot_group:      2H-Weapon",
  `Staff`            TINYINT     NOT NULL COMMENT "Weapon    slot_group:   Staff-Weapon",
  `Ranged`           TINYINT     NOT NULL COMMENT "Weapon    slot_group:  Ranged-Weapon",
  `Thrown`           TINYINT     NOT NULL COMMENT "Weapon    slot_group:  Ranged-Thrown",
  `Wand`             TINYINT     NOT NULL COMMENT "Weapon    slot_group:    Ranged-Wand",

  `Major`            TINYINT     NOT NULL COMMENT "Equipment slot_group:    Major-Armor",
  `Moderate`         TINYINT     NOT NULL COMMENT "Equipment slot_group: Moderate-Armor",
  `Minor`            TINYINT     NOT NULL COMMENT "Equipment slot_group:    Minor-Armor",
  `Back`             TINYINT     NOT NULL COMMENT "Equipment slot_group:           Back",
  `Shield`           TINYINT     NOT NULL COMMENT "Equipment slot_group:         Shield",
  `Accessory`        TINYINT     NOT NULL COMMENT "Equipment slot_group:      Accessory"

);

SET @PREV01 := 2, @PREV02 := 2, @PREV03 := 1,
    @PREV04 := 1, @PREV05 := 2, @PREV06 := 1,

    @PREV07 := 2, @PREV08 := 1, @PREV09 := 2,
    @PREV10 := 2, @PREV11 := 2, @PREV12 := 2;

INSERT INTO ACSBV3_aux_stat_count_epic

WITH RECURSIVE seq AS ( SELECT                       0 AS `ItemLevelBracket` UNION ALL
                        SELECT `ItemLevelBracket` + 20 AS `ItemLevelBracket`
                          FROM                  seq WHERE `ItemLevelBracket` < 300 )

SELECT seq.`ItemLevelBracket` AS `ItemLevelBracket`,
                      "Epic"  AS      `QualityName`,
       @PREV01 := COALESCE ( ROUND ( s01.`avg_mono`, 0 ), @PREV01 ) AS     `1H`, @PREV02 := COALESCE ( ROUND ( s02.`avg_mono`, 0 ), @PREV02 ) AS        `2H`,
       @PREV03 := COALESCE ( ROUND ( s03.`avg_mono`, 0 ), @PREV03 ) AS  `Staff`, @PREV04 := COALESCE ( ROUND ( s04.`avg_mono`, 0 ), @PREV04 ) AS    `Ranged`,
       @PREV05 := COALESCE ( ROUND ( s05.`avg_mono`, 0 ), @PREV05 ) AS `Thrown`, @PREV06 := COALESCE ( ROUND ( s06.`avg_mono`, 0 ), @PREV06 ) AS      `Wand`,
       @PREV07 := COALESCE ( ROUND ( s07.`avg_mono`, 0 ), @PREV07 ) AS  `Major`, @PREV08 := COALESCE ( ROUND ( s08.`avg_mono`, 0 ), @PREV08 ) AS  `Moderate`,
       @PREV09 := COALESCE ( ROUND ( s09.`avg_mono`, 0 ), @PREV09 ) AS  `Minor`, @PREV10 := COALESCE ( ROUND ( s10.`avg_mono`, 0 ), @PREV10 ) AS      `Back`,
       @PREV11 := COALESCE ( ROUND ( s11.`avg_mono`, 0 ), @PREV11 ) AS `Shield`, @PREV12 := COALESCE ( ROUND ( s12.`avg_mono`, 0 ), @PREV12 ) AS `Accessory`
FROM seq
LEFT JOIN ACSBV3_0604A_stat AS s01 ON s01.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s01.`slot_group` =      "1H-Weapon" AND s01.`Quality` = 4
LEFT JOIN ACSBV3_0604A_stat AS s02 ON s02.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s02.`slot_group` =      "2H-Weapon" AND s02.`Quality` = 4
LEFT JOIN ACSBV3_0604A_stat AS s03 ON s03.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s03.`slot_group` =   "Staff-Weapon" AND s03.`Quality` = 4
LEFT JOIN ACSBV3_0604A_stat AS s04 ON s04.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s04.`slot_group` =  "Ranged-Weapon" AND s04.`Quality` = 4
LEFT JOIN ACSBV3_0604A_stat AS s05 ON s05.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s05.`slot_group` =  "Ranged-Thrown" AND s05.`Quality` = 4
LEFT JOIN ACSBV3_0604A_stat AS s06 ON s06.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s06.`slot_group` =    "Ranged-Wand" AND s06.`Quality` = 4
LEFT JOIN ACSBV3_0604A_stat AS s07 ON s07.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s07.`slot_group` =    "Major-Armor" AND s07.`Quality` = 4
LEFT JOIN ACSBV3_0604A_stat AS s08 ON s08.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s08.`slot_group` = "Moderate-Armor" AND s08.`Quality` = 4
LEFT JOIN ACSBV3_0604A_stat AS s09 ON s09.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s09.`slot_group` =    "Minor-Armor" AND s09.`Quality` = 4
LEFT JOIN ACSBV3_0604A_stat AS s10 ON s10.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s10.`slot_group` =           "Back" AND s10.`Quality` = 4
LEFT JOIN ACSBV3_0604A_stat AS s11 ON s11.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s11.`slot_group` =         "Shield" AND s11.`Quality` = 4
LEFT JOIN ACSBV3_0604A_stat AS s12 ON s12.`ItemLevelBracket` = seq.`ItemLevelBracket` AND s12.`slot_group` =      "Accessory" AND s12.`Quality` = 4;

SELECT COUNT(*) FROM ACSBV3_aux_stat_count_epic;



/*=============================================================================================================================================
  10. Create and Populate Table: ACSBV3_aux_stat_count
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "10. Create and Populate Table: ACSBV3_aux_stat_count" );



DROP   TABLE IF EXISTS ACSBV3_aux_stat_count;

CREATE TABLE           ACSBV3_aux_stat_count
(

  `ItemLevelBracket` SMALLINT    NOT NULL COMMENT "ItemLevel in 20 Level Brackets.",
  `QualityName`      VARCHAR(10) NOT NULL COMMENT "Group Quality",

  `1H`               TINYINT     NOT NULL COMMENT "Weapon    slot_group:      1H-Weapon",
  `2H`               TINYINT     NOT NULL COMMENT "Weapon    slot_group:      2H-Weapon",
  `Staff`            TINYINT     NOT NULL COMMENT "Weapon    slot_group:   Staff-Weapon",
  `Ranged`           TINYINT     NOT NULL COMMENT "Weapon    slot_group:  Ranged-Weapon",
  `Thrown`           TINYINT     NOT NULL COMMENT "Weapon    slot_group:  Ranged-Thrown",
  `Wand`             TINYINT     NOT NULL COMMENT "Weapon    slot_group:    Ranged-Wand",

  `Major`            TINYINT     NOT NULL COMMENT "Equipment slot_group:    Major-Armor",
  `Moderate`         TINYINT     NOT NULL COMMENT "Equipment slot_group: Moderate-Armor",
  `Minor`            TINYINT     NOT NULL COMMENT "Equipment slot_group:    Minor-Armor",
  `Back`             TINYINT     NOT NULL COMMENT "Equipment slot_group:           Back",
  `Shield`           TINYINT     NOT NULL COMMENT "Equipment slot_group:         Shield",
  `Accessory`        TINYINT     NOT NULL COMMENT "Equipment slot_group:      Accessory"

);

INSERT INTO ACSBV3_aux_stat_count
SELECT * FROM ACSBV3_aux_stat_count_uncommon UNION ALL
SELECT * FROM ACSBV3_aux_stat_count_rare     UNION ALL
SELECT * FROM ACSBV3_aux_stat_count_epic;

SELECT * FROM ACSBV3_aux_stat_count;



CALL ACSBV3_print_footer ();

/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
