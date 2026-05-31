-- ============================================================================
-- Q19. Pivot / Unpivot / Cross-Tabulation
-- ============================================================================
-- Companies: Amazon, Microsoft | Difficulty: Medium
--
-- Pivot:   rows → columns (long → wide)
-- Unpivot: columns → rows (wide → long)
-- PostgreSQL doesn't have PIVOT keyword — use CASE WHEN + GROUP BY

-- === Pivot: sales per employee per region (rows → columns) ===
SELECT e.name,
    SUM(CASE WHEN s.region = 'East' THEN s.amount ELSE 0 END) AS east_sales,
    SUM(CASE WHEN s.region = 'West' THEN s.amount ELSE 0 END) AS west_sales,
    SUM(s.amount) AS total_sales
FROM sales s
JOIN employees e ON s.employee_id = e.id
GROUP BY e.id, e.name
ORDER BY total_sales DESC;

-- === Pivot: orders per month per status ===
SELECT DATE_TRUNC('month', order_date) AS month,
    COUNT(CASE WHEN status = 'completed' THEN 1 END) AS completed,
    COUNT(CASE WHEN status = 'shipped' THEN 1 END) AS shipped,
    COUNT(CASE WHEN status = 'pending' THEN 1 END) AS pending,
    COUNT(CASE WHEN status = 'cancelled' THEN 1 END) AS cancelled,
    COUNT(*) AS total
FROM orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;

-- === Pivot: product category revenue by month ===
SELECT DATE_TRUNC('month', o.order_date) AS month,
    SUM(CASE WHEN p.category = 'Electronics' THEN oi.quantity * oi.unit_price END) AS electronics,
    SUM(CASE WHEN p.category = 'Books' THEN oi.quantity * oi.unit_price END) AS books,
    SUM(CASE WHEN p.category = 'Clothing' THEN oi.quantity * oi.unit_price END) AS clothing,
    SUM(CASE WHEN p.category = 'Food' THEN oi.quantity * oi.unit_price END) AS food
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id
GROUP BY DATE_TRUNC('month', o.order_date)
ORDER BY month;

-- === Dynamic pivot with crosstab (PostgreSQL extension) ===
-- CREATE EXTENSION IF NOT EXISTS tablefunc;
-- SELECT * FROM crosstab(...) — for truly dynamic column names

-- === Unpivot: columns → rows ===
-- Turn department stats columns into rows
SELECT d.name AS department, metric, value
FROM departments d
CROSS JOIN LATERAL (
    VALUES
        ('employee_count', (SELECT COUNT(*) FROM employees WHERE department_id = d.id)::text),
        ('avg_salary', (SELECT ROUND(AVG(salary), 2) FROM employees WHERE department_id = d.id)::text),
        ('max_salary', (SELECT MAX(salary) FROM employees WHERE department_id = d.id)::text)
) AS metrics(metric, value)
ORDER BY d.name, metric;
