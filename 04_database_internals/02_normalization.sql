-- ============================================================================
-- Q13. Normalization (1NF, 2NF, 3NF, BCNF) + When to Denormalize
-- ============================================================================
-- Companies: Amazon, Google | Difficulty: Medium (conceptual)
--
-- Normalization reduces data redundancy by organizing tables.
--
-- 1NF: No repeating groups, atomic values
--   ❌ skills = "Java, Python, SQL"     (multi-valued)
--   ✅ Separate skills table with one row per skill
--
-- 2NF: 1NF + no partial dependencies
--   Every non-key column depends on the WHOLE primary key (not just part of composite key)
--   ❌ (student_id, course_id) → student_name  (depends only on student_id)
--   ✅ Separate students table
--
-- 3NF: 2NF + no transitive dependencies
--   Non-key columns don't depend on OTHER non-key columns
--   ❌ employee → department_id → department_name  (transitive)
--   ✅ Separate departments table (which we already have!)
--
-- BCNF: 3NF + every determinant is a candidate key
--   Rare edge case — 3NF is sufficient for most interviews
--
-- WHEN TO DENORMALIZE:
--   ✅ Read-heavy workloads (analytics, dashboards, reporting)
--   ✅ Reducing JOIN complexity (pre-compute aggregations)
--   ✅ Caching layer (materialized views)
--   ❌ Write-heavy with consistency requirements → keep normalized

-- === Example: Our schema IS normalized (3NF) ===
-- employees.department_id → departments.id (no transitive dependency)
-- orders.customer_id → customers.id (proper foreign key)
-- order_items has its own table (no repeating groups in orders)

-- === Denormalized example: add department_name directly to employees ===
-- This avoids a JOIN but creates data redundancy
-- ALTER TABLE employees ADD COLUMN department_name VARCHAR(50);
-- UPDATE employees e SET department_name = d.name FROM departments d WHERE e.department_id = d.id;
-- Now you have department_name in TWO places — must keep in sync!

-- === Materialized View: pre-computed denormalized data ===
-- Best of both worlds: normalized source tables + fast denormalized reads
CREATE MATERIALIZED VIEW IF NOT EXISTS customer_summary AS
SELECT c.id, c.name, c.city,
    COUNT(o.id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS total_spent,
    MAX(o.order_date) AS last_order_date
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id AND o.status = 'completed'
GROUP BY c.id, c.name, c.city;

-- Refresh when data changes:
-- REFRESH MATERIALIZED VIEW customer_summary;

SELECT * FROM customer_summary ORDER BY total_spent DESC;
