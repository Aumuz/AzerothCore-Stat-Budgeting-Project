/*============================================================================================
Filename:       ACSBV3-00-07C.sql
Title:          Phase 00 – Canonical Combined Dataset (Master Dataset)
Author:         ChatGPT + Aumuz Messick
Version:        1.1
Created:        2025-10-20
Description:    v1.1 added .csv export.
                Joins the reduced dataset to ACSBV3_00_00A_raw_items to include all
                item_template-derived fields.  Serves as the full audit/master dataset.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS ACSBV3_00_07C_master_dataset;

CREATE TABLE ACSBV3_00_07C_master_dataset AS
SELECT
    a.*,
    r.drop_environment,
    r.source_type,
    r.effective_chance_total,
    r.freq_weight_total,
    r.encounter_weight_base,
    r.final_weight_total,
    r.source_count,
    r.multi_source_flag,
    r.date_finalized
FROM ACSBV3_00_00A_raw_items AS a
LEFT JOIN ACSBV3_00_07B_reduced_items AS r
  ON a.ItemID = r.ItemID;

SELECT *
FROM ACSBV3_00_07C_master_dataset
INTO OUTFILE '/var/lib/mysql-files/ACSBV3-00-07C.CSV'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n';

/* Verification */
SELECT COUNT(*) AS total_records,
       COUNT(DISTINCT ItemID) AS distinct_items
FROM ACSBV3_00_07C_master_dataset;
/*============================================================================================*/
