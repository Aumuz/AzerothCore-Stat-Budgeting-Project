/*============================================================================================
Filename:       ACSBV3-00-05B.sql
Title:          Phase 00 – Encounter Weighting (Quest Rewards)
Author:         ChatGPT + Aumuz Messick
Version:        1.0
Created:        2025-10-20
Description:    Assigns deterministic weights to quest rewards.
----------------------------------------------------------------------------------------------
Notes:
 - Quests are deterministic sources; rewards are guaranteed upon completion.
 - p_eff = 1, freq_weight = 1, final_weight = 1.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS ACSBV3_00_05B_weighted_quest;

CREATE TABLE ACSBV3_00_05B_weighted_quest AS
SELECT
    s.ItemID,
    s.quest_id,
    s.reward_type,
    s.drop_environment,
    s.encounter_weight_base,
    s.encounters_per_week,

    100.0 AS effective_chance,
    1.0   AS freq_weight,
    s.encounter_weight_base * 1.0 AS final_weight,

    s.source_type,
    NOW() AS date_weighted

FROM ACSBV3_00_05A_quest_src AS s;

/*============================================================================================
Verification Block
----------------------------------------------------------------------------------------------
 - Confirms totals and average final weight.
============================================================================================*/

SELECT COUNT(*) AS total_records,
       COUNT(DISTINCT ItemID) AS distinct_items,
       ROUND(AVG(final_weight),3) AS avg_final_weight
FROM ACSBV3_00_05B_weighted_quest;

SELECT reward_type,
       COUNT(*) AS cnt,
       ROUND(AVG(final_weight),3) AS avg_final_weight
FROM ACSBV3_00_05B_weighted_quest
GROUP BY reward_type
ORDER BY reward_type;

/*============================================================================================
End of File
============================================================================================*/
