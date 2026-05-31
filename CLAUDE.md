# SQL & Database Interview Prep

## What This Is
30 SQL interview questions as runnable .sql files against PostgreSQL 16 (Docker). 5 categories: fundamentals, window functions, optimization, internals, interview favorites.

## Tech Stack
- PostgreSQL 16 (Docker on port 5433)
- 14 SQL files + 1 seed data file

## Run
```bash
docker compose up -d
docker exec -i sql-interview-postgres psql -U interview -d interviewdb < data/00_setup.sql
docker exec -i sql-interview-postgres psql -U interview -d interviewdb < 01_fundamentals/01_joins.sql
```

## Structure
```
data/                    — seed data (employees, customers, orders, products, sales)
01_fundamentals/         — JOINs, GROUP BY, CTEs, CASE, UPSERT
02_window_functions/     — RANK, LAG/LEAD, running totals
03_query_optimization/   — EXPLAIN, indexes, anti-patterns
04_database_internals/   — ACID, normalization, partitioning
05_interview_favorites/  — Nth salary, duplicates, gaps, pivot, top FAANG
```
