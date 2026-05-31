-- ============================================================================
-- Q18. Gaps and Islands Problem
-- ============================================================================
-- Companies: Google, Amazon, Uber | Difficulty: Hard
--
-- "Islands" = consecutive sequences of values
-- "Gaps" = missing values between islands
--
-- Classic examples:
--   Find consecutive login days (streak)
--   Find missing IDs in a sequence
--   Find consecutive months with sales

-- === Find consecutive sale dates per employee (islands) ===
-- Trick: date - ROW_NUMBER gives same value for consecutive dates
WITH numbered AS (
    SELECT DISTINCT employee_id, sale_date,
        sale_date - (ROW_NUMBER() OVER (PARTITION BY employee_id ORDER BY sale_date))::int AS grp
    FROM sales
)
SELECT employee_id, MIN(sale_date) AS streak_start,
       MAX(sale_date) AS streak_end,
       MAX(sale_date) - MIN(sale_date) + 1 AS streak_days
FROM numbered
GROUP BY employee_id, grp
HAVING MAX(sale_date) - MIN(sale_date) >= 1
ORDER BY employee_id, streak_start;

-- === Find gaps in order IDs ===
SELECT id + 1 AS gap_start,
       next_id - 1 AS gap_end
FROM (
    SELECT id, LEAD(id) OVER (ORDER BY id) AS next_id
    FROM orders
) t
WHERE next_id - id > 1;

-- === Find months with no orders (gaps) ===
WITH all_months AS (
    SELECT generate_series(
        DATE_TRUNC('month', MIN(order_date)),
        DATE_TRUNC('month', MAX(order_date)),
        '1 month'::interval
    )::date AS month
    FROM orders
),
order_months AS (
    SELECT DISTINCT DATE_TRUNC('month', order_date)::date AS month FROM orders
)
SELECT am.month AS missing_month
FROM all_months am
LEFT JOIN order_months om ON am.month = om.month
WHERE om.month IS NULL;
