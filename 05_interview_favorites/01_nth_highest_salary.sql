-- ============================================================================
-- Q15. Find the Nth Highest Salary (THE classic SQL interview question)
-- ============================================================================
-- Companies: ALL FAANG — asked in ~40% of SQL interviews
-- LeetCode: #176, #177 | Difficulty: Medium
-- Multiple solutions — know at least 3

-- === Method 1: DENSE_RANK (best — handles ties, clean) ===
-- N = 3 (third highest)
WITH ranked AS (
    SELECT DISTINCT salary,
        DENSE_RANK() OVER (ORDER BY salary DESC) AS dr
    FROM employees
)
SELECT salary AS third_highest FROM ranked WHERE dr = 3;

-- === Method 2: OFFSET/LIMIT (simple but breaks on ties) ===
SELECT DISTINCT salary
FROM employees
ORDER BY salary DESC
LIMIT 1 OFFSET 2;  -- skip 2, take 1 = 3rd highest

-- === Method 3: Subquery (no window functions — older SQL) ===
SELECT MAX(salary) AS third_highest
FROM employees
WHERE salary < (
    SELECT MAX(salary) FROM employees
    WHERE salary < (SELECT MAX(salary) FROM employees)
);

-- === Method 4: Generic Nth (parameterized) ===
-- Replace 3 with any N
SELECT DISTINCT salary
FROM employees e1
WHERE 3 = (
    SELECT COUNT(DISTINCT salary)
    FROM employees e2
    WHERE e2.salary >= e1.salary
);

-- === Second highest salary per department ===
WITH ranked AS (
    SELECT name, salary, department_id,
        DENSE_RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS dr
    FROM employees WHERE is_active = true
)
SELECT d.name AS department, r.name, r.salary
FROM ranked r
JOIN departments d ON r.department_id = d.id
WHERE dr = 2;
