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