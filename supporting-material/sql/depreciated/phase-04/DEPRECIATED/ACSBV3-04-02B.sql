/*======================================================================================================================================
  Filename:       ACSBV3-04-02B.sql
  Title:          Normalized Budget Verification – Summary Procedure
  Author:         ChatGPT + Aumuz Messick
  Version:        1.0
  Created:        2025-10-31
  Description:    Aggregates verification results (04-02A) into layered summaries.
                  Reports average deviation statistics by multiple grouping levels.

  Notes:
   • Operates entirely in normalized space – no slot/drop/misc modifiers applied here.
   • Source table: ACSBV3_04_02A_verification_normalized
   • Target table: ACSBV3_04_02B_summary_normalized
   • Each grouping layer shows progressively finer diagnostic detail.
   • Precision: analytical (DOUBLE, ~3–5 decimals).  Final _doc_ exports will round to 2 decimals.

======================================================================================================================================*/


/*======================================================================================================================================
  1. Drop Old Objects (safe re-run)
======================================================================================================================================*/
DROP PROCEDURE IF EXISTS ACSBV3_proc_verify_curve_fit;
DROP TABLE IF EXISTS ACSBV3_04_02B_summary_normalized;


/*======================================================================================================================================
  2. Create Summary Table
======================================================================================================================================*/
CREATE TABLE ACSBV3_04_02B_summary_normalized
(
  group_level     TINYINT        COMMENT "1-5 hierarchy level (see procedure comments).",
  family          VARCHAR(10)    COMMENT "Equipment or Weapon.",
  Quality         TINYINT        COMMENT "0–7 = Poor–Legendary.",
  ItemLevel       SMALLINT       COMMENT "Item Level range midpoint for this group.",
  InventoryType   TINYINT        COMMENT "Equipment slot (NULL if not applicable).",
  subclass        TINYINT        COMMENT "Weapon subclass (NULL if not applicable).",
  drop_environment VARCHAR(7)    COMMENT "World/Dungeon/Raid (NULL if not applicable).",
  random_property  TINYINT       COMMENT "1 = RandomProperty/Suffix > 0 else 0 (NULL if not applied).",
  avg_budget_diff  DOUBLE        COMMENT "Mean (Observed - Target) normalized budget.",
  avg_budget_percent DOUBLE      COMMENT "Mean (Observed / Target × 100).",
  avg_abs_percent   DOUBLE       COMMENT "Mean |Deviation| percentage (MAPE proxy).",
  n_items           INT          COMMENT "Number of items in group."
);


/*======================================================================================================================================
  3. Create Stored Procedure
======================================================================================================================================*/
DELIMITER $$

CREATE PROCEDURE ACSBV3_proc_verify_curve_fit()
BEGIN

  /*--------------------------------------------------------------------------------------------
    Level 1 – iLvl + Quality (global fit per tier)
  --------------------------------------------------------------------------------------------*/
  INSERT INTO ACSBV3_04_02B_summary_normalized
  SELECT
      1 AS group_level,
      family, Quality,
      ItemLevel,
      NULL, NULL, NULL, NULL,
      AVG(budget_diff),
      AVG(budget_percent),
      AVG(abs_percent),
      COUNT(*)
  FROM ACSBV3_04_02A_verification_normalized
  GROUP BY family, Quality, ItemLevel;

  /*--------------------------------------------------------------------------------------------
    Level 2 – iLvl + Quality + Equipment Slot
  --------------------------------------------------------------------------------------------*/
  INSERT INTO ACSBV3_04_02B_summary_normalized
  SELECT
      2 AS group_level,
      family, Quality,
      ItemLevel,
      InventoryType, NULL, NULL, NULL,
      AVG(budget_diff),
      AVG(budget_percent),
      AVG(abs_percent),
      COUNT(*)
  FROM ACSBV3_04_02A_verification_normalized
  WHERE family='Equipment'
  GROUP BY family, Quality, ItemLevel, InventoryType;

  /*--------------------------------------------------------------------------------------------
    Level 2b – iLvl + Quality + Weapon Subclass
  --------------------------------------------------------------------------------------------*/
  INSERT INTO ACSBV3_04_02B_summary_normalized
  SELECT
      2 AS group_level,
      family, Quality,
      ItemLevel,
      NULL AS InventoryType,
      subclass,
      NULL AS drop_environment,
      NULL AS random_property,
      AVG(budget_diff),
      AVG(budget_percent),
      AVG(abs_percent),
      COUNT(*)
  FROM ACSBV3_04_02A_verification_normalized
  WHERE family='Weapon'
  GROUP BY family, Quality, ItemLevel, subclass;


  /*--------------------------------------------------------------------------------------------
    Level 3 – iLvl + Quality + Drop
  --------------------------------------------------------------------------------------------*/
  INSERT INTO ACSBV3_04_02B_summary_normalized
  SELECT
      3 AS group_level,
      family, Quality,
      ItemLevel,
      NULL, NULL, drop_environment, NULL,
      AVG(budget_diff),
      AVG(budget_percent),
      AVG(abs_percent),
      COUNT(*)
  FROM ACSBV3_04_02A_verification_normalized
  GROUP BY family, Quality, ItemLevel, drop_environment;

  /*--------------------------------------------------------------------------------------------
    Level 4 – iLvl + Quality + Drop + Equipment Slot
  --------------------------------------------------------------------------------------------*/
  INSERT INTO ACSBV3_04_02B_summary_normalized
  SELECT
      4 AS group_level,
      family, Quality,
      ItemLevel,
      InventoryType, NULL, drop_environment, NULL,
      AVG(budget_diff),
      AVG(budget_percent),
      AVG(abs_percent),
      COUNT(*)
  FROM ACSBV3_04_02A_verification_normalized
  WHERE family='Equipment'
  GROUP BY family, Quality, ItemLevel, drop_environment, InventoryType;

  /*--------------------------------------------------------------------------------------------
    Level 4b – iLvl + Quality + Drop + Weapon Subclass
  --------------------------------------------------------------------------------------------*/
  INSERT INTO ACSBV3_04_02B_summary_normalized
  SELECT
      4 AS group_level,
      family, Quality,
      ItemLevel,
      NULL AS InventoryType,
      subclass,
      drop_environment,
      NULL AS random_property,
      AVG(budget_diff),
      AVG(budget_percent),
      AVG(abs_percent),
      COUNT(*)
  FROM ACSBV3_04_02A_verification_normalized
  WHERE family='Weapon'
  GROUP BY family, Quality, ItemLevel, drop_environment, subclass;

  /*--------------------------------------------------------------------------------------------
    Level 5 – iLvl + Quality + Drop + Slot + RandomProperty
  --------------------------------------------------------------------------------------------*/
  INSERT INTO ACSBV3_04_02B_summary_normalized
  SELECT
      5 AS group_level,
      family, Quality,
      ItemLevel,
      InventoryType, subclass, drop_environment, random_property,
      AVG(budget_diff),
      AVG(budget_percent),
      AVG(abs_percent),
      COUNT(*)
  FROM ACSBV3_04_02A_verification_normalized
  GROUP BY family, Quality, ItemLevel, drop_environment, InventoryType, subclass, random_property;

END$$

DELIMITER ;


/*======================================================================================================================================
  4. Verification Block
======================================================================================================================================*/

-- Run procedure to populate summary table
CALL ACSBV3_proc_verify_curve_fit();

-- Quick sanity check
SELECT
    group_level,
    ROUND(AVG(avg_abs_percent),2) AS mean_abs_dev,
    COUNT(DISTINCT CONCAT(family,'-',Quality,'-',ItemLevel)) AS n_groups
FROM ACSBV3_04_02B_summary_normalized
GROUP BY group_level
ORDER BY group_level;


/*======================================================================================================================================
  End of File
======================================================================================================================================*/
