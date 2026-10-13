-- task 1
WITH daily_sales AS (
    SELECT
        sale_date,
        SUM(total_amount) AS total_daily_sales
    FROM flourmills_sales
    GROUP BY sale_date
)
SELECT
    ds.sale_date,
    ds.total_daily_sales
FROM daily_sales AS ds
WHERE ds.total_daily_sales > 3000000
ORDER BY ds.total_daily_sales DESC
LIMIT 5;

--task 2

WITH category_sales AS (
    SELECT
        product_category,
        SUM(total_amount) AS total_sales
    FROM flourmills_sales
    GROUP BY product_category
)
SELECT
    cs.product_category,
    cs.total_sales
FROM category_sales AS cs
ORDER BY cs.total_sales DESC;

-- task 3 

WITH product_sales AS (
    SELECT
        product_category,
        product_name,
        SUM(total_amount) AS total_product_sales
    FROM flourmills_sales
    GROUP BY
        product_category,
        product_name
),
ranked_products AS (
    SELECT
        ps.product_category,
        ps.product_name,
        ps.total_product_sales,
        RANK() OVER (
            PARTITION BY ps.product_category
            ORDER BY ps.total_product_sales DESC
        ) AS category_rank
    FROM product_sales AS ps
)
SELECT
    rp.product_category,
    rp.product_name,
    rp.total_product_sales,
    rp.category_rank
FROM ranked_products AS rp
WHERE rp.category_rank BETWEEN 1 AND 3
ORDER BY
    rp.product_category,
    rp.category_rank
LIMIT 10;

-- task 4

WITH customer_revenue AS (
    SELECT
        customer_type,
        SUM(total_amount) AS revenue
    FROM flourmills_sales
    GROUP BY customer_type
),
revenue_analysis AS (
    SELECT
        cr.customer_type,
        cr.revenue,
        SUM(cr.revenue) OVER () AS total_revenue,
        ROUND(
            cr.revenue * 100.0 / NULLIF(SUM(cr.revenue) OVER (), 0),
            2
        ) AS revenue_percentage
    FROM customer_revenue AS cr
)
SELECT
    ra.customer_type,
    ra.revenue,
    ra.total_revenue,
    ra.revenue_percentage
FROM revenue_analysis AS ra
ORDER BY ra.revenue DESC;

-- task 5

WITH last_purchases AS (
    SELECT
        customer_id,
        product_name,
        sale_date,
        total_amount,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY sale_date DESC
        ) AS rn
    FROM flourmills_sales
)
SELECT
    customer_id,
    product_name,
    sale_date,
    total_amount
FROM last_purchases
WHERE rn = 1
ORDER BY customer_id ASC LIMIT 5;

-- task 6

WITH RECURSIVE
date_range AS (
    SELECT
        MIN(sale_date) AS start_date,
        MAX(sale_date) AS end_date
    FROM flourmills_sales
),
calendar AS (
    SELECT
        d.start_date AS sale_date
    FROM date_range AS d
    WHERE d.start_date IS NOT NULL

    UNION ALL

    SELECT
        cal.sale_date + INTERVAL '1 day'
    FROM calendar AS cal
    CROSS JOIN date_range AS d
    WHERE cal.sale_date < d.end_date
)
SELECT
    sale_date
FROM calendar
ORDER BY sale_date;

-- task 7 

WITH RECURSIVE monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', sale_date)::date AS month,
        SUM(total_amount) AS revenue
    FROM flourmills_sales
    GROUP BY DATE_TRUNC('month', sale_date)
),
ordered_months AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY month ASC) AS rn,
        month,
        revenue
    FROM monthly_revenue
),
cumulative_target AS (
    SELECT
        rn,
        month,
        revenue,
        revenue AS cumulative_revenue
    FROM ordered_months
    WHERE rn = 1

    UNION ALL

    SELECT
        om.rn,
        om.month,
        om.revenue,
        ct.cumulative_revenue + om.revenue AS cumulative_revenue
    FROM cumulative_target AS ct
    INNER JOIN ordered_months AS om
        ON om.rn = ct.rn + 1
    WHERE ct.cumulative_revenue < 500000000
)
SELECT
    *
FROM cumulative_target
ORDER BY rn ASC;