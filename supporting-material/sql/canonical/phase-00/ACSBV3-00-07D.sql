/*============================================================================================
Filename:       ACSBV3-00-07D.sql
Title:          Phase 00 – Reference Dataset (Normalized for Phase 01+)
Author:         ChatGPT + Aumuz Messick
Version:        1.5
Created:        2025-10-20
Description:    v1.1 Removed legacy column a.StatsCount (not present in AzerothCore schema).
                     No impact to logic or output. Compatible with ACSBV3_00_00A_raw_items structure.
                v1.2 Added CSV export of final reference dataset (ACSBV3_00_07D_reference_items)
                     for offline analysis and documentation.
                v1.3 Added additional field values.
                v1.4 Aligned stat and damage field names with 00-00A schema; verified
                     armor and socket fields for curve analysis compatibility.
                v1.5 Renamed final table to ACSBV3_ref_items to match canonical reference naming
                     convention used across ACSBV3 (e.g., ACSBV3_ref_map_environment).
                Produces the minimal reference dataset for subsequent phases.
                Keeps item_template-style columns plus source_type and final weight.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS ACSBV3_ref_items;

CREATE TABLE ACSBV3_ref_items AS
SELECT
    a.ItemID        AS entry,
    a.ItemName      AS name,
    a.Quality,
    a.ItemLevel,
    a.RequiredLevel,
    a.class,
    a.subclass,
    a.InventoryType,
    a.Flags,
    a.SellPrice,
    a.BuyPrice,
    a.bonding,
    a.armor,
    a.dmg_min1,
    a.dmg_max1,
    a.dmg_type1,
    a.delay,
    a.socketColor_1,
    a.socketColor_2,
    a.socketColor_3,
    a.socketBonus,
    a.stat_type1, a.stat_value1,
    a.stat_type2, a.stat_value2,
    a.stat_type3, a.stat_value3,
    a.stat_type4, a.stat_value4,
    a.stat_type5, a.stat_value5,
    a.stat_type6, a.stat_value6,
    a.stat_type7, a.stat_value7,
    a.stat_type8, a.stat_value8,
    a.stat_type9, a.stat_value9,
    a.stat_type10, a.stat_value10,
    r.drop_environment,
    r.source_type,
    r.final_weight_total AS weight
FROM ACSBV3_00_07C_master_dataset AS a
LEFT JOIN ACSBV3_00_07B_reduced_items AS r
  ON a.ItemID = r.ItemID;

SELECT *
FROM ACSBV3_ref_items
INTO OUTFILE '/var/lib/mysql-files/ACSBV3_ref_items.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n';

/* Verification */
SELECT COUNT(*) AS total_records,
       COUNT(DISTINCT entry) AS distinct_items,
       ROUND(AVG(weight),3) AS avg_weight
FROM ACSBV3_ref_items;
/*============================================================================================*/
