-- ============================================================================
-- Q3. Subqueries vs CTEs (WITH clause)
-- ============================================================================
-- Companies: Google, Amazon, Meta | Difficulty: Medium
--
-- Subquery: query nested inside another query
-- CTE (Common Table Expression): named temporary result set using WITH
-- CTE advantages: readable, reusable within query, recursive queries possible

-- === Subquery in WHERE: employees earning above average ===
SELECT name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees)
ORDER BY salary DESC;

-- === Same with CTE (more readable) ===
WITH avg_salary AS (
    SELECT AVG(salary) AS avg_sal FROM employees
)
SELECT e.name, e.salary, a.avg_sal
FROM employees e, avg_salary a
WHERE e.salary > a.avg_sal
ORDER BY e.salary DESC;

-- === Correlated subquery: employees earning max in their department ===
-- Runs the subquery FOR EACH ROW in the outer query
SELECT e.name, e.salary, d.name AS department
FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE e.salary = (
    SELECT MAX(salary)
    FROM employees e2
    WHERE e2.department_id = e.department_id  -- correlated: references outer query
);

-- === CTE: same result, clearer ===
WITH dept_max AS (
    SELECT department_id, MAX(salary) AS max_salary
    FROM employees
    GROUP BY department_id
)
SELECT e.name, e.salary, d.name AS department
FROM employees e
JOIN departments d ON e.department_id = d.id
JOIN dept_max dm ON e.department_id = dm.department_id AND e.salary = dm.max_salary;

-- === Multiple CTEs chained ===
WITH monthly_revenue AS (
    SELECT DATE_TRUNC('month', order_date) AS month,
           SUM(total_amount) AS revenue
    FROM orders WHERE status = 'completed'
    GROUP BY DATE_TRUNC('month', order_date)
),
revenue_with_growth AS (
    SELECT month, revenue,
           LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
           ROUND((revenue - LAG(revenue) OVER (ORDER BY month)) /
                 NULLIF(LAG(revenue) OVER (ORDER BY month), 0) * 100, 1) AS growth_pct
    FROM monthly_revenue
)
SELECT * FROM revenue_with_growth ORDER BY month;

-- === Recursive CTE: org chart (manager hierarchy) ===
WITH RECURSIVE org_chart AS (
    -- Base case: top-level managers (no manager)
    SELECT id, name, manager_id, 1 AS level, name AS path
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive: employees who report to someone in the previous level
    SELECT e.id, e.name, e.manager_id, oc.level + 1,
           oc.path || ' → ' || e.name
    FROM employees e
    JOIN org_chart oc ON e.manager_id = oc.id
)
SELECT level, name, path FROM org_chart ORDER BY path;

-- === EXISTS vs IN (subquery performance) ===
-- EXISTS: stops at first match (faster for large subqueries)
-- IN: evaluates entire subquery first
-- Use EXISTS when subquery returns many rows

-- Customers who have at least one order (EXISTS — faster)
SELECT c.name FROM customers c
WHERE EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.id);

-- Same with IN (slower for large datasets)
SELECT c.name FROM customers c
WHERE c.id IN (SELECT customer_id FROM orders);
