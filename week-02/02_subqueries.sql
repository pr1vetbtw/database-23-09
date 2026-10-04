-- task 1.1

SELECT COUNT(*)
FROM (
    SELECT
        product_name,
        total_amount
    FROM flourmills_sales
    WHERE total_amount > (
        SELECT AVG(total_amount)
        FROM flourmills_sales
    )
) AS result;

-- task 2 

SELECT *
FROM flourmills_sales
WHERE product_category = (
    SELECT product_category
    FROM flourmills_sales
    GROUP BY product_category
    ORDER BY SUM(total_amount) DESC
    LIMIT 1
)
ORDER BY sales_id ASC;

-- task 3

SELECT
    product_name,
    total_amount,
    (
        SELECT AVG(total_amount)
        FROM flourmills_sales
    ) AS avg_amount
FROM flourmills_sales;