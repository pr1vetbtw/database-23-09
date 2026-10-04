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

-- task 4

SELECT
    product_name,
    total_amount,
    total_amount / (
        SELECT SUM(total_amount)
        FROM flourmills_sales
    ) AS amount_share
FROM flourmills_sales;

-- task 5

SELECT
    month,
    monthly_sales
FROM (
    SELECT
        EXTRACT(MONTH FROM sale_date) AS month,
        SUM(total_amount) AS monthly_sales
    FROM flourmills_sales
    GROUP BY EXTRACT(MONTH FROM sale_date)
) AS monthly_summary
ORDER BY monthly_sales DESC;

-- task 6

SELECT
    product_category,
    total_sales
FROM (
    SELECT
        product_category,
        SUM(total_amount) AS total_sales
    FROM flourmills_sales
    GROUP BY product_category
) AS category_sales
WHERE total_sales > 50000000
ORDER BY total_sales DESC;

-- task 7

SELECT COUNT(*)
FROM flourmills_sales s
WHERE s.total_amount > (
    SELECT AVG(s2.total_amount)
    FROM flourmills_sales s2
    WHERE s2.product_category = s.product_category
);

-- task 8 

SELECT
    s.product_name,
    s.region,
    s.total_amount,
    (
        SELECT MIN(s2.total_amount)
        FROM flourmills_sales s2
        WHERE s2.region = s.region
    ) AS region_min_amount
FROM flourmills_sales s;
