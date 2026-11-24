DROP SCHEMA IF EXISTS bronze CASCADE;
CREATE SCHEMA bronze;

CREATE TABLE bronze.categories (
    categoryid   INTEGER,
    categoryname VARCHAR(50),
    description  VARCHAR(100)
);

CREATE TABLE bronze.customers (
    customerid   INTEGER,
    customername VARCHAR(100),
    contactname  VARCHAR(100),
    address      VARCHAR(150),
    city         VARCHAR(50),
    postalcode   VARCHAR(20),
    country      VARCHAR(50)
);

CREATE TABLE bronze.employees (
    employeeid   INTEGER,
    lastname     VARCHAR(50),
    firstname    VARCHAR(50),
    birthdate    DATE,
    photo        VARCHAR(100),
    notes        TEXT
);

CREATE TABLE bronze.suppliers (
    supplierid   INTEGER,
    suppliername VARCHAR(100),
    contactname  VARCHAR(100),
    address      VARCHAR(150),
    city         VARCHAR(50),
    postalcode   VARCHAR(20),
    country      VARCHAR(50),
    phone        VARCHAR(30)
);

CREATE TABLE bronze.shippers (
    shipperid    INTEGER,
    shippername  VARCHAR(100),
    phone        VARCHAR(30)
);

CREATE TABLE bronze.products (
    productid    INTEGER,
    productname  VARCHAR(100),
    supplierid   INTEGER,
    categoryid   INTEGER,
    unit         VARCHAR(50),
    price        NUMERIC(10,2)
);

CREATE TABLE bronze.orders (
    orderid      INTEGER,
    customerid   INTEGER,
    employeeid   INTEGER,
    orderdate    DATE,
    shipperid    INTEGER
);

CREATE TABLE bronze.orderdetails (
    orderdetailid INTEGER,
    orderid       INTEGER,
    productid     INTEGER,
    quantity      INTEGER
);

COPY bronze.categories   FROM 'C:/Users/Public/Northwind/categories.csv'   WITH (FORMAT csv, DELIMITER ';', HEADER true, ENCODING 'UTF8');
COPY bronze.customers    FROM 'C:/Users/Public/Northwind/customers.csv'    WITH (FORMAT csv, DELIMITER ';', HEADER true, ENCODING 'UTF8');
COPY bronze.employees    FROM 'C:/Users/Public/Northwind/employees.csv'    WITH (FORMAT csv, DELIMITER ';', HEADER true, ENCODING 'UTF8');
COPY bronze.suppliers    FROM 'C:/Users/Public/Northwind/suppliers.csv'    WITH (FORMAT csv, DELIMITER ';', HEADER true, ENCODING 'UTF8');
COPY bronze.shippers     FROM 'C:/Users/Public/Northwind/shippers.csv'     WITH (FORMAT csv, DELIMITER ';', HEADER true, ENCODING 'UTF8');
COPY bronze.products     FROM 'C:/Users/Public/Northwind/products.csv'     WITH (FORMAT csv, DELIMITER ';', HEADER true, ENCODING 'UTF8');
COPY bronze.orders       FROM 'C:/Users/Public/Northwind/orders.csv'       WITH (FORMAT csv, DELIMITER ';', HEADER true, ENCODING 'UTF8');
COPY bronze.orderdetails FROM 'C:/Users/Public/Northwind/orderdetails.csv' WITH (FORMAT csv, DELIMITER ';', HEADER true, ENCODING 'UTF8');

SELECT 'categories' AS tabulka, COUNT(*) AS riadkov FROM bronze.categories
UNION ALL SELECT 'customers',    COUNT(*) FROM bronze.customers
UNION ALL SELECT 'employees',    COUNT(*) FROM bronze.employees
UNION ALL SELECT 'suppliers',    COUNT(*) FROM bronze.suppliers
UNION ALL SELECT 'shippers',     COUNT(*) FROM bronze.shippers
UNION ALL SELECT 'products',     COUNT(*) FROM bronze.products
UNION ALL SELECT 'orders',       COUNT(*) FROM bronze.orders
UNION ALL SELECT 'orderdetails', COUNT(*) FROM bronze.orderdetails;
