-- ============================================================================
-- Q20-25. Top FAANG SQL Questions (Most Frequently Asked 2024-2025)
-- ============================================================================

-- === Q20. Customers who never ordered (Amazon — most asked) ===
-- LeetCode #183
SELECT c.name
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
WHERE o.id IS NULL;
-- OR using NOT EXISTS (faster):
SELECT name FROM customers c
WHERE NOT EXISTS (SELECT 1 FROM orders WHERE customer_id = c.id);

-- === Q21. Department with highest average salary ===
SELECT d.name, ROUND(AVG(e.salary), 2) AS avg_salary
FROM employees e
JOIN departments d ON e.department_id = d.id
GROUP BY d.id, d.name
ORDER BY avg_salary DESC
LIMIT 1;

-- === Q22. Employees earning more than department average ===
SELECT e.name, e.salary, d.name AS department, dept_avg.avg_salary
FROM employees e
JOIN departments d ON e.department_id = d.id
JOIN (
    SELECT department_id, ROUND(AVG(salary), 2) AS avg_salary
    FROM employees GROUP BY department_id
) dept_avg ON e.department_id = dept_avg.department_id
WHERE e.salary > dept_avg.avg_salary
ORDER BY d.name, e.salary DESC;

-- === Q23. Year-over-year growth (Meta favorite) ===
WITH monthly_revenue AS (
    SELECT DATE_TRUNC('month', order_date) AS month,
           SUM(total_amount) AS revenue
    FROM orders WHERE status = 'completed'
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT month, revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month,
    CASE WHEN LAG(revenue) OVER (ORDER BY month) IS NOT NULL
         THEN ROUND((revenue - LAG(revenue) OVER (ORDER BY month)) /
                     LAG(revenue) OVER (ORDER BY month) * 100, 1)
    END AS growth_pct
FROM monthly_revenue ORDER BY month;

-- === Q24. Top spending customer per city (Uber favorite) ===
WITH ranked AS (
    SELECT c.city, c.name, SUM(o.total_amount) AS total_spent,
        RANK() OVER (PARTITION BY c.city ORDER BY SUM(o.total_amount) DESC) AS rk
    FROM customers c
    JOIN orders o ON c.id = o.customer_id
    WHERE o.status = 'completed'
    GROUP BY c.city, c.id, c.name
)
SELECT city, name, total_spent FROM ranked WHERE rk = 1;

-- === Q25. Products that were never ordered ===
SELECT p.name, p.category, p.price
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
WHERE oi.id IS NULL;

-- === Q26. Percentage of total (Google favorite) ===
SELECT p.category,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS category_revenue,
    ROUND(SUM(oi.quantity * oi.unit_price) /
          SUM(SUM(oi.quantity * oi.unit_price)) OVER () * 100, 1) AS pct_of_total
FROM order_items oi
JOIN products p ON oi.product_id = p.id
GROUP BY p.category
ORDER BY category_revenue DESC;

-- === Q27. Consecutive days with orders (Uber — streaks) ===
WITH daily_orders AS (
    SELECT DISTINCT order_date FROM orders ORDER BY order_date
),
with_groups AS (
    SELECT order_date,
        order_date - (ROW_NUMBER() OVER (ORDER BY order_date))::int AS grp
    FROM daily_orders
)
SELECT MIN(order_date) AS streak_start, MAX(order_date) AS streak_end,
       COUNT(*) AS consecutive_days
FROM with_groups
GROUP BY grp
HAVING COUNT(*) > 1
ORDER BY streak_start;

-- === Q28. Moving average of last 3 orders per customer ===
SELECT c.name, o.order_date, o.total_amount,
    ROUND(AVG(o.total_amount) OVER (
        PARTITION BY o.customer_id ORDER BY o.order_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS moving_avg_3
FROM orders o
JOIN customers c ON o.customer_id = c.id
WHERE o.status = 'completed'
ORDER BY c.name, o.order_date;

-- === Q29. Median salary (no built-in MEDIAN in PostgreSQL) ===
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary) AS median_salary
FROM employees WHERE is_active = true;

-- Per department:
SELECT d.name,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY e.salary) AS median_salary
FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE e.is_active = true
GROUP BY d.name;

-- === Q30. Customers who ordered every product category ===
WITH customer_categories AS (
    SELECT DISTINCT o.customer_id, p.category
    FROM orders o
    JOIN order_items oi ON o.id = oi.order_id
    JOIN products p ON oi.product_id = p.id
)
SELECT c.name, COUNT(DISTINCT cc.category) AS categories_ordered
FROM customer_categories cc
JOIN customers c ON cc.customer_id = c.id
GROUP BY c.id, c.name
HAVING COUNT(DISTINCT cc.category) = (SELECT COUNT(DISTINCT category) FROM products);
