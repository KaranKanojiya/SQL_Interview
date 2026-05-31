-- ============================================================================
-- Q5. CASE WHEN, COALESCE, NULL handling
-- ============================================================================
-- Companies: ALL | Difficulty: Easy-Medium

-- === CASE WHEN: conditional logic in SQL ===
SELECT name, salary,
    CASE
        WHEN salary >= 150000 THEN 'Senior'
        WHEN salary >= 120000 THEN 'Mid'
        WHEN salary >= 100000 THEN 'Junior'
        ELSE 'Entry'
    END AS level,
    CASE
        WHEN salary >= (SELECT AVG(salary) FROM employees) THEN 'Above Average'
        ELSE 'Below Average'
    END AS vs_average
FROM employees
WHERE is_active = true
ORDER BY salary DESC;

-- === CASE in aggregation: pivot-like behavior ===
SELECT d.name AS department,
    COUNT(CASE WHEN e.salary >= 130000 THEN 1 END) AS high_earners,
    COUNT(CASE WHEN e.salary < 130000 THEN 1 END) AS others,
    COUNT(*) AS total
FROM employees e
JOIN departments d ON e.department_id = d.id
GROUP BY d.name;

-- === COALESCE: first non-NULL value ===
-- Useful for: default values, fallbacks
SELECT name,
    COALESCE(email, 'no-email@company.com') AS email,
    COALESCE(city, 'Unknown') AS city
FROM customers;

-- === NULLIF: returns NULL if two values are equal ===
-- Useful for: avoiding division by zero
SELECT name, salary,
    salary / NULLIF((SELECT COUNT(*) FROM employees WHERE department_id = e.department_id), 0) AS salary_per_dept_member
FROM employees e;

-- === NULL gotchas ===
-- NULL = NULL is NOT true! Use IS NULL
-- NULL in WHERE: WHERE col = NULL → never matches! Use WHERE col IS NULL
-- NULL in aggregations: COUNT(*) counts all rows, COUNT(col) skips NULLs
SELECT
    COUNT(*) AS total_customers,
    COUNT(email) AS with_email,        -- skips NULLs
    COUNT(*) - COUNT(email) AS without_email
FROM customers;
