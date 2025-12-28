/*============================================================================================
  Filename:       ACSBV3-01-10D.sql
  Title:          Phase 01 - Reference Table: Equipment Slot Modifiers (Unified)
  Author:         ChatGPT + Aumuz Messick
  Version:        1.0
  Created:        2025-10-22
  Description:    Consolidates per-quality slot modifiers into a single normalized reference
                  table. Based on empirical means from ACSBV3_01_10C_slotmod_equipment_summary
                  and validated by cross-quality variance analysis (01-10C).
----------------------------------------------------------------------------------------------
  Statistical Summary:
    * No significant variation across Quality tiers (CV approx 1.3-1.6; noise from low-level data)
    * Final modifiers are quality-agnostic except for Shields.
    * Chest normalized to 100 percent.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

-- -------------------------------------------------------------------------------------------
-- 1. Drop any existing table
-- -------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS ACSBV3_ref_slotmod_equipment;

-- -------------------------------------------------------------------------------------------
-- 2. Create unified slot modifier reference
-- -------------------------------------------------------------------------------------------
CREATE TABLE ACSBV3_ref_slotmod_equipment (
    InventoryType SMALLINT PRIMARY KEY,
    slot_name     VARCHAR(64),
    slot_modifier DECIMAL(6,2),
    notes         VARCHAR(255)
);

-- -------------------------------------------------------------------------------------------
-- 3. Populate table with consolidated values (Chest = 100%)
-- -------------------------------------------------------------------------------------------
INSERT INTO ACSBV3_ref_slotmod_equipment (InventoryType, slot_name, slot_modifier, notes) VALUES
(1,  'Head',              86.0, 'Average of qualities 2-4; stable +/-3%.'),
(2,  'Neck',              34.0, 'Consistent across qualities; treated as jewelry.'),
(3,  'Shoulder',          72.0, 'Stable +/-3%; slightly lower for low-level gear.'),
(5,  'Chest',             100.0,'Baseline slot for normalization.'),
(6,  'Waist',             59.0, 'Consistent +/-2%.'),
(7,  'Legs',              87.0, 'Parallel to Head slot; +/-3%.'),
(8,  'Feet',              63.0, 'Consistent +/-3%.'),
(9,  'Wrist',             44.0, 'Stable +/-2%; lowest of primary armor pieces.'),
(10, 'Hands',             63.0, 'Aligned with Feet slot; +/-3%.'),
(11, 'Finger',            33.0, 'Same as Neck; jewelry classification.'),
(14, 'Shield',            340.0,'Exceptionally high defensive budget; separate treatment.'),
(16, 'Cloak',             30.0, 'Flat across qualities; consistent scaling.'),
(20, 'Robe',              100.0,'Alternate chest model; treated as Chest equivalent.'),
(23, 'Held in Off-Hand',  33.0, 'Equivalent to Finger/Neck; +/-3%.');

-- -------------------------------------------------------------------------------------------
-- 4. Verification Queries
-- -------------------------------------------------------------------------------------------

-- Confirm entries
SELECT COUNT(*) AS total_slots FROM ACSBV3_ref_slotmod_equipment;

-- Preview ordered list
SELECT * FROM ACSBV3_ref_slotmod_equipment ORDER BY InventoryType;

/*============================================================================================
  End of File
============================================================================================*/
