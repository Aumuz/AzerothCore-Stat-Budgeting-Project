/*=============================================================================================================================================
  Filename:       ACSBV3-05-03B.sql
  Title:          Populate Fictional (Derived) Band Values in ACSBV3_0503A_curve_bracket
  Author:         ChatGPT + Aumuz Messick
  Version:        1.0
  Created:        2025-12-04

  Description:
      Phase 05 replacement for Phase 04 ACSBV3-04-04B.

      - Uses ACSBV3_0503A_curve_bracket as the input band table.
      - Ensures Epic curve is continuous across all 10-level brackets.
      - Derives Common/Uncommon/Rare/Legendary values from Epic using per-region
        Quality:Epic ratios (RegionID 1..3).
      - Recalculates slopes after interpolation.
      - Applies final quality-order corrections so that:
            Common <= Uncommon <= Rare <= Epic <= Legendary
        wherever the values exist.

      Regions:
        Region 1: ItemLevelBracket 10 - 60
        Region 2: ItemLevelBracket 70 - 140
        Region 3: ItemLevelBracket 150 - 300
=============================================================================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';


/*=============================================================================================================================================
  0. Script Metadata
=============================================================================================================================================*/

SET @SCRIPT  := '0503B';
SET @VERSION := 1.0;

CALL ACSBV3_print_header("05-03B: Populate Fictional Band Values in ACSBV3_0503A_curve_bracket");

SELECT "The script is processing. Please wait..." AS ``;


/*=============================================================================================================================================
  1. Build Base Quality:Epic Ratio Table (per Region)
=============================================================================================================================================*/

DROP TEMPORARY TABLE IF EXISTS ACSBV3_0503B_quality_ratio;

CREATE TEMPORARY TABLE ACSBV3_0503B_quality_ratio
(
  `Quality`          VARCHAR(16),
  `RegionID`         TINYINT,
  `ItemLevelBracket` SMALLINT,
  `Ratio`            DECIMAL(12,5)
);

/* Common / Epic */
INSERT INTO ACSBV3_0503B_quality_ratio
SELECT 'Common' AS Quality,
       CASE
         WHEN ItemLevelBracket BETWEEN 10 AND 60  THEN 1
         WHEN ItemLevelBracket BETWEEN 70 AND 140 THEN 2
         WHEN ItemLevelBracket BETWEEN 150 AND 300 THEN 3
       END AS RegionID,
       ItemLevelBracket,
       Common / Epic AS Ratio
FROM ACSBV3_0503A_curve_bracket
WHERE Epic > 0 AND Common > 0;

/* Uncommon / Epic */
INSERT INTO ACSBV3_0503B_quality_ratio
SELECT 'Uncommon' AS Quality,
       CASE
         WHEN ItemLevelBracket BETWEEN 10 AND 60  THEN 1
         WHEN ItemLevelBracket BETWEEN 70 AND 140 THEN 2
         WHEN ItemLevelBracket BETWEEN 150 AND 300 THEN 3
       END AS RegionID,
       ItemLevelBracket,
       Uncommon / Epic AS Ratio
FROM ACSBV3_0503A_curve_bracket
WHERE Epic > 0 AND Uncommon > 0;

/* Rare / Epic */
INSERT INTO ACSBV3_0503B_quality_ratio
SELECT 'Rare' AS Quality,
       CASE
         WHEN ItemLevelBracket BETWEEN 10 AND 60  THEN 1
         WHEN ItemLevelBracket BETWEEN 70 AND 140 THEN 2
         WHEN ItemLevelBracket BETWEEN 150 AND 300 THEN 3
       END AS RegionID,
       ItemLevelBracket,
       Rare / Epic AS Ratio
FROM ACSBV3_0503A_curve_bracket
WHERE Epic > 0 AND Rare > 0;

/* Legendary / Epic */
INSERT INTO ACSBV3_0503B_quality_ratio
SELECT 'Legendary' AS Quality,
       CASE
         WHEN ItemLevelBracket BETWEEN 10 AND 60  THEN 1
         WHEN ItemLevelBracket BETWEEN 70 AND 140 THEN 2
         WHEN ItemLevelBracket BETWEEN 150 AND 300 THEN 3
       END AS RegionID,
       ItemLevelBracket,
       Legendary / Epic AS Ratio
FROM ACSBV3_0503A_curve_bracket
WHERE Epic > 0 AND Legendary > 0;


/* Build averaged region ratios */
DROP TEMPORARY TABLE IF EXISTS ACSBV3_0503B_region_ratio;

CREATE TEMPORARY TABLE ACSBV3_0503B_region_ratio
(
  `Quality`   VARCHAR(16),
  `RegionID`  TINYINT,
  `Ratio_Avg` DECIMAL(12,5),
  PRIMARY KEY (`Quality`,`RegionID`)
);

INSERT INTO ACSBV3_0503B_region_ratio
SELECT Quality, RegionID, AVG(Ratio) AS Ratio_Avg
FROM ACSBV3_0503B_quality_ratio
GROUP BY Quality, RegionID;


/*=============================================================================================================================================
  1b. Apply Simple Region Fallbacks
       - Common: Region 3 falls back to Region 2
       - Legendary: Region 1 falls back to Region 2
=============================================================================================================================================*/

DROP TEMPORARY TABLE IF EXISTS ACSBV3_0503B_region_ratio_src;
CREATE TEMPORARY TABLE ACSBV3_0503B_region_ratio_src AS
SELECT * FROM ACSBV3_0503B_region_ratio;

/* Common: ensure Region 3 exists by falling back to Region 2 */
INSERT IGNORE INTO ACSBV3_0503B_region_ratio (`Quality`,`RegionID`,`Ratio_Avg`)
SELECT 'Common' AS Quality, 3 AS RegionID, r2.Ratio_Avg
FROM ACSBV3_0503B_region_ratio_src AS r2
WHERE r2.Quality = 'Common'
  AND r2.RegionID = 2;

/* Legendary: ensure Region 1 exists by falling back to Region 2 */
INSERT IGNORE INTO ACSBV3_0503B_region_ratio (`Quality`,`RegionID`,`Ratio_Avg`)
SELECT 'Legendary' AS Quality, 1 AS RegionID, r2.Ratio_Avg
FROM ACSBV3_0503B_region_ratio_src AS r2
WHERE r2.Quality = 'Legendary'
  AND r2.RegionID = 2;


/*=============================================================================================================================================
  2. Reconstruct Missing Epic Values
=============================================================================================================================================*/

/* 2.1 Low-end Epic for 10 and 20
       Use Rare:Epic Region 1 ratio as a guide:
         Epic = Rare / Ratio_Rare_R1
*/

SET @Ratio_Rare_R1 := (
  SELECT Ratio_Avg
  FROM   ACSBV3_0503B_region_ratio
  WHERE  Quality = 'Rare'
    AND  RegionID = 1
);

/* Fill Epic(10) and Epic(20) where Rare exists but Epic is NULL */
UPDATE ACSBV3_0503A_curve_bracket AS b
SET b.Epic = b.Rare / @Ratio_Rare_R1
WHERE b.ItemLevelBracket IN (10,20)
  AND (b.Epic IS NULL OR b.Epic <= 0)
  AND b.Rare > 0;


/* 2.2 Mid-gap Epic for 170, 180, 190
       Linear interpolation between 150 and 200
*/

SET @Epic_150 := (SELECT Epic FROM ACSBV3_0503A_curve_bracket WHERE ItemLevelBracket = 150);
SET @Epic_200 := (SELECT Epic FROM ACSBV3_0503A_curve_bracket WHERE ItemLevelBracket = 200);

SET @m_mid := (@Epic_200 - @Epic_150) / 50.0;  /* per-level slope over 150->200 */

UPDATE ACSBV3_0503A_curve_bracket AS b
SET b.Epic = @Epic_150 + @m_mid * (b.ItemLevelBracket - 150)
WHERE b.ItemLevelBracket IN (170,180,190)
  AND (b.Epic IS NULL OR b.Epic <= 0);


/* 2.3 Tail Epic for 290 and 300
       Extrapolate forward using slope from 260->280
*/

SET @Epic_260 := (SELECT Epic FROM ACSBV3_0503A_curve_bracket WHERE ItemLevelBracket = 260);
SET @Epic_280 := (SELECT Epic FROM ACSBV3_0503A_curve_bracket WHERE ItemLevelBracket = 280);

SET @m_tail := (@Epic_280 - @Epic_260) / 20.0;  /* per-level slope over 260->280 */

UPDATE ACSBV3_0503A_curve_bracket AS b
SET b.Epic = @Epic_280 + @m_tail * (b.ItemLevelBracket - 280)
WHERE b.ItemLevelBracket IN (290,300)
  AND (b.Epic IS NULL OR b.Epic <= 0);


/*=============================================================================================================================================
  3. Recalculate Epic Slope
=============================================================================================================================================*/

UPDATE ACSBV3_0503A_curve_bracket AS b
LEFT JOIN ACSBV3_0503A_curve_bracket AS n
  ON n.ItemLevelBracket = b.ItemLevelBracket + 10
SET b.Epic_Slope = CASE
                     WHEN n.Epic IS NOT NULL AND b.Epic IS NOT NULL
                     THEN (n.Epic - b.Epic) / 10.0
                     ELSE NULL
                   END;


/*=============================================================================================================================================
  4. Fill Missing Common/Uncommon/Rare/Legendary Values from Epic * Region Ratio
=============================================================================================================================================*/

/* Helper: RegionID expression reused in all updates */
-- Region 1: 10-60, Region 2: 70-140, Region 3: 150-300

/* 4.1 Common */
UPDATE ACSBV3_0503A_curve_bracket AS b
LEFT JOIN ACSBV3_0503B_region_ratio AS r
  ON r.Quality = 'Common'
 AND r.RegionID = CASE
                    WHEN b.ItemLevelBracket BETWEEN 10 AND 60  THEN 1
                    WHEN b.ItemLevelBracket BETWEEN 70 AND 140 THEN 2
                    WHEN b.ItemLevelBracket BETWEEN 150 AND 300 THEN 3
                  END
SET b.Common = b.Epic * r.Ratio_Avg
WHERE (b.Common IS NULL OR b.Common <= 0)
  AND b.Epic > 0;

/* 4.2 Uncommon */
UPDATE ACSBV3_0503A_curve_bracket AS b
LEFT JOIN ACSBV3_0503B_region_ratio AS r
  ON r.Quality = 'Uncommon'
 AND r.RegionID = CASE
                    WHEN b.ItemLevelBracket BETWEEN 10 AND 60  THEN 1
                    WHEN b.ItemLevelBracket BETWEEN 70 AND 140 THEN 2
                    WHEN b.ItemLevelBracket BETWEEN 150 AND 300 THEN 3
                  END
SET b.Uncommon = b.Epic * r.Ratio_Avg
WHERE (b.Uncommon IS NULL OR b.Uncommon <= 0)
  AND b.Epic > 0;

/* 4.3 Rare */
UPDATE ACSBV3_0503A_curve_bracket AS b
LEFT JOIN ACSBV3_0503B_region_ratio AS r
  ON r.Quality = 'Rare'
 AND r.RegionID = CASE
                    WHEN b.ItemLevelBracket BETWEEN 10 AND 60  THEN 1
                    WHEN b.ItemLevelBracket BETWEEN 70 AND 140 THEN 2
                    WHEN b.ItemLevelBracket BETWEEN 150 AND 300 THEN 3
                  END
SET b.Rare = b.Epic * r.Ratio_Avg
WHERE (b.Rare IS NULL OR b.Rare <= 0)
  AND b.Epic > 0;

/* 4.4 Legendary */
UPDATE ACSBV3_0503A_curve_bracket AS b
LEFT JOIN ACSBV3_0503B_region_ratio AS r
  ON r.Quality = 'Legendary'
 AND r.RegionID = CASE
                    WHEN b.ItemLevelBracket BETWEEN 10 AND 60  THEN 1
                    WHEN b.ItemLevelBracket BETWEEN 70 AND 140 THEN 2
                    WHEN b.ItemLevelBracket BETWEEN 150 AND 300 THEN 3
                  END
SET b.Legendary = b.Epic * r.Ratio_Avg
WHERE (b.Legendary IS NULL OR b.Legendary <= 0)
  AND b.Epic > 0;


/*=============================================================================================================================================
  5. Recalculate Slopes for All Qualities
=============================================================================================================================================*/

UPDATE ACSBV3_0503A_curve_bracket AS b
LEFT JOIN ACSBV3_0503A_curve_bracket AS n
  ON n.ItemLevelBracket = b.ItemLevelBracket + 10
SET b.Common_Slope    = CASE WHEN n.Common    IS NOT NULL AND b.Common    IS NOT NULL THEN (n.Common    - b.Common)    / 10.0 ELSE NULL END,
    b.Uncommon_Slope  = CASE WHEN n.Uncommon  IS NOT NULL AND b.Uncommon  IS NOT NULL THEN (n.Uncommon  - b.Uncommon)  / 10.0 ELSE NULL END,
    b.Rare_Slope      = CASE WHEN n.Rare      IS NOT NULL AND b.Rare      IS NOT NULL THEN (n.Rare      - b.Rare)      / 10.0 ELSE NULL END,
    b.Epic_Slope      = CASE WHEN n.Epic      IS NOT NULL AND b.Epic      IS NOT NULL THEN (n.Epic      - b.Epic)      / 10.0 ELSE NULL END,
    b.Legendary_Slope = CASE WHEN n.Legendary IS NOT NULL AND b.Legendary IS NOT NULL THEN (n.Legendary - b.Legendary) / 10.0 ELSE NULL END;


/*=============================================================================================================================================
  6. Final Quality-Order Monotonic Corrections
       Enforce per-bracket:
         Common <= Uncommon <= Rare <= Epic <= Legendary
=============================================================================================================================================*/

/* 6.1 Epic >= Rare */
UPDATE ACSBV3_0503A_curve_bracket
SET Epic = Rare
WHERE Epic IS NOT NULL
  AND Rare IS NOT NULL
  AND Epic < Rare;

/* 6.2 Rare >= Uncommon */
UPDATE ACSBV3_0503A_curve_bracket
SET Rare = Uncommon
WHERE Rare IS NOT NULL
  AND Uncommon IS NOT NULL
  AND Rare < Uncommon;

/* 6.3 Uncommon >= Common */
UPDATE ACSBV3_0503A_curve_bracket
SET Uncommon = Common
WHERE Uncommon IS NOT NULL
  AND Common   IS NOT NULL
  AND Uncommon < Common;

/* 6.4 Legendary >= Epic (where Legendary exists) */
UPDATE ACSBV3_0503A_curve_bracket
SET Legendary = Epic
WHERE Legendary IS NOT NULL
  AND Epic       IS NOT NULL
  AND Legendary  < Epic;

UPDATE ACSBV3_0503A_curve_bracket AS b
JOIN   ACSBV3_0503B_region_ratio AS r
  ON   r.Quality  = 'Legendary'
 AND   r.RegionID = 3
SET    b.Legendary = b.Epic * r.Ratio_Avg
WHERE  b.ItemLevelBracket = 160;

UPDATE ACSBV3_0503A_curve_bracket AS b
JOIN   ACSBV3_0503B_region_ratio AS r
  ON   r.Quality  = 'Legendary'
 AND   r.RegionID = 3
SET    b.Legendary = b.Epic * r.Ratio_Avg
WHERE  b.ItemLevelBracket = 280;

UPDATE ACSBV3_0503A_curve_bracket AS b
LEFT JOIN ACSBV3_0503A_curve_bracket AS n
  ON n.ItemLevelBracket = b.ItemLevelBracket + 10
SET b.Legendary_Slope = CASE
                          WHEN n.Legendary IS NOT NULL AND b.Legendary IS NOT NULL
                          THEN (n.Legendary - b.Legendary) / 10.0
                          ELSE NULL
                        END;


/*=============================================================================================================================================
  7. Verification Output
=============================================================================================================================================*/

SELECT
  ItemLevelBracket,
  Common, Uncommon, Rare, Epic, Legendary,
  Common_Slope, Uncommon_Slope, Rare_Slope, Epic_Slope, Legendary_Slope
FROM ACSBV3_0503A_curve_bracket
ORDER BY ItemLevelBracket;

SELECT "Script Complete." AS ``;

CALL ACSBV3_print_footer();
