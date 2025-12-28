/*============================================================================================
Filename:       ACSBV3-04-07A.sql
Title:          Phase 04 – Cleanup Script
Author:         ChatGPT + Aumuz Messick
Version:        1.0
Created:        2025-11-22
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS
  ACSBV3_ref_statcost_equipment,
  ACSBV3_ref_statcost_weapons,
  ACSBV3_ref_dropmod,
  ACSBV3_ref_map_environment,
  ACSBV3_ref_miscmod,
  ACSBV3_ref_slotmod_equipment,
  ACSBV3_ref_slotmod_weapons,

  ACSBV3_doc_chart_blizzard,

  ACSBV3_doc_armor,
  ACSBV3_doc_cost,
  ACSBV3_doc_curve,
  ACSBV3_doc_curve_bands,
  ACSBV3_doc_drop,
  ACSBV3_doc_item_template,
  ACSBV3_doc_slot_equipment,
  ACSBV3_doc_slot_weapons,
  ACSBV3_doc_socket,
  ACSBV3_doc_source,

  temp_curve,
  temp_ilvl,
  temp_index,
  temp_quality,
  temp_slot,

  ACSBV3_print_info,

  ACSBV3_0400Z_view_ilvl,
  ACSBV3_0400Z_view_index,
  ACSBV3_0400Z_view_quality,
  ACSBV3_0400Z_view_slot,
  ACSBV3_0401A_curve,
  ACSBV3_0402A_diagnostic_dataset,
  ACSBV3_0402A_diagnostic_dataset_main,
  ACSBV3_0402B_report,
  ACSBV3_0402_report,
  ACSBV3_0403_report,
  ACSBV3_0404A_master_chart,
  ACSBV3_0404B_chart_band,
  ACSBV3_0404B_quality_ratio,
  ACSBV3_0404B_region_ratio,
  ACSBV3_0404B_region_ratio_src,
  ACSBV3_0406A_armor_report,
  ACSBV3_0406A_drop_report,
  ACSBV3_0406A_slot_report,
  ACSBV3_0406A_source_report

/*============================================================================================*/
