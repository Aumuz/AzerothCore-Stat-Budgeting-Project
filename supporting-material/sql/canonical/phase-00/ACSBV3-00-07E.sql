/*============================================================================================
Filename:       ACSBV3-00-07E.sql
Title:          Phase 00 – Cleanup Script
Author:         ChatGPT + Aumuz Messick
Version:        1.1
Created:        2025-10-20
Description:    v1.1 updated ACSBV3_00_07D_reference_items to ACSBV3_ref_items.
                Removes all intermediate Phase 00 tables, leaving only the final
                reference dataset (ACSBV3_00_07D_reference_items).
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS
  ACSBV3_00_00A_raw_items,
  ACSBV3_00_01A_creature_src,
  ACSBV3_00_01B_weighted_creature,
  ACSBV3_00_02A_gameobject_src,
  ACSBV3_00_02B_weighted_gameobject,
  ACSBV3_00_03A_itemloot_src,
  ACSBV3_00_03B_weighted_itemloot,
  ACSBV3_00_04A_vendor_src,
  ACSBV3_00_04B_weighted_vendor,
  ACSBV3_00_05A_quest_src,
  ACSBV3_00_05B_weighted_quest,
  ACSBV3_00_06A_crafted_src,
  ACSBV3_00_06B_weighted_crafted,
  ACSBV3_00_07A_all_sources,
  ACSBV3_00_07B_reduced_items,
  ACSBV3_00_07C_master_dataset,
  ACSBV3_00_07D_reference_items;

-- Verify final table exists
SHOW TABLES LIKE 'ACSBV3_ref_items';
SHOW TABLES LIKE 'ACSBV3_ref_map_environment';
/*============================================================================================*/
