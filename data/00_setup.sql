-- ============================================================================
-- SETUP: Create tables and seed data for all SQL interview questions
-- ============================================================================
-- Run this FIRST:  psql -U interview -d interviewdb -f data/00_setup.sql
-- Or via Docker:   docker exec -i interview-postgres psql -U interview -d interviewdb < data/00_setup.sql

DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS departments CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS sales CASCADE;

-- ============================================================
-- DEPARTMENTS
-- ============================================================
CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    location VARCHAR(50)
);

INSERT INTO departments (name, location) VALUES
('Engineering', 'San Francisco'),
('Sales', 'New York'),
('Marketing', 'Chicago'),
('HR', 'San Francisco'),
('Finance', 'New York');

-- ============================================================
-- EMPLOYEES (self-referencing: manager_id → employees.id)
-- ============================================================
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    salary DECIMAL(10,2),
    department_id INT REFERENCES departments(id),
    manager_id INT REFERENCES employees(id),
    hire_date DATE,
    is_active BOOLEAN DEFAULT true
);

INSERT INTO employees (name, email, salary, department_id, manager_id, hire_date, is_active) VALUES
('Alice Chen',    'alice@company.com',    150000, 1, NULL,  '2020-01-15', true),
('Bob Smith',     'bob@company.com',      130000, 1, 1,     '2020-06-01', true),
('Charlie Brown', 'charlie@company.com',  120000, 1, 1,     '2021-03-10', true),
('Diana Prince',  'diana@company.com',    140000, 2, NULL,  '2019-08-20', true),
('Eve Davis',     'eve@company.com',      110000, 2, 4,     '2021-01-05', true),
('Frank Wilson',  'frank@company.com',    125000, 2, 4,     '2020-11-15', true),
('Grace Lee',     'grace@company.com',    135000, 3, NULL,  '2020-03-01', true),
('Hank Miller',   'hank@company.com',     105000, 3, 7,     '2022-01-10', true),
('Ivy Johnson',   'ivy@company.com',      95000,  4, NULL,  '2021-07-01', true),
('Jack Taylor',   'jack@company.com',     145000, 5, NULL,  '2019-05-15', true),
('Karan Kumar',   'karan@company.com',    155000, 1, 1,     '2020-09-01', true),
('Liam Brown',    'liam@company.com',     120000, 1, 1,     '2022-06-15', false),
('Maria Garcia',  'maria@company.com',    130000, 2, 4,     '2023-01-10', true),
('Nina Patel',    'nina@company.com',     115000, 3, 7,     '2023-06-01', true),
('Oscar White',   'oscar@company.com',    140000, 5, 10,    '2021-11-01', true);

-- ============================================================
-- CUSTOMERS
-- ============================================================
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    city VARCHAR(50),
    signup_date DATE
);

INSERT INTO customers (name, email, city, signup_date) VALUES
('Customer A', 'a@mail.com', 'New York',      '2023-01-15'),
('Customer B', 'b@mail.com', 'San Francisco',  '2023-02-20'),
('Customer C', 'c@mail.com', 'Chicago',        '2023-03-10'),
('Customer D', 'd@mail.com', 'New York',       '2023-04-05'),
('Customer E', 'e@mail.com', 'San Francisco',  '2023-05-12'),
('Customer F', 'f@mail.com', 'Chicago',        '2023-06-01'),
('Customer G', 'g@mail.com', 'New York',       '2023-07-20'),
('Customer H', NULL,         'Boston',          '2023-08-15');

-- ============================================================
-- PRODUCTS
-- ============================================================
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2)
);

INSERT INTO products (name, category, price) VALUES
('Laptop',    'Electronics', 999.99),
('Phone',     'Electronics', 699.99),
('Tablet',    'Electronics', 499.99),
('Headphones','Electronics', 149.99),
('Book A',    'Books',       29.99),
('Book B',    'Books',       39.99),
('Shirt',     'Clothing',    49.99),
('Pants',     'Clothing',    69.99),
('Coffee',    'Food',        14.99),
('Tea',       'Food',        9.99);

-- ============================================================
-- ORDERS
-- ============================================================
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(id),
    order_date DATE,
    status VARCHAR(20) DEFAULT 'pending',
    total_amount DECIMAL(10,2)
);

INSERT INTO orders (customer_id, order_date, status, total_amount) VALUES
(1, '2024-01-10', 'completed', 1199.98),
(1, '2024-02-15', 'completed', 699.99),
(2, '2024-01-20', 'completed', 549.98),
(2, '2024-03-05', 'shipped',   999.99),
(3, '2024-02-01', 'completed', 79.98),
(3, '2024-03-15', 'cancelled', 149.99),
(4, '2024-01-25', 'completed', 1499.97),
(4, '2024-02-28', 'completed', 69.99),
(5, '2024-03-10', 'pending',   499.99),
(6, '2024-01-05', 'completed', 29.99),
(7, '2024-02-10', 'completed', 119.98),
(1, '2024-03-20', 'completed', 49.99),
(2, '2024-04-01', 'pending',   149.99);

-- ============================================================
-- ORDER ITEMS
-- ============================================================
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(id),
    product_id INT REFERENCES products(id),
    quantity INT,
    unit_price DECIMAL(10,2)
);

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 999.99), (1, 4, 1, 149.99), (1, 9, 1, 14.99),
(2, 2, 1, 699.99),
(3, 3, 1, 499.99), (3, 7, 1, 49.99),
(4, 1, 1, 999.99),
(5, 5, 1, 29.99), (5, 6, 1, 39.99), (5, 10, 1, 9.99),
(6, 4, 1, 149.99),
(7, 1, 1, 999.99), (7, 3, 1, 499.99),
(8, 8, 1, 69.99),
(9, 3, 1, 499.99),
(10, 5, 1, 29.99),
(11, 7, 1, 49.99), (11, 8, 1, 69.99),
(12, 7, 1, 49.99),
(13, 4, 1, 149.99);

-- ============================================================
-- SALES (for window function demos)
-- ============================================================
CREATE TABLE sales (
    id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(id),
    sale_date DATE,
    amount DECIMAL(10,2),
    region VARCHAR(50)
);

INSERT INTO sales (employee_id, sale_date, amount, region) VALUES
(4, '2024-01-10', 5000,  'East'), (4, '2024-01-20', 7500,  'East'),
(4, '2024-02-05', 3000,  'East'), (4, '2024-02-15', 8000,  'East'),
(4, '2024-03-01', 6500,  'East'),
(5, '2024-01-08', 4000,  'East'), (5, '2024-01-25', 6000,  'East'),
(5, '2024-02-10', 5500,  'East'), (5, '2024-03-05', 7000,  'East'),
(6, '2024-01-15', 9000,  'West'), (6, '2024-02-01', 4500,  'West'),
(6, '2024-02-20', 11000, 'West'), (6, '2024-03-10', 8500,  'West'),
(7, '2024-01-05', 3500,  'West'), (7, '2024-02-12', 5000,  'West'),
(7, '2024-03-01', 6000,  'West');

SELECT 'Setup complete: ' ||
    (SELECT COUNT(*) FROM employees) || ' employees, ' ||
    (SELECT COUNT(*) FROM customers) || ' customers, ' ||
    (SELECT COUNT(*) FROM orders) || ' orders, ' ||
    (SELECT COUNT(*) FROM products) || ' products, ' ||
    (SELECT COUNT(*) FROM sales) || ' sales' AS status;
