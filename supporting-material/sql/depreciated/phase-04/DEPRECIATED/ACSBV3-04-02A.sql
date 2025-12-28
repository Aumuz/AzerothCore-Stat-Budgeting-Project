/*======================================================================================================================================
  Filename:       ACSBV3-04-02A.sql
  Title:          Normalized Budget Verification – Per-Item Comparison
  Author:         ChatGPT + Aumuz Messick
  Version:        1.0
  Created:        2025-10-31
  Description:    Compares each item’s normalized budget to its target curve value.
                  Calculates difference and deviation metrics for analytical verification.

  Notes:
   • Compares normalized budgets ONLY – modifiers (slot, drop, misc) already applied upstream.
   • Joins ACSBV3_doc_item_template to ACSBV3_ref_curve_<family>_final_fixed by ItemLevel + Quality + family.
   • Outputs per-item deviation metrics; used by 04-02B summary procedure.
   • Precision: analytical (DOUBLE, ~3–5 decimals).  Final _doc_ exports will use 2-decimal precision.

======================================================================================================================================*/


/*======================================================================================================================================
  1. Create Table: ACSBV3_04_02A_verification_normalized
     Purpose: Store per-item normalized-space verification results.
======================================================================================================================================*/

DROP TABLE IF EXISTS ACSBV3_04_02A_verification_normalized;

CREATE TABLE ACSBV3_04_02A_verification_normalized
(
  entry            INT UNSIGNED PRIMARY KEY COMMENT "Item ID (from ACSBV3_doc_item_template).",
  name             VARCHAR(255)              COMMENT "Item name for manual lookup of outliers.",
  family           VARCHAR(10)               COMMENT "Equipment or Weapon (join selector).",
  Quality          TINYINT UNSIGNED          COMMENT "0–7 = Poor–Legendary.",
  ItemLevel        SMALLINT UNSIGNED         COMMENT "Item Level (curve index).",
  budget_normalized DOUBLE                   COMMENT "Observed normalized budget (from _doc_item_template).",
  curve_value       DOUBLE                   COMMENT "Target curve value (from _final_fixed curve table).",
  budget_diff       DOUBLE                   COMMENT "Observed - Target (normalized space).",
  budget_percent    DOUBLE                   COMMENT "(Observed / Target) * 100.",
  abs_diff          DOUBLE                   COMMENT "Absolute difference (for MAE diagnostics).",
  abs_percent       DOUBLE                   COMMENT "Absolute percent deviation from target (for MAPE).",
  drop_environment  VARCHAR(7)               COMMENT "World, Dungeon, Raid – used for summary grouping.",
  InventoryType     TINYINT UNSIGNED         COMMENT "Equipment slot ID (used in 04-02B summaries).",
  subclass          TINYINT UNSIGNED         COMMENT "Weapon subclass ID (used in 04-02B summaries).",
  random_property   TINYINT                  COMMENT "1 = RandomProperty/Suffix > 0, else 0."
);


/*======================================================================================================================================
  2. Populate Verification Table
     Logic:
       • Join ACSBV3_doc_item_template (observed budgets)
         to the appropriate curve table based on `family`.
       • Compute difference and deviation metrics.
======================================================================================================================================*/

INSERT INTO ACSBV3_04_02A_verification_normalized
SELECT
    a.entry,
    a.name,
    a.family,
    a.Quality,
    a.ItemLevel,
    a.budget_normalized,
    b.curve_value,
    (a.budget_normalized - b.curve_value) AS budget_diff,
    (a.budget_normalized / b.curve_value * 100) AS budget_percent,
    ABS(a.budget_normalized - b.curve_value) AS abs_diff,
    ABS((a.budget_normalized / b.curve_value * 100) - 100) AS abs_percent,
    a.drop_environment,
    a.InventoryType,
    a.subclass,
    IF(a.misc_mod < 1.00, 1, 0) AS random_property
FROM ACSBV3_doc_item_template AS a
JOIN (
      SELECT * FROM ACSBV3_ref_curve_equipment_final_fixed
      UNION ALL
      SELECT * FROM ACSBV3_ref_curve_weapons_final_fixed
     ) AS b
  ON  a.family     = b.family
  AND a.Quality    = b.Quality
  AND a.ItemLevel  = b.ItemLevel;


/*======================================================================================================================================
  3. Verification Block
     Quick health check to ensure data integrity and curve-fit quality.
======================================================================================================================================*/

-- Verify expected row count alignment
SELECT COUNT(*) AS total_rows FROM ACSBV3_04_02A_verification_normalized;

-- Basic deviation summary by quality tier
SELECT
    Quality,
    ROUND(AVG(abs_percent),2) AS avg_deviation_percent,
    ROUND(MAX(abs_percent),2) AS max_deviation_percent,
    COUNT(*)                  AS n_items
FROM ACSBV3_04_02A_verification_normalized
GROUP BY Quality
ORDER BY Quality;


/*======================================================================================================================================
  End of File
======================================================================================================================================*/
