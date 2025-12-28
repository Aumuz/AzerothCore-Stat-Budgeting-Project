/*=============================================================================================================================================
  Filename:       ACSBV3-05-03A.sql
  Title:          Create Final Curve Tables.
  Author:         Aumuz Messick
  Version:        1.0
  Created:        2025-11-26
  Description:    Create Final "Documentation Ready" Curve Tables.

                  The following tables will be created:

                   - 1. Create and Populate Master Curve Table: ACSBV3_0503A_curve_master
                   - 2. Create and Populate Curve Bracket Table: ACSBV3_0503A_curve_bracket

                  Tables retain NULL values, so zero values will not effect calculations.
                  NULL values will be replaced by zero before publication.

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

SET @SCRIPT  := "0503A",
    @VERSION := "1.0";



/*=============================================================================================================================================
  1. Create and Populate Master Curve Table: ACSBV3_0503A_curve_master
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "1. Create and Populate Master Curve Table: ACSBV3_0503A_curve_master" );

DROP   TABLE IF EXISTS ACSBV3_0503A_curve_master;

CREATE TABLE           ACSBV3_0503A_curve_master
(

  `ItemLevel`        SMALLINT             NOT NULL,
  `ItemLevelBracket` SMALLINT             NOT NULL,
  `Poor`             DECIMAL(12,5),
  `Common`           DECIMAL(12,5),    -- Note: must allow NULL values.
  `Uncommon`         DECIMAL(12,5),    -- Note: must allow NULL values.
  `Rare`             DECIMAL(12,5),    -- Note: must allow NULL values.
  `Epic`             DECIMAL(12,5),    -- Note: must allow NULL values.
  `Legendary`        DECIMAL(12,5)     -- Note: must allow NULL values.

);

INSERT INTO ACSBV3_0503A_curve_master

WITH RECURSIVE seq AS ( SELECT               10 AS `ItemLevel` UNION ALL
                        SELECT `ItemLevel` +  1 AS `ItemLevel`
                          FROM           seq WHERE `ItemLevel` < 300 )

SELECT    seq.`ItemLevel`             AS        `ItemLevel`,
 FLOOR  ( seq.`ItemLevel` / 10 ) * 10 AS `ItemLevelBracket`,
                                    0 AS             `Poor`,
          c1.`curve_mono`             AS           `Common`,
          c2.`curve_mono`             AS         `Uncommon`,
          c3.`curve_mono`             AS             `Rare`,
          c4.`curve_mono`             AS             `Epic`,
          c5.`curve_mono`             AS        `Legendary`
FROM seq
LEFT JOIN ACSBV3_0501C_curve AS c1 ON c1.`ItemLevel` = seq.`ItemLevel` AND c1.`Quality` = 1
LEFT JOIN ACSBV3_0501C_curve AS c2 ON c2.`ItemLevel` = seq.`ItemLevel` AND c2.`Quality` = 2
LEFT JOIN ACSBV3_0501C_curve AS c3 ON c3.`ItemLevel` = seq.`ItemLevel` AND c3.`Quality` = 3
LEFT JOIN ACSBV3_0501C_curve AS c4 ON c4.`ItemLevel` = seq.`ItemLevel` AND c4.`Quality` = 4
LEFT JOIN ACSBV3_0501C_curve AS c5 ON c5.`ItemLevel` = seq.`ItemLevel` AND c5.`Quality` = 5;

SELECT * FROM ACSBV3_0503A_curve_master;



/*=============================================================================================================================================
  2. Create and Populate Curve Bracket Table: ACSBV3_0503A_curve_bracket
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "2. Create and Populate Curve Bracket Table: ACSBV3_0503A_curve_bracket" );

DROP   TABLE IF EXISTS ACSBV3_0503A_curve_bracket;

CREATE TABLE           ACSBV3_0503A_curve_bracket
(

  `ItemLevelBracket` SMALLINT             NOT NULL,
  `Poor`             DECIMAL(12,5),    -- Note: must allow NULL values.
  `Poor_Slope`       DECIMAL(12,5),    -- Note: must allow NULL values.
  `Common`           DECIMAL(12,5),    -- Note: must allow NULL values.
  `Common_Slope`     DECIMAL(12,5),    -- Note: must allow NULL values.
  `Uncommon`         DECIMAL(12,5),    -- Note: must allow NULL values.
  `Uncommon_Slope`   DECIMAL(12,5),    -- Note: must allow NULL values.
  `Rare`             DECIMAL(12,5),    -- Note: must allow NULL values.
  `Rare_Slope`       DECIMAL(12,5),    -- Note: must allow NULL values.
  `Epic`             DECIMAL(12,5),    -- Note: must allow NULL values.
  `Epic_Slope`       DECIMAL(12,5),    -- Note: must allow NULL values.
  `Legendary`        DECIMAL(12,5),    -- Note: must allow NULL values.
  `Legendary_Slope`  DECIMAL(12,5)     -- Note: must allow NULL values.

);

INSERT INTO ACSBV3_0503A_curve_bracket ( `ItemLevelBracket`, `Poor`, `Common`, `Uncommon`, `Rare`, `Epic`, `Legendary` )

SELECT  c.`ItemLevelBracket` AS `ItemLevelBracket`,
  AVG ( c.`Poor`          )  AS             `Poor`,
  AVG ( c.`Common`        )  AS           `Common`,
  AVG ( c.`Uncommon`      )  AS         `Uncommon`,
  AVG ( c.`Rare`          )  AS             `Rare`,
  AVG ( c.`Epic`          )  AS             `Epic`,
  AVG ( c.`Legendary`     )  AS        `Legendary`

FROM ACSBV3_0503A_curve_master AS c GROUP BY `ItemLevelBracket`;

UPDATE    ACSBV3_0503A_curve_bracket AS b
LEFT JOIN ACSBV3_0503A_curve_bracket AS n ON n.`ItemLevelBracket` = b.`ItemLevelBracket` + 10
SET b.`Poor_Slope`      = ( n.`Poor`      - b.`Poor`      ) / 10,
    b.`Common_Slope`    = ( n.`Common`    - b.`Common`    ) / 10,
    b.`Uncommon_Slope`  = ( n.`Uncommon`  - b.`Uncommon`  ) / 10,
    b.`Rare_Slope`      = ( n.`Rare`      - b.`Rare`      ) / 10,
    b.`Epic_Slope`      = ( n.`Epic`      - b.`Epic`      ) / 10,
    b.`Legendary_Slope` = ( n.`Legendary` - b.`Legendary` ) / 10;

SELECT * FROM ACSBV3_0503A_curve_bracket;



CALL ACSBV3_print_footer ();

/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
