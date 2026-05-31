# SQL & Database Interview Prep

**30 SQL interview questions with runnable queries — tested against PostgreSQL.**

> **21 SQL files** | **5 categories** | **30 questions** | **1 cheatsheet (L1→Staff)** | **PostgreSQL 16 (Docker)**

```
Category 1  [==========]  Fundamentals         JOINs, GROUP BY, Subqueries, CTEs, CASE    6 files
Category 2  [==========]  Window Functions      RANK, LAG/LEAD, Running Totals             3 files
Category 3  [==========]  Query Optimization    EXPLAIN, Indexes, Anti-patterns             2 files
Category 4  [==========]  Database Internals    ACID, Normalization, Partitioning           3 files
Category 5  [==========]  Interview Favorites   Nth Salary, Duplicates, Gaps, Pivot, Top FAANG  6 files (includes seed data)
```

---

## Quick Start

### Step 1: Start PostgreSQL (Docker)

```bash
cd SQL_Interview
docker compose up -d
```

| Setting | Value |
|---------|-------|
| Host | `localhost` |
| Port | `5433` (not 5432 — avoids conflict with Spring Boot's PostgreSQL) |
| Database | `interviewdb` |
| Username | `interview` |
| Password | `interview123` |
| JDBC URL | `jdbc:postgresql://localhost:5433/interviewdb` |

### Step 2: Load Seed Data

```bash
docker exec -i sql-interview-postgres psql -U interview -d interviewdb < data/00_setup.sql
```

You should see: `Setup complete: 15 employees, 8 customers, 13 orders, 10 products, 16 sales`

### Step 3: Run Any Query File

```bash
# Run a specific file
docker exec -i sql-interview-postgres psql -U interview -d interviewdb < 01_fundamentals/01_joins.sql

# Or connect interactively and paste queries
docker exec -it sql-interview-postgres psql -U interview -d interviewdb
```

### Connect via DB Client (IntelliJ / DBeaver)

| Setting | Value |
|---------|-------|
| Host | `localhost` |
| Port | `5433` |
| Database | `interviewdb` |
| Username | `interview` |
| Password | `interview123` |
| JDBC URL | `jdbc:postgresql://localhost:5433/interviewdb` |

### Stop PostgreSQL

```bash
docker compose down        # stop (keep data)
docker compose down -v     # stop + delete data
```

---

## All 30 Questions

### Category 1: SQL Fundamentals (6 files)

| # | Question | File | Key Concepts |
|---|----------|------|-------------|
| Q1 | All types of JOINs | `01_joins.sql` | INNER, LEFT, RIGHT, FULL, CROSS, SELF + employees earning more than manager |
| Q2 | GROUP BY + HAVING | `02_group_by_having.sql` | WHERE vs HAVING, multiple aggregations, monthly summaries |
| Q3 | Subqueries vs CTEs | `03_subqueries_cte.sql` | Correlated subquery, recursive CTE (org chart), EXISTS vs IN |
| Q4 | Set Operations | `04_set_operations.sql` | UNION, UNION ALL, INTERSECT, EXCEPT |
| Q5 | CASE + NULL handling | `05_case_coalesce_null.sql` | CASE WHEN, COALESCE, NULLIF, NULL gotchas |
| Q6 | INSERT/UPDATE/DELETE | `06_insert_update_delete_upsert.sql` | UPSERT (ON CONFLICT), UPDATE with JOIN, RETURNING |

### Category 2: Window Functions (3 files)

| # | Question | File | Key Concepts |
|---|----------|------|-------------|
| Q7 | ROW_NUMBER, RANK, DENSE_RANK | `01_rank_functions.sql` | Top earner per dept, Nth highest salary, Top N per group |
| Q8 | LAG, LEAD | `02_lag_lead.sql` | Month-over-month comparison, consecutive days, growth rate |
| Q9 | Running Totals | `03_running_totals.sql` | Cumulative sum, moving average, NTILE, FIRST_VALUE |

### Category 3: Query Optimization (2 files)

| # | Question | File | Key Concepts |
|---|----------|------|-------------|
| Q10 | EXPLAIN + Indexes | `01_explain_indexes.sql` | B-Tree, composite, covering index, anti-patterns |
| Q11 | Query Anti-Patterns | `02_query_anti_patterns.sql` | SELECT *, N+1, NOT IN with NULLs, keyset pagination |

### Category 4: Database Internals (3 files)

| # | Question | File | Key Concepts |
|---|----------|------|-------------|
| Q12 | ACID + Transactions | `01_acid_transactions.sql` | Isolation levels, FOR UPDATE, savepoints, deadlocks |
| Q13 | Normalization | `02_normalization.sql` | 1NF-3NF-BCNF, when to denormalize, materialized views |
| Q14 | Partitioning | `03_partitioning_replication.sql` | Range partition, replication, sharding concepts |

### Category 5: Interview Favorites (6 files)

| # | Question | File | Companies |
|---|----------|------|-----------|
| Q15 | Nth Highest Salary (4 methods) | `01_nth_highest_salary.sql` | ALL FAANG |
| Q16 | Find Duplicates + Delete | `02_find_duplicates.sql` | Amazon, Google |
| Q17 | Running Total / Cumulative | `03_running_total_cumulative.sql` | Amazon, Uber |
| Q18 | Gaps and Islands | `04_gaps_and_islands.sql` | Google, Uber |
| Q19 | Pivot / Unpivot | `05_pivot_unpivot.sql` | Amazon, Microsoft |
| Q20-30 | Top FAANG Questions | `06_top_faang_questions.sql` | All — 11 most-asked queries |

---

## Project Structure

```
SQL_Interview/
├── data/
│   └── 00_setup.sql                    # Seed data (employees, customers, orders, products, sales)
├── 01_fundamentals/
│   ├── 01_joins.sql                    # All JOIN types + self join
│   ├── 02_group_by_having.sql          # Aggregations, WHERE vs HAVING
│   ├── 03_subqueries_cte.sql           # CTEs, recursive, EXISTS vs IN
│   ├── 04_set_operations.sql           # UNION, INTERSECT, EXCEPT
│   ├── 05_case_coalesce_null.sql       # Conditional logic, NULL handling
│   └── 06_insert_update_delete_upsert.sql  # DML + UPSERT
├── 02_window_functions/
│   ├── 01_rank_functions.sql           # ROW_NUMBER, RANK, DENSE_RANK
│   ├── 02_lag_lead.sql                 # Previous/next row access
│   └── 03_running_totals.sql           # Cumulative, moving avg, NTILE
├── 03_query_optimization/
│   ├── 01_explain_indexes.sql          # EXPLAIN ANALYZE, index types
│   └── 02_query_anti_patterns.sql      # N+1, SELECT *, pagination
├── 04_database_internals/
│   ├── 01_acid_transactions.sql        # ACID, isolation, locking
│   ├── 02_normalization.sql            # 1NF-BCNF, materialized views
│   └── 03_partitioning_replication.sql # Partitioning, sharding concepts
├── 05_interview_favorites/
│   ├── 01_nth_highest_salary.sql       # 4 different methods
│   ├── 02_find_duplicates.sql          # Find + delete duplicates
│   ├── 03_running_total_cumulative.sql # Running totals, YTD
│   ├── 04_gaps_and_islands.sql         # Consecutive sequences
│   ├── 05_pivot_unpivot.sql            # Rows ↔ columns
│   └── 06_top_faang_questions.sql      # 11 most-asked FAANG queries
├── docker-compose.yml
├── SQL_CHEATSHEET.md                   # L1 to Staff: must-know questions + company-specific
├── CLAUDE.md
└── README.md
```

---

## Cheatsheet: [SQL_CHEATSHEET.md](SQL_CHEATSHEET.md)

Covers questions by seniority level with sample queries and company-specific focus:

| Level | Focus | # Questions |
|-------|-------|-------------|
| L1/L2 (Junior/Mid) | Basic JOINs, GROUP BY, WHERE, NULL handling | 10 |
| L3/L4 (Mid/Senior) | Window functions, CTEs, self-joins, duplicates | 14 |
| L5 (Senior) | Gaps & islands, moving avg, EXPLAIN, pagination | 10 |
| L6/L7 (Staff) | ACID, isolation, partitioning, sharding, design tradeoffs | 10 |
| **Company-specific** | Amazon (6), Google (5), Meta (5), Uber (5), Microsoft (5) | 26 |

Also includes: execution order, window function syntax, JOIN visual, index decision guide, NULL rules.

---

## Troubleshooting

### Port 5433 already in use
```bash
lsof -i :5433
kill <PID>
docker compose up -d
```

### Reset data
```bash
docker exec -i sql-interview-postgres psql -U interview -d interviewdb < data/00_setup.sql
```

### Connect failed
```bash
docker compose ps   # check container is running
docker compose logs # check for errors
```
