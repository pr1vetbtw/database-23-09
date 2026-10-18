-- task 3 

WITH customer_sales AS (
    SELECT
        customer_id,
        SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_id
)
SELECT
    c.customer_name,
    cs.total_sales,
    NTILE(4) OVER (
        ORDER BY cs.total_sales DESC
    ) AS quartile
FROM customer_sales cs
JOIN customers c
    ON c.customer_id = cs.customer_id
ORDER BY cs.total_sales DESC;