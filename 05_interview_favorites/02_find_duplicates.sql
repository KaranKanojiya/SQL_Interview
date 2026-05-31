-- ============================================================================
-- Q16. Find Duplicate Records
-- ============================================================================
-- Companies: Amazon, Google, Meta | LeetCode: #182 | Difficulty: Easy-Medium

-- === Find duplicate emails ===
SELECT email, COUNT(*) AS count
FROM employees
GROUP BY email
HAVING COUNT(*) > 1;

-- === Find duplicate salaries with employee names ===
SELECT e1.name, e1.salary
FROM employees e1
WHERE EXISTS (
    SELECT 1 FROM employees e2
    WHERE e2.salary = e1.salary AND e2.id != e1.id
)
ORDER BY e1.salary DESC;

-- === Delete duplicates, keep the one with lowest ID ===
-- Shows which would be deleted (don't actually run on interview data!)
WITH duplicates AS (
    SELECT id, email,
        ROW_NUMBER() OVER (PARTITION BY email ORDER BY id) AS rn
    FROM employees
)
SELECT * FROM duplicates WHERE rn > 1;

-- To actually delete:
-- DELETE FROM employees WHERE id IN (
--     SELECT id FROM (
--         SELECT id, ROW_NUMBER() OVER (PARTITION BY email ORDER BY id) AS rn
--         FROM employees
--     ) t WHERE rn > 1
-- );

-- === Find customers who ordered the same product more than once ===
SELECT c.name, p.name AS product, COUNT(*) AS times_ordered
FROM order_items oi
JOIN orders o ON oi.order_id = o.id
JOIN customers c ON o.customer_id = c.id
JOIN products p ON oi.product_id = p.id
GROUP BY c.id, c.name, p.id, p.name
HAVING COUNT(*) > 1;
