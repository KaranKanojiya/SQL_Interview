-- ============================================================================
-- Q7. ROW_NUMBER, RANK, DENSE_RANK
-- ============================================================================
-- Companies: Amazon, Google, Meta, Uber — #1 most asked SQL topic
-- Difficulty: Medium
--
-- ROW_NUMBER(): unique sequential number (1,2,3,4) — no ties
-- RANK():       gaps on ties (1,2,2,4) — skips rank after tie
-- DENSE_RANK(): no gaps on ties (1,2,2,3) — doesn't skip
--
-- Syntax: function() OVER (PARTITION BY col ORDER BY col)
--   PARTITION BY = group (like GROUP BY but keeps individual rows)
--   ORDER BY = ranking order within partition

-- === Compare all three on salary ===
SELECT name, department_id, salary,
    ROW_NUMBER() OVER (ORDER BY salary DESC) AS row_num,     -- 1,2,3,4,5
    RANK()       OVER (ORDER BY salary DESC) AS rank,         -- 1,2,3,3,5 (skips 4)
    DENSE_RANK() OVER (ORDER BY salary DESC) AS dense_rank    -- 1,2,3,3,4 (no skip)
FROM employees
WHERE is_active = true;

-- === Top earner PER DEPARTMENT (PARTITION BY) ===
-- This is the #1 most asked window function question
WITH ranked AS (
    SELECT name, salary, d.name AS department,
        ROW_NUMBER() OVER (PARTITION BY e.department_id ORDER BY e.salary DESC) AS rn
    FROM employees e
    JOIN departments d ON e.department_id = d.id
    WHERE e.is_active = true
)
SELECT department, name, salary
FROM ranked
WHERE rn = 1;  -- only top earner per department

-- === Top N per group (top 2 earners per department) ===
WITH ranked AS (
    SELECT e.name, e.salary, d.name AS department,
        DENSE_RANK() OVER (PARTITION BY e.department_id ORDER BY e.salary DESC) AS dr
    FROM employees e
    JOIN departments d ON e.department_id = d.id
    WHERE e.is_active = true
)
SELECT department, name, salary, dr
FROM ranked
WHERE dr <= 2;

-- === Nth highest salary (classic interview question) ===
-- Find the 3rd highest salary
WITH ranked AS (
    SELECT DISTINCT salary,
        DENSE_RANK() OVER (ORDER BY salary DESC) AS dr
    FROM employees
)
SELECT salary FROM ranked WHERE dr = 3;
