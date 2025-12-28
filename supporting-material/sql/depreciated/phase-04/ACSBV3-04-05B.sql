/*=============================================================================================================================================
  Filename:       ACSBV3-04-05B.sql
  Title:          Export Table: ACSBV3_doc_item_template.
  Author:         Aumuz Messick
  Version:        1.0
  Created:        2025-11-22
  Description:    This script will prepare and export table: ACSBV3_doc_item_template

-----------------------------------------------------------------------------------------------------------------------------------------------
  Updates:
   - v1.0 -> Script Created.

=============================================================================================================================================*/


SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';


/*=============================================================================================================================================
  1. Update: ACSBV3_doc_item_template FROM ACSBV3_0402A_diagnostic_dataset
=============================================================================================================================================*/

SELECT "The script is processing. Please wait..." AS `` UNION ALL SELECT "" AS ``;



UPDATE ACSBV3_doc_item_template AS i
JOIN ACSBV3_0402A_diagnostic_dataset AS d ON i.`entry` = d.`entry`
SET

  i.`budget_target1` = d.`budget_target1`, i.`budget_diff1` = d.`budget_diff1`, i.`budget_perc1` = d.`budget_perc1`,
  i.`budget_target2` = d.`budget_target2`, i.`budget_diff2` = d.`budget_diff2`, i.`budget_perc2` = d.`budget_perc2`,
  i.`budget_target3` = d.`budget_target3`, i.`budget_diff3` = d.`budget_diff3`, i.`budget_perc3` = d.`budget_perc3`

WHERE d.`CurveName` IN ( "Q1", "Q2", "Q3", "Q4C", "Q5" );

SELECT

  `budget_target1`, `budget_diff1`, `budget_perc1`,
  `budget_target2`, `budget_diff2`, `budget_perc2`,
  `budget_target3`, `budget_diff3`, `budget_perc3`

FROM ACSBV3_doc_item_template
ORDER BY RAND()
LIMIT 10;



/*=============================================================================================================================================
  2. Export: ACSBV3_doc_item_template
=============================================================================================================================================*/

SELECT

  'entry', 'name', 'class', 'subclass', 'Quality', 'BuyPrice', 'SellPrice', 'InventoryType', 'ItemLevel', 'RequiredLevel',
  'drop_environment', 'source_type', 'FamilyID', 'SlotID', 'QualityName',
  'stat_type1', 'stat_value1', 'stat_cost1', 'stat_total1', 'stat_type2', 'stat_value2', 'stat_cost2', 'stat_total2', 'stat_type3', 'stat_value3', 'stat_cost3', 'stat_total3', 'stat_type4', 'stat_value4', 'stat_cost4', 'stat_total4', 'stat_type5',  'stat_value5',  'stat_cost5',  'stat_total5',
  'stat_type6', 'stat_value6', 'stat_cost6', 'stat_total6', 'stat_type7', 'stat_value7', 'stat_cost7', 'stat_total7', 'stat_type8', 'stat_value8', 'stat_cost8', 'stat_total8', 'stat_type9', 'stat_value9', 'stat_cost9', 'stat_total9', 'stat_type10', 'stat_value10', 'stat_cost10', 'stat_total10', 'stat_sum',
  'dmg_min1', 'dmg_max1', 'delay', 'DPS', 'armor', 'armorCost', 'RandomProperty', 'RandomSuffix', 'socketBonus', 'socketCost',
  'budget_actual', 'mod_drop', 'mod_source', 'mod_misc', 'mod_slot', 'budget_normalized',
  'budget_target1', 'budget_diff1', 'budget_perc1', 'budget_target2', 'budget_diff2', 'budget_perc2', 'budget_target3', 'budget_diff3', 'budget_perc3'

UNION ALL

SELECT

  `entry`, `name`, `class`, `subclass`, `Quality`, `BuyPrice`, `SellPrice`, `InventoryType`, `ItemLevel`, `RequiredLevel`,
  `drop_environment`, `source_type`, `FamilyID`, `SlotID`, `QualityName`,
  `stat_type1`, `stat_value1`, `stat_cost1`, `stat_total1`, `stat_type2`, `stat_value2`, `stat_cost2`, `stat_total2`, `stat_type3`, `stat_value3`, `stat_cost3`, `stat_total3`, `stat_type4`, `stat_value4`, `stat_cost4`, `stat_total4`, `stat_type5`,  `stat_value5`,  `stat_cost5`,  `stat_total5`,
  `stat_type6`, `stat_value6`, `stat_cost6`, `stat_total6`, `stat_type7`, `stat_value7`, `stat_cost7`, `stat_total7`, `stat_type8`, `stat_value8`, `stat_cost8`, `stat_total8`, `stat_type9`, `stat_value9`, `stat_cost9`, `stat_total9`, `stat_type10`, `stat_value10`, `stat_cost10`, `stat_total10`, `stat_sum`,
  `dmg_min1`, `dmg_max1`, `delay`, `DPS`, `armor`, `armorCost`, `RandomProperty`, `RandomSuffix`, `socketBonus`, `socketCost`,
  `budget_actual`, `mod_drop`, `mod_source`, `mod_misc`, `mod_slot`, `budget_normalized`,
  `budget_target1`, `budget_diff1`, `budget_perc1`, `budget_target2`, `budget_diff2`, `budget_perc2`, `budget_target3`, `budget_diff3`, `budget_perc3`

FROM ACSBV3_doc_item_template
INTO OUTFILE '/var/lib/mysql-files/ACSBV3_dataset.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n';



SELECT "Script Complete." AS ``;



/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
