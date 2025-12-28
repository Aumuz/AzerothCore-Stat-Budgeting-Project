/*============================================================================================
  Filename:       ACSBV3-01-20A.sql
  Title:          Phase 01 – Weapon Stat Cost Expansion (Extraction and Expansion)
  Author:         ChatGPT + Aumuz Messick
  Version:        1.0
  Created:        2025-10-22
  Description:    Extracts all valid weapons from ACSBV3_ref_items and expands the ten
                  stat_type/stat_value pairs into a long-form dataset for unweighted
                  Stat ? Budget analysis.  Adds derived DPS fields for later normalization.
----------------------------------------------------------------------------------------------
  Notes:
   - Processes weapon class (class = 2) only.
   - Excludes fishing poles and miscellaneous subclasses.
   - Each stat pair (stat_typeX/stat_valueX) is expanded into its own row.
   - Derived field: DPS = (dmg_min1 + dmg_max1) / 2 / (delay / 1000).
   - Weighted or normalized values are not applied in this sub-phase.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS ACSBV3_01_20A_stat_cost_weapons;

CREATE TABLE ACSBV3_01_20A_stat_cost_weapons AS
SELECT
    entry,
    name,
    Quality,
    ItemLevel,
    subclass,
    InventoryType,
    dmg_min1,
    dmg_max1,
    delay,
    ROUND((dmg_min1 + dmg_max1) / 2 / (delay / 1000), 3) AS dps,
    stat_type1  AS stat_type,
    stat_value1 AS stat_value
FROM ACSBV3_ref_items
WHERE class = 2
  AND subclass NOT IN (14,16)                -- exclude fishing poles, misc
  AND InventoryType NOT IN (0,18,19,23,24)
  AND stat_type1 <> 0

UNION ALL
SELECT entry,name,Quality,ItemLevel,subclass,InventoryType,
       dmg_min1,dmg_max1,delay,
       ROUND((dmg_min1 + dmg_max1) / 2 / (delay / 1000), 3),
       stat_type2,stat_value2
FROM ACSBV3_ref_items
WHERE class = 2 AND subclass NOT IN (14,16)
  AND InventoryType NOT IN (0,18,19,23,24)
  AND stat_type2 <> 0

UNION ALL
SELECT entry,name,Quality,ItemLevel,subclass,InventoryType,
       dmg_min1,dmg_max1,delay,
       ROUND((dmg_min1 + dmg_max1) / 2 / (delay / 1000), 3),
       stat_type3,stat_value3
FROM ACSBV3_ref_items
WHERE class = 2 AND subclass NOT IN (14,16)
  AND InventoryType NOT IN (0,18,19,23,24)
  AND stat_type3 <> 0

UNION ALL
SELECT entry,name,Quality,ItemLevel,subclass,InventoryType,
       dmg_min1,dmg_max1,delay,
       ROUND((dmg_min1 + dmg_max1) / 2 / (delay / 1000), 3),
       stat_type4,stat_value4
FROM ACSBV3_ref_items
WHERE class = 2 AND subclass NOT IN (14,16)
  AND InventoryType NOT IN (0,18,19,23,24)
  AND stat_type4 <> 0

UNION ALL
SELECT entry,name,Quality,ItemLevel,subclass,InventoryType,
       dmg_min1,dmg_max1,delay,
       ROUND((dmg_min1 + dmg_max1) / 2 / (delay / 1000), 3),
       stat_type5,stat_value5
FROM ACSBV3_ref_items
WHERE class = 2 AND subclass NOT IN (14,16)
  AND InventoryType NOT IN (0,18,19,23,24)
  AND stat_type5 <> 0

UNION ALL
SELECT entry,name,Quality,ItemLevel,subclass,InventoryType,
       dmg_min1,dmg_max1,delay,
       ROUND((dmg_min1 + dmg_max1) / 2 / (delay / 1000), 3),
       stat_type6,stat_value6
FROM ACSBV3_ref_items
WHERE class = 2 AND subclass NOT IN (14,16)
  AND InventoryType NOT IN (0,18,19,23,24)
  AND stat_type6 <> 0

UNION ALL
SELECT entry,name,Quality,ItemLevel,subclass,InventoryType,
       dmg_min1,dmg_max1,delay,
       ROUND((dmg_min1 + dmg_max1) / 2 / (delay / 1000), 3),
       stat_type7,stat_value7
FROM ACSBV3_ref_items
WHERE class = 2 AND subclass NOT IN (14,16)
  AND InventoryType NOT IN (0,18,19,23,24)
  AND stat_type7 <> 0

UNION ALL
SELECT entry,name,Quality,ItemLevel,subclass,InventoryType,
       dmg_min1,dmg_max1,delay,
       ROUND((dmg_min1 + dmg_max1) / 2 / (delay / 1000), 3),
       stat_type8,stat_value8
FROM ACSBV3_ref_items
WHERE class = 2 AND subclass NOT IN (14,16)
  AND InventoryType NOT IN (0,18,19,23,24)
  AND stat_type8 <> 0

UNION ALL
SELECT entry,name,Quality,ItemLevel,subclass,InventoryType,
       dmg_min1,dmg_max1,delay,
       ROUND((dmg_min1 + dmg_max1) / 2 / (delay / 1000), 3),
       stat_type9,stat_value9
FROM ACSBV3_ref_items
WHERE class = 2 AND subclass NOT IN (14,16)
  AND InventoryType NOT IN (0,18,19,23,24)
  AND stat_type9 <> 0

UNION ALL
SELECT entry,name,Quality,ItemLevel,subclass,InventoryType,
       dmg_min1,dmg_max1,delay,
       ROUND((dmg_min1 + dmg_max1) / 2 / (delay / 1000), 3),
       stat_type10,stat_value10
FROM ACSBV3_ref_items
WHERE class = 2 AND subclass NOT IN (14,16)
  AND InventoryType NOT IN (0,18,19,23,24)
  AND stat_type10 <> 0
;

/*--------------------------------------------------------------------------------------------
  Verification Queries
--------------------------------------------------------------------------------------------*/

-- Confirm total record count
SELECT COUNT(*) AS total_rows FROM ACSBV3_01_20A_stat_cost_weapons;

-- Distribution of stat types
SELECT stat_type, COUNT(*) AS occurrences
FROM ACSBV3_01_20A_stat_cost_weapons
GROUP BY stat_type
ORDER BY stat_type;

-- Average DPS by weapon subclass
SELECT subclass, ROUND(AVG(dps),3) AS avg_dps, COUNT(*) AS items
FROM ACSBV3_01_20A_stat_cost_weapons
GROUP BY subclass
ORDER BY subclass;

-- Top 10 weapons by DPS (diagnostic)
SELECT entry, name, ItemLevel, subclass, dps
FROM ACSBV3_01_20A_stat_cost_weapons
ORDER BY dps DESC
LIMIT 10;

/*============================================================================================
  End of File
============================================================================================*/
