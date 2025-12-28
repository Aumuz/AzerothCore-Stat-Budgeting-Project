/*============================================================================================
  Filename:       ACSBV3-01-00C.sql
  Title:          Phase 01 – Equipment Stat Cost Expansion (Extended Attributes)
  Author:         ChatGPT + Aumuz Messick
  Version:        1.0
  Created:        2025-10-21
  Description:    Extends the equipment stat dataset to include Armor, Resistances,
                  Sockets, and Socket Bonus fields. Produces unweighted empirical
                  diagnostics for these attributes.
----------------------------------------------------------------------------------------------
  Notes:
   - Uses unweighted values (no weighting or normalization yet).
   - Focus: Determine whether these attributes show measurable scaling behavior.
   - Socket bonus is retained as an ID only; effect mapping will occur in 01-00D.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

-- -------------------------------------------------------------------------------------------
-- Drop any previous runs
-- -------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS ACSBV3_01_00C_stat_cost_equipment_ext;
DROP TABLE IF EXISTS ACSBV3_01_00C_statcost_diagnostic;

-- -------------------------------------------------------------------------------------------
-- Create Extended Dataset
-- -------------------------------------------------------------------------------------------
CREATE TABLE ACSBV3_01_00C_stat_cost_equipment_ext AS
SELECT
    entry,
    name,
    Quality,
    ItemLevel,
    InventoryType,
    armor,
    holy_res,
    fire_res,
    nature_res,
    frost_res,
    shadow_res,
    arcane_res,
    (COALESCE(holy_res,0) + COALESCE(fire_res,0) + COALESCE(nature_res,0) +
     COALESCE(frost_res,0) + COALESCE(shadow_res,0) + COALESCE(arcane_res,0)) AS resist_total,
    socketColor_1,
    socketColor_2,
    socketColor_3,
    ((socketColor_1 <> 0) + (socketColor_2 <> 0) + (socketColor_3 <> 0)) AS socket_count,
    socketBonus,
    CASE WHEN socketBonus > 0 THEN 1 ELSE 0 END AS has_socket_bonus
FROM ACSBV3_ref_items
WHERE class = 4
  AND subclass NOT IN (8, 11)              -- exclude trinkets, relics
  AND InventoryType NOT IN (0, 18, 19, 23, 24);

-- -------------------------------------------------------------------------------------------
-- Diagnostic Aggregation
-- -------------------------------------------------------------------------------------------
CREATE TABLE ACSBV3_01_00C_statcost_diagnostic AS
SELECT
    COUNT(*) AS total_items,
    ROUND(AVG(armor),2) AS avg_armor,
    ROUND(STDDEV_SAMP(armor),2) AS stdev_armor,
    ROUND(AVG(resist_total),2) AS avg_resist_total,
    ROUND(STDDEV_SAMP(resist_total),2) AS stdev_resist_total,
    ROUND(AVG(socket_count),2) AS avg_socket_count,
    ROUND(SUM(has_socket_bonus)/COUNT(*)*100,2) AS pct_with_bonus
FROM ACSBV3_01_00C_stat_cost_equipment_ext;

-- -------------------------------------------------------------------------------------------
-- Verification Queries
-- -------------------------------------------------------------------------------------------

-- Verify total rows match expected count of equipment
SELECT COUNT(*) AS total_rows FROM ACSBV3_01_00C_stat_cost_equipment_ext;

-- Quick summary preview
SELECT * FROM ACSBV3_01_00C_statcost_diagnostic;

-- Distribution of socket counts
SELECT socket_count, COUNT(*) AS items
FROM ACSBV3_01_00C_stat_cost_equipment_ext
GROUP BY socket_count
ORDER BY socket_count;

-- Distribution of socket bonuses
SELECT has_socket_bonus, COUNT(*) AS items
FROM ACSBV3_01_00C_stat_cost_equipment_ext
GROUP BY has_socket_bonus;

-- Armor vs ItemLevel preview
SELECT ROUND(ItemLevel,-1) AS iLvl_band,
       ROUND(AVG(armor),2) AS avg_armor
FROM ACSBV3_01_00C_stat_cost_equipment_ext
GROUP BY iLvl_band
ORDER BY iLvl_band;

-- Resistances check (optional detailed view)
SELECT
    ROUND(AVG(holy_res),2)   AS avg_holy,
    ROUND(AVG(fire_res),2)   AS avg_fire,
    ROUND(AVG(nature_res),2) AS avg_nature,
    ROUND(AVG(frost_res),2)  AS avg_frost,
    ROUND(AVG(shadow_res),2) AS avg_shadow,
    ROUND(AVG(arcane_res),2) AS avg_arcane
FROM ACSBV3_01_00C_stat_cost_equipment_ext;

/*============================================================================================
  End of File
============================================================================================*/
