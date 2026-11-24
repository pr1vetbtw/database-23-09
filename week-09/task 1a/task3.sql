CREATE SCHEMA IF NOT EXISTS gold;

CREATE TABLE IF NOT EXISTS gold.dim_time (
    time_id INTEGER PRIMARY KEY,
    hour    SMALLINT NOT NULL,
    minute  SMALLINT NOT NULL,
    second  SMALLINT NOT NULL
);

CREATE TABLE IF NOT EXISTS gold.dim_date (
    date_id     INTEGER PRIMARY KEY,
    full_date   DATE NOT NULL,
    year        SMALLINT NOT NULL,
    quarter     SMALLINT NOT NULL,
    month       SMALLINT NOT NULL,
    month_name  VARCHAR(20) NOT NULL,
    day         SMALLINT NOT NULL,
    day_of_week SMALLINT NOT NULL,
    day_name    VARCHAR(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS gold.dim_user (
    user_id         INTEGER PRIMARY KEY,
    age             SMALLINT,
    age_group       VARCHAR(20),
    gender          CHAR(1),
    occupation_id   INTEGER,
    occupation_name VARCHAR(50),
    zip_code        VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS gold.dim_movie (
    movie_id     INTEGER PRIMARY KEY,
    title        VARCHAR(200) NOT NULL,
    release_year SMALLINT,
    genres       TEXT
);

CREATE TABLE IF NOT EXISTS gold.fact_rating (
    rating_id INTEGER PRIMARY KEY,
    user_id   INTEGER  NOT NULL REFERENCES gold.dim_user(user_id),
    movie_id  INTEGER  NOT NULL REFERENCES gold.dim_movie(movie_id),
    date_id   INTEGER  NOT NULL REFERENCES gold.dim_date(date_id),
    time_id   INTEGER  NOT NULL REFERENCES gold.dim_time(time_id),
    rating    SMALLINT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_fact_rating_user  ON gold.fact_rating(user_id);
CREATE INDEX IF NOT EXISTS idx_fact_rating_movie ON gold.fact_rating(movie_id);
CREATE INDEX IF NOT EXISTS idx_fact_rating_date  ON gold.fact_rating(date_id);
CREATE INDEX IF NOT EXISTS idx_fact_rating_time  ON gold.fact_rating(time_id);

TRUNCATE gold.fact_rating, gold.dim_user, gold.dim_movie, gold.dim_date, gold.dim_time;

INSERT INTO gold.dim_time (time_id, hour, minute, second)
SELECT
    s,
    (s / 3600)::SMALLINT,
    ((s % 3600) / 60)::SMALLINT,
    (s % 60)::SMALLINT
FROM generate_series(0, 86399) AS g(s);

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
        (SELECT MIN(rated_at)::DATE FROM silver.ratings),
        (SELECT MAX(rated_at)::DATE FROM silver.ratings),
        INTERVAL '1 day') AS g(d);

INSERT INTO gold.dim_user (user_id, age, age_group, gender, occupation_id, occupation_name, zip_code)
SELECT
    u.id,
    u.age,
    ag.name,
    u.gender,
    u.occupation_id,
    o.name,
    u.zip_code
FROM silver.users u
LEFT JOIN silver.age_group   ag ON ag.id = u.age
LEFT JOIN silver.occupations o  ON o.id  = u.occupation_id;

INSERT INTO gold.dim_movie (movie_id, title, release_year, genres)
SELECT
    m.id,
    m.title,
    m.release_year,
    STRING_AGG(g.name, ', ' ORDER BY g.name)
FROM silver.movies m
LEFT JOIN silver.genres_movies gm ON gm.movie_id = m.id
LEFT JOIN silver.genres        g  ON g.id = gm.genre_id
GROUP BY m.id, m.title, m.release_year;

INSERT INTO gold.fact_rating (rating_id, user_id, movie_id, date_id, time_id, rating)
SELECT
    r.id,
    r.user_id,
    r.movie_id,
    TO_CHAR(r.rated_at, 'YYYYMMDD')::INTEGER,
    (EXTRACT(HOUR FROM r.rated_at) * 3600
     + EXTRACT(MINUTE FROM r.rated_at) * 60
     + FLOOR(EXTRACT(SECOND FROM r.rated_at)))::INTEGER,
    r.rating
FROM silver.ratings r;