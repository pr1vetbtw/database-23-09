--task 3

CREATE OR REPLACE VIEW analyst_orders AS
SELECT
    order_id,
    customer_id,
    product_id,
    sales,
    quantity,
    discount
FROM orders;

SELECT profit FROM orders;

-- task 4 

CREATE INDEX IF NOT EXISTS idx_customer_orders
ON orders USING btree (customer_id);

SELECT o.*
FROM orders AS o
WHERE o.customer_id = 'C001';

EXPLAIN ANALYZE
SELECT o.*
FROM orders AS o
WHERE o.customer_id = 'C001';

--task 6

CREATE INDEX IF NOT EXISTS idx_customer_date
ON orders USING btree (customer_id, order_date);

SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    o.profit
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id
WHERE c.region = 'West'
  AND o.order_date >= DATE '2024-01-01'
ORDER BY o.order_date ASC;

-- task 7 

EXPLAIN ANALYZE
SELECT o.*
FROM orders AS o
WHERE o.customer_id = 'C001';

-- task 8 

CREATE DATABASE retail_sales;

CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    order_date DATE NOT NULL,
    region VARCHAR(20) NOT NULL,
    category VARCHAR(50) NOT NULL,
    ship_mode VARCHAR(30) NOT NULL,
    sales NUMERIC(12, 2) NOT NULL,
    profit NUMERIC(12, 2) NOT NULL
);

ALTER DATABASE retail_sales
SET datestyle TO 'ISO, MDY';

SELECT *
FROM orders;