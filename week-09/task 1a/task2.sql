DROP SCHEMA IF EXISTS silver CASCADE;
CREATE SCHEMA silver;

CREATE VIEW silver.age_group AS
SELECT
    id::INTEGER                AS id,
    TRIM(name::TEXT)::VARCHAR  AS name
FROM bronze.age_group;

CREATE VIEW silver.occupations AS
SELECT
    id::INTEGER                AS id,
    TRIM(name::TEXT)::VARCHAR  AS name
FROM bronze.occupations;

CREATE VIEW silver.genres AS
SELECT
    id::INTEGER                AS id,
    TRIM(name::TEXT)::VARCHAR  AS name
FROM bronze.genres;

CREATE VIEW silver.users AS
SELECT
    id::INTEGER                                  AS id,
    age::SMALLINT                                AS age,
    TRIM(gender::TEXT)::CHAR(1)                  AS gender,
    occupation_id::INTEGER                       AS occupation_id,
    NULLIF(TRIM(zip_code::TEXT), '')::VARCHAR    AS zip_code
FROM bronze.users;

CREATE VIEW silver.movies AS
SELECT
    id::INTEGER                  AS id,
    TRIM(title::TEXT)::VARCHAR   AS title,
    release_year::SMALLINT       AS release_year
FROM bronze.movies;

CREATE VIEW silver.genres_movies AS
SELECT
    id::INTEGER        AS id,
    movie_id::INTEGER  AS movie_id,
    genre_id::INTEGER  AS genre_id
FROM bronze.genres_movies;

CREATE VIEW silver.ratings AS
SELECT
    id::INTEGER                          AS id,
    user_id::INTEGER                     AS user_id,
    movie_id::INTEGER                    AS movie_id,
    rating::SMALLINT                     AS rating,
    TO_TIMESTAMP("timestamp")::TIMESTAMP AS rated_at
FROM bronze.ratings;