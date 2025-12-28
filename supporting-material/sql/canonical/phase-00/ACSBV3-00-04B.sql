/*============================================================================================
Filename:       ACSBV3-00-04B.sql
Title:          Phase 00 – Encounter Weighting (Vendors)
Author:         ChatGPT + Aumuz Messick
Version:        1.1
Created:        2025-10-20
Description:    Weights vendor-sold items. Vendors are deterministic sources; availability is
                effectively guaranteed. Unlimited stock => full weight. Limited stock was
                studied in v2 and also converged ~1.0; we preserve that here.
----------------------------------------------------------------------------------------------
Notes:
 - v1.0 mistakenly referenced s.drop_chance (vendors have none). Removed.
 - Vendors modeled with effective_chance = 100% and freq_weight = 1.0.
 - Base encounter weight for vendors remains 1.0.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS ACSBV3_00_04B_weighted_vendor;

CREATE TABLE ACSBV3_00_04B_weighted_vendor AS
SELECT
    s.ItemID,
    s.vendor_entry,
    s.vendor_name,
    s.vendor_subname,
    s.vendor_rank,
    s.vendor_type,
    s.faction_id,
    s.expansion,
    s.maxcount,
    s.incrtime,
    s.ExtendedCost,
    s.stock_type,
    s.drop_environment,          -- always 'World' from 00-04A
    s.encounter_weight_base,     -- 1.0
    s.encounters_per_week,       -- 1 (kept for schema symmetry)
    s.drop_environment AS environment_final,

    /* Deterministic availability for vendors */
    100.0 AS effective_chance,

    /* Frequency curve collapses to 1.0 for deterministic sources */
    1.0 AS freq_weight,

    /* Final per-source weight = encounter_weight_base × freq_weight = 1.0 */
    s.encounter_weight_base * 1.0 AS final_weight,

    'Vendor' AS source_type,
    NOW() AS date_weighted

FROM ACSBV3_00_04A_vendor_src AS s;

/*============================================================================================
Verification Block
----------------------------------------------------------------------------------------------
 - Confirms totals and that all vendor weights are 1.0 as intended.
============================================================================================*/

SELECT COUNT(*) AS total_records,
       COUNT(DISTINCT ItemID) AS distinct_items,
       MIN(final_weight) AS min_final_weight,
       MAX(final_weight) AS max_final_weight,
       ROUND(AVG(final_weight), 3) AS avg_final_weight
FROM ACSBV3_00_04B_weighted_vendor;

SELECT stock_type,
       COUNT(*) AS cnt,
       ROUND(AVG(final_weight), 3) AS avg_final_weight
FROM ACSBV3_00_04B_weighted_vendor
GROUP BY stock_type
ORDER BY stock_type;

/*============================================================================================
End of File
============================================================================================*/
