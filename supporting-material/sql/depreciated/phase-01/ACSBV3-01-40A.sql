/*============================================================================================
  Filename:       ACSBV3-01-40A.sql
  Title:          Phase 01 – Cleanup and Canonical Export
  Author:         ChatGPT + Aumuz Messick
  Version:        1.0
  Created:        2025-10-23
  Description:    Removes all intermediate Phase 01 tables, leaving only canonical reference
                  tables.  Exports each final table to CSV for documentation.
----------------------------------------------------------------------------------------------
  Canonical Tables Preserved:
     • ACSBV3_ref_statcost_equipment
     • ACSBV3_ref_statcost_weapons
     • ACSBV3_ref_slotmod_equipment
     • ACSBV3_ref_slotmod_weapons
     • ACSBV3_ref_dropmod
     • ACSBV3_ref_miscmod
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

-- -------------------------------------------------------------------------------------------
-- 1. Rename shared reference tables
-- -------------------------------------------------------------------------------------------
RENAME TABLE
  ACSBV3_ref_dropmod_equipment TO ACSBV3_ref_dropmod,
  ACSBV3_ref_miscmod_equipment TO ACSBV3_ref_miscmod;

-- -------------------------------------------------------------------------------------------
-- 2. Drop all non-canonical tables created during Phase 01
-- -------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS
  ACSBV3_01_00A_reference_items,
  ACSBV3_01_00A_stat_cost_equipment,
  ACSBV3_01_00B_reference_env,
  ACSBV3_01_00B_statcost_diagnostic,
  ACSBV3_01_10A_budget_equipment,
  ACSBV3_01_10B_budget_slot_averages,
  ACSBV3_01_10C_slotmod_equipment_raw,
  ACSBV3_01_10C_slotmod_equipment_summary,
  ACSBV3_01_00C_stat_cost_equipment_ext,
  ACSBV3_01_00C_statcost_diagnostic,
  ACSBV3_01_10D_slotmod_equipment_temp,
  ACSBV3_01_00D_socketbonus_diagnostic,
  ACSBV3_01_00D_socketbonus_map,
  ACSBV3_01_00D_stat_cost_socketbonus,
  ACSBV3_01_10E_dropmod_equipment_raw,
  ACSBV3_01_10F_dropmod_equipment_temp,
  ACSBV3_01_10G_spell_random_diagnostic,
  ACSBV3_01_10I_dropmod_equipment_retest,
  ACSBV3_01_10I_env_averages,
  ACSBV3_01_10J_dropmod_equipment_retest,
  ACSBV3_01_10J_env_averages,
  ACSBV3_01_20A_stat_cost_weapons,
  ACSBV3_01_20B_statcost_diagnostic,
  ACSBV3_01_20C_stat_cost_weapons_ext,
  ACSBV3_01_20C_dps_subclass_avg,
  ACSBV3_01_20C_dps_diagnostic,
  ACSBV3_01_20D_miscmod_weapons,
  ACSBV3_01_20D_miscmod_diagnostic,
  ACSBV3_01_30A_budget_weapons,
  ACSBV3_01_30B_budget_subclass_averages,
  ACSBV3_01_30B_subclassmod_weapons_raw,
  ACSBV3_01_34A_dropmod_weapons_raw,
  ACSBV3_ref_dropmod_weapons;

-- -------------------------------------------------------------------------------------------
-- 3. Verify canonical tables remain
-- -------------------------------------------------------------------------------------------
SHOW TABLES LIKE 'ACSBV3_ref_statcost_equipment';
SHOW TABLES LIKE 'ACSBV3_ref_statcost_weapons';
SHOW TABLES LIKE 'ACSBV3_ref_slotmod_equipment';
SHOW TABLES LIKE 'ACSBV3_ref_slotmod_weapons';
SHOW TABLES LIKE 'ACSBV3_ref_dropmod';
SHOW TABLES LIKE 'ACSBV3_ref_miscmod';

-- -------------------------------------------------------------------------------------------
-- 4. Export canonical tables to CSV
-- -------------------------------------------------------------------------------------------
SELECT * FROM ACSBV3_ref_statcost_equipment
INTO OUTFILE '/var/lib/mysql-files/ACSBV3_ref_statcost_equipment.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n';

SELECT * FROM ACSBV3_ref_statcost_weapons
INTO OUTFILE '/var/lib/mysql-files/ACSBV3_ref_statcost_weapons.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n';

SELECT * FROM ACSBV3_ref_slotmod_equipment
INTO OUTFILE '/var/lib/mysql-files/ACSBV3_ref_slotmod_equipment.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n';

SELECT * FROM ACSBV3_ref_slotmod_weapons
INTO OUTFILE '/var/lib/mysql-files/ACSBV3_ref_slotmod_weapons.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n';

SELECT * FROM ACSBV3_ref_dropmod
INTO OUTFILE '/var/lib/mysql-files/ACSBV3_ref_dropmod.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n';

SELECT * FROM ACSBV3_ref_miscmod
INTO OUTFILE '/var/lib/mysql-files/ACSBV3_ref_miscmod.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n';

-- -------------------------------------------------------------------------------------------
-- 5. Final verification summary
-- -------------------------------------------------------------------------------------------
SHOW TABLES LIKE 'ACSBV3_ref_%';

/*============================================================================================
  End of File
============================================================================================*/
