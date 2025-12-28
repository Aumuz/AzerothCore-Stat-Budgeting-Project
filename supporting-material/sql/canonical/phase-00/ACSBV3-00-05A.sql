/*============================================================================================
Filename:       ACSBV3-00-05A.sql
Title:          Phase 00 – Source Linkage (Quest Rewards)
Author:         ChatGPT + Aumuz Messick
Version:        1.0
Created:        2025-10-20
Description:    Expands guaranteed and choice quest rewards into item-level entries.
                Output: ACSBV3_00_05A_quest_src
----------------------------------------------------------------------------------------------
Notes:
 - Guaranteed rewards: RewardItem1..4
 - Choice rewards: RewardChoiceItemID1..6
 - All entries treated as deterministic sources.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS ACSBV3_00_05A_quest_src;

CREATE TABLE ACSBV3_00_05A_quest_src AS
/*---------------------------------------------------------------
  1. Combine guaranteed and choice rewards
---------------------------------------------------------------*/
SELECT
    it.ItemID,
    qt.ID AS quest_id,
    'Guaranteed' AS reward_type,
    'World' AS drop_environment,
    1.00 AS encounter_weight_base,
    1 AS encounters_per_week,
    'Quest' AS source_type,
    NOW() AS date_linked
FROM quest_template qt
JOIN ACSBV3_00_00A_raw_items it
  ON it.ItemID IN (qt.RewardItem1, qt.RewardItem2, qt.RewardItem3, qt.RewardItem4)
WHERE qt.RewardItem1 > 0 OR qt.RewardItem2 > 0 OR qt.RewardItem3 > 0 OR qt.RewardItem4 > 0

UNION ALL

SELECT
    it.ItemID,
    qt.ID AS quest_id,
    'Choice' AS reward_type,
    'World' AS drop_environment,
    1.00 AS encounter_weight_base,
    1 AS encounters_per_week,
    'Quest' AS source_type,
    NOW() AS date_linked
FROM quest_template qt
JOIN ACSBV3_00_00A_raw_items it
  ON it.ItemID IN (
       qt.RewardChoiceItemID1, qt.RewardChoiceItemID2, qt.RewardChoiceItemID3,
       qt.RewardChoiceItemID4, qt.RewardChoiceItemID5, qt.RewardChoiceItemID6)
WHERE qt.RewardChoiceItemID1 > 0 OR qt.RewardChoiceItemID2 > 0 OR qt.RewardChoiceItemID3 > 0
   OR qt.RewardChoiceItemID4 > 0 OR qt.RewardChoiceItemID5 > 0 OR qt.RewardChoiceItemID6 > 0;

/*============================================================================================
Verification Block
----------------------------------------------------------------------------------------------
 - Confirms total quest reward links and distinct items.
============================================================================================*/

SELECT COUNT(*) AS total_links,
       COUNT(DISTINCT ItemID) AS distinct_items
FROM ACSBV3_00_05A_quest_src;

SELECT reward_type,
       COUNT(*) AS count_per_type
FROM ACSBV3_00_05A_quest_src
GROUP BY reward_type
ORDER BY reward_type;

/*============================================================================================
End of File
============================================================================================*/
