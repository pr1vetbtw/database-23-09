SELECT
    o.order_id,
    c.customer_name,
    o.sales
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE o.sales > 500
ORDER BY o.sales DESC;

-- task 3

SELECT
    o.order_id,
    c.customer_name,
    p.category,
    o.sales
FROM orders AS o
INNER JOIN customers AS c
    ON o.customer_id = c.customer_id
INNER JOIN products AS p
    ON o.product_id = p.product_id;

-- task 4

SELECT
    c.region,
    COALESCE(SUM(o.sales), 0) AS total_sales
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.region
ORDER BY c.region;

-- task 5 

SELECT
    p.product_name,
    SUM(o.sales) AS total_sales
FROM products AS p
LEFT JOIN orders AS o
    ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name
ORDER BY p.product_name;

-- task 6

SELECT
    c.customer_name,
    o.order_id,
    o.sales
FROM customers AS c
FULL OUTER JOIN orders AS o
    ON c.customer_id = o.customer_id;