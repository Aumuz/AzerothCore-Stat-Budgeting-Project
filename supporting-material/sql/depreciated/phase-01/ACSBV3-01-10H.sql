/*============================================================================================
  Filename:       ACSBV3-01-10H.sql
  Title:          Phase 01 - Reference Table: Miscellaneous Equipment Modifiers
  Author:         ChatGPT + Aumuz Messick
  Version:        1.0
  Created:        2025-10-22
  Description:    Establishes reference multipliers for secondary item effects not captured
                  by standard stat or socket budgets.  Derived from empirical analysis in
                  ACSBV3_01_10G_spell_random_diagnostic.
----------------------------------------------------------------------------------------------
  Statistical Summary:
    * SpellID effects:  Ratios average 75-90 percent of baseline; hidden DBC spell values
      already consume internal budget.  No adjustment applied.
    * RandomProperty/Suffix: Ratios average 60-65 percent of baseline; applying a 1.35x
      multiplier normalizes effective budget to approximately 100 percent.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

-- -------------------------------------------------------------------------------------------
-- 1. Drop any existing table
-- -------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS ACSBV3_ref_miscmod_equipment;

-- -------------------------------------------------------------------------------------------
-- 2. Create table
-- -------------------------------------------------------------------------------------------
CREATE TABLE ACSBV3_ref_miscmod_equipment (
    modifier_name VARCHAR(64) PRIMARY KEY,
    multiplier    DECIMAL(6,3),
    notes         VARCHAR(255)
);

-- -------------------------------------------------------------------------------------------
-- 3. Insert final multipliers
-- -------------------------------------------------------------------------------------------
INSERT INTO ACSBV3_ref_miscmod_equipment (modifier_name, multiplier, notes) VALUES
('SpellID',             1.000, 'No adjustment; spell effects already budgeted via DBC.'),
('RandomPropertySuffix',1.350, 'Empirical correction; random affix items average 60-65 percent of baseline.');

-- -------------------------------------------------------------------------------------------
-- 4. Verification Queries
-- -------------------------------------------------------------------------------------------

-- Confirm table contents
SELECT COUNT(*) AS total_modifiers FROM ACSBV3_ref_miscmod_equipment;

-- Display entries
SELECT * FROM ACSBV3_ref_miscmod_equipment ORDER BY modifier_name;

/*============================================================================================
  End of File
============================================================================================*/
