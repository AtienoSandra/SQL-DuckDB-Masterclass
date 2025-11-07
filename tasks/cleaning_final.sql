-- DATA CLEANING SCRIPT 
-- Author: Sandra Atieno

-- STEP 1: FILTER INVALID ROWS 
---------------------------------------------------------------
DROP TABLE IF EXISTS yellow_filtered;

CREATE TABLE yellow_filtered AS
SELECT *
FROM yellow_data
WHERE 
    fare_amount IS NOT NULL AND fare_amount > 0
    AND trip_distance IS NOT NULL AND trip_distance > 0
    AND passenger_count BETWEEN 1 AND 6
    AND tpep_dropoff_datetime > tpep_pickup_datetime
    AND DATE_DIFF('minute', tpep_pickup_datetime, tpep_dropoff_datetime) BETWEEN 1 AND 360
    AND trip_distance <= 100
    AND EXTRACT(year FROM tpep_pickup_datetime) BETWEEN 2015 AND 2025
    AND EXTRACT(year FROM tpep_dropoff_datetime) BETWEEN 2015 AND 2025;

-- STEP 2: REMOVE DUPLICATES 
---------------------------------------------------------------
DROP TABLE IF EXISTS yellow_data_clean;

CREATE TABLE yellow_data_clean AS
SELECT DISTINCT ON (
    tpep_pickup_datetime, 
    tpep_dropoff_datetime, 
    PULocationID, 
    DOLocationID, 
    total_amount
) *
FROM yellow_filtered;

-- STEP 3: CHECK CLEANING RESULTS
---------------------------------------------------------------
CREATE OR REPLACE TABLE cleaning_summary AS
SELECT 
    'YELLOW' AS dataset,
    (SELECT COUNT(*) FROM yellow_data) AS rows_before,
    (SELECT COUNT(*) FROM yellow_data_clean) AS rows_after,
    ROUND(
        100.0 * (SELECT COUNT(*) FROM yellow_data_clean) / (SELECT COUNT(*) FROM yellow_data),
        2
    ) AS percent_remaining;


SELECT * FROM cleaning_summary;
