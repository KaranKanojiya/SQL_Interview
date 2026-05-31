# SQL Interview Cheatsheet — L1 to Staff Level

**Must-know questions by seniority level — what to expect and how to answer.**

---

## Table of Contents

1. [L1/L2 (Junior/Mid) — Fundamentals](#l1l2-juniormid)
2. [L3/L4 (Mid/Senior) — Window Functions + Optimization](#l3l4-midsenior)
3. [L5 (Senior) — Complex Queries + Design](#l5-senior)
4. [L6/L7 (Staff/Principal) — Architecture + Tradeoffs](#l6l7-staffprincipal)
5. [Most Famous Questions by Company](#most-famous-by-company)
6. [Quick Reference — SQL Syntax](#quick-reference)

---

## L1/L2 (Junior/Mid)

**Expect:** Basic SQL, simple JOINs, GROUP BY, filtering. Can you read and write queries?

### Must-Know Questions

| # | Question | Pattern | One-liner |
|---|----------|---------|-----------|
| 1 | **SELECT with WHERE, ORDER BY, LIMIT** | Basics | `SELECT * FROM t WHERE x > 5 ORDER BY y DESC LIMIT 10` |
| 2 | **INNER JOIN two tables** | JOIN | `SELECT * FROM a JOIN b ON a.id = b.a_id` |
| 3 | **LEFT JOIN + NULL check** | JOIN | Find customers with no orders: `LEFT JOIN ... WHERE o.id IS NULL` |
| 4 | **COUNT, SUM, AVG, MIN, MAX** | Aggregation | `SELECT dept, COUNT(*), AVG(salary) FROM emp GROUP BY dept` |
| 5 | **GROUP BY + HAVING** | Aggregation | `GROUP BY dept HAVING COUNT(*) > 5` (filter groups, not rows) |
| 6 | **WHERE vs HAVING** | Concept | WHERE filters rows BEFORE grouping, HAVING filters AFTER |
| 7 | **DISTINCT** | Dedup | `SELECT DISTINCT city FROM customers` |
| 8 | **LIKE pattern matching** | Filter | `WHERE name LIKE 'K%'` (starts with K), `'%an%'` (contains an) |
| 9 | **IN, NOT IN, BETWEEN** | Filter | `WHERE id IN (1,2,3)`, `WHERE salary BETWEEN 50000 AND 100000` |
| 10 | **NULL handling** | Gotcha | `NULL = NULL` is NOT true → use `IS NULL`. COUNT(*) includes NULLs, COUNT(col) doesn't |

### Sample Interview Questions

```sql
-- "Find all employees in Engineering department" (basic JOIN)
SELECT e.name, e.salary FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE d.name = 'Engineering';

-- "Find customers who never ordered" (LEFT JOIN + NULL)
SELECT c.name FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
WHERE o.id IS NULL;

-- "Count employees per department, only departments with 3+" (GROUP BY + HAVING)
SELECT d.name, COUNT(*) as emp_count
FROM employees e JOIN departments d ON e.department_id = d.id
GROUP BY d.name HAVING COUNT(*) >= 3;
```

---

## L3/L4 (Mid/Senior)

**Expect:** Window functions, subqueries, CTEs, self-joins. Can you solve multi-step problems?

### Must-Know Questions

| # | Question | Pattern | Key |
|---|----------|---------|-----|
| 11 | **Nth highest salary** | Window | `DENSE_RANK() OVER (ORDER BY salary DESC)` — know 3+ methods |
| 12 | **Top N per group** | Window | `ROW_NUMBER() OVER (PARTITION BY dept ORDER BY salary DESC)` then filter rn <= N |
| 13 | **ROW_NUMBER vs RANK vs DENSE_RANK** | Window | ROW_NUMBER: unique, RANK: gaps on ties, DENSE_RANK: no gaps |
| 14 | **LAG / LEAD** | Window | Previous/next row: month-over-month comparison, growth rate |
| 15 | **Running total** | Window | `SUM(amount) OVER (ORDER BY date)` |
| 16 | **Self JOIN** | JOIN | Employee + manager, employees earning more than their manager |
| 17 | **CTE (WITH clause)** | Subquery | Named temporary results, reusable, cleaner than nested subqueries |
| 18 | **Recursive CTE** | Advanced | Org chart, hierarchical data: `WITH RECURSIVE org AS (...)` |
| 19 | **EXISTS vs IN** | Performance | EXISTS stops at first match (faster for large subqueries) |
| 20 | **Find duplicates** | Aggregation | `GROUP BY col HAVING COUNT(*) > 1` |
| 21 | **Delete duplicates** | Window | Keep lowest ID: `ROW_NUMBER() OVER (PARTITION BY email ORDER BY id)`, delete rn > 1 |
| 22 | **UNION vs UNION ALL** | Set ops | UNION removes dups (slower), UNION ALL keeps dups (faster) |
| 23 | **CASE WHEN in aggregation** | Pivot | `COUNT(CASE WHEN status = 'active' THEN 1 END)` — manual pivot |
| 24 | **Correlated subquery** | Subquery | Subquery references outer query: `WHERE salary > (SELECT AVG(salary) FROM emp e2 WHERE e2.dept = e1.dept)` |

### Sample Interview Questions

```sql
-- "Find the 3rd highest salary" (DENSE_RANK)
WITH ranked AS (
    SELECT DISTINCT salary, DENSE_RANK() OVER (ORDER BY salary DESC) AS dr
    FROM employees
)
SELECT salary FROM ranked WHERE dr = 3;

-- "Top earner per department" (ROW_NUMBER + PARTITION BY)
WITH ranked AS (
    SELECT name, salary, department_id,
        ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) AS rn
    FROM employees
)
SELECT * FROM ranked WHERE rn = 1;

-- "Month-over-month revenue growth" (LAG)
WITH monthly AS (
    SELECT DATE_TRUNC('month', order_date) AS month, SUM(total_amount) AS revenue
    FROM orders WHERE status = 'completed' GROUP BY 1
)
SELECT month, revenue, LAG(revenue) OVER (ORDER BY month) AS prev,
    ROUND((revenue - LAG(revenue) OVER (ORDER BY month)) / 
          NULLIF(LAG(revenue) OVER (ORDER BY month), 0) * 100, 1) AS growth_pct
FROM monthly;

-- "Employees earning more than their manager" (SELF JOIN)
SELECT e.name AS employee, e.salary, m.name AS manager, m.salary AS mgr_salary
FROM employees e JOIN employees m ON e.manager_id = m.id
WHERE e.salary > m.salary;

-- "Employees earning more than department average" (Correlated subquery)
SELECT name, salary, department_id FROM employees e
WHERE salary > (SELECT AVG(salary) FROM employees WHERE department_id = e.department_id);
```

---

## L5 (Senior)

**Expect:** Complex multi-step queries, optimization, gaps & islands, explain plans. Can you design efficient queries?

### Must-Know Questions

| # | Question | Pattern | Key |
|---|----------|---------|-----|
| 25 | **Gaps and Islands** | Window | Consecutive sequences: `date - ROW_NUMBER() AS grp` |
| 26 | **Moving average** | Window | `AVG(x) OVER (ORDER BY date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)` |
| 27 | **Pivot / Cross-tabulation** | CASE + GROUP BY | Rows → columns: `SUM(CASE WHEN region='East' THEN amount END)` |
| 28 | **Percentage of total** | Window | `SUM(x) / SUM(SUM(x)) OVER () * 100` |
| 29 | **EXPLAIN / EXPLAIN ANALYZE** | Optimization | Read query plans: Seq Scan bad, Index Scan good |
| 30 | **Index strategy** | Optimization | When to create, composite order, covering index |
| 31 | **Query anti-patterns** | Optimization | SELECT *, N+1, NOT IN with NULLs, OFFSET pagination |
| 32 | **Median** | Aggregation | `PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary)` |
| 33 | **UPSERT** | DML | `INSERT ... ON CONFLICT DO UPDATE` (PostgreSQL) |
| 34 | **Keyset pagination** | Performance | `WHERE id > last_id ORDER BY id LIMIT N` (not OFFSET) |

### Sample Interview Questions

```sql
-- "Find consecutive days with orders" (Gaps & Islands)
WITH daily AS (SELECT DISTINCT order_date FROM orders),
grouped AS (
    SELECT order_date,
        order_date - (ROW_NUMBER() OVER (ORDER BY order_date))::int AS grp
    FROM daily
)
SELECT MIN(order_date) AS start, MAX(order_date) AS end, COUNT(*) AS streak
FROM grouped GROUP BY grp HAVING COUNT(*) > 1;

-- "Revenue per category as percentage of total" (Window in aggregate)
SELECT category,
    SUM(quantity * unit_price) AS revenue,
    ROUND(SUM(quantity * unit_price) / SUM(SUM(quantity * unit_price)) OVER () * 100, 1) AS pct
FROM order_items oi JOIN products p ON oi.product_id = p.id
GROUP BY category ORDER BY revenue DESC;

-- "Moving average of last 3 orders" (ROWS BETWEEN)
SELECT customer_id, order_date, total_amount,
    ROUND(AVG(total_amount) OVER (
        PARTITION BY customer_id ORDER BY order_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS moving_avg
FROM orders WHERE status = 'completed';
```

---

## L6/L7 (Staff/Principal)

**Expect:** Database design decisions, trade-offs, scaling strategies. Not just writing queries — designing systems.

### Must-Know Concepts

| # | Topic | What they ask | Key answer |
|---|-------|--------------|-----------|
| 35 | **ACID properties** | "Explain ACID" | Atomicity (all or nothing), Consistency (constraints), Isolation (concurrent txns), Durability (survives crash) |
| 36 | **Isolation levels** | "Which level for this use case?" | READ COMMITTED (default, 95% of cases), SERIALIZABLE (money transfers), REPEATABLE READ (reports) |
| 37 | **Normalization vs Denormalization** | "When to denormalize?" | Normalize for writes/consistency. Denormalize for reads/analytics. Use materialized views for best of both. |
| 38 | **Indexing strategy** | "Design indexes for this schema" | Index WHERE/JOIN/ORDER BY columns. Composite: most selective first. Covering for read-heavy. Don't over-index write-heavy tables. |
| 39 | **Partitioning** | "Table has 1B rows, queries slow" | Range partition by date (archive old), Hash partition by user_id (even distribution). Partition key must be in WHERE clause. |
| 40 | **Replication** | "How to scale reads?" | Primary-replica: writes to primary, reads from replicas. Async replication = faster but may read stale data. |
| 41 | **Sharding** | "Table too large for one server" | Shard by user_id (even distribution). Challenges: cross-shard queries, rebalancing, no cross-shard JOINs. |
| 42 | **Deadlocks** | "How to prevent?" | Always lock in same order. Keep transactions short. Use SELECT FOR UPDATE with timeout. Detect: DB auto-kills one. |
| 43 | **Connection pooling** | "Why use HikariCP?" | Reuse DB connections (creating is expensive ~50ms). Pool size: cores × 2 + disk spindles. Too many connections = contention. |
| 44 | **Read vs write optimization** | "Design for this workload" | Read-heavy: indexes, replicas, caching, materialized views. Write-heavy: minimal indexes, batch inserts, partitioning, async replication. |

### Staff-Level Design Questions

```
"Design the database schema for an e-commerce platform"
→ Users, Products, Orders, OrderItems, Inventory, Payments, Reviews
→ Discuss: normalization, indexes, partitioning orders by date,
   eventual consistency for inventory, CQRS for read/write separation

"This query takes 30 seconds. How do you optimize?"
→ 1. EXPLAIN ANALYZE — find the slow part (Seq Scan? Sort? Nested Loop?)
→ 2. Add indexes (on WHERE, JOIN, ORDER BY columns)
→ 3. Rewrite query (replace correlated subquery with JOIN, avoid SELECT *)
→ 4. If data is huge → partition, materialized view, or denormalize
→ 5. If read pattern → cache (Redis/application cache)

"How do you handle a table with 10B rows?"
→ 1. Partition by date (range) or user_id (hash)
→ 2. Archive old data to cold storage
→ 3. Shard across multiple databases if single server can't hold it
→ 4. Read replicas for query traffic
→ 5. Materialized views for common aggregations
```

---

## Most Famous Questions by Company

### Amazon (SQL heavy in backend rounds)
1. Find customers who never ordered
2. Nth highest salary
3. Employees earning more than manager
4. Department with highest average salary
5. Duplicate emails
6. Rising temperature (compare consecutive days)

### Google (focuses on window functions)
1. Rank employees per department
2. Month-over-month growth
3. Gaps and islands (consecutive sequences)
4. Percentage of total
5. Median salary

### Meta (growth/metrics focused)
1. Year-over-year growth rate
2. Active users (30-day rolling window)
3. Retention rate by cohort
4. Revenue by category as percentage of total
5. Running cumulative sum

### Uber (real-time/temporal data)
1. Consecutive days with trips
2. Top driver per city
3. Moving average of ride fare
4. Peak hours analysis
5. Customer lifetime value

### Microsoft (broad, includes DML)
1. Pivot queries (CASE + GROUP BY)
2. UPSERT (MERGE in SQL Server)
3. CTE + recursive (hierarchy)
4. Find and delete duplicates
5. Transaction isolation scenarios

---

## Quick Reference

### Execution Order (SQL processes in this order, NOT the written order)
```
1. FROM / JOIN        ← tables and joins first
2. WHERE              ← filter rows
3. GROUP BY           ← group remaining rows
4. HAVING             ← filter groups
5. SELECT             ← compute output columns
6. DISTINCT           ← remove duplicates
7. ORDER BY           ← sort
8. LIMIT / OFFSET     ← paginate
```

### Window Function Syntax
```sql
function() OVER (
    PARTITION BY col          -- group (optional)
    ORDER BY col              -- order within group
    ROWS BETWEEN x AND y      -- frame (optional)
)

-- Frame options:
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW      -- default for SUM/AVG
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW               -- last 3 rows
ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING        -- current to end
```

### JOIN Cheatsheet
```
INNER JOIN:  only matching rows        A ∩ B
LEFT JOIN:   all from A + matching B   A + (A ∩ B)
RIGHT JOIN:  all from B + matching A   B + (A ∩ B)
FULL JOIN:   all from both             A ∪ B
CROSS JOIN:  every A × every B         A × B (cartesian)
SELF JOIN:   table with itself         A × A (e.g., employee-manager)
```

### Index Decision
```
CREATE INDEX when:
  ✅ Column used in WHERE frequently
  ✅ Column used in JOIN condition
  ✅ Column used in ORDER BY
  ✅ High cardinality (many distinct values)

DON'T index when:
  ❌ Small table (< 1000 rows)
  ❌ Low cardinality (boolean, status)
  ❌ Write-heavy table (every write updates index)
  ❌ Column rarely queried
```

### NULL Rules
```
NULL = NULL        → NULL (NOT true!)
NULL <> NULL       → NULL
NULL AND TRUE      → NULL
NULL OR TRUE       → TRUE
COUNT(*)           → counts ALL rows (including NULL)
COUNT(column)      → counts NON-NULL only
SUM/AVG/MIN/MAX    → ignores NULLs
COALESCE(a, b, c)  → first non-NULL value
NULLIF(a, b)       → NULL if a = b (avoid division by zero)
IS NULL / IS NOT NULL → correct way to check NULL
```
