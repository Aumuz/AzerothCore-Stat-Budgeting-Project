/*=============================================================================================================================================
  Filename:       ACSBV3-05-02A.sql
  Title:          Generate Comparative Budget Information.
  Author:         Aumuz Messick
  Version:        1.0
  Created:        2025-12-01
  Description:    This script will generate comparative budget information.
                  This will cross-reference ACSBV3_ref_dataset with ACSBV3_0501C_curve,
                  comparing budget_normalized to three budget curves (curve_raw, curve_3pnt, curve_mono).

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

SET @SCRIPT  := "0502A",
    @VERSION := "1.0";



/*=============================================================================================================================================
  1. Update Final Dataset With Curve Values: ACSBV3_ref_dataset FROM ACSBV3_0501C_curve
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "1. Update Final Dataset With Curve Values: ACSBV3_ref_dataset FROM ACSBV3_0501C_curve" );

UPDATE ACSBV3_ref_dataset AS d
JOIN   ACSBV3_0501C_curve AS c ON d.`Quality` = c.`Quality` AND d.`ItemLevel` = c.`ItemLevel`
SET d.`budget_target_raw`  = c.`curve_raw`,
    d.`budget_target_3pnt` = c.`curve_3pnt`,
    d.`budget_target_mono` = c.`curve_mono`;

SELECT CONCAT ( "Table Updated: ", COUNT(*), " rows, with ", COUNT( DISTINCT `entry` ), " distinct items." ) AS `` FROM ACSBV3_ref_dataset;



/*=============================================================================================================================================
  2. Calculate Comparative Budget Information: ACSBV3_ref_dataset
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "2. Calculate Comparative Budget Information: ACSBV3_ref_dataset" );

UPDATE ACSBV3_ref_dataset
SET `budget_diff_raw`  = ( `budget_normalized` - `budget_target_raw`  ), `budget_perc_raw`  = ( `budget_normalized` / `budget_target_raw`  ),
    `budget_diff_3pnt` = ( `budget_normalized` - `budget_target_3pnt` ), `budget_perc_3pnt` = ( `budget_normalized` / `budget_target_3pnt` ),
    `budget_diff_mono` = ( `budget_normalized` - `budget_target_mono` ), `budget_perc_mono` = ( `budget_normalized` / `budget_target_mono` );

SELECT

  CONCAT ( LPAD ( `entry`,               8, " " ), " | ",
           RPAD ( `name`,               30, " " ), " | ",
           LPAD ( `budget_normalized`,  12, " " ), " | ",

           LPAD ( `budget_target_raw`,  12, " " ), "   ",
           LPAD ( `budget_diff_raw`,    12, " " ), "   ",
           LPAD ( `budget_perc_raw`,    12, " " ), " | ",

           LPAD ( `budget_target_3pnt`, 12, " " ), "   ",
           LPAD ( `budget_diff_3pnt`,   12, " " ), "   ",
           LPAD ( `budget_perc_3pnt`,   12, " " ), " | ",

           LPAD ( `budget_target_mono`, 12, " " ), "   ",
           LPAD ( `budget_diff_mono`,   12, " " ), "   ",
           LPAD ( `budget_perc_mono`,   12, " " )       ) AS ``

FROM ACSBV3_ref_dataset
ORDER BY RAND()
LIMIT 25;



CALL ACSBV3_print_footer ();

/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
