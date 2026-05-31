-- ============================================================================
-- Q14. Partitioning, Replication, Sharding (Conceptual)
-- ============================================================================
-- Companies: Amazon, Google, Uber | Difficulty: Hard (conceptual)
--
-- PARTITIONING: split ONE table into smaller physical pieces
--   Range:  orders_2024_q1, orders_2024_q2 (by date range)
--   Hash:   partition by hash(user_id) % N (even distribution)
--   List:   partition by region = 'US', 'EU', 'APAC'
--
--   Benefits: faster queries on partition key, easier archiving, parallel scans
--   PostgreSQL supports declarative partitioning since v10
--
-- REPLICATION: copy data to multiple servers
--   Primary-Replica (Master-Slave):
--     Writes → Primary only
--     Reads  → Primary or Replicas (read scaling)
--     If Primary dies → promote a Replica
--
--   Sync vs Async:
--     Synchronous:  Primary waits for Replica ack → consistent but slower
--     Asynchronous: Primary doesn't wait → faster but may lose recent writes
--
-- SHARDING: split data across MULTIPLE databases/servers
--   Each shard holds a SUBSET of data (e.g., users 1-1M on shard1, 1M-2M on shard2)
--   Key choice matters: shard by user_id (even distribution) not by city (hotspots)
--   Challenges: cross-shard queries, rebalancing, distributed transactions

-- === PostgreSQL Range Partitioning Example ===
CREATE TABLE orders_partitioned (
    id SERIAL,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2)
) PARTITION BY RANGE (order_date);

CREATE TABLE orders_2024_q1 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');
CREATE TABLE orders_2024_q2 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2024-04-01') TO ('2024-07-01');

-- Insert goes to correct partition automatically
INSERT INTO orders_partitioned (customer_id, order_date, total_amount)
VALUES (1, '2024-02-15', 199.99);

-- Query only scans relevant partition
EXPLAIN SELECT * FROM orders_partitioned WHERE order_date = '2024-02-15';
-- Shows: Seq Scan on orders_2024_q1 (not q2!)

-- Cleanup
DROP TABLE orders_partitioned CASCADE;
