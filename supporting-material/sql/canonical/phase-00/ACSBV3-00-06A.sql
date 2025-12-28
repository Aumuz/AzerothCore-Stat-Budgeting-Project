/*============================================================================================
Filename:       ACSBV3-00-06A.sql
Title:          Phase 00 – Source Linkage (Crafted / Residual Items)
Author:         ChatGPT + Aumuz Messick
Version:        1.2
Created:        2025-10-20
Description:    Identifies items not present in any prior Phase 00 weighted datasets.
                Includes Legendary audit for verification.
----------------------------------------------------------------------------------------------
Notes:
 - v1.1 attempt used NOT IN (…) with UNION subquery; some MySQL builds still mis-handle
   outer alias resolution. Switched to LEFT JOIN anti-join and quoted it.`name`.
 - v1.2 Switched residual filter to LEFT JOIN anti-join and quoted it.`name`.
        This avoids MySQL alias resolution issues seen with NOT IN (…) + UNION.
        No logic change; structural compatibility fix.
 - v1.3 Corrected column reference from it.name ? it.ItemName to match schema of
        ACSBV3_00_00A_raw_items. No logic change; resolves column mismatch error.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS ACSBV3_00_06A_crafted_src;

CREATE TABLE ACSBV3_00_06A_crafted_src AS
SELECT DISTINCT
    it.ItemID,
    it.ItemName,
    it.Quality,
    it.ItemLevel,
    it.RequiredLevel,
    'World' AS drop_environment,
    1.00 AS encounter_weight_base,
    1 AS encounters_per_week,
    'Crafted' AS source_type,
    NOW() AS date_linked
FROM ACSBV3_00_00A_raw_items AS it
LEFT JOIN (
    SELECT ItemID FROM ACSBV3_00_01B_weighted_creature
    UNION
    SELECT ItemID FROM ACSBV3_00_02B_weighted_gameobject
    UNION
    SELECT ItemID FROM ACSBV3_00_03B_weighted_itemloot
    UNION
    SELECT ItemID FROM ACSBV3_00_04B_weighted_vendor
    UNION
    SELECT ItemID FROM ACSBV3_00_05B_weighted_quest
) AS src ON src.ItemID = it.ItemID
WHERE src.ItemID IS NULL;

/*============================================================================================
Verification Block
----------------------------------------------------------------------------------------------
 - Totals and Legendary audit
============================================================================================*/

SELECT COUNT(*) AS total_residual_items,
       COUNT(DISTINCT ItemID) AS distinct_items
FROM ACSBV3_00_06A_crafted_src;

-- Legendary audit (expect exactly 1: Sulfuras, Hand of Ragnaros)
SELECT COUNT(*) AS legendary_count
FROM ACSBV3_00_06A_crafted_src
WHERE Quality = 5;

SELECT ItemID, ItemName, ItemLevel, RequiredLevel
FROM ACSBV3_00_06A_crafted_src
WHERE Quality = 5
ORDER BY ItemLevel DESC;

/*============================================================================================
End of File
============================================================================================*/
