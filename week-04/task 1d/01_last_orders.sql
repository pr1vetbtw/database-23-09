-- task 1

WITH ranked_orders AS (
    SELECT
        customer_id,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_date DESC
        ) AS rn
    FROM orders
)
SELECT COUNT(*)
FROM ranked_orders
WHERE rn <= 2;