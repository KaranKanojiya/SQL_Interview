-- ============================================================================
-- Q12. ACID Properties + Transaction Isolation Levels
-- ============================================================================
-- Companies: ALL — conceptual, asked in every backend interview
-- Difficulty: Medium
--
-- ACID:
--   A — Atomicity:    all or nothing (transaction fully completes or fully rolls back)
--   C — Consistency:  DB moves from one valid state to another (constraints enforced)
--   I — Isolation:    concurrent transactions don't interfere with each other
--   D — Durability:   committed data survives crashes (written to disk/WAL)
--
-- ISOLATION LEVELS (weakest → strongest):
--   READ UNCOMMITTED: can read uncommitted data (dirty reads) — rarely used
--   READ COMMITTED:   can only read committed data — PostgreSQL default
--   REPEATABLE READ:  same query returns same result within a transaction — MySQL default
--   SERIALIZABLE:     transactions appear to execute one at a time — safest, slowest
--
-- Problems prevented:
--   | Level            | Dirty Read | Non-Repeatable Read | Phantom Read |
--   |-----------------|------------|---------------------|-------------|
--   | READ UNCOMMITTED | Possible   | Possible            | Possible    |
--   | READ COMMITTED   | Prevented  | Possible            | Possible    |
--   | REPEATABLE READ  | Prevented  | Prevented           | Possible    |
--   | SERIALIZABLE     | Prevented  | Prevented           | Prevented   |

-- === Transaction example ===
BEGIN;
    UPDATE employees SET salary = salary - 1000 WHERE name = 'Alice Chen';
    UPDATE employees SET salary = salary + 1000 WHERE name = 'Bob Smith';
    -- If either fails → ROLLBACK, both are undone
COMMIT;

-- === Set isolation level ===
-- SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- BEGIN;
--   SELECT * FROM employees WHERE department_id = 1;
--   -- Another transaction can't modify these rows until we commit
-- COMMIT;

-- === Savepoint (partial rollback) ===
BEGIN;
    INSERT INTO customers (name, city) VALUES ('Test1', 'NYC');
    SAVEPOINT sp1;
    INSERT INTO customers (name, city) VALUES ('Test2', 'LA');
    ROLLBACK TO sp1;  -- undo Test2 only
COMMIT;  -- Test1 is committed, Test2 is not

-- === Deadlock example (conceptual) ===
-- Transaction A: locks row 1, then tries to lock row 2
-- Transaction B: locks row 2, then tries to lock row 1
-- → Deadlock! PostgreSQL detects and kills one transaction
-- Prevention: always lock rows in the same order

-- === PostgreSQL locking ===
-- SELECT ... FOR UPDATE    → exclusive row lock (others wait)
-- SELECT ... FOR SHARE     → shared row lock (others can read, not write)
-- Useful for: inventory deduction, seat booking, balance updates
SELECT * FROM employees WHERE id = 1 FOR UPDATE;
-- This row is now locked until COMMIT/ROLLBACK
