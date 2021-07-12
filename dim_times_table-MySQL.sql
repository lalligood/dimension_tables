-- USE {DATABASENAME};

DROP TABLE IF EXISTS dim_times;

CREATE TABLE IF NOT EXISTS dim_times (
    time_id INT UNSIGNED PRIMARY KEY COMMENT 'Time in HHMM00 as integer'
    , time_12hr CHAR(8) COMMENT '12-hour time with AM/PM indicator: "12:00 AM"'
    , time_24hr CHAR(5) COMMENT '24-hour military time (00:00:00-23:59:00)'
    , hour_12hr TINYINT UNSIGNED COMMENT '12hr clock hour (1-12)--must use with AM/PM!'
    , hour_24hr TINYINT UNSIGNED COMMENT 'Hour(s) since midnight (0-23)'
    , minute SMALLINT UNSIGNED COMMENT 'Minute(s) since beginning of hour (0-59)'
    , minutes_of_day SMALLINT UNSIGNED COMMENT 'Minute(s) since beginning of day (0-1439)'
    , am_pm ENUM('AM', 'PM') COMMENT 'AM/PM indicator text'
    , time_of_day ENUM('Overnight', 'Morning', 'Afternoon', 'Evening')
        COMMENT 'Text description of time of day (Morning, Afternoon, Evening, Overnight)'
) CHARACTER SET utf8mb4;

CREATE UNIQUE INDEX dim_times__time_12hr ON dim_times (time_12hr) USING BTREE;
CREATE UNIQUE INDEX dim_times__time_24hr ON dim_times (time_24hr) USING BTREE;
CREATE UNIQUE INDEX dim_times__hour_12hr_minute_am_pm
    ON dim_times (hour_12hr, minute, am_pm) USING BTREE;
CREATE UNIQUE INDEX dim_times__hour_24hr_minute
    ON dim_times (hour_24hr, minute) USING BTREE;
CREATE UNIQUE INDEX dim_times__minutes_of_day
    ON dim_times (minutes_of_day) USING BTREE;
CREATE INDEX dim_times__time_of_day ON dim_times (time_of_day) USING BTREE;

INSERT INTO dim_times
SELECT
	FLOOR(CAST(time_format(gen_time, '%H%i%s') AS unsigned) * .01) AS time_id
    , time_format(gen_time, '%h:%i %p') AS time_12hr
    , time_format(gen_time, '%H:%i') AS time_24hr
    , CAST(time_format(gen_time, '%h') AS unsigned) AS hour_12hr
    , CAST(time_format(gen_time, '%H') AS unsigned) AS hour_24hr
    , CAST(time_format(gen_time, '%i') AS unsigned) AS minute
    , CAST((time_format(gen_time, '%H') * 60)
        + time_format(gen_time, '%i') AS unsigned) AS minutes_of_day
    , time_format(gen_time, '%p') AS am_pm
    , CASE WHEN CAST(time_format(gen_time, '%H') AS unsigned) < 6 THEN 'Overnight'
        WHEN CAST(time_format(gen_time, '%H') AS unsigned) < 12 THEN 'Morning'
        WHEN CAST(time_format(gen_time, '%H') AS unsigned) < 18 THEN 'Afternoon'
        ELSE 'Evening' END AS time_of_day
FROM (
    SELECT addtime('2000-01-01 00:00:00'
        , CONCAT(t3, t2, ':', t1, t0, ':00')) AS gen_time
    FROM (SELECT 0 t0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION
            SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t0,
        (SELECT 0 t1 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION
            SELECT 5) t1,
        (SELECT 0 t2 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION
            SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t2,
        (SELECT 0 t3 UNION SELECT 1 UNION SELECT 2) t3
    ) v
WHERE gen_time < '2000-01-02 00:00:00';
