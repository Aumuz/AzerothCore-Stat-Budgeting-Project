/*============================================================================================
Filename:       ACSBV3-00-04A.sql
Title:          Phase 00 – Source Linkage (Vendors)
Author:         ChatGPT + Aumuz Messick
Version:        1.0
Created:        2025-10-20
Description:    Maps valid items from ACSBV3_00_00A_raw_items to vendor sources.
                Classifies vendors by stock type (limited/unlimited) and sets initial
                encounter/environment context for weighting in 00-04B.
----------------------------------------------------------------------------------------------
Notes:
 - Links npc_vendor.item ? creature_template.entry (vendor definition).
 - Incorporates limited-stock and restock-time data where available.
 - Environment defaults to 'World'; weighting handled in next step.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS ACSBV3_00_04A_vendor_src;

CREATE TABLE ACSBV3_00_04A_vendor_src AS
SELECT
    it.ItemID,
    nv.entry              AS vendor_entry,
    COALESCE(ct.name, 'Unknown Vendor') AS vendor_name,
    COALESCE(ct.subname, '') AS vendor_subname,
    COALESCE(ct.rank, 0)    AS vendor_rank,
    COALESCE(ct.type, 0)    AS vendor_type,
    COALESCE(ct.faction, 0) AS faction_id,
    COALESCE(ct.exp, 0)     AS expansion,
    nv.maxcount,
    nv.incrtime,
    nv.ExtendedCost,
    /*---------------------------------------------------------------
      Stock classification
      - Limited if maxcount > 0 or incrtime > 0
      - Otherwise unlimited
    ---------------------------------------------------------------*/
    CASE
        WHEN (nv.maxcount > 0 OR nv.incrtime > 0) THEN 'Limited'
        ELSE 'Unlimited'
    END AS stock_type,

    /*---------------------------------------------------------------
      Environment & weighting context
      Vendors are always World-scope; weighting = 1.0 (later adjusted
      for limited stock/cooldown in 00-04B)
    ---------------------------------------------------------------*/
    'World' AS drop_environment,
    1.00    AS encounter_weight_base,
    1       AS encounters_per_week,

    'Vendor' AS source_type,
    NOW()    AS date_linked

FROM npc_vendor AS nv
JOIN ACSBV3_00_00A_raw_items AS it
  ON it.ItemID = nv.item
LEFT JOIN creature_template AS ct
  ON ct.entry = nv.entry
WHERE nv.item > 0;

/*============================================================================================
Verification Block
----------------------------------------------------------------------------------------------
 - Confirms linkage counts and limited vs. unlimited stock split.
============================================================================================*/

SELECT COUNT(*) AS total_links,
       COUNT(DISTINCT ItemID) AS distinct_items
FROM ACSBV3_00_04A_vendor_src;

SELECT
    stock_type,
    COUNT(*) AS count_per_stock,
    ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM ACSBV3_00_04A_vendor_src), 1) AS pct
FROM ACSBV3_00_04A_vendor_src
GROUP BY stock_type
ORDER BY stock_type;

/*============================================================================================
End of File
============================================================================================*/
