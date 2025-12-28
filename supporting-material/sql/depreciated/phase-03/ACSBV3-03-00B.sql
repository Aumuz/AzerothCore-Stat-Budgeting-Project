/*============================================================================================
  Filename:       ACSBV3-03-00B.sql
  Title:          Phase 03 – Export Filter (Equipment + Weapons, Valid Budgets Only)
  Author:         ChatGPT
  Version:        1.0
  Created:        2025-10-24
  Description:
    Filters ACSBV3_03_00A_curve_raw to remove records with zero or null budgets and writes a
    clean export table suitable for external smoothing in Python. Adds a header row to preserve
    column names in the CSV export.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS ACSBV3_03_00B_curve_export;

CREATE TABLE ACSBV3_03_00B_curve_export AS
SELECT
  entry,
  name,
  class,
  subclass,
  InventoryType,
  Quality,
  ItemLevel,
  actual_budget,
  normalized_budget,
  item_family
FROM ACSBV3_03_00A_curve_raw
WHERE
  COALESCE(actual_budget,0) > 0
  AND COALESCE(normalized_budget,0) > 0
  AND Quality BETWEEN 1 AND 4;

-- -------------------------------------------------------------------------------------------
-- Verification: counts by family and quality after filtering
-- -------------------------------------------------------------------------------------------
SELECT item_family, Quality, COUNT(*) AS n
FROM ACSBV3_03_00B_curve_export
GROUP BY item_family, Quality
ORDER BY item_family, Quality;

-- -------------------------------------------------------------------------------------------
-- Export command (MySQL shell syntax)
-- -------------------------------------------------------------------------------------------
-- NOTE: Adjust path as needed.  MySQL must have FILE privilege for OUTFILE.

-- 1) Add header row
SELECT 'entry','name','class','subclass','InventoryType','Quality','ItemLevel',
       'actual_budget','normalized_budget','item_family'
UNION ALL
SELECT
  entry, name, class, subclass, InventoryType, Quality, ItemLevel,
  actual_budget, normalized_budget, item_family
INTO OUTFILE '/var/lib/mysql-files/ACSBV3_03_00B_curve_export.csv'
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
FROM ACSBV3_03_00B_curve_export;

/*============================================================================================
  End of File
============================================================================================*/
