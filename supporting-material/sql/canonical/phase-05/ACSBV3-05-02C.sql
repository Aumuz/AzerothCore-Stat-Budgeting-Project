/*=============================================================================================================================================
  Filename:       ACSBV3-05-02C.sql
  Title:          Overall Comparative Reports.
  Author:         Aumuz Messick
  Version:        2.0
  Created:        2025-12-02
  Description:    This script will generate a series of comparative reports.
                  These reports are used to adjust various budget modifiers.

                  The following reports will be generated:

                   - 1. Global Report: Compares all items and curves into one report.
                   - 2. Quality Report: Compares all items within each quality curve.
                   - 3. ItemLevel Report: Compares all items of similar ItemLevel to all curves.
                   - 4. Drop Report: Compares all items and curves, grouped by drop_environment.
                   - 5. Source Report: Compares all items and curves, grouped by source_type.
                   - 6. Slot Report: Compares all items of similar class, subclass, and InventoryType to all curves.
                   - 7. Random Modifier Report: Compares all items mod_misc to all curves.

-----------------------------------------------------------------------------------------------------------------------------------------------
  Notes:

   - Attempted to balance modifiers with a goal between 0.99 and 1.01 during v1.9+. This resulted in unstable numbers. Reverted back to v1.8 numbers.

   - During the failed v1.9+ attempts, it was discovered that most Drop Modifiers and Source Modifiers appear to be 1.00 (excluding conjured items at 0.50).
     Conjured Items only reflect one legendary item. Setting this value to 0.50 pulls the legendary curve off. This value was set to 1.00 to eliminate the modifier.
     These modifiers have been updated to reflect this.

-----------------------------------------------------------------------------------------------------------------------------------------------
  Updates:
   - v1.0 -> Script Created.
   - v1.1 -> (2025-12-02) Updated slot modifiers in ACSBV3_ref_slot.             (script: ACSBV3-05-01A.sql)
   - v1.2 -> (2025-12-02) Updated source_type modifiers in ACSBV3_ref_source.    (script: ACSBV3-05-01A.sql)
   - v1.3 -> (2025-12-02) Updated drop_environment modifiers in ACSBV3_ref_drop. (script: ACSBV3-05-01A.sql)
   - v1.4 -> (2025-12-02) Updated GoalMin from 0.90 to 0.95.
                          Updated GoalMax from 1.10 to 1.05.
   - v1.5 -> (2025-12-03) Updated slot modifiers in ACSBV3_ref_slot.             (script: ACSBV3-05-01A.sql)
                          Updated source_type modifiers in ACSBV3_ref_source.    (script: ACSBV3-05-01A.sql)
   - v1.6 -> (2025-12-03) Updated GoalMin from 0.95 to 0.97.
                          Updated GoalMax from 1.05 to 1.03.
   - v1.7 -> (2025-12-03) Updated drop_environment modifiers in ACSBV3_ref_drop. (script: ACSBV3-05-01A.sql)
                          Updated source_type modifiers in ACSBV3_ref_source.    (script: ACSBV3-05-01A.sql)
                          DID NOT - Updated slot modifiers in ACSBV3_ref_slot.   (script: ACSBV3-05-01A.sql)
   - v1.8 -> (2025-12-03) Updated slot modifiers in ACSBV3_ref_slot.             (script: ACSBV3-05-01A.sql)

   - v1.9 -> (2025-12-03) Reverted GoalMin from 0.97 to 0.90.
                          Reverted GoalMax from 1.03 to 1.10.
                          Reverted modifiers to v1.8 values.
                          Updated drop_environment and source_type modifiers.    (script: ACSBV3-05-01A.sql)

   - v2.0 -> (2025-12-03) Added mod_misc support.                                (script: ACSBV3-05-02B.sql)

=============================================================================================================================================*/



/*=============================================================================================================================================
  0.1 - Update MYSQL Collation for AzerothCore:
=============================================================================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';



/*=============================================================================================================================================
  0.2 - Set Script Variables:
=============================================================================================================================================*/

SET @SCRIPT  := "0502C",
    @VERSION := "2.0",

    @GoalMin := 0.90,
    @GoalMax := 1.10;



/*=============================================================================================================================================
  1. Global Report: Compares all items and curves into one report.
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "1. Global Report: Compares all items and curves into one report." );

CALL ACSBV3_generate_report ( 1, "Global" );



/*=============================================================================================================================================
  2. Quality Report: Compares all items within each quality curve.
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "2. Quality Report: Compares all items within each quality curve." );

CALL ACSBV3_generate_report ( 2, "Quality" );



/*=============================================================================================================================================
  3. ItemLevel Report: Compares all items of similar ItemLevel to all curves.
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "3. ItemLevel Report: Compares all items of similar ItemLevel to all curves." );

CALL ACSBV3_generate_report ( 3, "ItemLevel" );



/*=============================================================================================================================================
  4. Drop Report: Compares all items and curves, grouped by drop_environment.
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "4. Drop Report: Compares all items and curves, grouped by drop_environment." );

CALL ACSBV3_generate_report ( 4, "drop_environment" );



/*=============================================================================================================================================
  5. Source Report: Compares all items and curves, grouped by source_type.
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "5. Source Report: Compares all items and curves, grouped by source_type." );

CALL ACSBV3_generate_report ( 5, "source_type" );



/*=============================================================================================================================================
  6. Slot Report: Compares all items of similar class, subclass, and InventoryType to all curves.
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "6. Slot Report: Compares all items of similar class, subclass, and InventoryType to all curves." );

CALL ACSBV3_generate_report ( 6, "slot" );



/*=============================================================================================================================================
  7. Random Modifier Report: Compares all items mod_misc to all curves.
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "7. Random Modifier Report: Compares all items mod_misc to all curves." );

CALL ACSBV3_generate_report ( 7, "mod_misc" );



CALL ACSBV3_print_footer ();

/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
