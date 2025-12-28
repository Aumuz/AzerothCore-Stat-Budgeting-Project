/*======================================================================================================================================
  Routine:        ACSBV3_proc_smooth_curve
  Title:          Build Smoothed, Monotonic Curves (Expansion-Aware)
  Author:         ChatGPT + Aumuz Messick
  Version:        1.0
  Created:        2025-10-29
  Description:    From a source table containing item budgets (ACSBV3_doc_item_template), compute per-ItemLevel curve values by:
                   1) taking the median(budget_normalized) per (ItemLevel, Quality) within each expansion band,
                   2) applying a 3-point rolling median within each (Quality, Expansion) sequence,
                   3) applying monotonic non-decreasing enforcement within each (Quality, Expansion) sequence,
                   4) writing results to the target curve table.

                  Call example:
                    CALL ACSBV3_proc_smooth_curve(
                      'ACSBV3_doc_item_template',
                      'ACSBV3_ref_curve_equipment_final',
                      'Equipment'
                    );

                  Notes:
                   - Uses TEMPORARY TABLEs for clarity; all are session-scoped.
                   - Expansion map is defined inside and can be edited easily.
                   - Target table is dropped/recreated on each call.
======================================================================================================================================*/

DELIMITER $$

DROP PROCEDURE IF EXISTS ACSBV3_proc_smooth_curve $$
CREATE PROCEDURE ACSBV3_proc_smooth_curve(
  IN in_source_table  VARCHAR(128),
  IN in_target_table  VARCHAR(128),
  IN in_family        VARCHAR(16)   -- 'Equipment' or 'Weapon'
)
BEGIN
  /* ----------------------------
     0) Safety / house-keeping
     ---------------------------- */
  SET SESSION sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_ALL_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

  /* --------------------------------------
     1) Expansion map (edit as desired)
     -------------------------------------- */
  DROP TEMPORARY TABLE IF EXISTS tmp_expansion_map;
  CREATE TEMPORARY TABLE tmp_expansion_map (
    expansion_name VARCHAR(16) NOT NULL,
    ilvl_min       INT         NOT NULL,
    ilvl_max       INT         NOT NULL
  );

  INSERT INTO tmp_expansion_map (expansion_name, ilvl_min, ilvl_max) VALUES
    ('Classic',  1,   100),
    ('TBC',      101, 164),
    ('Wrath',    165, 300);

  /* ----------------------------------------------------------
     2) tmp_src: rows from the source for the requested family
        Columns: quality, itemlevel, budget_normalized, expansion
     ---------------------------------------------------------- */
  DROP TEMPORARY TABLE IF EXISTS tmp_src;
  SET @sql_src = CONCAT(
    'CREATE TEMPORARY TABLE tmp_src AS ',
    'SELECT s.Quality, s.ItemLevel, s.budget_normalized, m.expansion_name ',
    'FROM ', in_source_table, ' s ',
    'JOIN tmp_expansion_map m ON s.ItemLevel BETWEEN m.ilvl_min AND m.ilvl_max ',
    'WHERE s.family = ? AND s.budget_normalized IS NOT NULL AND s.budget_normalized > 0'
  );
  PREPARE stmt_src FROM @sql_src;
  SET @p_family = in_family;
  EXECUTE stmt_src USING @p_family;
  DEALLOCATE PREPARE stmt_src;

  /* ----------------------------------------------------------------
     3) tmp_median: per-(quality, itemlevel, expansion) median value
        (median via row-number trick; average of middle two if even)
     ---------------------------------------------------------------- */
  DROP TEMPORARY TABLE IF EXISTS tmp_median;
  CREATE TEMPORARY TABLE tmp_median AS
  SELECT
    Quality,
    ItemLevel,
    expansion_name,
    AVG(budget_normalized) AS median_value
  FROM (
    SELECT
      Quality,
      ItemLevel,
      expansion_name,
      budget_normalized,
      ROW_NUMBER() OVER (PARTITION BY Quality, ItemLevel, expansion_name ORDER BY budget_normalized)        AS rn,
      COUNT(*)    OVER (PARTITION BY Quality, ItemLevel, expansion_name)                                    AS cnt
    FROM tmp_src
  ) x
  WHERE rn IN (FLOOR((cnt+1)/2), FLOOR((cnt+2)/2))
  GROUP BY Quality, ItemLevel, expansion_name;

  /* -------------------------------------------------------------------------
     4) tmp_roll: apply 3-point rolling median within (quality, expansion)
        Rolling median of [prev, curr, next] using sum - min - max trick.
        Edge handling: if missing prev/next, use mean of available values.
     ------------------------------------------------------------------------- */
  DROP TEMPORARY TABLE IF EXISTS tmp_roll;
  CREATE TEMPORARY TABLE tmp_roll AS
  SELECT
    Quality,
    ItemLevel,
    expansion_name,
    median_value AS median_raw,

    LAG(median_value, 1)  OVER (PARTITION BY Quality, expansion_name ORDER BY ItemLevel) AS prev_val,
    median_value          AS curr_val,
    LEAD(median_value, 1) OVER (PARTITION BY Quality, expansion_name ORDER BY ItemLevel) AS next_val,

    /* Rolling median with edge handling */
    CASE
      WHEN LAG(median_value,1)  OVER (PARTITION BY Quality, expansion_name ORDER BY ItemLevel) IS NULL
       AND LEAD(median_value,1) OVER (PARTITION BY Quality, expansion_name ORDER BY ItemLevel) IS NULL
        THEN median_value
      WHEN LAG(median_value,1)  OVER (PARTITION BY Quality, expansion_name ORDER BY ItemLevel) IS NULL
        THEN (median_value + LEAD(median_value,1) OVER (PARTITION BY Quality, expansion_name ORDER BY ItemLevel)) / 2
      WHEN LEAD(median_value,1) OVER (PARTITION BY Quality, expansion_name ORDER BY ItemLevel) IS NULL
        THEN (LAG(median_value,1) OVER (PARTITION BY Quality, expansion_name ORDER BY ItemLevel) + median_value) / 2
      ELSE
        (LAG(median_value,1)  OVER (PARTITION BY Quality, expansion_name ORDER BY ItemLevel)
        + median_value
        + LEAD(median_value,1) OVER (PARTITION BY Quality, expansion_name ORDER BY ItemLevel))
        - GREATEST(
            LAG(median_value,1)  OVER (PARTITION BY Quality, expansion_name ORDER BY ItemLevel),
            median_value,
            LEAD(median_value,1) OVER (PARTITION BY Quality, expansion_name ORDER BY ItemLevel)
          )
        - LEAST(
            LAG(median_value,1)  OVER (PARTITION BY Quality, expansion_name ORDER BY ItemLevel),
            median_value,
            LEAD(median_value,1) OVER (PARTITION BY Quality, expansion_name ORDER BY ItemLevel)
          )
    END AS smoothed_3pt
  FROM tmp_median;

/* -------------------------------------------------------------
   5) tmp_monotonic: placeholder for external monotonic enforcement
      -----------------------------------------------------------
      Monotonic enforcement now handled externally in Python.
      This section only creates the working table structure and
      copies smoothed results so later stages can proceed.
   ------------------------------------------------------------- */

DROP TEMPORARY TABLE IF EXISTS tmp_monotonic;
CREATE TEMPORARY TABLE tmp_monotonic (
  Quality        TINYINT UNSIGNED,
  ItemLevel      SMALLINT UNSIGNED,
  expansion_name VARCHAR(16),
  median_raw     DOUBLE,
  smoothed_3pt   DOUBLE,
  curve_value    DOUBLE,
  PRIMARY KEY (Quality, expansion_name, ItemLevel)
);

-- Seed table with smoothed values, leave curve_value NULL for now
INSERT INTO tmp_monotonic (Quality, ItemLevel, expansion_name, median_raw, smoothed_3pt, curve_value)
SELECT Quality, ItemLevel, expansion_name, median_raw, smoothed_3pt, NULL
FROM tmp_roll
ORDER BY Quality, expansion_name, ItemLevel;

  /* ---------------------------------------------------------
     6) Create target table and write results
     --------------------------------------------------------- */
  SET @sql_drop = CONCAT('DROP TABLE IF EXISTS ', in_target_table);
  PREPARE stmt_drop FROM @sql_drop; EXECUTE stmt_drop; DEALLOCATE PREPARE stmt_drop;

  SET @sql_create = CONCAT(
    'CREATE TABLE ', in_target_table, ' (',
    '  family        VARCHAR(10)      COMMENT ''Equipment or Weapon'',',
    '  Quality       TINYINT UNSIGNED COMMENT ''0=Poor..4=Epic..'',',
    '  ItemLevel     SMALLINT UNSIGNED COMMENT ''Curve index (iLvl)'',',
    '  expansion     VARCHAR(16)      COMMENT ''Classic/TBC/Wrath segmentation'',',
    '  median_raw    DOUBLE           COMMENT ''Per-(iLvl,Quality) median of budget_normalized'',',
    '  smoothed_3pt  DOUBLE           COMMENT ''3-point rolling median within expansion'',',
    '  curve_value   DOUBLE           COMMENT ''Final monotonic curve value'',',
    '  PRIMARY KEY (family, Quality, ItemLevel)',
    ') ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci'
  );
  PREPARE stmt_create FROM @sql_create; EXECUTE stmt_create; DEALLOCATE PREPARE stmt_create;

  SET @sql_insert = CONCAT(
    'INSERT INTO ', in_target_table, ' (family, Quality, ItemLevel, expansion, median_raw, smoothed_3pt, curve_value) ',
    'SELECT ?, Quality, ItemLevel, expansion_name, median_raw, smoothed_3pt, curve_value ',
    'FROM tmp_monotonic ',
    'ORDER BY Quality, expansion_name, ItemLevel'
  );
  PREPARE stmt_insert FROM @sql_insert;
  SET @p_fam = in_family;
  EXECUTE stmt_insert USING @p_fam;
  DEALLOCATE PREPARE stmt_insert;

  /* -----------------------------------------
     7) Optional summary to confirm row counts
     ----------------------------------------- */
  SET @sql_verify = CONCAT(
    'SELECT family, Quality, MIN(ItemLevel) AS ilvl_min, MAX(ItemLevel) AS ilvl_max, ',
    'COUNT(*) AS points FROM ', in_target_table, ' ',
    'WHERE family = ? GROUP BY family, Quality ORDER BY Quality'
  );
  PREPARE stmt_verify FROM @sql_verify;
  EXECUTE stmt_verify USING @p_fam;
  DEALLOCATE PREPARE stmt_verify;

END $$
DELIMITER ;
