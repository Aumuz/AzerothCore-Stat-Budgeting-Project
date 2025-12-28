/*=============================================================================================================================================
  Filename:       ACSBV3-04-02A.sql
  Title:          Generate Comparative Budget Tables.
  Author:         Aumuz Messick
  Version:        2.4
  Created:        2025-11-08
  Description:    This script will generate comparative budget tables.
                  This will cross-reference ACSBV3_doc_item_template with ACSBV3_0401A_curve,
                  comparing budget_normalized to three budget curves (curve_raw, curve_3pnt, curve_mono).

-----------------------------------------------------------------------------------------------------------------------------------------------
  Updates:
   - v2.0 -> Script Created (completely reworked from v1.0).
   - v2.1 -> (2025-11-10) Added print-out formatting: ACSBV3_print_info.
   - v2.2 -> (2025-11-18) Skipped to sync version numbers with pipeline.
   - v2.3 -> (2025-11-18) Added `mod_source` support.
   - v2.4 -> (2025-11-18) Skipped to sync version numbers with pipeline (updated headers).

=============================================================================================================================================*/


SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';


/*=============================================================================================================================================
  0. Update Print Information Table: ACSBV3_print_info
=============================================================================================================================================*/

DELETE FROM ACSBV3_print_info WHERE `script` = "0402A";

INSERT INTO ACSBV3_print_info ( `script`, `part`, `print`, `output` ) VALUES
( "0402A", 2, 1, "##  Verification: ACSBV3_0402A_diagnostic_dataset                                                                (v2.4)  ##" );



/*=============================================================================================================================================
  1. Create Table: ACSBV3_0402A_diagnostic_dataset
=============================================================================================================================================*/

SELECT "The script is processing. Please wait..." AS ``;



DROP TABLE IF EXISTS ACSBV3_0402A_diagnostic_dataset;

CREATE TABLE ACSBV3_0402A_diagnostic_dataset
(

  /* Canonical Metadata */

     `entry`             INT,
     `name`              VARCHAR(255),
     `ItemLevel`         SMALLINT,



  /* ACSBV3 Metadata */

     `drop_environment`  VARCHAR(16),
     `source_type`       VARCHAR(16),
     `FamilyID`          VARCHAR(16),
     `ArmorID`           VARCHAR(16),
     `WeaponID`          VARCHAR(25),
     `SlotID`            VARCHAR(16),
     `QualityName`       VARCHAR(10),
     `CurveName`         VARCHAR(10),



  /* Budget Information */

     `budget_actual`     DECIMAL(12,5),
     `mod_drop`          DECIMAL(8,2),
     `mod_source`        DECIMAL(8,2),
     `mod_misc`          DECIMAL(8,2),
     `mod_slot`          DECIMAL(8,2),
     `budget_normalized` DECIMAL(12,5),



  /* Curve Information */

     `budget_target1`    DECIMAL(12,5),
     `budget_diff1`      DECIMAL(12,5),
     `budget_perc1`      DECIMAL(12,5),

     `budget_target2`    DECIMAL(12,5),
     `budget_diff2`      DECIMAL(12,5),
     `budget_perc2`      DECIMAL(12,5),

     `budget_target3`    DECIMAL(12,5),
     `budget_diff3`      DECIMAL(12,5),
     `budget_perc3`      DECIMAL(12,5)

);



/*=============================================================================================================================================
  2. Populate Table: ACSBV3_0402A_diagnostic_dataset
=============================================================================================================================================*/

INSERT INTO ACSBV3_0402A_diagnostic_dataset

(

  `entry`, `name`, `ItemLevel`,
  `drop_environment`, `source_type`, `FamilyID`, `ArmorID`, `WeaponID`, `SlotID`, `QualityName`,
  `budget_actual`, `mod_drop`, `mod_source`, `mod_misc`, `mod_slot`, `budget_normalized`,

  `CurveName`,

  `budget_target1`, `budget_diff1`, `budget_perc1`,
  `budget_target2`, `budget_diff2`, `budget_perc2`,
  `budget_target3`, `budget_diff3`, `budget_perc3`

)

SELECT

  /* Direct Copy From ACSBV3_doc_item_template */

     i.`entry`, i.`name`, i.`ItemLevel`,
     i.`drop_environment`, i.`source_type`, i.`FamilyID`, i.`ArmorID`, i.`WeaponID`, i.`SlotID`, i.`QualityName`,
     i.`budget_actual`, i.`mod_drop`, i.`mod_source`, i.`mod_misc`, i.`mod_slot`, i.`budget_normalized`,



  /* Find Curve Name */

     `CurveName`,



  /* Calculate Budget Curve Information */

     c.`curve_raw`  AS `budget_target1`, (i.`budget_normalized` - c.`curve_raw` ) AS `budget_diff1`, (i.`budget_normalized` / c.`curve_raw` ) AS `budget_perc1`,
     c.`curve_3pnt` AS `budget_target2`, (i.`budget_normalized` - c.`curve_3pnt`) AS `budget_diff2`, (i.`budget_normalized` / c.`curve_3pnt`) AS `budget_perc2`,
     c.`curve_mono` AS `budget_target3`, (i.`budget_normalized` - c.`curve_mono`) AS `budget_diff3`, (i.`budget_normalized` / c.`curve_mono`) AS `budget_perc3`

FROM ACSBV3_doc_item_template AS i
 LEFT JOIN ACSBV3_0401A_curve AS c ON i.`QualityName` = c.`QualityName` AND i.`ItemLevel` = c.`ItemLevel` WHERE c.`CurveName` IN ("Q1", "Q2", "Q3", "Q4C", "Q5");



INSERT INTO ACSBV3_0402A_diagnostic_dataset

(

  `entry`, `name`, `ItemLevel`,
  `drop_environment`, `source_type`, `FamilyID`, `SlotID`, `QualityName`,
  `budget_actual`, `mod_drop`, `mod_source`, `mod_misc`, `mod_slot`, `budget_normalized`,

  `CurveName`,

  `budget_target1`, `budget_diff1`, `budget_perc1`,
  `budget_target2`, `budget_diff2`, `budget_perc2`,
  `budget_target3`, `budget_diff3`, `budget_perc3`

)

SELECT

  /* Direct Copy From ACSBV3_doc_item_template */

     i.`entry`, i.`name`, i.`ItemLevel`,
     i.`drop_environment`, i.`source_type`, i.`FamilyID`, i.`SlotID`, i.`QualityName`,
     i.`budget_actual`, i.`mod_drop`, i.`mod_source`, i.`mod_misc`, i.`mod_slot`, i.`budget_normalized`,



  /* Find Curve Name */

     `CurveName`,



  /* Calculate Budget Curve Information */

     c.`curve_raw`  AS `budget_target1`, (i.`budget_normalized` - c.`curve_raw` ) AS `budget_diff1`, (i.`budget_normalized` / c.`curve_raw` ) AS `budget_perc1`,
     c.`curve_3pnt` AS `budget_target2`, (i.`budget_normalized` - c.`curve_3pnt`) AS `budget_diff2`, (i.`budget_normalized` / c.`curve_3pnt`) AS `budget_perc2`,
     c.`curve_mono` AS `budget_target3`, (i.`budget_normalized` - c.`curve_mono`) AS `budget_diff3`, (i.`budget_normalized` / c.`curve_mono`) AS `budget_perc3`

FROM ACSBV3_doc_item_template AS i
 LEFT JOIN ACSBV3_0401A_curve AS c ON i.`QualityName` = c.`QualityName` AND i.`ItemLevel` = c.`ItemLevel` WHERE c.`CurveName` = "Q4E" AND i.`FamilyID` = "Equipment";



INSERT INTO ACSBV3_0402A_diagnostic_dataset

(

  `entry`, `name`, `ItemLevel`,
  `drop_environment`, `source_type`, `FamilyID`, `SlotID`, `QualityName`,
  `budget_actual`, `mod_drop`, `mod_source`, `mod_misc`, `mod_slot`, `budget_normalized`,

  `CurveName`,

  `budget_target1`, `budget_diff1`, `budget_perc1`,
  `budget_target2`, `budget_diff2`, `budget_perc2`,
  `budget_target3`, `budget_diff3`, `budget_perc3`

)

SELECT

  /* Direct Copy From ACSBV3_doc_item_template */

     i.`entry`, i.`name`, i.`ItemLevel`,
     i.`drop_environment`, i.`source_type`, i.`FamilyID`, i.`SlotID`, i.`QualityName`,
     i.`budget_actual`, i.`mod_drop`, i.`mod_source`, i.`mod_misc`, i.`mod_slot`, i.`budget_normalized`,



  /* Find Curve Name */

     `CurveName`,



  /* Calculate Budget Curve Information */

     c.`curve_raw`  AS `budget_target1`, (i.`budget_normalized` - c.`curve_raw` ) AS `budget_diff1`, (i.`budget_normalized` / c.`curve_raw` ) AS `budget_perc1`,
     c.`curve_3pnt` AS `budget_target2`, (i.`budget_normalized` - c.`curve_3pnt`) AS `budget_diff2`, (i.`budget_normalized` / c.`curve_3pnt`) AS `budget_perc2`,
     c.`curve_mono` AS `budget_target3`, (i.`budget_normalized` - c.`curve_mono`) AS `budget_diff3`, (i.`budget_normalized` / c.`curve_mono`) AS `budget_perc3`

FROM ACSBV3_doc_item_template AS i
 LEFT JOIN ACSBV3_0401A_curve AS c ON i.`QualityName` = c.`QualityName` AND i.`ItemLevel` = c.`ItemLevel` WHERE c.`CurveName` = "Q4W" AND i.`FamilyID` = "Weapon";



/*=============================================================================================================================================
  3. Verification: ACSBV3_doc_item_template
=============================================================================================================================================*/

SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0402A" AND `print` = 1 ) ORDER BY `part`, `auto`;    -- Print Header



SELECT `entry`, `name`, `CurveName`, `budget_target1`, `budget_diff1`, `budget_perc1`,
                                     `budget_target2`, `budget_diff2`, `budget_perc2`,
                                     `budget_target3`, `budget_diff3`, `budget_perc3`
FROM ACSBV3_0402A_diagnostic_dataset
ORDER BY RAND()
LIMIT 5;

SELECT

  COUNT(*) AS `total_count`,
  COUNT(DISTINCT `entry`) AS `distinct_items`

FROM ACSBV3_0402A_diagnostic_dataset;



SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` >= 8 ) ORDER BY `part`, `auto`;    -- Print Footer



/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
