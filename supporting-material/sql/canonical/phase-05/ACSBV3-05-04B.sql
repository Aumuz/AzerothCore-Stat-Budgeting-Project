/*============================================================================================
Filename:       ACSBV3-05-04B.sql
Title:          Phase 05 – Cleanup Script
Author:         ChatGPT + Aumuz Messick
Version:        1.0
Created:        2025-12-04
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS

  ACSBV3_ref_items,
  ACSBV3_ref_map_environment,

  ACSBV3_0501C_curve,
  ACSBV3_0502B_report,
  ACSBV3_0503A_curve_bracket,
  ACSBV3_0503A_curve_master

/*============================================================================================*/
