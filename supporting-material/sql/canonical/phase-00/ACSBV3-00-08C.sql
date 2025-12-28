/*============================================================================================
Filename:       ACSBV3-00-08C.sql
Title:          Remove Unwanted Items
Author:         Aumuz Messick
Version:        1.0
Created:        2025-11-28
============================================================================================*/

-- 0. Initial Row Count: ACSBV3_ref_items

SET @Count0 := ( SELECT COUNT(*) FROM ACSBV3_ref_items );

SELECT CONCAT ( LPAD ( COUNT(*), 5, " " ), " - Total     Items in ACSBV3_ref_items." ) AS `` FROM ACSBV3_ref_items                   UNION ALL
SELECT CONCAT ( LPAD ( COUNT(*), 5, " " ), " - Weapon    Items in ACSBV3_ref_items." ) AS `` FROM ACSBV3_ref_items WHERE `class` = 2 UNION ALL
SELECT CONCAT ( LPAD ( COUNT(*), 5, " " ), " - Equipment Items in ACSBV3_ref_items." ) AS `` FROM ACSBV3_ref_items WHERE `class` = 4;



-- 1. Remove Items Missed in 00-00A Global Filter: Expected - 7

DELETE FROM ACSBV3_ref_items
WHERE `name` LIKE "%MONSTER%";    -- Monster Items  (8)

DELETE FROM ACSBV3_ref_items
WHERE `class`    =  2
  AND `subclass` = 11;            -- Exotic Weapons (1)

SET @Count1 := ( SELECT COUNT(*) FROM ACSBV3_ref_items );

SELECT "1. Remove Items Missed in 00-00A Global Filter: Expected - 7" AS `` UNION ALL
SELECT CONCAT ( ( @Count0 - @Count1 ), " Items Removed." ) AS ``;



-- 2. Remove Impossible or Unwanted Slot Combinations: Expected - 3

DELETE FROM ACSBV3_ref_items
WHERE `class`         =  2
  AND `subclass`      =  1
  AND `InventoryType` = 13;    -- 2H Axe,  1 Hand     (1)

DELETE FROM ACSBV3_ref_items
WHERE `class`         =  2
  AND `subclass`      =  6
  AND `InventoryType` = 13;    -- Polearm, 1 Hand     (1)

DELETE FROM ACSBV3_ref_items
WHERE `class`         =  2
  AND `subclass`      = 11
  AND `InventoryType` = 21;    -- Exotic,  Main Hand  (0 - removed in previous step)

DELETE FROM ACSBV3_ref_items
WHERE `class`         =  4
  AND `subclass`      =  0
  AND `InventoryType` =  1;    -- Misc,    Head       (1)

SET @Count2 := ( SELECT COUNT(*) FROM ACSBV3_ref_items );

SELECT "2. Remove Impossible or Unwanted Slot Combinations: Expected - 3" AS `` UNION ALL
SELECT CONCAT ( ( @Count1 - @Count2 ), " Items Removed." ) AS ``;



-- 3. Remove Unknown Items: Expected - 5

DELETE FROM ACSBV3_ref_items
WHERE `drop_environment` = "Unknown"
   OR `source_type`      = "Unknown";

SET @Count3 := ( SELECT COUNT(*) FROM ACSBV3_ref_items );

SELECT "3. Remove Unknown Items: Expected - 5" AS `` UNION ALL
SELECT CONCAT ( ( @Count2 - @Count3 ), " Items Removed." ) AS ``;



-- 4. Remove Negative Stats: Expected - 15 (our model does not account for this behavior)

DELETE FROM ACSBV3_ref_items
WHERE LEAST ( `stat_value1`, `stat_value2`, `stat_value3`, `stat_value4`, `stat_value5`,
              `stat_value6`, `stat_value7`, `stat_value8`, `stat_value9`, `stat_value10` ) < 0;

SET @Count4 := ( SELECT COUNT(*) FROM ACSBV3_ref_items );

SELECT "4. Remove Negative Stats: Expected - 15 (our model does not account for this behavior)" AS `` UNION ALL
SELECT CONCAT ( ( @Count3 - @Count4 ), " Items Removed." ) AS ``;



-- 5. Remove Zero Budget Items: Expected - 335

DELETE FROM ACSBV3_ref_items
WHERE `dmg_min1`    = 0
  AND `dmg_max1`    = 0
  AND `armor`       = 0
  AND `socketBonus` = 0
  AND GREATEST ( `stat_value1`, `stat_value2`, `stat_value3`, `stat_value4`, `stat_value5`,
                 `stat_value6`, `stat_value7`, `stat_value8`, `stat_value9`, `stat_value10` ) = 0;

SET @Count5 := ( SELECT COUNT(*) FROM ACSBV3_ref_items );

SELECT "5. Remove Zero Budget Items: Expected - 335" AS `` UNION ALL
SELECT CONCAT ( ( @Count4 - @Count5 ), " Items Removed." ) AS ``;



-- 6. Remove Zero DPS Weapons: Expected - 48 (our model does account for this behavior, however these items are typically noise)

DELETE FROM ACSBV3_ref_items
WHERE `class`    = 2
  AND `dmg_min1` = 0
  AND `dmg_max1` = 0;

SET @Count6 := ( SELECT COUNT(*) FROM ACSBV3_ref_items );

SELECT "6. Remove Zero DPS Weapons: Expected - 48 (our model does account for this behavior, however these items are typically noise)" AS `` UNION ALL
SELECT CONCAT ( ( @Count5 - @Count6 ), " Items Removed." ) AS ``;



-- 7. Final Row Count:

SELECT "  +-----------------------------------------------------------+  "                                                                                                                    AS `` UNION ALL
SELECT "  |              Initial Count - Items Removed = Final Count  |  "                                                                                                                    AS `` UNION ALL
SELECT "  +----------------------------+---------------+--------------+  "                                                                                                                    AS `` UNION ALL
SELECT CONCAT ( "  |  Expected:   ", LPAD (   18731, 13, " " ), " | ", LPAD (                   413, 13, " " ), " | ", LPAD (   18318, 11, " " ), "  |  " )                                   AS `` UNION ALL
SELECT CONCAT ( "  |  Actual:     ", LPAD ( @Count0, 13, " " ), " | ", LPAD ( ( @Count0 - @Count6 ), 13, " " ), " | ", LPAD ( @Count6, 11, " " ), "  |  " )                                   AS `` UNION ALL
SELECT "  +----------------------------+---------------+--------------+  "                                                                                                                    AS `` UNION ALL
SELECT CONCAT ( "  |  Difference: ", LPAD ( ( @Count0 - 18731 ), 13, " " ), " | ", LPAD ( ( ( @Count0 - @Count6 ) - 413 ), 13, " " ), " | ", LPAD ( ( @Count6 - 18318 ), 11, " " ), "  |  " ) AS `` UNION ALL
SELECT "  +----------------------------+---------------+--------------+  "                                                                                                                    AS `` UNION ALL

SELECT CONCAT ( LPAD ( COUNT(*), 5, " " ), " - Total     Items in ACSBV3_ref_items." ) AS `` FROM ACSBV3_ref_items                   UNION ALL
SELECT CONCAT ( LPAD ( COUNT(*), 5, " " ), " - Weapon    Items in ACSBV3_ref_items." ) AS `` FROM ACSBV3_ref_items WHERE `class` = 2 UNION ALL
SELECT CONCAT ( LPAD ( COUNT(*), 5, " " ), " - Equipment Items in ACSBV3_ref_items." ) AS `` FROM ACSBV3_ref_items WHERE `class` = 4;
