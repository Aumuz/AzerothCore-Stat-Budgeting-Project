WITH base AS (
    SELECT
        Quality,
        (SellPrice / budget_actual) AS sell_budget_ratio
    FROM ACSBV3_ref_dataset
    WHERE
        BuyPrice > 0
        AND SellPrice > 0
        AND budget_actual > 0
        -- Optional: exclude Common (recommended)
        AND Quality > 1
),
ranked AS (
    SELECT
        Quality,
        sell_budget_ratio,
        ROW_NUMBER() OVER (PARTITION BY Quality ORDER BY sell_budget_ratio) AS rn,
        COUNT(*)    OVER (PARTITION BY Quality) AS cnt
    FROM base
)
SELECT
    Quality,
    AVG(sell_budget_ratio) AS median_sell_budget_ratio,
    MAX(cnt) AS item_count
FROM ranked
WHERE rn IN (
    FLOOR((cnt + 1) / 2),
    FLOOR((cnt + 2) / 2)
)
GROUP BY Quality
ORDER BY Quality;



SELECT
    Quality,
    COUNT(*) AS items,
    AVG(BuyPrice / SellPrice) AS avg_buy_sell_ratio,
    MIN(BuyPrice / SellPrice) AS min_ratio,
    MAX(BuyPrice / SellPrice) AS max_ratio
FROM ACSBV3_ref_dataset
WHERE BuyPrice > 0 AND SellPrice > 0
GROUP BY Quality
ORDER BY Quality;



WITH base AS (
    SELECT
        Quality,
        ItemLevelBracket,
        (budget_actual / SellPrice) AS k
    FROM ACSBV3_ref_dataset
    WHERE
        BuyPrice > 0
        AND SellPrice > 0
        AND budget_actual > 0
        AND Quality IN (2,3,4)
),
ranked AS (
    SELECT
        Quality,
        ItemLevelBracket,
        k,
        ROW_NUMBER() OVER (PARTITION BY Quality, ItemLevelBracket ORDER BY k) AS rn,
        COUNT(*)    OVER (PARTITION BY Quality, ItemLevelBracket) AS cnt
    FROM base
)
SELECT
    Quality,
    ItemLevelBracket,
    AVG(k) AS median_k,
    MAX(cnt) AS item_count
FROM ranked
WHERE rn IN (FLOOR((cnt + 1) / 2), FLOOR((cnt + 2) / 2))
GROUP BY Quality, ItemLevelBracket
ORDER BY Quality, ItemLevelBracket;



CREATE TABLE ACSBV3_ref_price_ilvl_medians AS
WITH base AS (
    SELECT
        ItemLevelBracket,
        (SellPrice / budget_actual) AS sell_per_budget
    FROM ACSBV3_ref_dataset
    WHERE
        BuyPrice  > 0
        AND SellPrice > 0
        AND budget_actual > 0
),
ranked AS (
    SELECT
        ItemLevelBracket,
        sell_per_budget,
        ROW_NUMBER() OVER (
            PARTITION BY ItemLevelBracket
            ORDER BY sell_per_budget
        ) AS rn,
        COUNT(*) OVER (
            PARTITION BY ItemLevelBracket
        ) AS cnt
    FROM base
)
SELECT
    ItemLevelBracket,
    AVG(sell_per_budget) AS median_sell_per_budget,
    MAX(cnt) AS item_count
FROM ranked
WHERE rn IN (
    FLOOR((cnt + 1) / 2),
    FLOOR((cnt + 2) / 2)
)
GROUP BY ItemLevelBracket
ORDER BY ItemLevelBracket;



WITH base AS (
    -- your existing median-by-bracket result
    SELECT
        ItemLevelBracket,
        median_sell_per_budget
    FROM ACSBV3_ref_price_ilvl_medians   -- or temp table / CTE
),
windowed AS (
    SELECT
        ItemLevelBracket,
        median_sell_per_budget,
        LAG(median_sell_per_budget)  OVER (ORDER BY ItemLevelBracket) AS prev_val,
        LEAD(median_sell_per_budget) OVER (ORDER BY ItemLevelBracket) AS next_val
    FROM base
)
SELECT
    ItemLevelBracket,

    CASE
        WHEN ItemLevelBracket < 120 THEN
            median_sell_per_budget
        WHEN prev_val IS NULL OR next_val IS NULL THEN
            median_sell_per_budget
        ELSE
            -- rolling median of (prev, current, next)
            (
              prev_val
            + median_sell_per_budget
            + next_val
            )
            - GREATEST(prev_val, median_sell_per_budget, next_val)
            - LEAST(prev_val, median_sell_per_budget, next_val)
    END AS smoothed_sell_per_budget

FROM windowed
ORDER BY ItemLevelBracket;
