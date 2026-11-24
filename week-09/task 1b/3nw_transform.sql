DROP SCHEMA IF EXISTS gold CASCADE;
CREATE SCHEMA gold;

CREATE TABLE gold.dim_date (
    date_key     INTEGER PRIMARY KEY,
    full_date    DATE    NOT NULL UNIQUE,
    year         SMALLINT NOT NULL,
    quarter      SMALLINT NOT NULL,
    month        SMALLINT NOT NULL,
    month_name   VARCHAR(20) NOT NULL,
    day          SMALLINT NOT NULL,
    day_of_week  SMALLINT NOT NULL,
    day_name     VARCHAR(20) NOT NULL
);

CREATE TABLE gold.dim_customer (
    customer_key  INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id   INTEGER NOT NULL UNIQUE,
    customer_name VARCHAR(100) NOT NULL,
    contact_name  VARCHAR(100),
    address       VARCHAR(150),
    city          VARCHAR(50),
    postal_code   VARCHAR(20),
    country       VARCHAR(50)
);

CREATE TABLE gold.dim_employee (
    employee_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    employee_id  INTEGER NOT NULL UNIQUE,
    first_name   VARCHAR(50),
    last_name    VARCHAR(50),
    full_name    VARCHAR(101),
    birth_date   DATE
);

CREATE TABLE gold.dim_shipper (
    shipper_key  INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    shipper_id   INTEGER NOT NULL UNIQUE,
    shipper_name VARCHAR(100) NOT NULL,
    phone        VARCHAR(30)
);

CREATE TABLE gold.dim_category (
    category_key  INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_id   INTEGER NOT NULL UNIQUE,
    category_name VARCHAR(50) NOT NULL,
    description   VARCHAR(100)
);

CREATE TABLE gold.dim_supplier (
    supplier_key  INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    supplier_id   INTEGER NOT NULL UNIQUE,
    supplier_name VARCHAR(100) NOT NULL,
    contact_name  VARCHAR(100),
    address       VARCHAR(150),
    city          VARCHAR(50),
    postal_code   VARCHAR(20),
    country       VARCHAR(50),
    phone         VARCHAR(30)
);

CREATE TABLE gold.dim_product (
    product_key   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id    INTEGER NOT NULL UNIQUE,
    product_name  VARCHAR(100) NOT NULL,
    unit          VARCHAR(50),
    unit_price    NUMERIC(10,2),
    category_key  INTEGER NOT NULL REFERENCES gold.dim_category(category_key),
    supplier_key  INTEGER NOT NULL REFERENCES gold.dim_supplier(supplier_key)
);

CREATE TABLE gold.fact_sales (
    sales_key       INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_detail_id INTEGER NOT NULL UNIQUE,
    order_id        INTEGER NOT NULL,
    date_key        INTEGER NOT NULL REFERENCES gold.dim_date(date_key),
    customer_key    INTEGER NOT NULL REFERENCES gold.dim_customer(customer_key),
    employee_key    INTEGER NOT NULL REFERENCES gold.dim_employee(employee_key),
    product_key     INTEGER NOT NULL REFERENCES gold.dim_product(product_key),
    shipper_key     INTEGER NOT NULL REFERENCES gold.dim_shipper(shipper_key),
    quantity        INTEGER       NOT NULL,
    unit_price      NUMERIC(10,2) NOT NULL,
    total_amount    NUMERIC(12,2) NOT NULL
);

CREATE INDEX idx_fact_sales_date     ON gold.fact_sales(date_key);
CREATE INDEX idx_fact_sales_customer ON gold.fact_sales(customer_key);
CREATE INDEX idx_fact_sales_employee ON gold.fact_sales(employee_key);
CREATE INDEX idx_fact_sales_product  ON gold.fact_sales(product_key);
CREATE INDEX idx_fact_sales_shipper  ON gold.fact_sales(shipper_key);

INSERT INTO gold.dim_date
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INTEGER,
    d::DATE,
    EXTRACT(YEAR    FROM d)::SMALLINT,
    EXTRACT(QUARTER FROM d)::SMALLINT,
    EXTRACT(MONTH   FROM d)::SMALLINT,
    TRIM(TO_CHAR(d, 'Month')),
    EXTRACT(DAY     FROM d)::SMALLINT,
    EXTRACT(ISODOW  FROM d)::SMALLINT,
    TRIM(TO_CHAR(d, 'Day'))
FROM generate_series(
        (SELECT MIN(orderdate) FROM silver.orders),
        (SELECT MAX(orderdate) FROM silver.orders),
        INTERVAL '1 day') AS g(d);

INSERT INTO gold.dim_customer (customer_id, customer_name, contact_name, address, city, postal_code, country)
SELECT customerid, customername, contactname, address, city, postalcode, country
FROM silver.customers
ORDER BY customerid;

INSERT INTO gold.dim_employee (employee_id, first_name, last_name, full_name, birth_date)
SELECT employeeid, firstname, lastname, fullname, birthdate
FROM silver.employees
ORDER BY employeeid;

INSERT INTO gold.dim_shipper (shipper_id, shipper_name, phone)
SELECT shipperid, shippername, phone
FROM silver.shippers
ORDER BY shipperid;

INSERT INTO gold.dim_category (category_id, category_name, description)
SELECT categoryid, categoryname, description
FROM silver.categories
ORDER BY categoryid;

INSERT INTO gold.dim_supplier
    (supplier_id, supplier_name, contact_name, address, city, postal_code, country, phone)
SELECT supplierid, suppliername, contactname, address, city, postalcode, country, phone
FROM silver.suppliers
ORDER BY supplierid;

INSERT INTO gold.dim_product
    (product_id, product_name, unit, unit_price, category_key, supplier_key)
SELECT
    p.productid, p.productname, p.unit, p.price,
    dc.category_key, ds.supplier_key
FROM silver.products p
JOIN gold.dim_category dc ON dc.category_id = p.categoryid
JOIN gold.dim_supplier ds ON ds.supplier_id = p.supplierid
ORDER BY p.productid;

INSERT INTO gold.fact_sales
    (order_detail_id, order_id, date_key, customer_key, employee_key,
     product_key, shipper_key, quantity, unit_price, total_amount)
SELECT
    ol.orderdetailid,
    ol.orderid,
    TO_CHAR(ol.orderdate, 'YYYYMMDD')::INTEGER,
    dc.customer_key,
    de.employee_key,
    dp.product_key,
    ds.shipper_key,
    ol.quantity,
    ol.unitprice,
    ol.lineamount
FROM silver.order_lines ol
JOIN gold.dim_customer dc ON dc.customer_id = ol.customerid
JOIN gold.dim_employee de ON de.employee_id = ol.employeeid
JOIN gold.dim_product  dp ON dp.product_id  = ol.productid
JOIN gold.dim_shipper  ds ON ds.shipper_id  = ol.shipperid
ORDER BY ol.orderdetailid;

SELECT 'fact_sales' AS tabulka, COUNT(*) AS riadkov, SUM(total_amount) AS suma FROM gold.fact_sales
UNION ALL SELECT 'dim_customer', COUNT(*), NULL FROM gold.dim_customer
UNION ALL SELECT 'dim_employee', COUNT(*), NULL FROM gold.dim_employee
UNION ALL SELECT 'dim_product',  COUNT(*), NULL FROM gold.dim_product
UNION ALL SELECT 'dim_category', COUNT(*), NULL FROM gold.dim_category
UNION ALL SELECT 'dim_supplier', COUNT(*), NULL FROM gold.dim_supplier
UNION ALL SELECT 'dim_shipper',  COUNT(*), NULL FROM gold.dim_shipper
UNION ALL SELECT 'dim_date',     COUNT(*), NULL FROM gold.dim_date;
