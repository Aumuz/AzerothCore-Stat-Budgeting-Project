/*=============================================================================================================================================
  Filename:       ACSBV3-04-04B.sql
  Title:          Populate Fictional (Derived) Band Values in ACSBV3_doc_curve_bands
  Author:         ChatGPT + Aumuz Messick
  Version:        4.3
  Created:        2025-11-20

  Description:
      v4.1:
        - Corrects MySQL "Can't reopen table" issue by creating a snapshot table
          ACSBV3_0404B_region_ratio_src for region fallback logic.

      (All other details same as v4.0 — quality inversion, Epic reconstruction, ratio derivation,
       region fallback logic, value fill, slope recalculation.)
=============================================================================================================================================*/


SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';


/*=============================================================================================================================================
  1. Correct Quality Inversions
=============================================================================================================================================*/

SELECT "The script is processing. Please wait..." AS ``;

UPDATE ACSBV3_doc_curve_bands AS b
SET b.`Uncommon` = b.`Common`
WHERE b.`Common`   > 0
  AND b.`Uncommon` > 0
  AND b.`Uncommon` < b.`Common`;

UPDATE ACSBV3_doc_curve_bands AS b
SET b.`Rare` = b.`Uncommon`
WHERE b.`Uncommon` > 0
  AND b.`Rare`     > 0
  AND b.`Rare`     < b.`Uncommon`;

UPDATE ACSBV3_doc_curve_bands AS b
SET b.`Epic` = b.`Rare`
WHERE b.`Rare` > 0
  AND b.`Epic` > 0
  AND b.`Epic` < b.`Rare`;

UPDATE ACSBV3_doc_curve_bands AS b
SET b.`Legendary` = b.`Epic`
WHERE b.`Epic`      > 0
  AND b.`Legendary` > 0
  AND b.`Legendary` < b.`Epic`;


/*=============================================================================================================================================
  2. Reconstruct Missing Epic Values
=============================================================================================================================================*/

SET @Epic_40  := (SELECT `Epic` FROM ACSBV3_doc_curve_bands WHERE `ItemLevel` = 40);
SET @Epic_50  := (SELECT `Epic` FROM ACSBV3_doc_curve_bands WHERE `ItemLevel` = 50);

SET @Epic_160 := (SELECT `Epic` FROM ACSBV3_doc_curve_bands WHERE `ItemLevel` = 160);
SET @Epic_200 := (SELECT `Epic` FROM ACSBV3_doc_curve_bands WHERE `ItemLevel` = 200);

SET @Epic_240 := (SELECT `Epic` FROM ACSBV3_doc_curve_bands WHERE `ItemLevel` = 240);
SET @Epic_280 := (SELECT `Epic` FROM ACSBV3_doc_curve_bands WHERE `ItemLevel` = 280);

SET @m_40_50   := (@Epic_50  - @Epic_40 ) / 10;
SET @m_160_200 := (@Epic_200 - @Epic_160) / 40;
SET @m_240_280 := (@Epic_280 - @Epic_240) / 40;

UPDATE ACSBV3_doc_curve_bands
SET `Epic` = @Epic_40 + @m_40_50 * (`ItemLevel` - 40)
WHERE `ItemLevel` IN (10,20,30);

UPDATE ACSBV3_doc_curve_bands
SET `Epic` = @Epic_160 + @m_160_200 * (`ItemLevel` - 160)
WHERE `ItemLevel` IN (170,180,190)
  AND `Epic` <= 0;

UPDATE ACSBV3_doc_curve_bands
SET `Epic` = @Epic_280 + @m_240_280 * (`ItemLevel` - 280)
WHERE `ItemLevel` IN (290,300)
  AND `Epic` <= 0;


/*=============================================================================================================================================
  3. Build Base Ratio Table
=============================================================================================================================================*/

DROP TEMPORARY TABLE IF EXISTS ACSBV3_0404B_quality_ratio;

CREATE TEMPORARY TABLE ACSBV3_0404B_quality_ratio
(
  `Quality`   VARCHAR(16),
  `RegionID`  TINYINT,
  `ItemLevel` SMALLINT,
  `Ratio`     DECIMAL(12,5)
);

INSERT INTO ACSBV3_0404B_quality_ratio
SELECT 'Common',
       CASE
         WHEN ItemLevel BETWEEN 10 AND 39 THEN 1
         WHEN ItemLevel BETWEEN 40 AND 99 THEN 2
         WHEN ItemLevel BETWEEN 100 AND 164 THEN 3
         WHEN ItemLevel BETWEEN 165 AND 239 THEN 4
         WHEN ItemLevel BETWEEN 240 AND 300 THEN 5
       END,
       ItemLevel,
       Common / Epic
FROM ACSBV3_doc_curve_bands
WHERE Epic > 0 AND Common > 0;

INSERT INTO ACSBV3_0404B_quality_ratio
SELECT 'Uncommon',
       CASE
         WHEN ItemLevel BETWEEN 10 AND 39 THEN 1
         WHEN ItemLevel BETWEEN 40 AND 99 THEN 2
         WHEN ItemLevel BETWEEN 100 AND 164 THEN 3
         WHEN ItemLevel BETWEEN 165 AND 239 THEN 4
         WHEN ItemLevel BETWEEN 240 AND 300 THEN 5
       END,
       ItemLevel,
       Uncommon / Epic
FROM ACSBV3_doc_curve_bands
WHERE Epic > 0 AND Uncommon > 0;

INSERT INTO ACSBV3_0404B_quality_ratio
SELECT 'Rare',
       CASE
         WHEN ItemLevel BETWEEN 10 AND 39 THEN 1
         WHEN ItemLevel BETWEEN 40 AND 99 THEN 2
         WHEN ItemLevel BETWEEN 100 AND 164 THEN 3
         WHEN ItemLevel BETWEEN 165 AND 239 THEN 4
         WHEN ItemLevel BETWEEN 240 AND 300 THEN 5
       END,
       ItemLevel,
       Rare / Epic
FROM ACSBV3_doc_curve_bands
WHERE Epic > 0 AND Rare > 0;

INSERT INTO ACSBV3_0404B_quality_ratio
SELECT 'Legendary',
       CASE
         WHEN ItemLevel BETWEEN 10 AND 39 THEN 1
         WHEN ItemLevel BETWEEN 40 AND 99 THEN 2
         WHEN ItemLevel BETWEEN 100 AND 164 THEN 3
         WHEN ItemLevel BETWEEN 165 AND 239 THEN 4
         WHEN ItemLevel BETWEEN 240 AND 300 THEN 5
       END,
       ItemLevel,
       Legendary / Epic
FROM ACSBV3_doc_curve_bands
WHERE Epic > 0 AND Legendary > 0;

/* Build averaged region ratios */
DROP TEMPORARY TABLE IF EXISTS ACSBV3_0404B_region_ratio;

CREATE TEMPORARY TABLE ACSBV3_0404B_region_ratio
(
  `Quality`   VARCHAR(16),
  `RegionID`  TINYINT,
  `Ratio_Avg` DECIMAL(12,5),
  PRIMARY KEY (`Quality`,`RegionID`)
);

INSERT INTO ACSBV3_0404B_region_ratio
SELECT Quality, RegionID, AVG(Ratio)
FROM ACSBV3_0404B_quality_ratio
GROUP BY Quality, RegionID;


/*=============================================================================================================================================
  3b. Apply Region Fallbacks Using Snapshot Table
=============================================================================================================================================*/

DROP TEMPORARY TABLE IF EXISTS ACSBV3_0404B_region_ratio_src;
CREATE TEMPORARY TABLE ACSBV3_0404B_region_ratio_src AS
SELECT * FROM ACSBV3_0404B_region_ratio;

/* Common: Regions 1<-2, 4<-3, 5<-4 */
INSERT IGNORE INTO ACSBV3_0404B_region_ratio
SELECT 'Common',1,Ratio_Avg
FROM ACSBV3_0404B_region_ratio_src
WHERE Quality='Common' AND RegionID=2;

INSERT IGNORE INTO ACSBV3_0404B_region_ratio
SELECT 'Common',4,Ratio_Avg
FROM ACSBV3_0404B_region_ratio_src
WHERE Quality='Common' AND RegionID=3;

INSERT IGNORE INTO ACSBV3_0404B_region_ratio
SELECT 'Common',5,Ratio_Avg
FROM ACSBV3_0404B_region_ratio_src
WHERE Quality='Common' AND RegionID=4;

/* Guarantee Common ratio exists for Region 5 */

/* Fallback #1: Region 5 <- Region 4 */
INSERT IGNORE INTO ACSBV3_0404B_region_ratio (`Quality`, `RegionID`, `Ratio_Avg`)
SELECT 'Common', 5, r4.Ratio_Avg
FROM ACSBV3_0404B_region_ratio_src AS r4
WHERE r4.Quality = 'Common'
  AND r4.RegionID = 4;

/* Fallback #2: Region 5 <- Region 3 (if Region 4 had no data) */
INSERT IGNORE INTO ACSBV3_0404B_region_ratio (`Quality`, `RegionID`, `Ratio_Avg`)
SELECT 'Common', 5, r3.Ratio_Avg
FROM ACSBV3_0404B_region_ratio_src AS r3
WHERE r3.Quality = 'Common'
  AND r3.RegionID = 3;

/* Uncommon: same pattern */
INSERT IGNORE INTO ACSBV3_0404B_region_ratio
SELECT 'Uncommon',1,Ratio_Avg
FROM ACSBV3_0404B_region_ratio_src
WHERE Quality='Uncommon' AND RegionID=2;

INSERT IGNORE INTO ACSBV3_0404B_region_ratio
SELECT 'Uncommon',4,Ratio_Avg
FROM ACSBV3_0404B_region_ratio_src
WHERE Quality='Uncommon' AND RegionID=3;

INSERT IGNORE INTO ACSBV3_0404B_region_ratio
SELECT 'Uncommon',5,Ratio_Avg
FROM ACSBV3_0404B_region_ratio_src
WHERE Quality='Uncommon' AND RegionID=4;

/* Rare: same pattern */
INSERT IGNORE INTO ACSBV3_0404B_region_ratio
SELECT 'Rare',1,Ratio_Avg
FROM ACSBV3_0404B_region_ratio_src
WHERE Quality='Rare' AND RegionID=2;

INSERT IGNORE INTO ACSBV3_0404B_region_ratio
SELECT 'Rare',4,Ratio_Avg
FROM ACSBV3_0404B_region_ratio_src
WHERE Quality='Rare' AND RegionID=3;

INSERT IGNORE INTO ACSBV3_0404B_region_ratio
SELECT 'Rare',5,Ratio_Avg
FROM ACSBV3_0404B_region_ratio_src
WHERE Quality='Rare' AND RegionID=4;

/* Legendary:
     Regions 1,2,3 -> Region 2
     Regions 4,5   -> Region 5
*/
INSERT IGNORE INTO ACSBV3_0404B_region_ratio
SELECT 'Legendary',1,Ratio_Avg
FROM ACSBV3_0404B_region_ratio_src
WHERE Quality='Legendary' AND RegionID=2;

INSERT IGNORE INTO ACSBV3_0404B_region_ratio
SELECT 'Legendary',3,Ratio_Avg
FROM ACSBV3_0404B_region_ratio_src
WHERE Quality='Legendary' AND RegionID=2;

INSERT IGNORE INTO ACSBV3_0404B_region_ratio
SELECT 'Legendary',4,Ratio_Avg
FROM ACSBV3_0404B_region_ratio_src
WHERE Quality='Legendary' AND RegionID=5;


/*=============================================================================================================================================
  4. Fill Missing Values Using Ratios
=============================================================================================================================================*/

UPDATE ACSBV3_doc_curve_bands AS b
LEFT JOIN ACSBV3_0404B_region_ratio AS r
  ON r.Quality='Common'
 AND r.RegionID = CASE
                    WHEN b.ItemLevel BETWEEN 10 AND 39 THEN 1
                    WHEN b.ItemLevel BETWEEN 40 AND 99 THEN 2
                    WHEN b.ItemLevel BETWEEN 100 AND 164 THEN 3
                    WHEN b.ItemLevel BETWEEN 165 AND 239 THEN 4
                    WHEN b.ItemLevel BETWEEN 240 AND 300 THEN 5
                  END
SET b.`Common` = b.`Epic` * r.Ratio_Avg
WHERE b.`Common`<=0 AND b.`Epic`>0;

UPDATE ACSBV3_doc_curve_bands AS b
LEFT JOIN ACSBV3_0404B_region_ratio AS r
  ON r.Quality='Uncommon'
 AND r.RegionID = CASE
                    WHEN b.ItemLevel BETWEEN 10 AND 39 THEN 1
                    WHEN b.ItemLevel BETWEEN 40 AND 99 THEN 2
                    WHEN b.ItemLevel BETWEEN 100 AND 164 THEN 3
                    WHEN b.ItemLevel BETWEEN 165 AND 239 THEN 4
                    WHEN b.ItemLevel BETWEEN 240 AND 300 THEN 5
                  END
SET b.`Uncommon` = b.`Epic` * r.Ratio_Avg
WHERE b.`Uncommon`<=0 AND b.`Epic`>0;

UPDATE ACSBV3_doc_curve_bands AS b
LEFT JOIN ACSBV3_0404B_region_ratio AS r
  ON r.Quality='Rare'
 AND r.RegionID = CASE
                    WHEN b.ItemLevel BETWEEN 10 AND 39 THEN 1
                    WHEN b.ItemLevel BETWEEN 40 AND 99 THEN 2
                    WHEN b.ItemLevel BETWEEN 100 AND 164 THEN 3
                    WHEN b.ItemLevel BETWEEN 165 AND 239 THEN 4
                    WHEN b.ItemLevel BETWEEN 240 AND 300 THEN 5
                  END
SET b.`Rare` = b.`Epic` * r.Ratio_Avg
WHERE b.`Rare`<=0 AND b.`Epic`>0;

UPDATE ACSBV3_doc_curve_bands AS b
LEFT JOIN ACSBV3_0404B_region_ratio AS r
  ON r.Quality='Legendary'
 AND r.RegionID = CASE
                    WHEN b.ItemLevel BETWEEN 10 AND 39 THEN 1
                    WHEN b.ItemLevel BETWEEN 40 AND 99 THEN 2
                    WHEN b.ItemLevel BETWEEN 100 AND 164 THEN 3
                    WHEN b.ItemLevel BETWEEN 165 AND 239 THEN 4
                    WHEN b.ItemLevel BETWEEN 240 AND 300 THEN 5
                  END
SET b.`Legendary` = b.`Epic` * r.Ratio_Avg
WHERE b.`Legendary`<=0 AND b.`Epic`>0;


/*=============================================================================================================================================
  5. Recalculate Slopes
=============================================================================================================================================*/

UPDATE ACSBV3_doc_curve_bands AS b
LEFT JOIN ACSBV3_doc_curve_bands AS n
  ON n.ItemLevel = b.ItemLevel+10
SET b.Common_Slope    = (n.Common    - b.Common)    / 10,
    b.Uncommon_Slope  = (n.Uncommon  - b.Uncommon)  / 10,
    b.Rare_Slope      = (n.Rare      - b.Rare)      / 10,
    b.Epic_Slope      = (n.Epic      - b.Epic)      / 10,
    b.Legendary_Slope = (n.Legendary - b.Legendary) / 10;



/*=====================================================================
  Phase 04 - Final Monotonic & Quality-Order Corrections
  Applies adjustments to finalize ACSBV3_doc_curve_bands.
=====================================================================*/

/*---------------------------------------------------------------------
  1. Fix Epic(10) so Rare(10) = Epic(10)
---------------------------------------------------------------------*/
UPDATE ACSBV3_doc_curve_bands
SET Epic = Rare
WHERE ItemLevel = 10;


/*---------------------------------------------------------------------
  2. Fix Legendary values that must be = Epic (quality order)
---------------------------------------------------------------------*/
-- Legendary(10)
UPDATE ACSBV3_doc_curve_bands
SET Legendary = Epic
WHERE ItemLevel = 10;

-- Legendary(20)
UPDATE ACSBV3_doc_curve_bands
SET Legendary = Epic
WHERE ItemLevel = 20;

-- Legendary(30)
UPDATE ACSBV3_doc_curve_bands
SET Legendary = Epic
WHERE ItemLevel = 30;


/*---------------------------------------------------------------------
  3. Fix Legendary monotonic breaks in the mid-game curve
---------------------------------------------------------------------*/

-- Legendary(150) must be = Legendary(140)
UPDATE ACSBV3_doc_curve_bands AS b
JOIN ACSBV3_doc_curve_bands AS p ON p.ItemLevel = 140
SET b.Legendary = p.Legendary
WHERE b.ItemLevel = 150
  AND b.Legendary < p.Legendary;

-- Legendary(170) must be = Legendary(160)
UPDATE ACSBV3_doc_curve_bands AS b
JOIN ACSBV3_doc_curve_bands AS p ON p.ItemLevel = 160
SET b.Legendary = p.Legendary
WHERE b.ItemLevel = 170
  AND b.Legendary < p.Legendary;

-- Legendary(180) must be = Legendary(170)
UPDATE ACSBV3_doc_curve_bands AS b
JOIN ACSBV3_doc_curve_bands AS p ON p.ItemLevel = 170
SET b.Legendary = p.Legendary
WHERE b.ItemLevel = 180
  AND b.Legendary < p.Legendary;

-- Legendary(190) must be = Legendary(180)
UPDATE ACSBV3_doc_curve_bands AS b
JOIN ACSBV3_doc_curve_bands AS p ON p.ItemLevel = 180
SET b.Legendary = p.Legendary
WHERE b.ItemLevel = 190
  AND b.Legendary < p.Legendary;

-- Legendary(200) must be = Legendary(190)
UPDATE ACSBV3_doc_curve_bands AS b
JOIN ACSBV3_doc_curve_bands AS p ON p.ItemLevel = 190
SET b.Legendary = p.Legendary
WHERE b.ItemLevel = 200
  AND b.Legendary < p.Legendary;


/*---------------------------------------------------------------------
  4. Fix Legendary monotonic break in Region 5 tail
---------------------------------------------------------------------*/

-- Legendary(280) must be = Legendary(260)
UPDATE ACSBV3_doc_curve_bands AS b
JOIN ACSBV3_doc_curve_bands AS p ON p.ItemLevel = 260
SET b.Legendary = p.Legendary
WHERE b.ItemLevel = 280
  AND b.Legendary < p.Legendary;


/*---------------------------------------------------------------------
  End of Patch
---------------------------------------------------------------------*/



SELECT "Script Complete." AS ``;



/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
