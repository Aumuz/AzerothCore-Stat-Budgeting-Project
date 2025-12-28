/*======================================================================================================================================
  Filename:       ACSBV3-04-00B.sql
  Title:          Create Documentation-Ready Item Template
  Author:         ChatGPT + Aumuz Messick
  Version:        1.0
  Created:        2025-10-28
  Description:    Generates ACSBV3_doc_item_template — the canonical documentation table replacing
                  ACSBV3_ref_items.  The structure mirrors AzerothCore's item_template up to the stat
                  fields and then appends ACSBV3-specific modifiers and budgets.

                  Includes:
                   - Encounter weight (for Phase 05)
                   - Drop, Slot, and Misc modifiers
                   - Family and Quality labels
                   - Actual and Normalized Budgets (for Phases 04–07)
----------------------------------------------------------------------------------------------------------------------------------------
  Notes:
   - Precision: 2 decimals for readability.
   - RandomProperty/Suffix items apply misc_mod = 0.65; all others = 1.00.
   - Order preserved for direct ID alignment with AzerothCore item_template.
   - Rows selected from ACSBV3_ref_items in ascending entry order.
   - Additional verification joins and analysis performed in Phase 04-02.
======================================================================================================================================*/


/*======================================================================================================================================
  1. Drop and Create Table
======================================================================================================================================*/

DROP TABLE IF EXISTS ACSBV3_doc_item_template;

CREATE TABLE ACSBV3_doc_item_template
(
  /* -------------------------------------------------------------------------------------------
     Core AzerothCore fields (trimmed to those relevant for budget analysis)
     ------------------------------------------------------------------------------------------- */
  `entry`          INT UNSIGNED      PRIMARY KEY COMMENT "Unique item ID (matches AzerothCore item_template).",
  `name`           VARCHAR(255)      COMMENT "Item name (developer readability).",
  `Quality`        TINYINT UNSIGNED  COMMENT "0–7 = Poor ? Legendary.",
  `ItemLevel`      SMALLINT UNSIGNED COMMENT "Primary independent variable (used in curve generation).",
  `RequiredLevel`  TINYINT UNSIGNED  COMMENT "Minimum player level to equip.",
  `class`          TINYINT UNSIGNED  COMMENT "2 = Weapons, 4 = Equipment.",
  `subclass`       TINYINT UNSIGNED  COMMENT "Weapon subclass or armor category.",
  `InventoryType`  TINYINT UNSIGNED  COMMENT "Equipment slot ID (1 = Head, 5 = Chest, etc.).",
  `SellPrice`      INT UNSIGNED      COMMENT "Vendor sell value in copper (Phase 06 use).",
  `BuyPrice`       BIGINT            COMMENT "Vendor purchase cost in copper (Phase 06 use).",
  `armor`          INT UNSIGNED      COMMENT "Base armor value used in budget calculations.",
  `dmg_min1`       FLOAT             COMMENT "Weapon minimum damage (budget input).",
  `dmg_max1`       FLOAT             COMMENT "Weapon maximum damage (budget input).",
  `delay`          SMALLINT UNSIGNED COMMENT "Weapon delay in ms (DPS normalization).",
  `socketBonus`    INT               COMMENT "Socket bonus ID (joins to ACSBV3_doc_cost_socket).",

  /* -------------------------------------------------------------------------------------------
     Stat block (kept for canonical compatibility with AzerothCore)
     ------------------------------------------------------------------------------------------- */
  `stat_type1`  TINYINT UNSIGNED,  `stat_value1`  INT,
  `stat_type2`  TINYINT UNSIGNED,  `stat_value2`  INT,
  `stat_type3`  TINYINT UNSIGNED,  `stat_value3`  INT,
  `stat_type4`  TINYINT UNSIGNED,  `stat_value4`  INT,
  `stat_type5`  TINYINT UNSIGNED,  `stat_value5`  INT,
  `stat_type6`  TINYINT UNSIGNED,  `stat_value6`  INT,
  `stat_type7`  TINYINT UNSIGNED,  `stat_value7`  INT,
  `stat_type8`  TINYINT UNSIGNED,  `stat_value8`  INT,
  `stat_type9`  TINYINT UNSIGNED,  `stat_value9`  INT,
  `stat_type10` TINYINT UNSIGNED,  `stat_value10` INT,

  /* -------------------------------------------------------------------------------------------
     Context & Modifier Fields
     ------------------------------------------------------------------------------------------- */
  `weight`           DOUBLE          COMMENT "Encounter-weighting factor (used in Phase 05 for iLvl progression; not part of budget).",
  `drop_environment` VARCHAR(7)      COMMENT "Drop environment source: 'World', 'Dungeon', or 'Raid'.",
  `source_type`      VARCHAR(10)     COMMENT "Origin of item: Vendor, Quest, Drop, etc.",
  `slot_mod`         DECIMAL(8,2)    COMMENT "Slot modifier from ACSBV3_doc_mod_slot_equipment or _weapons (Chest = 1.00 baseline).",
  `drop_mod`         DECIMAL(8,2)    COMMENT "Drop modifier from ACSBV3_doc_mod_drop (World = 1.00 baseline).",
  `misc_mod`         DECIMAL(8,2)    COMMENT "Affix visibility ratio (0.65 if RandomProperty/Suffix > 0, else 1.00).",
  `family`           VARCHAR(10)     COMMENT "Simplified classification: 'Equipment' or 'Weapon'.",
  `quality_name`     VARCHAR(10)     COMMENT "Human-readable quality tier: 'Common', 'Uncommon', 'Rare', 'Epic', etc.",

  /* -------------------------------------------------------------------------------------------
     Budget Fields (placed last for compatibility with verification results)
     ------------------------------------------------------------------------------------------- */
  `budget_actual`    DOUBLE          COMMENT "Actual stat budget (stat + armor + DPS value).",
  `budget_normalized`DOUBLE          COMMENT "Normalized stat budget (budget_actual / (slot_mod × drop_mod × misc_mod))."
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_general_ci;


/*======================================================================================================================================
  2. Populate Table
======================================================================================================================================*/

INSERT INTO ACSBV3_doc_item_template
(
  entry, name, Quality, ItemLevel, RequiredLevel,
  class, subclass, InventoryType,
  SellPrice, BuyPrice, armor, dmg_min1, dmg_max1, delay, socketBonus,
  stat_type1, stat_value1, stat_type2, stat_value2, stat_type3, stat_value3,
  stat_type4, stat_value4, stat_type5, stat_value5, stat_type6, stat_value6,
  stat_type7, stat_value7, stat_type8, stat_value8, stat_type9, stat_value9,
  stat_type10, stat_value10,
  weight, drop_environment, source_type,
  slot_mod, drop_mod, misc_mod, family, quality_name,
  budget_actual, budget_normalized
)
SELECT
  r.entry, r.name, r.Quality, r.ItemLevel, r.RequiredLevel,
  r.class, r.subclass, r.InventoryType,
  r.SellPrice, r.BuyPrice, r.armor, r.dmg_min1, r.dmg_max1, r.delay, r.socketBonus,
  r.stat_type1, r.stat_value1, r.stat_type2, r.stat_value2, r.stat_type3, r.stat_value3,
  r.stat_type4, r.stat_value4, r.stat_type5, r.stat_value5, r.stat_type6, r.stat_value6,
  r.stat_type7, r.stat_value7, r.stat_type8, r.stat_value8, r.stat_type9, r.stat_value9,
  r.stat_type10, r.stat_value10,
  r.weight, r.drop_environment, r.source_type,

  /* Slot modifier (equipment or weapon) */
  COALESCE(se.multiplier, sw.multiplier, 1.00) AS slot_mod,

  /* Drop modifier (environment) */
  COALESCE(d.multiplier, 1.00) AS drop_mod,

  /* Misc modifier (random affix correction) */
  CASE WHEN (r.RandomProperty > 0 OR r.RandomSuffix > 0) THEN 0.65 ELSE 1.00 END AS misc_mod,

  /* Family classification */
  CASE WHEN r.class = 2 THEN 'Weapon' ELSE 'Equipment' END AS family,

  /* Quality name for readability */
  CASE r.Quality
    WHEN 0 THEN 'Poor' WHEN 1 THEN 'Common' WHEN 2 THEN 'Uncommon' WHEN 3 THEN 'Rare'
    WHEN 4 THEN 'Epic' WHEN 5 THEN 'Legendary' ELSE 'Other' END AS quality_name,

  /* Placeholder budget calculations (to be expanded in later scripts) */
  NULL AS budget_actual,
  NULL AS budget_normalized

FROM ACSBV3_ref_items r
LEFT JOIN ACSBV3_doc_mod_slot_equipment se ON r.InventoryType = se.InventoryType
LEFT JOIN ACSBV3_doc_mod_slot_weapons   sw ON r.subclass = sw.subclass
LEFT JOIN ACSBV3_doc_mod_drop           d  ON r.drop_environment = d.drop_environment
ORDER BY r.entry ASC;


/*======================================================================================================================================
  3. Verification Block
     - Row count and quick sample output for diagnostic purposes.
======================================================================================================================================*/

SELECT
  COUNT(*)         AS total_rows,
  SUM(CASE WHEN misc_mod < 1.00 THEN 1 ELSE 0 END) AS random_affix_items,
  ROUND(AVG(slot_mod),2) AS avg_slotmod,
  ROUND(AVG(drop_mod),2) AS avg_dropmod
FROM ACSBV3_doc_item_template;

SELECT * FROM ACSBV3_doc_item_template LIMIT 10;


/*======================================================================================================================================
  End of File
======================================================================================================================================*/
