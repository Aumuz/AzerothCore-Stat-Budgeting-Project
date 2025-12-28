/*============================================================================================
Filename:       ACSBV3-06-05A.sql
Title:          Phase 06 – Cleanup Script
Author:         ChatGPT + Aumuz Messick
Version:        1.0
Created:        2025-12-19
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS

  ACSBV3_ref_items,
  ACSBV3_ref_map_environment,

  ACSBV3_0600A_dataset,
  ACSBV3_0600A_itemlevel,
  ACSBV3_0600A_quality,
  ACSBV3_0600A_recommend,
  ACSBV3_0600A_dps_curve,
  ACSBV3_0600A_armor_curve,
  ACSBV3_0600B_dps_curve,
  ACSBV3_0600C_armor_curve,

  ACSBV3_0601A_curve,
  ACSBV3_0601A_itemlevel,
  ACSBV3_0601A_quality,
  ACSBV3_0601B_curve,
  ACSBV3_0601B_itemlevel,
  ACSBV3_0601B_quality,
  ACSBV3_0601B_recommend,
  ACSBV3_0601C_curve,
  ACSBV3_0601D_curve,

  ACSBV3_0602A_curve,
  ACSBV3_0602B_curve,
  ACSBV3_0602C_curve,
  ACSBV3_0602C_dps_curve,
  ACSBV3_0602D_curve,
  ACSBV3_0602E_curve,
  ACSBV3_0602F_10,
  ACSBV3_0602F_11,
  ACSBV3_0602F_12,
  ACSBV3_0602F_13,
  ACSBV3_0602F_14,
  ACSBV3_0602F_20,
  ACSBV3_0602F_21,
  ACSBV3_0602F_22,
  ACSBV3_0602F_23,
  ACSBV3_0602F_24,
  ACSBV3_0602F_30,
  ACSBV3_0602F_31,
  ACSBV3_0602F_32,
  ACSBV3_0602F_33,
  ACSBV3_0602F_34,
  ACSBV3_0602F_40,
  ACSBV3_0602F_41,
  ACSBV3_0602F_42,
  ACSBV3_0602F_43,
  ACSBV3_0602F_44,
  ACSBV3_0602F_50,
  ACSBV3_0602F_51,
  ACSBV3_0602F_52,
  ACSBV3_0602F_53,
  ACSBV3_0602F_54,
  ACSBV3_0602F_60,
  ACSBV3_0602F_61,
  ACSBV3_0602F_62,
  ACSBV3_0602F_63,
  ACSBV3_0602F_64,

  ACSBV3_0603A_stats_long,
  ACSBV3_0603B_stats_budgeted,
  ACSBV3_0603B_stats_categorized,
  ACSBV3_0603C_stat_totals,
  ACSBV3_0603C_stats_totals,
  ACSBV3_0603D_stat_sum,
  ACSBV3_0603D_stats_sum,

  ACSBV3_0604A_slot,
  ACSBV3_0604A_stat

/*============================================================================================*/
