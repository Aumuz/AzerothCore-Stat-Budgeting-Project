/*============================================================================================
  Filename:       ACSBV3-01-20E.sql
  Title:          Phase 01 - Reference Table: Stat Cost Coefficients (Weapons)
  Author:         ChatGPT + Aumuz Messick
  Version:        1.0
  Created:        2025-10-22
  Description:    Builds ACSBV3_ref_statcost_weapons containing normalized cost multipliers
                  for all weapon stats and DPS contributions. Integrates subclass-normalized
                  DPS results and misc modifier corrections from prior steps.
----------------------------------------------------------------------------------------------
  Notes:
   - Derived from ACSBV3_01_20D_miscmod_weapons (final normalized dataset).
   - DPS introduced as ITEM_MOD_DPS with baseline cost = 1.00 (normalized).
   - Stat multipliers adapted from ACSBV3_ref_statcost_equipment, re-balanced
     for weapon scaling ratios observed in 01-20B.
   - All costs normalized relative to Stamina = 1.00.
   - Socket bonuses and resistances excluded (not relevant to weapons).
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

-- -------------------------------------------------------------------------------------------
-- 1. Drop any prior weapon stat-cost reference table
-- -------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS ACSBV3_ref_statcost_weapons;

CREATE TABLE ACSBV3_ref_statcost_weapons (
    id INT PRIMARY KEY,
    stat_name VARCHAR(64),
    normalized_cost DECIMAL(8,3),
    design_notes VARCHAR(255)
);

-- -------------------------------------------------------------------------------------------
-- 2. Insert Base Stat Costs (derived from equipment table, adjusted for weapon scaling)
-- -------------------------------------------------------------------------------------------
INSERT INTO ACSBV3_ref_statcost_weapons (id, stat_name, normalized_cost, design_notes) VALUES
(-1, 'DPS_BASE', 1.000, 'ITEM_MOD_DPS baseline (subclass-normalized mean = 1.0).'),
(3,  'ITEM_MOD_AGILITY', 1.10, 'Reduced from 1.25 -> weapons show ~12% lower stat magnitude.'),
(4,  'ITEM_MOD_STRENGTH', 0.85, 'Weapons average 0.69x equipment value after normalization.'),
(5,  'ITEM_MOD_INTELLECT', 0.92, 'Caster weapons slightly below equipment average.'),
(6,  'ITEM_MOD_SPIRIT', 0.80, 'Low regeneration influence; mirrors equipment trend.'),
(7,  'ITEM_MOD_STAMINA', 1.00, 'Normalization baseline for all stat costs.'),
(12, 'ITEM_MOD_DEFENSE_SKILL_RATING', 0.80, 'Observed 40% reduction from equipment; smoothed to 0.8.'),
(13, 'ITEM_MOD_DODGE_RATING', 0.85, 'Defensive rating scaled to melee 1H weapon norms.'),
(15, 'ITEM_MOD_BLOCK_RATING', 0.55, 'Rare on weapons; efficiency reduced.'),
(31, 'ITEM_MOD_HIT_RATING', 0.85, 'Average 35% lower than equipment.'),
(32, 'ITEM_MOD_CRIT_RATING', 0.90, 'Slightly reduced relative to equipment baseline.'),
(35, 'ITEM_MOD_RESILIENCE_RATING', 0.70, 'PvP mitigation unchanged from equipment.'),
(36, 'ITEM_MOD_HASTE_RATING', 0.88, 'Endgame Haste effect stable across both sets.'),
(37, 'ITEM_MOD_EXPERTISE_RATING', 1.10, 'Maintains higher scaling importance for melee control.'),
(38, 'ITEM_MOD_ATTACK_POWER', 0.40, 'Weapons supply AP directly; efficiency ~0.4 normalized.'),
(39, 'ITEM_MOD_RANGED_ATTACK_POWER', 0.40, 'Parallel to melee AP efficiency.'),
(42, 'ITEM_MOD_SPELL_DAMAGE_DONE', 0.45, 'Legacy caster stat; mirrors equipment.'),
(45, 'ITEM_MOD_SPELL_POWER', 0.90, 'Weapons show 4.4x magnitude -> adjusted cost raised to 0.9.'),
(44, 'ITEM_MOD_ARMOR_PENETRATION_RATING', 0.90, 'Identical to equipment after re-balancing.');

-- -------------------------------------------------------------------------------------------
-- 3. Insert DPS pseudo-stat entry
-- -------------------------------------------------------------------------------------------
INSERT INTO ACSBV3_ref_statcost_weapons (id, stat_name, normalized_cost, design_notes)
VALUES (1000, 'ITEM_MOD_DPS', 1.000, 'Derived DPS contribution; acts as baseline cost driver.');

-- -------------------------------------------------------------------------------------------
-- 4. Verification and Export
-- -------------------------------------------------------------------------------------------

-- Export CSV for external verification
SELECT *
FROM ACSBV3_ref_statcost_weapons
INTO OUTFILE '/var/lib/mysql-files/ACSBV3-01-20E.CSV'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n';

-- Row count check
SELECT COUNT(*) AS total_rows FROM ACSBV3_ref_statcost_weapons;

-- Preview base stats
SELECT * FROM ACSBV3_ref_statcost_weapons
ORDER BY id
LIMIT 20;

/*============================================================================================
  End of File
============================================================================================*/
