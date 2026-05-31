-- ============================================================================
-- Q1. Explain all types of JOINs with examples
-- ============================================================================
-- Companies: ALL — asked in every SQL interview
-- Difficulty: Medium
--
-- INNER JOIN:  only matching rows from both tables
-- LEFT JOIN:   all rows from LEFT + matching from RIGHT (NULL if no match)
-- RIGHT JOIN:  all rows from RIGHT + matching from LEFT (NULL if no match)
-- FULL JOIN:   all rows from BOTH (NULL where no match)
-- CROSS JOIN:  cartesian product (every row × every row)
-- SELF JOIN:   join a table with itself

-- === INNER JOIN: employees + departments (only employees WITH a department) ===
SELECT e.name AS employee, d.name AS department, e.salary
FROM employees e
INNER JOIN departments d ON e.department_id = d.id
ORDER BY d.name, e.salary DESC;

-- === LEFT JOIN: all customers, even those with NO orders ===
-- Customer H has no orders → shows NULL for order fields
SELECT c.name AS customer, COUNT(o.id) AS order_count,
       COALESCE(SUM(o.total_amount), 0) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name
ORDER BY total_spent DESC;

-- === RIGHT JOIN: all departments, even those with NO employees ===
-- (same as LEFT JOIN with tables swapped)
SELECT d.name AS department, COUNT(e.id) AS employee_count
FROM employees e
RIGHT JOIN departments d ON e.department_id = d.id
GROUP BY d.id, d.name;

-- === FULL OUTER JOIN: all from both, NULL where no match ===
SELECT c.name AS customer, o.id AS order_id, o.total_amount
FROM customers c
FULL OUTER JOIN orders o ON c.id = o.customer_id
ORDER BY c.name;

-- === CROSS JOIN: every product with every category (cartesian) ===
-- Useful for: generating combinations, calendar tables
SELECT p1.name AS product, p2.name AS paired_with
FROM products p1
CROSS JOIN products p2
WHERE p1.id < p2.id AND p1.category = p2.category
LIMIT 10;

-- === SELF JOIN: find employee and their manager ===
-- The table joins with ITSELF — e is employee, m is manager
SELECT e.name AS employee, m.name AS manager, e.salary
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id
ORDER BY m.name NULLS FIRST, e.name;

-- === Interview favorite: employees who earn more than their manager ===
SELECT e.name AS employee, e.salary AS emp_salary,
       m.name AS manager, m.salary AS mgr_salary
FROM employees e
INNER JOIN employees m ON e.manager_id = m.id
WHERE e.salary > m.salary;
