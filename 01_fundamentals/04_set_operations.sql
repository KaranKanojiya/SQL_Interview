-- ============================================================================
-- Q4. UNION vs UNION ALL vs INTERSECT vs EXCEPT
-- ============================================================================
-- Companies: Amazon, Microsoft | Difficulty: Easy-Medium
--
-- UNION:     combine results, remove duplicates
-- UNION ALL: combine results, keep duplicates (faster — no dedup)
-- INTERSECT: only rows in BOTH queries
-- EXCEPT:    rows in first query but NOT in second

-- === UNION: all unique cities from employees and customers ===
SELECT location AS city, 'department' AS source FROM departments
UNION
SELECT city, 'customer' FROM customers
ORDER BY city;

-- === UNION ALL: keeps duplicates (faster) ===
SELECT city FROM customers
UNION ALL
SELECT location FROM departments;

-- === INTERSECT: cities that appear in BOTH tables ===
SELECT city FROM customers
INTERSECT
SELECT location FROM departments;
-- Result: New York, San Francisco, Chicago

-- === EXCEPT: customer cities NOT in department locations ===
SELECT city FROM customers
EXCEPT
SELECT location FROM departments;
-- Result: Boston (only in customers)
