/*=============================================================================================================================================
  Filename:       ACSBV3-06-00A.sql
  Title:          Copy Dataset.
  Author:         Aumuz Messick
  Version:        1.0
  Created:        2025-12-05
  Description:    Copy ACSBV3_ref_dataset to ACSBV3_0600A_dataset.

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

SET @SCRIPT  := "0600A",
    @VERSION := "1.0";



/*=============================================================================================================================================
  1. Copy Table: ACSBV3_ref_dataset to ACSBV3_0600A_dataset
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "1. Copy Table: ACSBV3_ref_dataset to ACSBV3_0600A_dataset" );



DROP TABLE IF EXISTS ACSBV3_0600A_dataset;

CREATE TABLE ACSBV3_0600A_dataset LIKE ACSBV3_ref_dataset;

INSERT INTO ACSBV3_0600A_dataset SELECT * FROM ACSBV3_ref_dataset;

SELECT COUNT(*) FROM ACSBV3_0600A_dataset;



/*=============================================================================================================================================
  2. Update Table: ACSBV3_0600A_dataset - RequiredLevelBracket
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "2. Update Table: ACSBV3_0600A_dataset - RequiredLevelBracket" );



SELECT COUNT(*) AS `bad_bracket` FROM ACSBV3_0600A_dataset WHERE `RequiredLevelBracket` = 0;

UPDATE ACSBV3_0600A_dataset
SET `RequiredLevelBracket` = ( CASE WHEN `RequiredLevel` BETWEEN  1 AND 10 THEN 10
                                    WHEN `RequiredLevel` BETWEEN 11 AND 20 THEN 20
                                    WHEN `RequiredLevel` BETWEEN 21 AND 30 THEN 30
                                    WHEN `RequiredLevel` BETWEEN 31 AND 40 THEN 40
                                    WHEN `RequiredLevel` BETWEEN 41 AND 50 THEN 50
                                    WHEN `RequiredLevel` BETWEEN 51 AND 60 THEN 60
                                    WHEN `RequiredLevel` BETWEEN 61 AND 70 THEN 70
                                    WHEN `RequiredLevel` BETWEEN 71 AND 80 THEN 80 ELSE 0 END );

SELECT "" AS ``;
SELECT COUNT(*) AS `bad_bracket` FROM ACSBV3_0600A_dataset WHERE `RequiredLevelBracket` = 0;

SELECT "" AS ``;
SELECT `RequiredLevel`, `RequiredLevelBracket` FROM ACSBV3_0600A_dataset GROUP BY `RequiredLevel`, `RequiredLevelBracket`;



CALL ACSBV3_print_footer ();

/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
