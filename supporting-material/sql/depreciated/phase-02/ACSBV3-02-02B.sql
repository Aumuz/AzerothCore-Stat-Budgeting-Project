/*============================================================================================
  Filename:       ACSBV3-02-02B.sql
  Title:          Phase 02 – Data Export for External Analysis
  Author:         ChatGPT
  Version:        2.1
  Created:        2025-10-23
  Description:    Exports Phase 02 results for external curve validation and analysis.
                  Includes CSV headers for each export.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

-- -------------------------------------------------------------------------------------------
-- Unweighted curve export (with headers)
-- -------------------------------------------------------------------------------------------
(SELECT 'ItemLevel','Quality','median_budget')
UNION ALL
SELECT ItemLevel, Quality, median_budget
INTO OUTFILE '/var/lib/mysql-files/ACSBV3_02_01A_curve_unweighted.csv'
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n'
FROM ACSBV3_02_01A_curve_unweighted;

-- -------------------------------------------------------------------------------------------
-- Weighted curve export (with headers)
-- -------------------------------------------------------------------------------------------
(SELECT 'ItemLevel','Quality','weighted_median_budget')
UNION ALL
SELECT ItemLevel, Quality, weighted_median_budget
INTO OUTFILE '/var/lib/mysql-files/ACSBV3_02_01B_curve_weighted.csv'
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n'
FROM ACSBV3_02_01B_curve_weighted;

-- -------------------------------------------------------------------------------------------
-- Validation test set export (with headers)
-- -------------------------------------------------------------------------------------------
(SELECT 'entry','name','ItemLevel','Quality','actual_stat_budget','normalized_budget')
UNION ALL
SELECT entry, name, ItemLevel, Quality,
       actual_stat_budget, normalized_budget
INTO OUTFILE '/var/lib/mysql-files/ACSBV3_02_02A_testset_equipment.csv'
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n'
FROM ACSBV3_02_02A_testset_equipment;

-- -------------------------------------------------------------------------------------------
-- Confirmation message
-- -------------------------------------------------------------------------------------------
SELECT 'Phase 02 data successfully exported for external analysis (headers included).' AS status_message;

/*============================================================================================
  End of File
============================================================================================*/
