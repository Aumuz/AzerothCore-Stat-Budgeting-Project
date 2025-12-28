/*============================================================================================
  Filename:       ACSBV3-01-00E.sql
  Title:          Phase 01 – Reference Table: Stat Cost Coefficients (Equipment)
  Author:         ChatGPT + Aumuz Messick
  Version:        1.0
  Created:        2025-10-21
  Description:    Builds ACSBV3_ref_statcost_equipment containing normalized cost multipliers
                  for all equipment stats and socket bonuses.  Combines refined v3 empirical
                  stat costs with computed socket-bonus budgets.
----------------------------------------------------------------------------------------------
  Notes:
   - Armor retains id = -1 (not part of stat_type pairs).
   - Mana (id = 0) retains normalized_cost = 0.00.
   - All values normalized to Stamina = 1.00.
   - Socket bonuses are inserted dynamically from ACSBV3_01_00D_socketbonus_map.
   - Each socket bonus id reflects its total budget contribution:
         normalized_cost = stat_value × base_stat_cost
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS ACSBV3_ref_statcost_equipment;

CREATE TABLE ACSBV3_ref_statcost_equipment (
    id              INT PRIMARY KEY,
    stat_name       VARCHAR(64),
    normalized_cost DECIMAL(8,3),
    design_notes    VARCHAR(255)
);

-- -------------------------------------------------------------------------------------------
-- 1.  Base Stat Costs (Refined v3)
-- -------------------------------------------------------------------------------------------
INSERT INTO ACSBV3_ref_statcost_equipment (id, stat_name, normalized_cost, design_notes) VALUES
(-1, 'ARMOR',                       1.04, 'Scaled logarithmically (~1 budget per 5 Armor).'),
(0,  'MANA',                        0.00, 'ITEM_MOD_MANA; excluded from stat budgets.'),
(3,  'ITEM_MOD_AGILITY',            1.25, 'Primary DPS stat; slightly reduced from 1.28 after v3 averages.'),
(4,  'ITEM_MOD_STRENGTH',           1.00, 'Primary melee stat; balanced with Stamina.'),
(5,  'ITEM_MOD_INTELLECT',          1.02, 'Primary caster stat; near-equal to Stamina.'),
(6,  'ITEM_MOD_SPIRIT',             0.85, 'Regeneration stat; low impact.'),
(7,  'ITEM_MOD_STAMINA',            1.00, 'Normalization baseline for all stat costs.'),
(12, 'ITEM_MOD_DEFENSE_SKILL_RATING',0.84,'Core tank stat; mild diminishing returns.'),
(13, 'ITEM_MOD_DODGE_RATING',       0.97, 'Defensive avoidance; high marginal value.'),
(15, 'ITEM_MOD_BLOCK_RATING',       0.63, 'Low impact; complements Defense.'),
(31, 'ITEM_MOD_HIT_RATING',         1.00, 'Baseline offensive rating; parity with Stamina.'),
(32, 'ITEM_MOD_CRIT_RATING',        1.00, 'Balanced offensive rating.'),
(35, 'ITEM_MOD_RESILIENCE_RATING',  0.70, 'PvP mitigation; mid-tier cost.'),
(36, 'ITEM_MOD_HASTE_RATING',       0.90, 'Endgame scaling; slightly cheaper after v3 analysis.'),
(37, 'ITEM_MOD_EXPERTISE_RATING',   1.36, 'Avoidance control; intentionally expensive.'),
(38, 'ITEM_MOD_ATTACK_POWER',       0.42, 'Primary melee offense; efficient scaling.'),
(42, 'ITEM_MOD_SPELL_DAMAGE_DONE',  0.45, 'Legacy caster stat; mirrors Attack Power efficiency.'),
(44, 'ITEM_MOD_ARMOR_PENETRATION_RATING',0.90,'Rounded adjustment from v2 values.'),
(45, 'ITEM_MOD_SPELL_POWER',        0.88, 'Standard caster power; consistent with empirical data.');

-- -------------------------------------------------------------------------------------------
-- 2.  Insert Socket Bonus Entries
-- -------------------------------------------------------------------------------------------
-- Each bonus is converted to total normalized cost based on its base stat cost.

INSERT INTO ACSBV3_ref_statcost_equipment (id, stat_name, normalized_cost, design_notes)
SELECT
    m.id,
    m.stat_name,
    ROUND(m.stat_value * b.normalized_cost * 0.5,3) AS normalized_cost,
    CONCAT('Socket bonus: ', m.effect)
FROM ACSBV3_01_00D_socketbonus_map AS m
JOIN ACSBV3_ref_statcost_equipment AS b
  ON m.stat_name = b.stat_name;

-- -------------------------------------------------------------------------------------------
-- 3.  Verification Queries
-- -------------------------------------------------------------------------------------------

SELECT *
FROM ACSBV3_ref_statcost_equipment
INTO OUTFILE '/var/lib/mysql-files/ACSBV3-01-00E.CSV'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n';

-- Count total entries (should include base stats + socket bonuses)
SELECT COUNT(*) AS total_rows FROM ACSBV3_ref_statcost_equipment;

-- Preview first few base stats
SELECT * FROM ACSBV3_ref_statcost_equipment
WHERE id < 100
ORDER BY id;

-- Preview socket bonuses
SELECT * FROM ACSBV3_ref_statcost_equipment
WHERE id > 2000
ORDER BY id
LIMIT 20;

/*============================================================================================
  End of File
============================================================================================*/
