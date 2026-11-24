DROP SCHEMA IF EXISTS bronze CASCADE;
CREATE SCHEMA bronze;

CREATE TABLE bronze.age_group (
    id   INTEGER,
    name VARCHAR(20)
);

CREATE TABLE bronze.occupations (
    id   INTEGER,
    name VARCHAR(50)
);

CREATE TABLE bronze.genres (
    id   INTEGER,
    name VARCHAR(30)
);

CREATE TABLE bronze.users (
    id            INTEGER,
    age           SMALLINT,
    gender        CHAR(1),
    occupation_id INTEGER,
    zip_code      VARCHAR(10)
);

CREATE TABLE bronze.movies (
    id           INTEGER,
    title        VARCHAR(200),
    release_year SMALLINT
);

CREATE TABLE bronze.genres_movies (
    id       INTEGER,
    movie_id INTEGER,
    genre_id INTEGER
);

CREATE TABLE bronze.ratings (
    id          INTEGER,
    user_id     INTEGER,
    movie_id    INTEGER,
    rating      SMALLINT,
    "timestamp" BIGINT
);

BEGIN;

\COPY bronze.age_group     FROM 'age_group.csv'     WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\COPY bronze.occupations   FROM 'occupations.csv'   WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\COPY bronze.genres        FROM 'genres.csv'        WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\COPY bronze.users         FROM 'users.csv'         WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\COPY bronze.movies        FROM 'movies.csv'        WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\COPY bronze.genres_movies FROM 'genres_movies.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\COPY bronze.ratings       FROM 'ratings.csv'       WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')

COMMIT;