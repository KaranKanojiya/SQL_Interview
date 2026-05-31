-- ============================================================================
-- Q10. EXPLAIN / EXPLAIN ANALYZE + Indexes
-- ============================================================================
-- Companies: Amazon, Google, Uber | Difficulty: Medium-Hard
--
-- EXPLAIN:         shows query plan WITHOUT executing
-- EXPLAIN ANALYZE: shows plan + ACTUAL execution times
--
-- Key things to look for:
--   Seq Scan     → full table scan (slow on large tables → need index)
--   Index Scan   → using an index (fast)
--   Nested Loop  → OK for small tables, slow for large
--   Hash Join    → good for large tables
--   Sort         → might need index if ORDER BY is slow
--   cost=0.00..X → estimated cost (lower is better)
--   rows=N       → estimated row count

-- === See query plan ===
EXPLAIN SELECT * FROM employees WHERE salary > 130000;
-- Shows: Seq Scan (no index on salary)

EXPLAIN ANALYZE SELECT * FROM employees WHERE department_id = 1;
-- Shows: actual execution time

-- === Create indexes ===
-- B-Tree (default): equality and range queries
CREATE INDEX idx_emp_salary ON employees(salary);
CREATE INDEX idx_emp_dept ON employees(department_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_customer ON orders(customer_id);

-- Now compare:
EXPLAIN ANALYZE SELECT * FROM employees WHERE salary > 130000;
-- Should show: Index Scan (faster)

-- === Composite index: order matters! ===
-- For WHERE department_id = 1 AND salary > 100000
CREATE INDEX idx_emp_dept_salary ON employees(department_id, salary);
-- This index works for:
--   WHERE department_id = 1                    ✅ (leftmost prefix)
--   WHERE department_id = 1 AND salary > 100000 ✅ (both columns)
--   WHERE salary > 100000                       ❌ (salary alone — not leftmost)

-- === Covering index: includes all columns needed ===
-- Query only needs name and salary → index covers it, no table lookup needed
CREATE INDEX idx_emp_covering ON employees(department_id) INCLUDE (name, salary);

-- === When NOT to index ===
-- Small tables (< 1000 rows): seq scan is faster than index overhead
-- Low cardinality columns (boolean, status with 3 values): index not selective
-- Write-heavy tables: every INSERT/UPDATE must update indexes too
-- Columns rarely used in WHERE/JOIN/ORDER BY

-- === Drop indexes ===
-- DROP INDEX idx_emp_salary;

-- === Anti-patterns that prevent index usage ===
-- ❌ Function on indexed column:
--    WHERE UPPER(name) = 'KARAN'     → doesn't use index on name
--    Fix: CREATE INDEX idx_name_upper ON employees(UPPER(name));
--
-- ❌ Implicit type conversion:
--    WHERE id = '123'                → id is INT, '123' is VARCHAR → no index
--
-- ❌ LIKE with leading wildcard:
--    WHERE name LIKE '%aran'         → can't use B-tree index
--    WHERE name LIKE 'Kar%'          → ✅ CAN use index
--
-- ❌ OR conditions:
--    WHERE dept = 1 OR salary > 100000 → may not use index efficiently
