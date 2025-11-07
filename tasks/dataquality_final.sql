-- DATA QUALITY CHECKS
-- Author: Sandra Atieno
-- Description:
-- Performs key data quality checks for the NYC TLC Yellow and Green taxi datasets.
-- Results are summarized in one compact audit table for tracking and visualization.
-- ===============================================================

-- CREATE CONSOLIDATED DATA QUALITY SUMMARY TABLE
---------------------------------------------------------------

CREATE OR REPLACE TABLE data_quality_summary AS
SELECT 
    CURRENT_DATE AS run_date,
    'YELLOW' AS dataset,
    COUNT(*) AS total_rows,  -- Total rows for reference

    COUNT(*) FILTER (
        WHERE fare_amount IS NULL OR trip_distance IS NULL 
           OR fare_amount <= 0 OR trip_distance <= 0
    ) AS inv_fare_dist,  -- Invalid fares or distances (NULL, zero, or negative)

    COUNT(*) FILTER (
        WHERE passenger_count IS NULL OR passenger_count <= 0 OR passenger_count > 6
    ) AS inv_passenger_count,     -- Invalid passenger counts (NULL, zero, or unrealistic >6)

    COUNT(*) FILTER (
        WHERE tpep_dropoff_datetime <= tpep_pickup_datetime
    ) AS inv_timestamps, -- Dropoff earlier than pickup

    COUNT(*) FILTER (
        WHERE DATE_DIFF('minute', tpep_pickup_datetime, tpep_dropoff_datetime) < 1
    ) AS trip_too_short,  -- Trips too short (<1 minute)

    COUNT(*) FILTER (
        WHERE DATE_DIFF('minute', tpep_pickup_datetime, tpep_dropoff_datetime) > 360
    ) AS trip_too_long,  -- Trips too long (>6 hours)

    COUNT(*) FILTER (
        WHERE trip_distance > 100
    ) AS inv_distance,     -- Extremely long distances (>100 miles)

    COUNT(*) FILTER (
        WHERE EXTRACT(year FROM tpep_pickup_datetime) NOT BETWEEN 2015 AND 2025
           OR EXTRACT(year FROM tpep_dropoff_datetime) NOT BETWEEN 2015 AND 2025
    ) AS inv_yrs     -- Invalid years (outside 2015–2025)

FROM yellow_data

UNION ALL

SELECT 
    CURRENT_DATE AS run_date,
    'GREEN' AS dataset,

    COUNT(*) AS total_rows,

    COUNT(*) FILTER (
        WHERE fare_amount IS NULL OR trip_distance IS NULL 
           OR fare_amount <= 0 OR trip_distance <= 0
    ) AS inv_fare_dist,

    COUNT(*) FILTER (
        WHERE passenger_count IS NULL OR passenger_count <= 0 OR passenger_count > 6
    ) AS inv_passenger_count,

    COUNT(*) FILTER (
        WHERE lpep_dropoff_datetime <= lpep_pickup_datetime
    ) AS inv_timestamps,

    COUNT(*) FILTER (
        WHERE DATE_DIFF('minute', lpep_pickup_datetime, lpep_dropoff_datetime) < 1
    ) AS trip_too_short,

    COUNT(*) FILTER (
        WHERE DATE_DIFF('minute', lpep_pickup_datetime, lpep_dropoff_datetime) > 360
    ) AS trip_too_long,

    COUNT(*) FILTER (
        WHERE trip_distance > 100
    ) AS inv_distance,

    COUNT(*) FILTER (
        WHERE EXTRACT(year FROM lpep_pickup_datetime) NOT BETWEEN 2015 AND 2025
           OR EXTRACT(year FROM lpep_dropoff_datetime) NOT BETWEEN 2015 AND 2025
    ) AS inv_yrs
FROM green_data;

-- REVIEW SUMMARY RESULTS
SELECT * FROM data_quality_summary;

