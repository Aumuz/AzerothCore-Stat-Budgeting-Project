/*=============================================================================================================================================
  Filename:       ACSBV3-05-04A.sql
  Title:          Export Table: ACSBV3_ref_dataset.
  Author:         Aumuz Messick
  Version:        1.1
  Created:        2025-12-04
  Description:    Export Table: ACSBV3_ref_dataset.

-----------------------------------------------------------------------------------------------------------------------------------------------
  Updates:
   - v1.0 -> Script Created.
   - v1.1 -> (2025-12-08) Added "slot_group" and "slot_group_desc"

=============================================================================================================================================*/



/*=============================================================================================================================================
  0.1 - Update MYSQL Collation for AzerothCore:
=============================================================================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';



/*=============================================================================================================================================
  0.2 - Set Script Variables:
=============================================================================================================================================*/

SET @SCRIPT  := "0504A",
    @VERSION := "1.1";



/*=============================================================================================================================================
  1. Export: ACSBV3_ref_dataset
=============================================================================================================================================*/

SELECT

  'entry', 'entry', 'Quality', 'QualityName', 'ItemLevel', 'ItemLevelBracket', 'slot_group', 'slot_group_desc', 'slot', 'slot_name', 'class', 'class_name', 'subclass', 'subclass_name',
  'InventoryType', 'InventoryTypeName', 'RequiredLevel', 'RequiredLevelBracket', 'BuyPrice', 'SellPrice', 'weight', 'drop_environment', 'source_type',

  'stat_type1', 'stat_value1', 'stat_cost1', 'stat_total1', 'stat_type2', 'stat_value2', 'stat_cost2', 'stat_total2', 'stat_type3', 'stat_value3', 'stat_cost3', 'stat_total3', 'stat_type4', 'stat_value4', 'stat_cost4', 'stat_total4', 'stat_type5',  'stat_value5',  'stat_cost5',  'stat_total5',
  'stat_type6', 'stat_value6', 'stat_cost6', 'stat_total6', 'stat_type7', 'stat_value7', 'stat_cost7', 'stat_total7', 'stat_type8', 'stat_value8', 'stat_cost8', 'stat_total8', 'stat_type9', 'stat_value9', 'stat_cost9', 'stat_total9', 'stat_type10', 'stat_value10', 'stat_cost10', 'stat_total10',

  'stat_sum', 'dmg_min1', 'dmg_max1', 'delay', 'DPS', 'armor', 'armorCost', 'RandomProperty', 'RandomSuffix', 'socketBonus', 'socketCost',

  'budget_actual', 'mod_drop', 'mod_misc', 'mod_slot', 'mod_source', 'budget_normalized', 'budget_target_raw', 'budget_diff_raw', 'budget_perc_raw', 'budget_target_3pnt', 'budget_diff_3pnt', 'budget_perc_3pnt', 'budget_target_mono', 'budget_diff_mono', 'budget_perc_mono'

UNION ALL

SELECT * FROM ACSBV3_ref_dataset

INTO OUTFILE '/var/lib/mysql-files/ACSBV3_dataset.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n';



SELECT "Script Complete." AS ``;

/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
