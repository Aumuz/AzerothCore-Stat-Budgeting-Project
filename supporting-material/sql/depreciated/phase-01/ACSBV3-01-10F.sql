/*============================================================================================
  Filename:       ACSBV3-01-10F.sql
  Title:          Phase 01 - Reference Table: Equipment Drop Modifiers (Unified)
  Author:         ChatGPT + Aumuz Messick
  Version:        1.0
  Created:        2025-10-22
  Description:    Creates the canonical reference table for environment-based drop modifiers.
                  Derived from empirical averages in ACSBV3_ref_dropmod_equipment (01-10E).
                  Baseline environment: WORLD = 100 percent.
----------------------------------------------------------------------------------------------
  Statistical Summary:
    * Dungeon gear budgets average 55-85 percent of World gear at equal item level.
    * Raid gear budgets average 120-130 percent of World gear at equal item level.
    * Quality-based variation is negligible; single global modifiers are sufficient.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

-- -------------------------------------------------------------------------------------------
-- 1. Drop any existing table
-- -------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS ACSBV3_ref_dropmod_equipment;

-- -------------------------------------------------------------------------------------------
-- 2. Create canonical environment modifier reference
-- -------------------------------------------------------------------------------------------
CREATE TABLE ACSBV3_ref_dropmod_equipment (
    drop_environment VARCHAR(32) PRIMARY KEY,
    drop_modifier    DECIMAL(6,2),
    notes            VARCHAR(255)
);

-- -------------------------------------------------------------------------------------------
-- 3. Insert unified environment modifiers
-- -------------------------------------------------------------------------------------------
INSERT INTO ACSBV3_ref_dropmod_equipment (drop_environment, drop_modifier, notes) VALUES
('WORLD',   100.00, 'Baseline environment; reference for normalization.'),
('DUNGEON',  75.00, 'Average dungeon items budgeted below world-level gear.'),
('RAID',    125.00, 'Raid gear consistently overbudgeted relative to world items.');

-- -------------------------------------------------------------------------------------------
-- 4. Verification Queries
-- -------------------------------------------------------------------------------------------

-- Confirm entries
SELECT COUNT(*) AS total_environments FROM ACSBV3_ref_dropmod_equipment;

-- Preview table
SELECT * FROM ACSBV3_ref_dropmod_equipment ORDER BY drop_modifier;

/*============================================================================================
  End of File
============================================================================================*/
