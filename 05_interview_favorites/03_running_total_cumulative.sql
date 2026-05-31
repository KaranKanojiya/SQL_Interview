-- ============================================================================
-- Q17. Running Total / Cumulative Sum
-- ============================================================================
-- Companies: Amazon, Google, Uber | Difficulty: Medium

-- === Running total of order amounts by date ===
SELECT order_date, total_amount,
    SUM(total_amount) OVER (ORDER BY order_date) AS running_total,
    ROUND(SUM(total_amount) OVER (ORDER BY order_date) /
          SUM(total_amount) OVER () * 100, 1) AS cumulative_pct
FROM orders
WHERE status = 'completed'
ORDER BY order_date;

-- === Running total per customer ===
SELECT c.name, o.order_date, o.total_amount,
    SUM(o.total_amount) OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS customer_running_total
FROM orders o
JOIN customers c ON o.customer_id = c.id
WHERE o.status = 'completed'
ORDER BY c.name, o.order_date;

-- === Year-to-date (YTD) revenue by month ===
WITH monthly AS (
    SELECT DATE_TRUNC('month', order_date) AS month,
           SUM(total_amount) AS revenue
    FROM orders WHERE status = 'completed'
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT month, revenue,
    SUM(revenue) OVER (ORDER BY month) AS ytd_revenue
FROM monthly ORDER BY month;
