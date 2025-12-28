/*=============================================================================================================================================
  Filename:       ACSBV3-04-00C.sql
  Title:          Remove Unwanted Items.
  Author:         Aumuz Messick
  Version:        2.4 (v1.0 does not exist)
  Created:        2025-11-06
  Description:    This script will remove unwanted items from ACSBV3_doc_item_template.
                  This script is new to the "Phase 04-00 to 04-03 Pipeline". Retaining v2.0 for consistency with other pipeline scripts.

                  The following items will be removed:

                   - 1. Remove Unknown Items: Remove items with "Unknown" tags.
                   - 2. Remove Bad Modifiers: Remove modifiers outside of expected parameters.
                   - 3. Remove Negative Stats: Remove any stat_value N with a negative value. Our model does not account for this behavior.
                   - 4. Remove Zero Budget Items: Remove items with a budget_actual value less than 0.20.
                   - 5. Remove Zero DPS: Remove weapon items with DPS value less than 1.00.
                   - 6. Remove Unavailable Items: Remove items unavailable to player, such as "%MONSTER%" items.

-----------------------------------------------------------------------------------------------------------------------------------------------
  Updates:
   - v2.0 -> Script Created.
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
    @LastCount := ( SELECT COUNT(*) FROM ACSBV3_doc_item_template ),    -- Last Row Count of ACSBV3_doc_item_template.

    @ModDrop0  := ( SELECT `multiplier` FROM ACSBV3_doc_drop WHERE `drop_environment` = "Dungeon" ),    -- drop_environment variable.
    @ModDrop1  := ( SELECT `multiplier` FROM ACSBV3_doc_drop WHERE `drop_environment` = "Raid" ),       -- drop_environment variable.
    @ModDrop2  := ( SELECT `multiplier` FROM ACSBV3_doc_drop WHERE `drop_environment` = "World" ),      -- drop_environment variable.

    @ModMisc0  := 0.65,    -- Has Random Property or Suffix.
    @ModMisc1  := 1.00;    -- Does not have Random Property or Suffix.



/*=============================================================================================================================================
  0.2 - Update Print Information Table: ACSBV3_print_info
=============================================================================================================================================*/

DELETE FROM ACSBV3_print_info WHERE `script` = "0400C";

INSERT INTO ACSBV3_print_info ( `script`, `part`, `print`, `output` ) VALUES
( "0400C", 2, 1, "##  1. Remove Unknown Items: Remove items with \"Unknown\" tags.                                                   (v2.4)  ##" ),
( "0400C", 2, 2, "##  2. Remove Unexpected Modifiers: Remove any modifiers with unexpected values.                                 (v2.4)  ##" ),
( "0400C", 2, 3, "##  3. Remove Negative Stats: Remove any stat_value N with a negative value.                                     (v2.4)  ##" ),
( "0400C", 2, 3, "##                             - Our model does not account for this behavior.                                           ##" ),
( "0400C", 2, 4, "##  4. Remove Zero Budget Items: Remove items with a budget_actual value less than 0.20.                         (v2.4)  ##" ),
( "0400C", 2, 5, "##  5. Remove Zero DPS: Remove weapon items with DPS value less than 1.00.                                       (v2.4)  ##" ),
( "0400C", 2, 6, "##  6. Remove Unavailable Items: Remove items unavailable to player, such as \"%MONSTER%\" items.                  (v2.4)  ##" ),
( "0400C", 2, 7, "##  7. Final Diagnostic Output:                                                                                  (v2.4)  ##" );



/*=============================================================================================================================================
  1. Remove Unknown Items: Remove items with "Unknown" tags.
=============================================================================================================================================*/

SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0400C" AND `print` = 1 ) ORDER BY `part`, `auto`;    -- Print Header



SELECT

  "Unknown Items: " AS `note`,

  @RowCount0 AS `ini_count`,
  @LastCount AS `last_count`,
  COUNT(*)   AS `current_count`,

  COUNT( CASE WHEN `drop_environment` = "Unknown" THEN 1 END ) AS `drop_environment`,    -- Expected: 0
  COUNT( CASE WHEN `source_type`      = "Unknown" THEN 1 END ) AS `source_type`,         -- Expected: 5
  COUNT( CASE WHEN `FamilyID`         = "Unknown" THEN 1 END ) AS `FamilyID`,            -- Expected: 0
  COUNT( CASE WHEN `SlotID`           = "Unknown" THEN 1 END ) AS `SlotID`,              -- Expected: 1
  COUNT( CASE WHEN `QualityName`      = "Unknown" THEN 1 END ) AS `QualityName`          -- Expected: 0

FROM ACSBV3_doc_item_template;



SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 8 ) ORDER BY `part`, `auto`;    -- Print 3-Line Break



SELECT `entry`, `name`, `drop_environment`, `source_type`, `FamilyID`, `SlotID`, `QualityName`
FROM ACSBV3_doc_item_template
WHERE `drop_environment` = "Unknown"
   OR `source_type`      = "Unknown"
   OR `FamilyID`         = "Unknown"
   OR `SlotID`           = "Unknown"
   OR `QualityName`      = "Unknown"
ORDER BY `entry`
LIMIT 6;



SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 8 ) ORDER BY `part`, `auto`;    -- Print 3-Line Break



DELETE FROM ACSBV3_doc_item_template
WHERE `drop_environment` = "Unknown"
   OR `source_type`      = "Unknown"
   OR `FamilyID`         = "Unknown"
   OR `SlotID`           = "Unknown"
   OR `QualityName`      = "Unknown";



SELECT

  "Unknown Items: " AS `note`,

  @RowCount0 AS `ini_count`,
  @LastCount AS `last_count`,
  COUNT(*)   AS `current_count`,

  COUNT( CASE WHEN `drop_environment` = "Unknown" THEN 1 END ) AS `drop_environment`,
  COUNT( CASE WHEN `source_type`      = "Unknown" THEN 1 END ) AS `source_type`,
  COUNT( CASE WHEN `FamilyID`         = "Unknown" THEN 1 END ) AS `FamilyID`,
  COUNT( CASE WHEN `SlotID`           = "Unknown" THEN 1 END ) AS `SlotID`,
  COUNT( CASE WHEN `QualityName`      = "Unknown" THEN 1 END ) AS `QualityName`,

  ( @LastCount - COUNT(*) ) AS `removed`,

  6 AS `expected`

FROM ACSBV3_doc_item_template;



SET @RowCount1 := ( SELECT COUNT(*) FROM ACSBV3_doc_item_template ),    -- Step 1. Row Count of ACSBV3_doc_item_template.
    @LastCount := ( SELECT COUNT(*) FROM ACSBV3_doc_item_template );    -- Update Last Row Count of ACSBV3_doc_item_template.



/*=============================================================================================================================================
  2. Remove Unexpected Modifiers: Remove any modifiers with unexpected values.
=============================================================================================================================================*/

SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0400C" AND `print` = 2 ) ORDER BY `part`, `auto`;    -- Print Header



SELECT

  "Unexpected Modifiers: " AS `note`,

  @RowCount0 AS `ini_count`,
  @LastCount AS `last_count`,
  COUNT(*)   AS `current_count`,

  COUNT( CASE WHEN `mod_drop` <> @ModDrop0
               AND `mod_drop` <> @ModDrop1
               AND `mod_drop` <> @ModDrop2
         THEN 1 END ) AS `mod_drop`,                               -- Expected: 0

  COUNT( CASE WHEN `mod_misc` <> @ModMisc0
               AND `mod_misc` <> @ModMisc1
         THEN 1 END ) AS `mod_misc`,                               -- Expected: 0

  COUNT( CASE WHEN `mod_slot` = 0.00 THEN 1 END ) AS `mod_slot`    -- Expected: 0`

FROM ACSBV3_doc_item_template;



SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 8 ) ORDER BY `part`, `auto`;    -- Print 3-Line Break



SELECT `entry`, `name`, `mod_drop`, `mod_misc`, `mod_slot`
FROM ACSBV3_doc_item_template
WHERE (`mod_drop` <> @ModDrop0 AND `mod_drop` <> @ModDrop1 AND `mod_drop` <> @ModDrop2)
   OR (`mod_misc` <> @ModMisc0 AND `mod_misc` <> @ModMisc1)
   OR (`mod_slot` = 0.00)
ORDER BY `entry`
LIMIT 5;



SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 8 ) ORDER BY `part`, `auto`;    -- Print 3-Line Break



DELETE FROM ACSBV3_doc_item_template
WHERE (`mod_drop` <> @ModDrop0 AND `mod_drop` <> @ModDrop1 AND `mod_drop` <> @ModDrop2)
   OR (`mod_misc` <> @ModMisc0 AND `mod_misc` <> @ModMisc1)
   OR (`mod_slot` = 0.00);



SELECT

  "Unexpected Modifiers: " AS `note`,

  @RowCount0 AS `ini_count`,
  @LastCount AS `last_count`,
  COUNT(*)   AS `current_count`,

  COUNT( CASE WHEN `mod_drop` <> @ModDrop0
               AND `mod_drop` <> @ModDrop1
               AND `mod_drop` <> @ModDrop2
         THEN 1 END ) AS `mod_drop`,

  COUNT( CASE WHEN `mod_misc` <> @ModMisc0
               AND `mod_misc` <> @ModMisc1
         THEN 1 END ) AS `mod_misc`,

  COUNT( CASE WHEN `mod_slot` = 0.00 THEN 1 END ) AS `mod_slot`,

  ( @LastCount - COUNT(*) ) AS `removed`,

  0 AS `expected`

FROM ACSBV3_doc_item_template;



SET @RowCount2 := ( SELECT COUNT(*) FROM ACSBV3_doc_item_template ),    -- Step 2. Row Count of ACSBV3_doc_item_template.
    @LastCount := ( SELECT COUNT(*) FROM ACSBV3_doc_item_template );    -- Update Last Row Count of ACSBV3_doc_item_template.



/*=============================================================================================================================================
  3. Remove Negative Stats: Remove any stat_value N with a negative value. Our model does not account for this behavior.
=============================================================================================================================================*/

SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0400C" AND `print` = 3 ) ORDER BY `part`, `auto`;    -- Print Header



SELECT

  "Negative Stats: " AS `note`,

  @RowCount0 AS `ini_count`,
  @LastCount AS `last_count`,
  COUNT(*)   AS `current_count`,

  COUNT( CASE WHEN LEAST ( `stat_value1`, `stat_value2`, `stat_value3`, `stat_value4`, `stat_value5`,
                           `stat_value6`, `stat_value7`, `stat_value8`, `stat_value9`, `stat_value10` ) < 0
         THEN 1 END ) AS `negative_stats`    -- Expected: 15

FROM ACSBV3_doc_item_template;



SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 8 ) ORDER BY `part`, `auto`;    -- Print 3-Line Break



SELECT `entry`, `name`, `stat_value1`, `stat_value2`, `stat_value3`, `stat_value4`, `stat_value5`,
                        `stat_value6`, `stat_value7`, `stat_value8`, `stat_value9`, `stat_value10`
FROM ACSBV3_doc_item_template
WHERE LEAST ( `stat_value1`, `stat_value2`, `stat_value3`, `stat_value4`, `stat_value5`,
              `stat_value6`, `stat_value7`, `stat_value8`, `stat_value9`, `stat_value10` ) < 0
ORDER BY `entry`
LIMIT 15;



SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 8 ) ORDER BY `part`, `auto`;    -- Print 3-Line Break



DELETE FROM ACSBV3_doc_item_template
WHERE LEAST ( `stat_value1`, `stat_value2`, `stat_value3`, `stat_value4`, `stat_value5`,
              `stat_value6`, `stat_value7`, `stat_value8`, `stat_value9`, `stat_value10` ) < 0;



SELECT

  "Negative Stats: " AS `note`,

  @RowCount0 AS `ini_count`,
  @LastCount AS `last_count`,
  COUNT(*)   AS `current_count`,

  COUNT( CASE WHEN LEAST ( `stat_value1`, `stat_value2`, `stat_value3`, `stat_value4`, `stat_value5`,
                           `stat_value6`, `stat_value7`, `stat_value8`, `stat_value9`, `stat_value10` ) < 0
         THEN 1 END ) AS `negative_stats`,

  ( @LastCount - COUNT(*) ) AS `removed`,

  15 AS `expected`

FROM ACSBV3_doc_item_template;



SET @RowCount3 := ( SELECT COUNT(*) FROM ACSBV3_doc_item_template ),    -- Step 3. Row Count of ACSBV3_doc_item_template.
    @LastCount := ( SELECT COUNT(*) FROM ACSBV3_doc_item_template );    -- Update Last Row Count of ACSBV3_doc_item_template.



/*=============================================================================================================================================
  4. Remove Zero Budget Items: Remove items with a budget_actual value less than 0.20.
=============================================================================================================================================*/

SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0400C" AND `print` = 4 ) ORDER BY `part`, `auto`;    -- Print Header



SELECT

  "Zero Budget Items: " AS `note`,

  @RowCount0 AS `ini_count`,
  @LastCount AS `last_count`,
  COUNT(*)   AS `current_count`,

  COUNT( CASE WHEN `budget_actual` < 0.20 THEN 1 END ) AS `budget_actual`    -- Expected: 339

FROM ACSBV3_doc_item_template;



SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 8 ) ORDER BY `part`, `auto`;    -- Print 3-Line Break



SELECT `entry`, `name`, `armor`, `socketBonus`, `stat_value1`, `stat_value2`, `stat_value3`, `stat_value4`, `stat_value5`,
                                                `stat_value6`, `stat_value7`, `stat_value8`, `stat_value9`, `stat_value10`, `budget_actual`
FROM ACSBV3_doc_item_template
WHERE `budget_actual` < 0.20
ORDER BY RAND()
LIMIT 5;



SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 8 ) ORDER BY `part`, `auto`;    -- Print 3-Line Break



DELETE FROM ACSBV3_doc_item_template
WHERE `budget_actual` < 0.20;



SELECT

  "Zero Budget Items: " AS `note`,

  @RowCount0 AS `ini_count`,
  @LastCount AS `last_count`,
  COUNT(*)   AS `current_count`,

  COUNT( CASE WHEN `budget_actual` < 0.20 THEN 1 END ) AS `budget_actual`,

  ( @LastCount - COUNT(*) ) AS `removed`,

  339 AS `expected`

FROM ACSBV3_doc_item_template;



SET @RowCount4 := ( SELECT COUNT(*) FROM ACSBV3_doc_item_template ),    -- Step 4. Row Count of ACSBV3_doc_item_template.
    @LastCount := ( SELECT COUNT(*) FROM ACSBV3_doc_item_template );    -- Update Last Row Count of ACSBV3_doc_item_template.



/*=============================================================================================================================================
  5. Remove Zero DPS: Remove weapon items with DPS value less than 1.00.
=============================================================================================================================================*/

SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0400C" AND `print` = 5 ) ORDER BY `part`, `auto`;    -- Print Header



SELECT

  "Zero DPS Items: " AS `note`,

  @RowCount0 AS `ini_count`,
  @LastCount AS `last_count`,
  COUNT(*)   AS `current_count`,

  COUNT( CASE WHEN `class` = 2 AND `DPS` < 1.00 THEN 1 END ) AS `DPS`    -- Expected: 56

FROM ACSBV3_doc_item_template;



SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 8 ) ORDER BY `part`, `auto`;    -- Print 3-Line Break



SELECT `entry`, `name`, `armor`, `dmg_min1`, `dmg_max1`, `delay`, `DPS`
FROM ACSBV3_doc_item_template
WHERE `class` = 2 AND `DPS` < 1.00
ORDER BY RAND()
LIMIT 5;



SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 8 ) ORDER BY `part`, `auto`;    -- Print 3-Line Break



DELETE FROM ACSBV3_doc_item_template
WHERE `class` = 2 AND `DPS` < 1.00;



SELECT

  "Zero DPS Items: " AS `note`,

  @RowCount0 AS `ini_count`,
  @LastCount AS `last_count`,
  COUNT(*)   AS `current_count`,

  COUNT( CASE WHEN `class` = 2 AND `DPS` < 1.00 THEN 1 END ) AS `DPS`,

  ( @LastCount - COUNT(*) ) AS `removed`,

  56 AS `expected`

FROM ACSBV3_doc_item_template;



SET @RowCount5 := ( SELECT COUNT(*) FROM ACSBV3_doc_item_template ),    -- Step 5. Row Count of ACSBV3_doc_item_template.
    @LastCount := ( SELECT COUNT(*) FROM ACSBV3_doc_item_template );    -- Update Last Row Count of ACSBV3_doc_item_template.



/*=============================================================================================================================================
  6. Remove Unavailable Items: Remove items unavailable to player, such as "%MONSTER%" items.
=============================================================================================================================================*/

SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0400C" AND `print` = 6 ) ORDER BY `part`, `auto`;    -- Print Header



SELECT

  "Unavailable Items: " AS `note`,

  @RowCount0 AS `ini_count`,
  @LastCount AS `last_count`,
  COUNT(*)   AS `current_count`,

  COUNT( CASE WHEN `name` LIKE "%MONSTER%" THEN 1 END ) AS `monster`    -- Expected: 1

FROM ACSBV3_doc_item_template;



SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 8 ) ORDER BY `part`, `auto`;    -- Print 3-Line Break



SELECT `entry`, `name`
FROM ACSBV3_doc_item_template
WHERE `name` LIKE "%MONSTER%"
ORDER BY `entry`
LIMIT 5;



SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 8 ) ORDER BY `part`, `auto`;    -- Print 3-Line Break



DELETE FROM ACSBV3_doc_item_template
WHERE `name` LIKE "%MONSTER%";



SELECT

  "Unavailable Items: " AS `note`,

  @RowCount0 AS `ini_count`,
  @LastCount AS `last_count`,
  COUNT(*)   AS `current_count`,

  COUNT( CASE WHEN `name` LIKE "%MONSTER%" THEN 1 END ) AS `monster`,

  ( @LastCount - COUNT(*) ) AS `removed`,

  1 AS `expected`

FROM ACSBV3_doc_item_template;



SET @RowCount6 := ( SELECT COUNT(*) FROM ACSBV3_doc_item_template ),    -- Step 6. Row Count of ACSBV3_doc_item_template.
    @LastCount := ( SELECT COUNT(*) FROM ACSBV3_doc_item_template );    -- Update Last Row Count of ACSBV3_doc_item_template.



/*=============================================================================================================================================
  7. Final Diagnostic Output:
=============================================================================================================================================*/

SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` = 1 OR `part` = 7 )
                                                OR ( `script` = "0400C" AND `print` = 7 ) ORDER BY `part`, `auto`;    -- Print Header



SELECT

  "Final Count: " AS `note`,

  @RowCount0 AS `ini_count`,
  COUNT(*)   AS `final_count`,

  ( @RowCount0 - @RowCount1 ) AS `unknown`,        -- Expected: 6
  ( @RowCount1 - @RowCount2 ) AS `mod`,            -- Expected: 0
  ( @RowCount2 - @RowCount3 ) AS `negative`,       -- Expected: 15
  ( @RowCount3 - @RowCount4 ) AS `zero`,           -- Expected: 339
  ( @RowCount4 - @RowCount5 ) AS `zero`,           -- Expected: 56
  ( @RowCount5 - @RowCount6 ) AS `unavailable`,    -- Expected: 1

  ( @RowCount0 - COUNT(*) ) AS `total_removed`,

  (6+0+15+339+56+1) AS `expected`

FROM ACSBV3_doc_item_template;



SELECT `output` AS `` FROM ACSBV3_print_info WHERE ( `part` >= 8 ) ORDER BY `part`, `auto`;    -- Print Footer



/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
