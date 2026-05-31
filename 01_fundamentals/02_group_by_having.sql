-- ============================================================================
-- Q2. GROUP BY + HAVING vs WHERE
-- ============================================================================
-- Companies: Amazon, Google, Meta | Difficulty: Medium
--
-- WHERE:   filters ROWS before grouping
-- HAVING:  filters GROUPS after grouping
-- Execution order: FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY

-- === Basic GROUP BY: count employees per department ===
SELECT d.name AS department, COUNT(*) AS employee_count,
       ROUND(AVG(e.salary), 2) AS avg_salary,
       MIN(e.salary) AS min_salary, MAX(e.salary) AS max_salary
FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE e.is_active = true               -- WHERE: filter BEFORE grouping
GROUP BY d.id, d.name
HAVING COUNT(*) >= 2                    -- HAVING: filter AFTER grouping
ORDER BY avg_salary DESC;

-- === GROUP BY with multiple aggregations ===
-- Revenue per category, only categories with 3+ products sold
SELECT p.category,
       COUNT(DISTINCT oi.order_id) AS total_orders,
       SUM(oi.quantity) AS total_units,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.id
GROUP BY p.category
HAVING SUM(oi.quantity * oi.unit_price) > 100
ORDER BY total_revenue DESC;

-- === Monthly order summary ===
SELECT DATE_TRUNC('month', order_date) AS month,
       COUNT(*) AS orders,
       SUM(total_amount) AS revenue,
       ROUND(AVG(total_amount), 2) AS avg_order_value
FROM orders
WHERE status != 'cancelled'
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;

-- === Customers with more than 2 orders ===
SELECT c.name, COUNT(o.id) AS order_count, SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o ON c.id = o.customer_id
WHERE o.status = 'completed'
GROUP BY c.id, c.name
HAVING COUNT(o.id) > 2
ORDER BY total_spent DESC;
