-- ============================================================================
-- Q8. LAG, LEAD — access previous/next rows
-- ============================================================================
-- Companies: Amazon, Google, Uber | Difficulty: Medium
--
-- LAG(col, N, default):  value from N rows BEFORE current row
-- LEAD(col, N, default): value from N rows AFTER current row
-- Use for: month-over-month comparison, growth rate, consecutive day problems

-- === Month-over-month revenue comparison ===
WITH monthly AS (
    SELECT DATE_TRUNC('month', order_date) AS month,
           SUM(total_amount) AS revenue
    FROM orders WHERE status = 'completed'
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT month,
    revenue AS current_revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
    revenue - LAG(revenue) OVER (ORDER BY month) AS revenue_change,
    ROUND((revenue - LAG(revenue) OVER (ORDER BY month)) /
          NULLIF(LAG(revenue) OVER (ORDER BY month), 0) * 100, 1) AS growth_pct
FROM monthly
ORDER BY month;

-- === Consecutive day streak (LEAD/LAG for gaps) ===
WITH daily_sales AS (
    SELECT DISTINCT sale_date FROM sales ORDER BY sale_date
),
with_prev AS (
    SELECT sale_date,
        sale_date - LAG(sale_date) OVER (ORDER BY sale_date) AS gap_days
    FROM daily_sales
)
SELECT sale_date, gap_days,
    CASE WHEN gap_days = 1 OR gap_days IS NULL THEN 'consecutive' ELSE 'gap' END AS status
FROM with_prev;

-- === Sales rep: compare each sale to their previous sale ===
SELECT s.employee_id, e.name, s.sale_date, s.amount,
    LAG(s.amount) OVER (PARTITION BY s.employee_id ORDER BY s.sale_date) AS prev_sale,
    s.amount - LAG(s.amount) OVER (PARTITION BY s.employee_id ORDER BY s.sale_date) AS change
FROM sales s
JOIN employees e ON s.employee_id = e.id
ORDER BY s.employee_id, s.sale_date;
