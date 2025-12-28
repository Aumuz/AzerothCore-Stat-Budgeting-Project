/*=============================================================================================================================================
  Filename:       ACSBV3-06-03A.sql
  Title:          Create Stat Distribution Table
  Author:         ChatGPT
  Version:        1.0
  Created:        2025-12-12
  Description:    This script will create a stat distribution table.

-----------------------------------------------------------------------------------------------------------------------------------------------
  Updates:
   - v1.0 -> Script Created.

=============================================================================================================================================*/



/*=============================================================================================================================================
  0.1 - Update MYSQL Collation for AzerothCore:
=============================================================================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';



/*=============================================================================================================================================
  0.2 - Set Script Variables:
=============================================================================================================================================*/

SET @SCRIPT  := "0603A",
    @VERSION := "1.0";



/*=============================================================================================================================================
  1. Unpivot stats (canonical approach)
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "1. Unpivot stats (canonical approach)" );



DROP TABLE IF EXISTS ACSBV3_0603A_stats_long;

CREATE TABLE ACSBV3_0603A_stats_long AS

SELECT
  d.entry,
  d.slot_group,
  d.ItemLevelBracket,
  s.stat_type,
  s.stat_value
FROM ACSBV3_ref_dataset d
JOIN (

  SELECT entry, stat_type1  AS stat_type, stat_value1  AS stat_value FROM ACSBV3_ref_dataset
  UNION ALL
  SELECT entry, stat_type2, stat_value2 FROM ACSBV3_ref_dataset
  UNION ALL
  SELECT entry, stat_type3, stat_value3 FROM ACSBV3_ref_dataset
  UNION ALL
  SELECT entry, stat_type4, stat_value4 FROM ACSBV3_ref_dataset
  UNION ALL
  SELECT entry, stat_type5, stat_value5 FROM ACSBV3_ref_dataset
  UNION ALL
  SELECT entry, stat_type6, stat_value6 FROM ACSBV3_ref_dataset
  UNION ALL
  SELECT entry, stat_type7, stat_value7 FROM ACSBV3_ref_dataset
  UNION ALL
  SELECT entry, stat_type8, stat_value8 FROM ACSBV3_ref_dataset
  UNION ALL
  SELECT entry, stat_type9, stat_value9 FROM ACSBV3_ref_dataset
  UNION ALL
  SELECT entry, stat_type10, stat_value10 FROM ACSBV3_ref_dataset

) s
  ON s.entry = d.entry
WHERE s.stat_value > 0;



SELECT COUNT(*) FROM ACSBV3_0603A_stats_long;



/*=============================================================================================================================================
  2. Attach cost and compute stat budget
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "2. Attach cost and compute stat budget" );



DROP TABLE IF EXISTS ACSBV3_0603B_stats_budgeted;

CREATE TABLE ACSBV3_0603B_stats_budgeted AS
SELECT
  l.slot_group,
  l.ItemLevelBracket,
  l.stat_type,
  l.stat_value,
  c.cost,
  (l.stat_value * c.cost) AS stat_budget
FROM ACSBV3_0603A_stats_long l
JOIN ACSBV3_ref_cost c
  ON c.stat_type = l.stat_type
WHERE c.cost > 0;



SELECT COUNT(*) FROM ACSBV3_0603B_stats_budgeted;



/*=============================================================================================================================================
  3. Apply stat categories (CASE mapping)
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "3. Apply stat categories (CASE mapping)" );



DROP TABLE IF EXISTS ACSBV3_0603B_stats_categorized;

CREATE TABLE ACSBV3_0603B_stats_categorized AS
SELECT
  slot_group,
  ItemLevelBracket,
  CASE
    WHEN stat_type = 7 THEN 'Stamina'
    WHEN stat_type IN (3,4,5,6) THEN 'Primary'
    WHEN stat_type IN (38,39,42,45) THEN 'Power'
    WHEN stat_type IN (12,13,14,15,31,32,35,36,37,44) THEN 'Rating'
    ELSE NULL
  END AS stat_category,
  stat_budget
FROM ACSBV3_0603B_stats_budgeted
WHERE stat_budget > 0;



SELECT COUNT(*) FROM ACSBV3_0603B_stats_categorized;



/*=============================================================================================================================================
  4. Aggregate per slot_group
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "4. Aggregate per slot_group" );



DROP TABLE IF EXISTS ACSBV3_0603C_stat_totals;

CREATE TABLE ACSBV3_0603C_stat_totals AS
SELECT
  slot_group,
  stat_category,
  SUM(stat_budget) AS category_budget
FROM ACSBV3_0603B_stats_categorized
GROUP BY slot_group, stat_category;



SELECT COUNT(*) FROM ACSBV3_0603C_stat_totals;



/*=============================================================================================================================================
  5. Compute total stat budget per slot_group
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "5. Compute total stat budget per slot_group" );



DROP TABLE IF EXISTS ACSBV3_0603D_stat_sum;

CREATE TABLE ACSBV3_0603D_stat_sum AS
SELECT
  slot_group,
  SUM(category_budget) AS stat_budget_total
FROM ACSBV3_0603C_stat_totals
GROUP BY slot_group;



SELECT COUNT(*) FROM ACSBV3_0603D_stat_sum;



/*=============================================================================================================================================
  6. Final normalized distribution table
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "6. Final normalized distribution table" );



DROP TABLE IF EXISTS ACSBV3_aux_stat_distribution;

CREATE TABLE ACSBV3_aux_stat_distribution AS
SELECT
  t.slot_group,
  t.stat_category,
  t.category_budget,
  (t.category_budget / s.stat_budget_total) * 100 AS category_percent
FROM ACSBV3_0603C_stat_totals t
JOIN ACSBV3_0603D_stat_sum s
  ON t.slot_group = s.slot_group
ORDER BY t.slot_group, category_percent DESC;



SELECT       *  FROM ACSBV3_aux_stat_distribution;
SELECT COUNT(*) FROM ACSBV3_aux_stat_distribution;



CALL ACSBV3_print_footer ();

/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
