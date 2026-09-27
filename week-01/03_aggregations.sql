-- task 7 

SELECT
    c.region,
    SUM(o.sales) AS total_sales
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.region
ORDER BY c.region;

-- task 8 

SELECT
    c.customer_name,
    COUNT(o.order_id) AS order_count
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY c.customer_name;

-- task 9 

SELECT
    p.category,
    AVG(o.discount) AS average_discount
FROM products AS p
JOIN orders AS o
    ON p.product_id = o.product_id
GROUP BY p.category
ORDER BY p.category;

-- task 10

SELECT
    c.customer_name,
    SUM(o.sales) AS total_sales
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING SUM(o.sales) > 2000
ORDER BY total_sales DESC;

-- task 11

SELECT
    c.region,
    SUM(o.sales) AS total_sales,
    AVG(o.discount) AS average_discount,
    COUNT(o.order_id) AS order_count
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.region
ORDER BY c.region;

-- task 12

SELECT
    c.region,
    COUNT(CASE WHEN o.sales > 1000 THEN 1 END) AS high_value_orders,
    COUNT(CASE WHEN o.sales <= 1000 THEN 1 END) AS low_value_orders
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.region
ORDER BY c.region;

-- task 13

SELECT
    c.customer_name,
    SUM(o.sales) AS total_sales,
    AVG(o.discount) AS average_discount,
    COUNT(o.order_id) AS order_count,
    CASE
        WHEN SUM(o.sales) > 2500 THEN 'VIP'
        ELSE 'REGULAR'
    END AS customer_type
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_sales DESC;