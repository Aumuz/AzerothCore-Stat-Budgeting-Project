/*======================================================================================================================================
  Filename:       ACSBV3-Compare-StatCost.sql
  Title:          Stat-Cost Table Comparison – Equipment vs Weapon
  Author:         ChatGPT + Aumuz Messick
  Version:        1.0
  Created:        2025-10-31
  Description:    Compares per-stat cost coefficients between equipment and weapon tables.
                  Confirms whether Equipment costs were derived from older (v1) scaling.
======================================================================================================================================*/

-- ---------------------------------------------------------------
-- 1. Basic Line-by-Line Comparison
-- ---------------------------------------------------------------
SELECT
    e.stat_type,
    e.stat_name,
    e.cost AS equip_cost,
    w.cost AS weapon_cost,
    ROUND(w.cost / e.cost,3) AS ratio_weapon_over_equip,
    CASE
      WHEN w.cost > e.cost THEN 'Weapon cost higher (Equip cheaper)'
      WHEN w.cost < e.cost THEN 'Equipment cost higher (Weapon cheaper)'
      ELSE 'Equal'
    END AS comparison
FROM ACSBV3_doc_cost_equipment AS e
JOIN ACSBV3_doc_cost_weapons   AS w
  ON e.stat_type = w.stat_type
ORDER BY ratio_weapon_over_equip DESC;

-- ---------------------------------------------------------------
-- 2. Summary Statistics
-- ---------------------------------------------------------------
SELECT
    ROUND(AVG(w.cost / e.cost),3) AS mean_ratio,
    ROUND(MIN(w.cost / e.cost),3) AS min_ratio,
    ROUND(MAX(w.cost / e.cost),3) AS max_ratio,
    COUNT(*) AS n_stats
FROM ACSBV3_doc_cost_equipment AS e
JOIN ACSBV3_doc_cost_weapons   AS w
  ON e.stat_type = w.stat_type;

-- Expected:
--   mean_ratio ˜ 1.2–1.3 if Equipment costs are too low (matching slot-mod offset)
--   mean_ratio ˜ 1.0 if already aligned
/*======================================================================================================================================
  End of File
======================================================================================================================================*/
