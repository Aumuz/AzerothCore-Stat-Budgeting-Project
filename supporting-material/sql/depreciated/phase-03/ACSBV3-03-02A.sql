/*============================================================================================
Filename:       ACSBV3-03-02A.sql
Title:          Phase 03 – Cleanup Script
Author:         ChatGPT + Aumuz Messick
Version:        1.0
Created:        2025-10-25
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS
  ACSBV3_03_00A_curve_raw,
  ACSBV3_03_00B_curve_export,
  ACSBV3_ref_statcost_equipment,
  ACSBV3_ref_statcost_weapons,
  ACSBV3_ref_dropmod,
  ACSBV3_ref_map_environment,
  ACSBV3_ref_miscmod,
  ACSBV3_ref_slotmod_equipment,
  ACSBV3_ref_slotmod_weapons;

/*============================================================================================*/
