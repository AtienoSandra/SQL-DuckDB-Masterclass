-- ===============================================================
-- AVERAGE TRIP SUMMARY BY BOROUGH (YELLOW TAXI)
-- Author: Sandra Atieno
-- Description:
-- Summarizes what an "average trip" looks like for NYC Yellow Taxis.
-- Calculates average trip distance, fare, fare per mile, and speed (mph)
-- grouped by Borough for management reporting or Power BI visualization.
-- ===============================================================

-- BASE DATA
-- Pull only essential columns and calculate trip duration in minutes.
-- Join taxi_zone_lookup to get the Borough name.
---------------------------------------------------------------

CREATE TABLE IF NOT EXISTS taxi_zone_lookup AS SELECT * FROM 
read_csv('https://d37ci6vzurychx.cloudfront.net/misc/taxi_zone_lookup.csv');

DESCRIBE taxi_zone_lookup;

SHOW TABLES;

-- create table using the CTEs (valid)
CREATE OR REPLACE TABLE yellow_trip_summary AS
WITH trip_base AS (
    SELECT
        y.vendorid,
        y.tpep_pickup_datetime,
        z.borough,
        y.trip_distance,
        y.fare_amount,
        y.total_amount,
        DATE_DIFF('minute', y.tpep_pickup_datetime, y.tpep_dropoff_datetime) AS trip_duration_mins
    FROM yellow_data_clean AS y
    LEFT JOIN taxi_zone_lookup AS z
        ON y.pulocationid = z.locationid
    WHERE y.trip_distance > 0
      AND y.fare_amount > 0
      AND y.tpep_dropoff_datetime > y.tpep_pickup_datetime
),
trip_metrics AS (
    SELECT
        vendorid,
        borough,
        trip_distance,
        fare_amount,
        total_amount,
        trip_duration_mins,
        ROUND(fare_amount / NULLIF(trip_distance, 0), 2) AS fare_per_mile,
        ROUND((trip_distance / NULLIF(trip_duration_mins, 0)) * 60, 2) AS speed_mph
    FROM trip_base
)
SELECT
    borough,
    ROUND(AVG(trip_distance), 2) AS avg_trip_dist_miles,
    ROUND(AVG(fare_amount), 2) AS avg_fare,
    ROUND(AVG(total_amount), 2) AS avg_total_amt,
    ROUND(AVG(fare_per_mile), 2) AS avg_fare_per_mile,
    ROUND(AVG(speed_mph), 2) AS avg_speed_mph,
    ROUND(AVG(trip_duration_mins), 2) AS avg_trip_duration_mins
FROM trip_metrics
WHERE borough IS NOT NULL
GROUP BY borough;

-- QUICK VIEW OF RESULTS
---------------------------------------------------------------
SELECT * 
FROM yellow_trip_summary
ORDER BY avg_trip_dist_miles DESC;

-- Pull year and pickup hour from pickup datetime.
---------------------------------------------------------------
WITH hourly_base AS (
    SELECT
        EXTRACT(year FROM tpep_pickup_datetime) AS trip_year,
        EXTRACT(hour FROM tpep_pickup_datetime) AS trip_hour
    FROM yellow_data_clean
    WHERE tpep_pickup_datetime IS NOT NULL
),

--  AGGREGATE TRIPS BY HOUR AND YEAR
---------------------------------------------------------------
hourly_summary AS (
    SELECT
        trip_year,
        trip_hour,
        COUNT(*) AS total_trips
    FROM hourly_base
    GROUP BY trip_year, trip_hour
)

-- FINAL OUTPUT: FORMATTED HOUR LABEL
--  in 12-hour format with AM/PM for readability.
---------------------------------------------------------------

SELECT
    trip_year,
    CASE
        WHEN trip_hour = 0 THEN '12:00 AM'
        WHEN trip_hour < 12 THEN LPAD(CAST(trip_hour AS VARCHAR), 2, '0') || ':00 AM'
        WHEN trip_hour = 12 THEN '12:00 PM'
        ELSE LPAD(CAST(trip_hour - 12 AS VARCHAR), 2, '0') || ':00 PM'
    END AS hour_label,
    total_trips
FROM hourly_summary
ORDER BY trip_year, trip_hour;
