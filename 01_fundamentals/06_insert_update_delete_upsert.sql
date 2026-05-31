-- ============================================================================
-- Q6. INSERT, UPDATE, DELETE, UPSERT
-- ============================================================================
-- Companies: Amazon, Microsoft | Difficulty: Easy

-- === INSERT ===
INSERT INTO customers (name, email, city, signup_date)
VALUES ('New Customer', 'new@mail.com', 'Boston', CURRENT_DATE);

-- === INSERT multiple rows ===
INSERT INTO products (name, category, price) VALUES
    ('Mouse', 'Electronics', 29.99),
    ('Keyboard', 'Electronics', 59.99);

-- === INSERT from SELECT ===
-- INSERT INTO archive_orders SELECT * FROM orders WHERE status = 'completed';

-- === UPDATE ===
UPDATE employees SET salary = salary * 1.10
WHERE department_id = 1 AND is_active = true;
-- Give 10% raise to all active Engineering employees

-- === UPDATE with JOIN (PostgreSQL) ===
UPDATE employees e SET salary = salary * 1.05
FROM departments d
WHERE e.department_id = d.id AND d.name = 'Sales';

-- === DELETE ===
DELETE FROM orders WHERE status = 'cancelled' AND order_date < '2024-01-01';

-- === UPSERT (INSERT ... ON CONFLICT) — PostgreSQL ===
-- Insert if not exists, update if exists (by unique constraint)
INSERT INTO customers (name, email, city, signup_date)
VALUES ('Customer A', 'a@mail.com', 'Updated City', CURRENT_DATE)
ON CONFLICT (email) DO UPDATE SET
    city = EXCLUDED.city,
    name = EXCLUDED.name;
-- EXCLUDED refers to the row that was trying to be inserted

-- === RETURNING: get back affected rows ===
-- UPDATE employees SET salary = salary * 1.05 WHERE department_id = 1
-- RETURNING id, name, salary;
