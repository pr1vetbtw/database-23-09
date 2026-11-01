-- Chinook ETL: load source data from chinook_source into chinook_dw
-- PostgreSQL / pgAdmin 4
-- Grain: one row in fact_sales = one source invoice_line row.
-- IMPORTANT: this script clears and reloads ONLY the five chinook_dw tables.

BEGIN;

TRUNCATE TABLE
    chinook_dw.fact_sales,
    chinook_dw.dim_billing_location,
    chinook_dw.dim_track,
    chinook_dw.dim_customer,
    chinook_dw.dim_date
RESTART IDENTITY CASCADE;

-- 1. Date dimension: one row for every calendar day covered by invoices.
INSERT INTO chinook_dw.dim_date (
    date_key, full_date, day_of_month, day_name, day_of_week,
    week_of_year, month_number, month_name, quarter_number, year_number
)
SELECT
    TO_CHAR(d::date, 'YYYYMMDD')::INTEGER,
    d::date,
    EXTRACT(DAY FROM d)::SMALLINT,
    TO_CHAR(d, 'FMDay'),
    EXTRACT(ISODOW FROM d)::SMALLINT,
    TO_CHAR(d, 'IW')::SMALLINT,
    EXTRACT(MONTH FROM d)::SMALLINT,
    TO_CHAR(d, 'FMMonth'),
    EXTRACT(QUARTER FROM d)::SMALLINT,
    EXTRACT(YEAR FROM d)::SMALLINT
FROM generate_series(
    (SELECT MIN(invoice_date)::date FROM chinook_source.invoice),
    (SELECT MAX(invoice_date)::date FROM chinook_source.invoice),
    INTERVAL '1 day'
) AS gs(d);

-- 2. Customer dimension.
INSERT INTO chinook_dw.dim_customer (
    customer_id, first_name, last_name, company, address, city, state,
    country, postal_code, phone, fax, email
)
SELECT
    customer_id, first_name, last_name, company, address, city, state,
    country, postal_code, phone, fax, email
FROM chinook_source.customer;

-- 3. Track dimension, flattened with album, artist, genre and media type.
INSERT INTO chinook_dw.dim_track (
    track_id, track_name, album_id, album_title, artist_id, artist_name,
    genre_id, genre_name, media_type_id, media_type_name, composer,
    milliseconds, bytes
)
SELECT
    t.track_id,
    t.name,
    t.album_id,
    a.title,
    a.artist_id,
    ar.name,
    t.genre_id,
    g.name,
    t.media_type_id,
    mt.name,
    t.composer,
    t.milliseconds,
    t.bytes
FROM chinook_source.track AS t
LEFT JOIN chinook_source.album AS a ON a.album_id = t.album_id
LEFT JOIN chinook_source.artist AS ar ON ar.artist_id = a.artist_id
LEFT JOIN chinook_source.genre AS g ON g.genre_id = t.genre_id
LEFT JOIN chinook_source.media_type AS mt ON mt.media_type_id = t.media_type_id;

-- 4. Billing location dimension: distinct invoice billing addresses.
INSERT INTO chinook_dw.dim_billing_location (
    billing_address, billing_city, billing_state,
    billing_country, billing_postal_code
)
SELECT DISTINCT
    billing_address, billing_city, billing_state,
    billing_country, billing_postal_code
FROM chinook_source.invoice;

-- 5. Sales fact table: one row per invoice line.
INSERT INTO chinook_dw.fact_sales (
    invoice_line_id, invoice_id, date_key, customer_key, track_key,
    billing_location_key, quantity, unit_price, sales_amount
)
SELECT
    il.invoice_line_id,
    i.invoice_id,
    TO_CHAR(i.invoice_date::date, 'YYYYMMDD')::INTEGER,
    dc.customer_key,
    dt.track_key,
    dbl.billing_location_key,
    il.quantity,
    il.unit_price,
    (il.quantity * il.unit_price)::NUMERIC(12,2)
FROM chinook_source.invoice_line AS il
JOIN chinook_source.invoice AS i
    ON i.invoice_id = il.invoice_id
JOIN chinook_dw.dim_customer AS dc
    ON dc.customer_id = i.customer_id
JOIN chinook_dw.dim_track AS dt
    ON dt.track_id = il.track_id
JOIN chinook_dw.dim_date AS dd
    ON dd.full_date = i.invoice_date::date
JOIN chinook_dw.dim_billing_location AS dbl
    ON dbl.billing_address IS NOT DISTINCT FROM i.billing_address
   AND dbl.billing_city IS NOT DISTINCT FROM i.billing_city
   AND dbl.billing_state IS NOT DISTINCT FROM i.billing_state
   AND dbl.billing_country IS NOT DISTINCT FROM i.billing_country
   AND dbl.billing_postal_code IS NOT DISTINCT FROM i.billing_postal_code;

COMMIT;

-- 6. Check row counts after loading.
SELECT 'dim_date' AS table_name, COUNT(*) AS row_count FROM chinook_dw.dim_date
UNION ALL
SELECT 'dim_customer', COUNT(*) FROM chinook_dw.dim_customer
UNION ALL
SELECT 'dim_track', COUNT(*) FROM chinook_dw.dim_track
UNION ALL
SELECT 'dim_billing_location', COUNT(*) FROM chinook_dw.dim_billing_location
UNION ALL
SELECT 'fact_sales', COUNT(*) FROM chinook_dw.fact_sales
ORDER BY table_name;
