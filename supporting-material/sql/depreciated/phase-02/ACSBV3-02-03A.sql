/*============================================================================================
Filename:       ACSBV3-02-03A.sql
Title:          Phase 02 – Cleanup Script
Author:         ChatGPT + Aumuz Messick
Version:        1.0
Created:        2025-10-24
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS
  ACSBV3_02_00A_budget_equipment,
  ACSBV3_02_00B_budget_normalized,
  ACSBV3_02_00C_budget_weighted,
  ACSBV3_02_01A_curve_unweighted,
  ACSBV3_02_01B_curve_weighted,
  ACSBV3_02_02A_testset_equipment,
  ACSBV3_02_02B_validation_results;

/*============================================================================================*/
