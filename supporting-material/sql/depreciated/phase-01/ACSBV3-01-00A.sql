/*============================================================================================
  Filename:       ACSBV3-01-00A.sql
  Title:          Phase 01 – Equipment Stat Cost Expansion (Extraction and Expansion)
  Author:         ChatGPT + Aumuz Messick
  Version:        1.0
  Created:        2025-10-21
  Description:    Extracts all valid equipment from ACSBV3_ref_items and expands the ten
                  stat_type/stat_value pairs into a long-form dataset for unweighted
                  Stat ? Budget analysis.
----------------------------------------------------------------------------------------------
  Notes:
   - This script processes only equipment (class = 4), excluding trinkets, relics, shirts,
     tabards, and bags.
   - Each stat pair (stat_typeX/stat_valueX) is expanded into its own row.
   - Weighted values are not applied in this sub-phase.
   - Armor, sockets, resistances, and bonuses will be handled in later sub-steps.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS ACSBV3_01_00A_stat_cost_equipment;

CREATE TABLE ACSBV3_01_00A_stat_cost_equipment AS
SELECT entry,
       name,
       Quality,
       ItemLevel,
       InventoryType,
       stat_type1  AS stat_type,
       stat_value1 AS stat_value
FROM ACSBV3_ref_items
WHERE class = 4
  AND subclass NOT IN (8, 11)              -- Exclude trinkets, relics
  AND InventoryType NOT IN (0, 18, 19, 23, 24)
  AND stat_type1 <> 0

UNION ALL
SELECT entry, name, Quality, ItemLevel, InventoryType, stat_type2, stat_value2
FROM ACSBV3_ref_items
WHERE class = 4 AND subclass NOT IN (8, 11)
  AND InventoryType NOT IN (0, 18, 19, 23, 24)
  AND stat_type2 <> 0

UNION ALL
SELECT entry, name, Quality, ItemLevel, InventoryType, stat_type3, stat_value3
FROM ACSBV3_ref_items
WHERE class = 4 AND subclass NOT IN (8, 11)
  AND InventoryType NOT IN (0, 18, 19, 23, 24)
  AND stat_type3 <> 0

UNION ALL
SELECT entry, name, Quality, ItemLevel, InventoryType, stat_type4, stat_value4
FROM ACSBV3_ref_items
WHERE class = 4 AND subclass NOT IN (8, 11)
  AND InventoryType NOT IN (0, 18, 19, 23, 24)
  AND stat_type4 <> 0

UNION ALL
SELECT entry, name, Quality, ItemLevel, InventoryType, stat_type5, stat_value5
FROM ACSBV3_ref_items
WHERE class = 4 AND subclass NOT IN (8, 11)
  AND InventoryType NOT IN (0, 18, 19, 23, 24)
  AND stat_type5 <> 0

UNION ALL
SELECT entry, name, Quality, ItemLevel, InventoryType, stat_type6, stat_value6
FROM ACSBV3_ref_items
WHERE class = 4 AND subclass NOT IN (8, 11)
  AND InventoryType NOT IN (0, 18, 19, 23, 24)
  AND stat_type6 <> 0

UNION ALL
SELECT entry, name, Quality, ItemLevel, InventoryType, stat_type7, stat_value7
FROM ACSBV3_ref_items
WHERE class = 4 AND subclass NOT IN (8, 11)
  AND InventoryType NOT IN (0, 18, 19, 23, 24)
  AND stat_type7 <> 0

UNION ALL
SELECT entry, name, Quality, ItemLevel, InventoryType, stat_type8, stat_value8
FROM ACSBV3_ref_items
WHERE class = 4 AND subclass NOT IN (8, 11)
  AND InventoryType NOT IN (0, 18, 19, 23, 24)
  AND stat_type8 <> 0

UNION ALL
SELECT entry, name, Quality, ItemLevel, InventoryType, stat_type9, stat_value9
FROM ACSBV3_ref_items
WHERE class = 4 AND subclass NOT IN (8, 11)
  AND InventoryType NOT IN (0, 18, 19, 23, 24)
  AND stat_type9 <> 0

UNION ALL
SELECT entry, name, Quality, ItemLevel, InventoryType, stat_type10, stat_value10
FROM ACSBV3_ref_items
WHERE class = 4 AND subclass NOT IN (8, 11)
  AND InventoryType NOT IN (0, 18, 19, 23, 24)
  AND stat_type10 <> 0
;

/*--------------------------------------------------------------------------------------------
  Verification Query:
  Confirms total rows and distribution of stat types.
--------------------------------------------------------------------------------------------*/
SELECT COUNT(*) AS total_rows FROM ACSBV3_01_00A_stat_cost_equipment;

SELECT stat_type, COUNT(*) AS occurrences
FROM ACSBV3_01_00A_stat_cost_equipment
GROUP BY stat_type
ORDER BY stat_type;

/*============================================================================================
  End of File
============================================================================================*/
