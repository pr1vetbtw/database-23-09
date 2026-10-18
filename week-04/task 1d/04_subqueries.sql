-- task 4

WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_date)::date AS month,
        SUM(sales) AS monthly_sales
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)::date
)
SELECT
    month,
    monthly_sales,
    LAG(monthly_sales) OVER (
        ORDER BY month
    ) AS prev_month_sales,
    LEAD(monthly_sales) OVER (
        ORDER BY month
    ) AS next_month_sales
FROM monthly_sales
ORDER BY month;

-- task 5 

WITH product_sales AS (
    SELECT
        p.category,
        p.product_name,
        SUM(o.sales) AS product_sales
    FROM orders o
    JOIN products p
        ON o.product_id = p.product_id
    GROUP BY p.category, p.product_name
)
SELECT
    category,
    product_name,
    product_sales,
    SUM(product_sales) OVER (
        PARTITION BY category
    ) AS category_total,
    ROUND(
        product_sales * 100.0 /
        SUM(product_sales) OVER (
            PARTITION BY category
        ),
        2
    ) AS pct_of_category
FROM product_sales
ORDER BY category, product_name;

-- task 6

WITH customer_orders AS (
    SELECT
        customer_id,
        MAX(order_date) OVER (
            PARTITION BY customer_id
        ) AS last_order_date,
        MAX(order_date) OVER () AS latest_order_date
    FROM orders
),
inactive_customers AS (
    SELECT DISTINCT
        customer_id,
        last_order_date
    FROM customer_orders
    WHERE last_order_date < latest_order_date - INTERVAL '90 days'
)
SELECT
    c.customer_id,
    c.customer_name,
    i.last_order_date
FROM inactive_customers i
JOIN customers c
    ON c.customer_id = i.customer_id
ORDER BY i.last_order_date;

-- task 7

WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_date)::date AS month,
        SUM(sales) AS monthly_sales
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)::date
),
sales_comparison AS (
    SELECT
        month,
        monthly_sales,
        LAG(monthly_sales) OVER (
            ORDER BY month
        ) AS prev_month_sales
    FROM monthly_sales
)
SELECT
    month,
    monthly_sales,
    prev_month_sales,
    monthly_sales - prev_month_sales AS sales_change,
    ROUND(
        (monthly_sales - prev_month_sales) * 100.0
        / NULLIF(prev_month_sales, 0),
        2
    ) AS growth_percentage
FROM sales_comparison
ORDER BY month;

-- task 8

WITH first_purchase AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', MIN(order_date)) AS first_month
    FROM orders
    GROUP BY customer_id
)
SELECT COUNT(*)
FROM first_purchase f
WHERE f.first_month = DATE '2024-06-01'
  AND EXISTS (
      SELECT 1
      FROM orders o
      WHERE o.customer_id = f.customer_id
        AND o.order_date >= DATE '2024-07-01'
  );