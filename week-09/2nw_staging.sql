DROP SCHEMA IF EXISTS silver CASCADE;
CREATE SCHEMA silver;

CREATE VIEW silver.categories AS
SELECT
    categoryid,
    TRIM(categoryname) AS categoryname,
    TRIM(description)  AS description
FROM bronze.categories;

CREATE VIEW silver.customers AS
SELECT
    customerid,
    TRIM(customername)           AS customername,
    TRIM(contactname)            AS contactname,
    TRIM(address)                AS address,
    TRIM(city)                   AS city,
    NULLIF(TRIM(postalcode), '') AS postalcode,
    TRIM(country)                AS country
FROM bronze.customers;

CREATE VIEW silver.employees AS
SELECT
    employeeid,
    TRIM(firstname)                          AS firstname,
    TRIM(lastname)                           AS lastname,
    TRIM(firstname) || ' ' || TRIM(lastname) AS fullname,
    birthdate
FROM bronze.employees;

CREATE VIEW silver.suppliers AS
SELECT
    supplierid,
    TRIM(suppliername)           AS suppliername,
    TRIM(contactname)            AS contactname,
    TRIM(address)                AS address,
    TRIM(city)                   AS city,
    NULLIF(TRIM(postalcode), '') AS postalcode,
    TRIM(country)                AS country,
    TRIM(phone)                  AS phone
FROM bronze.suppliers;

CREATE VIEW silver.shippers AS
SELECT
    shipperid,
    TRIM(shippername) AS shippername,
    TRIM(phone)       AS phone
FROM bronze.shippers;

CREATE VIEW silver.products AS
SELECT
    productid,
    TRIM(productname) AS productname,
    supplierid,
    categoryid,
    TRIM(unit)        AS unit,
    price
FROM bronze.products;

CREATE VIEW silver.orders AS
SELECT
    orderid,
    customerid,
    employeeid,
    shipperid,
    orderdate
FROM bronze.orders;

CREATE VIEW silver.order_lines AS
SELECT
    od.orderdetailid,
    od.orderid,
    o.orderdate,
    o.customerid,
    o.employeeid,
    o.shipperid,
    od.productid,
    od.quantity,
    p.price                    AS unitprice,
    od.quantity * p.price      AS lineamount
FROM bronze.orderdetails od
JOIN bronze.orders   o ON o.orderid   = od.orderid
JOIN bronze.products p ON p.productid = od.productid;
