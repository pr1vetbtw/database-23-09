SELECT
    o.order_id,
    c.customer_name,
    o.sales
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE o.sales > 500
ORDER BY o.sales DESC;
