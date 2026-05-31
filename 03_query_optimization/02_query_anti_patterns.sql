-- ============================================================================
-- Q11. Query Anti-Patterns and Optimizations
-- ============================================================================
-- Companies: Amazon, Google, Uber | Difficulty: Medium
--
-- Common performance killers and how to fix them

-- === Anti-pattern 1: SELECT * ===
-- ❌ BAD:  SELECT * FROM employees JOIN departments...
-- ✅ GOOD: SELECT e.name, e.salary, d.name FROM employees e JOIN departments d...
-- Why: fewer columns = less I/O, enables covering indexes

-- === Anti-pattern 2: N+1 query problem ===
-- ❌ BAD (application code):
--   for each department:
--     SELECT * FROM employees WHERE department_id = dept.id;  -- N queries!
--
-- ✅ GOOD: one query with JOIN
SELECT d.name, e.name, e.salary
FROM departments d
JOIN employees e ON d.id = e.department_id;

-- === Anti-pattern 3: DISTINCT instead of fixing JOINs ===
-- If you need DISTINCT, your JOIN might be wrong (creating duplicates)
-- ❌ SELECT DISTINCT e.name FROM employees e JOIN orders o ON ...
-- ✅ Fix the JOIN or use EXISTS instead

-- === Anti-pattern 4: NOT IN with NULLs ===
-- ❌ NOT IN fails silently with NULLs:
--    SELECT * FROM customers WHERE id NOT IN (SELECT customer_id FROM orders);
--    If customer_id has ANY NULL → returns ZERO rows!
-- ✅ Use NOT EXISTS instead:
SELECT c.name FROM customers c
WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.id);

-- === Anti-pattern 5: Correlated subquery in SELECT ===
-- ❌ BAD: runs subquery for EVERY row
-- SELECT name, (SELECT COUNT(*) FROM orders WHERE customer_id = c.id) FROM customers c;
-- ✅ GOOD: LEFT JOIN with GROUP BY
SELECT c.name, COUNT(o.id) AS order_count
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name;

-- === Optimization: LIMIT for pagination ===
-- ❌ BAD: OFFSET 10000 LIMIT 10 → DB reads 10010 rows, discards 10000
-- ✅ GOOD: keyset pagination (seek method)
--    WHERE id > last_seen_id ORDER BY id LIMIT 10
SELECT * FROM employees
WHERE id > 5  -- last seen ID from previous page
ORDER BY id
LIMIT 5;
