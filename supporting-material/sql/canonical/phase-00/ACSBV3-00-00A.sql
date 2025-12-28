/*============================================================================================
Filename:       ACSBV3-00-00A.sql
Title:          Phase 00 – Raw Extraction (Item Template Filter)
Author:         ChatGPT + Aumuz Messick
Version:        1.0
Created:        2025-10-19
Description:    Extracts all valid, obtainable equipment and weapons from `item_template`
                to establish the baseline dataset for Phase 00 – Data Collection.
----------------------------------------------------------------------------------------------
Notes:
 - Derived fields are generated for slot grouping and weapon classification.
 - Filters exclude test, deprecated, cosmetic, and unobtainable items.
 - Results feed directly into Phase 00 step 01A (Source Linkage).
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS ACSBV3_00_00A_raw_items;

CREATE TABLE ACSBV3_00_00A_raw_items AS
SELECT
    it.entry                        AS ItemID,
    it.name                         AS ItemName,
    it.class,
    it.subclass,
    it.Quality,
    it.ItemLevel,
    it.RequiredLevel,
    it.InventoryType,
    it.bonding,
    it.BuyPrice,
    it.SellPrice,
    it.BuyCount,
    it.Flags,
    it.FlagsExtra,
    it.RequiredSkill,
    it.RequiredSkillRank,
    it.RequiredSpell,
    it.RequiredReputationFaction,
    it.RequiredReputationRank,
    it.armor,
    it.delay,
    it.ammo_type,
    it.dmg_min1,
    it.dmg_max1,
    it.dmg_type1,
    it.socketColor_1,
    it.socketColor_2,
    it.socketColor_3,
    it.socketBonus,
    it.stat_type1, it.stat_value1,
    it.stat_type2, it.stat_value2,
    it.stat_type3, it.stat_value3,
    it.stat_type4, it.stat_value4,
    it.stat_type5, it.stat_value5,
    it.stat_type6, it.stat_value6,
    it.stat_type7, it.stat_value7,
    it.stat_type8, it.stat_value8,
    it.stat_type9, it.stat_value9,
    it.stat_type10, it.stat_value10,
    /*----------------------------------------------------------------------
      Derived fields for Phase 00 and beyond
    ----------------------------------------------------------------------*/
    CASE WHEN it.class = 2 THEN 1 ELSE 0 END                                  AS is_weapon,
    CASE
        WHEN it.InventoryType IN (1,3,5,6,7,8,9,10) THEN 'Armor'
        WHEN it.InventoryType IN (11,12,13,14,15,16,17,21,22,23,25,26) THEN 'Weapon'
        ELSE 'Misc'
    END                                                                       AS slot_group,
    CASE
        WHEN it.subclass IN (1) THEN 'Cloth'
        WHEN it.subclass IN (2) THEN 'Leather'
        WHEN it.subclass IN (3) THEN 'Mail'
        WHEN it.subclass IN (4) THEN 'Plate'
        WHEN it.class = 2 THEN 'Weapon'
        ELSE 'Other'
    END                                                                       AS slot_weight_class
FROM item_template AS it
WHERE
    it.Quality BETWEEN 1 AND 5
    AND it.ItemLevel BETWEEN 5 AND 400
    AND it.RequiredLevel BETWEEN 5 AND 80
    AND (
        (it.class = 2 AND it.subclass NOT IN (9, 14, 20))             /* weapons excluding wands, fishing poles, misc */
        OR
        (it.class = 4 AND it.InventoryType NOT IN (0, 4, 12, 18, 19, 24, 27, 28))  /* armor excluding none/shirt/bag/tabard/etc */
    )
    AND (it.Flags & 2048) = 0
    AND it.name NOT LIKE '%TEST%'
    AND it.name NOT LIKE '%DEPRECATED%'
    AND it.name NOT LIKE '%PLACEHOLDER%'
    AND (it.description IS NULL OR (
        it.description NOT LIKE '%TEST%'
        AND it.description NOT LIKE '%DEPRECATED%'
        AND it.description NOT LIKE '%PLACEHOLDER%'
    ))
    AND NOT (it.SellPrice = 0 AND it.BuyPrice = 0 AND it.bonding = 0);   /* Exclude unobtainable dev items */

/*============================================================================================
Verification Block
----------------------------------------------------------------------------------------------
 - Basic sanity checks to confirm dataset size and structure.
============================================================================================*/

SELECT COUNT(*) AS total_items FROM ACSBV3_00_00A_raw_items;

SELECT
    Quality,
    class,
    COUNT(*) AS count_per_group
FROM ACSBV3_00_00A_raw_items
GROUP BY Quality, class
ORDER BY Quality, class;

SELECT
    slot_group,
    slot_weight_class,
    COUNT(*) AS count_per_slot
FROM ACSBV3_00_00A_raw_items
GROUP BY slot_group, slot_weight_class
ORDER BY slot_group, slot_weight_class;

/*============================================================================================
End of File
============================================================================================*/
