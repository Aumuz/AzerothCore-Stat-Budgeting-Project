/*=============================================================================================================================================
  Filename:       ACSBV3-05-03C.sql
  Title:          Copy Finalized Curve Tables.
  Author:         Aumuz Messick
  Version:        1.0
  Created:        2025-12-04
  Description:    This script will copy finalized curve tables to "Documentation Ready" tables.

                  The following tables will be created FROM copied:

                   - 1. Copy Master Curve Table:  ACSBV3_ref_curve_master  FROM ACSBV3_0503A_curve_master
                   - 2. Copy Curve Bracket Table: ACSBV3_ref_curve_bracket FROM ACSBV3_0503A_curve_bracket

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

SET @SCRIPT  := "0503C",
    @VERSION := "1.0";



/*=============================================================================================================================================
  1. Copy Master Curve Table: ACSBV3_ref_curve_master FROM ACSBV3_0503A_curve_master
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "1. Copy Master Curve Table: ACSBV3_ref_curve_master FROM ACSBV3_0503A_curve_master" );

DROP   TABLE IF EXISTS ACSBV3_ref_curve_master;

CREATE TABLE           ACSBV3_ref_curve_master
(

  `ItemLevel`        SMALLINT       PRIMARY KEY NOT NULL COMMENT "Primary measurement of quality curves.",
  `Poor`             DECIMAL(12,5)              NOT NULL COMMENT "Quality Curve: Poor      - Quality = 0. (not produced in ACSBV3)",
  `Common`           DECIMAL(12,5)              NOT NULL COMMENT "Quality Curve: Common    - Quality = 1.",
  `Uncommon`         DECIMAL(12,5)              NOT NULL COMMENT "Quality Curve: Uncommon  - Quality = 2.",
  `Rare`             DECIMAL(12,5)              NOT NULL COMMENT "Quality Curve: Rare      - Quality = 3.",
  `Epic`             DECIMAL(12,5)              NOT NULL COMMENT "Quality Curve: Epic      - Quality = 4.",
  `Legendary`        DECIMAL(12,5)              NOT NULL COMMENT "Quality Curve: Legendary - Quality = 5."

);

INSERT INTO ACSBV3_ref_curve_master
SELECT       c.`ItemLevel`         AS `ItemLevel`,
  COALESCE ( c.`Poor`,      0.00 ) AS      `Poor`,
  COALESCE ( c.`Common`,    0.00 ) AS    `Common`,
  COALESCE ( c.`Uncommon`,  0.00 ) AS  `Uncommon`,
  COALESCE ( c.`Rare`,      0.00 ) AS      `Rare`,
  COALESCE ( c.`Epic`,      0.00 ) AS      `Epic`,
  COALESCE ( c.`Legendary`, 0.00 ) AS `Legendary`
FROM ACSBV3_0503A_curve_master AS c;

SELECT * FROM ACSBV3_ref_curve_master;



/*=============================================================================================================================================
  2. Copy Curve Bracket Table: ACSBV3_ref_curve_bracket FROM ACSBV3_0503A_curve_bracket
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "2. Copy Curve Bracket Table: ACSBV3_ref_curve_bracket FROM ACSBV3_0503A_curve_bracket" );

DROP   TABLE IF EXISTS ACSBV3_ref_curve_bracket;

CREATE TABLE           ACSBV3_ref_curve_bracket
(

  `ItemLevel`        SMALLINT       PRIMARY KEY NOT NULL COMMENT "Primary measurement of quality curves in 10 level increments.",
  `Poor`             DECIMAL(12,5)              NOT NULL COMMENT "Quality Curve: Poor      - Quality = 0. (not produced in ACSBV3)",
  `Common`           DECIMAL(12,5)              NOT NULL COMMENT "Quality Curve: Common    - Quality = 1.",
  `Uncommon`         DECIMAL(12,5)              NOT NULL COMMENT "Quality Curve: Uncommon  - Quality = 2.",
  `Rare`             DECIMAL(12,5)              NOT NULL COMMENT "Quality Curve: Rare      - Quality = 3.",
  `Epic`             DECIMAL(12,5)              NOT NULL COMMENT "Quality Curve: Epic      - Quality = 4.",
  `Legendary`        DECIMAL(12,5)              NOT NULL COMMENT "Quality Curve: Legendary - Quality = 5."

);

INSERT INTO ACSBV3_ref_curve_bracket
SELECT       c.`ItemLevelBracket`  AS `ItemLevel`,
  COALESCE ( c.`Poor`,      0.00 ) AS      `Poor`,
  COALESCE ( c.`Common`,    0.00 ) AS    `Common`,
  COALESCE ( c.`Uncommon`,  0.00 ) AS  `Uncommon`,
  COALESCE ( c.`Rare`,      0.00 ) AS      `Rare`,
  COALESCE ( c.`Epic`,      0.00 ) AS      `Epic`,
  COALESCE ( c.`Legendary`, 0.00 ) AS `Legendary`
FROM ACSBV3_0503A_curve_bracket AS c;

SELECT * FROM ACSBV3_ref_curve_bracket;



CALL ACSBV3_print_footer ();

/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
