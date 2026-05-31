-- ============================================================================
-- Q9. Running Totals, Moving Averages, Cumulative Sum
-- ============================================================================
-- Companies: Amazon, Google, Meta | Difficulty: Medium
--
-- SUM() OVER (ORDER BY ...)      → running total
-- AVG() OVER (ROWS BETWEEN ...)  → moving average
-- COUNT() OVER (...)              → running count

-- === Running total of sales per employee ===
SELECT e.name, s.sale_date, s.amount,
    SUM(s.amount) OVER (PARTITION BY s.employee_id ORDER BY s.sale_date) AS running_total,
    COUNT(*) OVER (PARTITION BY s.employee_id ORDER BY s.sale_date) AS sale_number,
    ROUND(AVG(s.amount) OVER (PARTITION BY s.employee_id ORDER BY s.sale_date), 2) AS running_avg
FROM sales s
JOIN employees e ON s.employee_id = e.id
ORDER BY e.name, s.sale_date;

-- === Moving average (last 3 sales) ===
SELECT e.name, s.sale_date, s.amount,
    ROUND(AVG(s.amount) OVER (
        PARTITION BY s.employee_id
        ORDER BY s.sale_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW  -- window: last 3 rows
    ), 2) AS moving_avg_3
FROM sales s
JOIN employees e ON s.employee_id = e.id
ORDER BY e.name, s.sale_date;

-- === Cumulative revenue percentage ===
WITH order_revenue AS (
    SELECT id, order_date, total_amount,
        SUM(total_amount) OVER (ORDER BY order_date) AS cumulative,
        SUM(total_amount) OVER () AS grand_total
    FROM orders WHERE status = 'completed'
)
SELECT id, order_date, total_amount, cumulative,
    ROUND(cumulative / grand_total * 100, 1) AS cumulative_pct
FROM order_revenue
ORDER BY order_date;

-- === NTILE: divide into equal groups ===
SELECT name, salary,
    NTILE(4) OVER (ORDER BY salary DESC) AS quartile
    -- Quartile 1 = top 25%, Quartile 4 = bottom 25%
FROM employees WHERE is_active = true;

-- === FIRST_VALUE / LAST_VALUE ===
SELECT name, department_id, salary,
    FIRST_VALUE(name) OVER (PARTITION BY department_id ORDER BY salary DESC) AS highest_paid,
    FIRST_VALUE(name) OVER (PARTITION BY department_id ORDER BY salary ASC) AS lowest_paid
FROM employees WHERE is_active = true;
