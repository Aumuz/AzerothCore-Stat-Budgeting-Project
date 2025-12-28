/*=============================================================================================================================================
  Filename:       ACSBV3-04-04A.sql
  Title:          Create Final Curve Tables.
  Author:         Aumuz Messick
  Version:        1.0
  Created:        2025-11-18
  Description:    Create Final "Documentation Ready" Curve Tables.

                  The following tables will be created:

                   - 1. Create and Populate Curve Table: ACSBV3_doc_curve FROM ACSBV3_0401A_curve
                         - Copy final product of Phase 04-00 to 04-03 pipeline to "Documentation Ready" table.

                   - 2. Create and Populate Curve Table: ACSBV3_0404A_master_chart FROM ACSBV3_doc_curve
                         - This acts as a master chart for generating "Documentation Ready" charts.

                   - 3. Create and Populate Curve Table: ACSBV3_doc_curve_bands FROM ACSBV3_0404A_master_chart
                         - Reduce ACSBV3_0404A_master_chart by consolidating all points in `Bracket` (10 level bands).
                         - Record average, minimum, maximum, and slope.

-----------------------------------------------------------------------------------------------------------------------------------------------
  Updates:
   - v1.0 -> Script Created.

=============================================================================================================================================*/


SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';


/*=============================================================================================================================================
  0. Update Print Information Table: ACSBV3_print_info
=============================================================================================================================================*/

DELETE FROM ACSBV3_print_info WHERE `script` = "0404A";

INSERT INTO ACSBV3_print_info ( `script`, `part`, `print`, `output` ) VALUES
( "0404A", 2, 1, "##  1. Create and Populate Curve Table: ACSBV3_doc_curve FROM ACSBV3_0401A_curve                                 (v1.0)  ##" ),
( "0404A", 2, 1, "##      - Copy final product of Phase 04-00 to 04-03 pipeline to \"Documentation Ready\" table.                            ##" ),
( "0404A", 2, 2, "##  2. Create and Populate Curve Table: ACSBV3_0404A_master_chart FROM ACSBV3_doc_curve                          (v1.0)  ##" ),
( "0404A", 2, 2, "##      - This acts as a master chart for generating \"Documentation Ready\" charts.                                       ##" ),
( "0404A", 2, 3, "##  3. Create and Populate Curve Table: ACSBV3_doc_curve_bands FROM ACSBV3_0404A_master_chart                    (v1.0)  ##" ),
( "0404A", 2, 3, "##      - Reduce ACSBV3_0404A_master_chart by consolidating all points in `Bracket` (10 level bands).                    ##" ),
( "0404A", 2, 3, "##      - Record average, minimum, maximum, and slope.                                                                   ##" );



/*=============================================================================================================================================

  1. Create and Populate Curve Table: ACSBV3_doc_curve FROM ACSBV3_0401A_curve

      - Copy final product of Phase 04-00 to 04-03 pipeline to "Documentation Ready" table.

=============================================================================================================================================*/

SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0404A" AND `print` = 1 ) ORDER BY `part`, `auto`;    -- Print Header

DROP TABLE IF EXISTS ACSBV3_doc_curve;

CREATE TABLE ACSBV3_doc_curve
(

  `CurveName`    VARCHAR(10)   COMMENT "Quality name of curve.",
  `ItemLevel`    SMALLINT      COMMENT "Primary variable used for budget curve generation.",
  `Value_Raw`    DECIMAL(12,5) COMMENT "Raw average of Quality/ItemLevel group.",
  `Value_Smooth` DECIMAL(12,5) COMMENT "Value_Raw with 3-point rolling smoothing window applied.",
  `Value_Final`  DECIMAL(12,5) COMMENT "Final curve value. Value_Smooth with monotonic enforcement applied."

);

INSERT INTO ACSBV3_doc_curve ( `CurveName`, `ItemLevel`, `Value_Raw`, `Value_Smooth`, `Value_Final` )
SELECT

  CASE

    WHEN c.`CurveName` = "Q1"  THEN "Common"
    WHEN c.`CurveName` = "Q2"  THEN "Uncommon"
    WHEN c.`CurveName` = "Q3"  THEN "Rare"
    WHEN c.`CurveName` = "Q4C" THEN "Epic"
    WHEN c.`CurveName` = "Q5"  THEN "Legendary"

  END AS `CurveName`,

  c.`ItemLevel`  AS `ItemLevel`,
  c.`curve_raw`  AS `Value_Raw`,
  c.`curve_3pnt` AS `Value_Smooth`,
  c.`curve_mono` AS `Value_Final`

FROM ACSBV3_0401A_curve AS c WHERE c.`CurveName` IN ( "Q1", "Q2", "Q3", "Q4C", "Q5" );

SELECT * FROM ACSBV3_doc_curve WHERE `CurveName` = "Common";



/*=============================================================================================================================================

  2. Create and Populate Curve Table: ACSBV3_0404A_master_chart FROM ACSBV3_doc_curve

      - This acts as a master chart for generating "Documentation Ready" charts.

=============================================================================================================================================*/

SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0404A" AND `print` = 2 ) ORDER BY `part`, `auto`;    -- Print Header

DROP TABLE IF EXISTS ACSBV3_0404A_master_chart;

CREATE TABLE ACSBV3_0404A_master_chart
(

  `Bracket`   SMALLINT      COMMENT "ItemLevel Bracket (10).",
  `ItemLevel` SMALLINT      COMMENT "Primary variable used for budget curve generation.",
  `Poor`      DECIMAL(12,5) COMMENT "Poor      Budget Curve (Quality = 0).",
  `Common`    DECIMAL(12,5) COMMENT "Common    Budget Curve (Quality = 1).",
  `Uncommon`  DECIMAL(12,5) COMMENT "Uncommon  Budget Curve (Quality = 2).",
  `Rare`      DECIMAL(12,5) COMMENT "Rare      Budget Curve (Quality = 3).",
  `Epic`      DECIMAL(12,5) COMMENT "Epic      Budget Curve (Quality = 4).",
  `Legendary` DECIMAL(12,5) COMMENT "Legendary Budget Curve (Quality = 5)."

);

INSERT INTO ACSBV3_0404A_master_chart ( `Bracket`, `ItemLevel`, `Poor`, `Common`, `Uncommon`, `Rare`, `Epic`, `Legendary` )

WITH RECURSIVE seq AS (

                        SELECT 10 AS `ItemLevel`

                        UNION ALL

                        SELECT `ItemLevel`+1 AS `ItemLevel`

                        FROM seq WHERE `ItemLevel` < 300

                      )

SELECT

  FLOOR ( seq.`ItemLevel` / 10 ) * 10 AS `Bracket`,

  seq.`ItemLevel`  AS `ItemLevel`,

  NULL             AS      `Poor`,

  c1.`Value_Final` AS    `Common`,
  c2.`Value_Final` AS  `Uncommon`,
  c3.`Value_Final` AS      `Rare`,
  c4.`Value_Final` AS      `Epic`,
  c5.`Value_Final` AS `Legendary`

FROM seq
LEFT JOIN ACSBV3_doc_curve AS c1 ON c1.`ItemLevel` = seq.`ItemLevel` AND c1.`CurveName` =    "Common"
LEFT JOIN ACSBV3_doc_curve AS c2 ON c2.`ItemLevel` = seq.`ItemLevel` AND c2.`CurveName` =  "Uncommon"
LEFT JOIN ACSBV3_doc_curve AS c3 ON c3.`ItemLevel` = seq.`ItemLevel` AND c3.`CurveName` =      "Rare"
LEFT JOIN ACSBV3_doc_curve AS c4 ON c4.`ItemLevel` = seq.`ItemLevel` AND c4.`CurveName` =      "Epic"
LEFT JOIN ACSBV3_doc_curve AS c5 ON c5.`ItemLevel` = seq.`ItemLevel` AND c5.`CurveName` = "Legendary";

SELECT * FROM ACSBV3_0404A_master_chart;



/*=============================================================================================================================================

  3. Create and Populate Curve Table: ACSBV3_doc_curve_bands FROM ACSBV3_0404A_master_chart

      - Reduce ACSBV3_0404A_master_chart by consolidating all points in `Bracket` (10 level bands).

      - Record average, minimum, maximum, and slope.

=============================================================================================================================================*/

SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0404A" AND `print` = 3 ) ORDER BY `part`, `auto`;    -- Print Header

DROP TABLE IF EXISTS ACSBV3_doc_curve_bands;

CREATE TABLE ACSBV3_doc_curve_bands
(

  `ItemLevel`       SMALLINT     COMMENT "Primary variable used for budget curve generation.",

  `Poor_Min`        DECIMAL(12,5) COMMENT "Poor      Budget Curve Minimum Value (Quality = 0).",
  `Poor`            DECIMAL(12,5) COMMENT "Poor      Budget Curve Average Value (Quality = 0).",
  `Poor_Max`        DECIMAL(12,5) COMMENT "Poor      Budget Curve Maximum Value (Quality = 0).",
  `Poor_Slope`      DECIMAL(12,5) COMMENT "Poor      Budget Curve Slope   Value (Quality = 0).",

  `Common_Min`      DECIMAL(12,5) COMMENT "Common    Budget Curve Minimum Value (Quality = 1).",
  `Common`          DECIMAL(12,5) COMMENT "Common    Budget Curve Average Value (Quality = 1).",
  `Common_Max`      DECIMAL(12,5) COMMENT "Common    Budget Curve Maximum Value (Quality = 1).",
  `Common_Slope`    DECIMAL(12,5) COMMENT "Common    Budget Curve Slope   Value (Quality = 1).",

  `Uncommon_Min`    DECIMAL(12,5) COMMENT "Uncommon  Budget Curve Minimum Value (Quality = 2).",
  `Uncommon`        DECIMAL(12,5) COMMENT "Uncommon  Budget Curve Average Value (Quality = 2).",
  `Uncommon_Max`    DECIMAL(12,5) COMMENT "Uncommon  Budget Curve Maximum Value (Quality = 2).",
  `Uncommon_Slope`  DECIMAL(12,5) COMMENT "Uncommon  Budget Curve Slope   Value (Quality = 2).",

  `Rare_Min`        DECIMAL(12,5) COMMENT "Rare      Budget Curve Minimum Value (Quality = 3).",
  `Rare`            DECIMAL(12,5) COMMENT "Rare      Budget Curve Average Value (Quality = 3).",
  `Rare_Max`        DECIMAL(12,5) COMMENT "Rare      Budget Curve Maximum Value (Quality = 3).",
  `Rare_Slope`      DECIMAL(12,5) COMMENT "Rare      Budget Curve Slope   Value (Quality = 3).",

  `Epic_Min`        DECIMAL(12,5) COMMENT "Epic      Budget Curve Minimum Value (Quality = 4).",
  `Epic`            DECIMAL(12,5) COMMENT "Epic      Budget Curve Average Value (Quality = 4).",
  `Epic_Max`        DECIMAL(12,5) COMMENT "Epic      Budget Curve Maximum Value (Quality = 4).",
  `Epic_Slope`      DECIMAL(12,5) COMMENT "Epic      Budget Curve Slope   Value (Quality = 4).",

  `Legendary_Min`   DECIMAL(12,5) COMMENT "Legendary Budget Curve Minimum Value (Quality = 5).",
  `Legendary`       DECIMAL(12,5) COMMENT "Legendary Budget Curve Average Value (Quality = 5).",
  `Legendary_Max`   DECIMAL(12,5) COMMENT "Legendary Budget Curve Maximum Value (Quality = 5).",
  `Legendary_Slope` DECIMAL(12,5) COMMENT "Legendary Budget Curve Slope   Value (Quality = 5)."

);

INSERT INTO ACSBV3_doc_curve_bands
(

  `ItemLevel`,

       `Poor`,      `Poor_Min`,      `Poor_Max`,
     `Common`,    `Common_Min`,    `Common_Max`,
   `Uncommon`,  `Uncommon_Min`,  `Uncommon_Max`,
       `Rare`,      `Rare_Min`,      `Rare_Max`,
       `Epic`,      `Epic_Min`,      `Epic_Max`,
  `Legendary`, `Legendary_Min`, `Legendary_Max`

)

SELECT

  c.`Bracket` AS `ItemLevel`,

  COALESCE ( AVG ( c.`Poor`      ), 0.00 ) AS      `Poor`,  COALESCE ( MIN( c.`Poor`      ), 0.00 ) AS      `Poor_Min`,  COALESCE ( MAX( c.`Poor`      ), 0.00 ) AS      `Poor_Max`,
  COALESCE ( AVG ( c.`Common`    ), 0.00 ) AS    `Common`,  COALESCE ( MIN( c.`Common`    ), 0.00 ) AS    `Common_Min`,  COALESCE ( MAX( c.`Common`    ), 0.00 ) AS    `Common_Max`,
  COALESCE ( AVG ( c.`Uncommon`  ), 0.00 ) AS  `Uncommon`,  COALESCE ( MIN( c.`Uncommon`  ), 0.00 ) AS  `Uncommon_Min`,  COALESCE ( MAX( c.`Uncommon`  ), 0.00 ) AS  `Uncommon_Max`,
  COALESCE ( AVG ( c.`Rare`      ), 0.00 ) AS      `Rare`,  COALESCE ( MIN( c.`Rare`      ), 0.00 ) AS      `Rare_Min`,  COALESCE ( MAX( c.`Rare`      ), 0.00 ) AS      `Rare_Max`,
  COALESCE ( AVG ( c.`Epic`      ), 0.00 ) AS      `Epic`,  COALESCE ( MIN( c.`Epic`      ), 0.00 ) AS      `Epic_Min`,  COALESCE ( MAX( c.`Epic`      ), 0.00 ) AS      `Epic_Max`,
  COALESCE ( AVG ( c.`Legendary` ), 0.00 ) AS `Legendary`,  COALESCE ( MIN( c.`Legendary` ), 0.00 ) AS `Legendary_Min`,  COALESCE ( MAX( c.`Legendary` ), 0.00 ) AS `Legendary_Max`

FROM ACSBV3_0404A_master_chart AS c GROUP BY `Bracket`;

UPDATE    ACSBV3_doc_curve_bands AS b
LEFT JOIN ACSBV3_doc_curve_bands AS n ON n.`ItemLevel` = b.`ItemLevel` + 10
SET b.`Common_Slope`    = ( n.`Common`    - b.`Common`    ) / 10,
    b.`Uncommon_Slope`  = ( n.`Uncommon`  - b.`Uncommon`  ) / 10,
    b.`Rare_Slope`      = ( n.`Rare`      - b.`Rare`      ) / 10,
    b.`Epic_Slope`      = ( n.`Epic`      - b.`Epic`      ) / 10,
    b.`Legendary_Slope` = ( n.`Legendary` - b.`Legendary` ) / 10;

SELECT * FROM ACSBV3_doc_curve_bands;



SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` >= 8 ) ORDER BY `part`, `auto`;    -- Print Footer



/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
