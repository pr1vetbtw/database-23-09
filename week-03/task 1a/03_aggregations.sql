--task 1

CREATE VIEW high_value_customers AS
SELECT
    c.customer_id,
    c.customer_name,
    SUM(o.sales) AS total_sales
FROM customers AS c
INNER JOIN orders AS o
    ON o.customer_id = c.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
HAVING total_sales > 2000;

SELECT
    *
FROM high_value_customers;

SELECT
    COUNT(*) AS customer_count
FROM high_value_customers;

--task 2

CREATE VIEW regional_monthly_sales AS
SELECT
    c.region,
    DATE_TRUNC('month', o.order_date) AS month,
    SUM(o.sales) AS monthly_sales
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.region,
    DATE_TRUNC('month', o.order_date);

SELECT *
FROM regional_monthly_sales
WHERE region = 'West'
ORDER BY month;

--task 5

CREATE INDEX IF NOT EXISTS idx_order_date
ON orders USING btree (order_date);

SELECT
    DATE_TRUNC('month', o.order_date) AS sales_month,
    SUM(o.sales) AS total_sales
FROM orders AS o
GROUP BY
    DATE_TRUNC('month', o.order_date)
ORDER BY
    sales_month;

    -- task 9 

CREATE OR REPLACE PROCEDURE get_customer_sales(
    p_customer_id VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_sales NUMERIC(12, 2) := 0;
BEGIN
    SELECT COALESCE(SUM(o.sales), 0)
    INTO v_total_sales
    FROM orders AS o
    WHERE o.customer_id = p_customer_id;

    RAISE NOTICE 'Zákazník: %, Celkový predaj: %',
        p_customer_id, v_total_sales;
END;
$$;

CALL get_customer_sales('C001');

-- task 10

CREATE OR REPLACE PROCEDURE apply_regional_discount(
    p_region VARCHAR,
    p_discount NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE orders AS o
    SET sales = ROUND(o.sales * (1 - p_discount), 2)
    WHERE o.region = p_region;

    RAISE NOTICE 'Zľava: %, Región: %',
        p_discount, p_region;
END;
$$;

BEGIN;

SELECT SUM(sales) AS sales_before_discount
FROM orders
WHERE region = 'West';

CALL apply_regional_discount('West', 0.10);

SELECT SUM(sales) AS sales_after_first_discount
FROM orders
WHERE region = 'West';

CALL apply_regional_discount('West', 0.10);

SELECT SUM(sales) AS sales_after_second_discount
FROM orders
WHERE region = 'West';

ROLLBACK;

-- task 11

CREATE OR REPLACE PROCEDURE get_sales_between(
    start_date DATE,
    end_date DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    total_sales NUMERIC(12, 2);
BEGIN
    SELECT COALESCE(SUM(sales), 0)
    INTO total_sales
    FROM orders
    WHERE order_date BETWEEN start_date AND end_date;

    RAISE NOTICE 'Obdobie: % až %, Celkový predaj: %',
        start_date, end_date, total_sales;
END;
$$;

CALL get_sales_between('2024-01-01', '2024-03-31');