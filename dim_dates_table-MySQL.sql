-- USE {DATABASENAME};

DROP TABLE IF EXISTS dim_dates;

CREATE TABLE IF NOT EXISTS dim_dates (
    date_id INT UNSIGNED PRIMARY KEY COMMENT 'Date in YYYYMMDD as integer'
    , full_date DATE COMMENT 'Date in standard YYYY-MM-DD format'
    , full_date_text VARCHAR(40) COMMENT 'Date as text: "January 1, 2000"'
    , year INT UNSIGNED COMMENT 'Year integer'
    , quarter_of_year ENUM('Q1', 'Q2', 'Q3', 'Q4')
        COMMENT 'Quarter as string: Q1, Q2, Q3, Q4'
    , month TINYINT UNSIGNED COMMENT 'Month integer'
    , month_text ENUM('January', 'February', 'March', 'April', 'May', 'June', 'July'
        , 'August', 'September', 'October', 'November', 'December')
        COMMENT 'Month text: January, February, etc.'
    , month_text_abbr ENUM('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep'
        , 'Oct', 'Nov', 'Dec') COMMENT 'Month abbreviated text: Jan, Feb, Mar, etc.'
    , week_of_year TINYINT UNSIGNED COMMENT 'Week of year integer'
    , day_of_year SMALLINT UNSIGNED COMMENT 'Day of year integer'
    , day_of_month TINYINT UNSIGNED COMMENT 'Day of month integer'
    , day_of_week TINYINT UNSIGNED COMMENT 'Day of week integer'
    , day_of_week_text ENUM('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday'
        , 'Friday', 'Saturday') COMMENT 'Day of week text: Monday, Tuesday, etc.'
    , day_of_week_text_abbr ENUM('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat')
        COMMENT 'Day of week abbreviated text: Mon, Tue, Wed, etc.'
    , weekday_weekend ENUM('weekday', 'weekend') COMMENT 'Weekday/weeekend text'
) CHARACTER SET utf8mb4;

CREATE UNIQUE INDEX dim_dates__year_month_day_of_month
    ON dim_dates (year, month, day_of_month) USING BTREE;
CREATE UNIQUE INDEX dim_dates__year_month_text_day_of_month
    ON dim_dates (year, month_text, day_of_month) USING BTREE;
CREATE UNIQUE INDEX dim_dates__year_month_text_abbr_day_of_month
    ON dim_dates (year, month_text_abbr, day_of_month) USING BTREE;
CREATE INDEX dim_dates__quarter_of_year ON dim_dates (quarter_of_year) USING BTREE;
CREATE INDEX dim_dates__week_of_year ON dim_dates (week_of_year) USING BTREE;
CREATE INDEX dim_dates__day_of_year ON dim_dates (day_of_year) USING BTREE;
CREATE INDEX dim_dates__day_of_week ON dim_dates (day_of_week) USING BTREE;
CREATE INDEX dim_dates__day_of_week_text ON dim_dates (day_of_week_text) USING BTREE;
CREATE INDEX dim_dates__day_of_week_text_abbr
    ON dim_dates (day_of_week_text_abbr) USING BTREE;
CREATE INDEX dim_dates__weekday_weekend ON dim_dates (weekday_weekend) USING BTREE;

INSERT INTO dim_dates
SELECT
    CAST(DATE_FORMAT(gen_date, '%Y%m%d') AS unsigned) AS date_id
    , gen_date AS full_date
    , DATE_FORMAT(gen_date, '%M %e, %Y') AS full_date_text
    , YEAR(gen_date) AS year
    , CONCAT('Q', quarter(gen_date)) AS quarter_of_year
    , MONTH(gen_date) AS month
    , MONTHNAME(gen_date) AS month_text
    , LEFT(MONTHNAME(gen_date), 3) AS month_text_abbr
    , WEEKOFYEAR(gen_date) AS week_of_year
    , DAYOFYEAR(gen_date) AS day_of_year
    , DAYOFMONTH(gen_date) AS day_of_month
    , DAYOFWEEK(gen_date) AS day_of_week
    , DAYNAME(gen_date) AS day_of_week_text
    , LEFT(DAYNAME(gen_date), 3) AS day_of_week_text_abbr
    , CASE WHEN DAYOFWEEK(gen_date) IN (1, 7)
        THEN 'weekend' ELSE 'weekday' END AS weekday_weekend
FROM (
    SELECT adddate('1970-01-01'
        , (t4 * 10000) + (t3 * 1000) + (t2 * 100) + (t1 * 10) + t0) AS gen_date
    FROM (SELECT 0 t0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION
            SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t0,
        (SELECT 0 t1 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION
            SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t1,
        (SELECT 0 t2 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION
            SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t2,
        (SELECT 0 t3 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION
            SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t3,
        (SELECT 0 t4 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION
            SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t4
        ) v
WHERE gen_date BETWEEN '2000-01-01' AND '2099-12-31';
