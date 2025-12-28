/*=============================================================================================================================================
  Filename:       ACSBV3-04-00D.sql
  Title:          Remove Specific Items.
  Author:         Aumuz Messick
  Version:        2.4 (v1.0 does not exist)
  Created:        2025-11-06
  Description:    This script will remove specific unwanted items from ACSBV3_doc_item_template.
                  These items mostly consist of extreme outliers (compared to our budget curve).
                  This script is new to the "Phase 04-00 to 04-03 Pipeline". Retaining v2.0 for consistency with other pipeline scripts.

                  The following items will be removed:

                   - 1. PLACEHOLDER

-----------------------------------------------------------------------------------------------------------------------------------------------
  Updates:
   - v2.0 -> Script created as a placeholder. Will update on future iterations.
   - v2.1 -> (2025-11-09) Added print-out formatting: ACSBV3_print_info.
   - v2.2 -> (2025-11-18) Skipped to sync version numbers with pipeline (no change).
   - v2.3 -> (2025-11-18) Skipped to sync version numbers with pipeline (updated headers).
   - v2.4 -> (2025-11-18) Skipped to sync version numbers with pipeline (updated headers).

=============================================================================================================================================*/


SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';


/*=============================================================================================================================================
  0.1 - Set Diagnostic Variables:
=============================================================================================================================================*/

SET @RowCount0 := ( SELECT COUNT(*) FROM ACSBV3_doc_item_template ),    -- Initial Row Count of ACSBV3_doc_item_template.
    @LastCount := ( SELECT COUNT(*) FROM ACSBV3_doc_item_template );    -- Last Row Count of ACSBV3_doc_item_template.



/*=============================================================================================================================================
  0.2 - Update Print Information Table: ACSBV3_print_info
=============================================================================================================================================*/

DELETE FROM ACSBV3_print_info WHERE `script` = "0400D";

INSERT INTO ACSBV3_print_info ( `script`, `part`, `print`, `output` ) VALUES
( "0400D", 2, 1, "##  1. Final Diagnostic Output:                                                                                  (v2.4)  ##" );



/*=============================================================================================================================================
  1. Final Diagnostic Output:
=============================================================================================================================================*/

SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0400D" AND `print` = 1 ) ORDER BY `part`, `auto`;    -- Print Header



SELECT

  "Final Count: " AS `note`,

  @RowCount0 AS `ini_count`,
  COUNT(*)   AS `final_count`,

  ( @RowCount0 - @RowCount0 ) AS `PLACEHOLDER`,    -- Expected: 0

  ( @RowCount0 - COUNT(*) ) AS `total_removed`,

  (0) AS `expected`

FROM ACSBV3_doc_item_template;



SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` >= 8 ) ORDER BY `part`, `auto`;    -- Print Footer



/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
