-- DATA VALIDATION
-- Author: Sandra Atieno
-- Description:
-- This script validates the structure, format, and completeness of the 
-- NYC TLC Yellow and Green taxi trip datasets before cleaning.

-- ===============================================================
--STANDARDIZE TABLE NAMES
-- Rename raw input tables to consistent names used across pre-analysis scripts.       
---------------------------------------------------------------

ALTER TABLE yellow_taxi_trip_data RENAME TO yellow_data;
ALTER TABLE green_taxi_trip_data RENAME TO green_data;

-- Confirm renaming
SHOW TABLES;

-- CHECK RECORD COUNTS
---------------------------------------------------------------
SELECT 
    'YELLOW' AS dataset, COUNT(*) AS total_rows 
FROM yellow_data
UNION ALL
SELECT 
    'GREEN', COUNT(*) 
FROM green_data;

-- CHECK COLUMN STRUCTURE
---------------------------------------------------------------
DESCRIBE yellow_data;
DESCRIBE green_data;

-- SAMPLE DATA
---------------------------------------------------------------
SELECT * FROM yellow_data LIMIT 5;
SELECT * FROM green_data LIMIT 5;

-- CHECK FOR MISSING OR NULL VALUES
---------------------------------------------------------------
SELECT
    'YELLOW' AS dataset,
    COUNT(*) FILTER (WHERE fare_amount IS NULL) AS missing_fare,
    COUNT(*) FILTER (WHERE trip_distance IS NULL) AS missing_distance,
    COUNT(*) FILTER (WHERE tpep_pickup_datetime IS NULL OR tpep_dropoff_datetime IS NULL) AS missing_timestamps
FROM yellow_data
UNION ALL
SELECT
    'GREEN' AS dataset,
    COUNT(*) FILTER (WHERE fare_amount IS NULL),
    COUNT(*) FILTER (WHERE trip_distance IS NULL),
    COUNT(*) FILTER (WHERE lpep_pickup_datetime IS NULL OR lpep_dropoff_datetime IS NULL)
FROM green_data;

-- CHECK DATE RANGE OF TRIPS
---------------------------------------------------------------
SELECT
    'YELLOW' AS dataset,
    MIN(DATE(tpep_pickup_datetime)) AS min_trip_date,
    MAX(DATE(tpep_dropoff_datetime)) AS max_trip_date
FROM yellow_data
UNION ALL
SELECT
    'GREEN',
    MIN(DATE(lpep_pickup_datetime)),
    MAX(DATE(lpep_dropoff_datetime))
FROM green_data;


-- CHECK FOR INVALID DATE RANGES
---------------------------------------------------------------
SELECT 
    'YELLOW' AS dataset,
    COUNT(*) AS invalid_date_rows
FROM yellow_data
WHERE tpep_pickup_datetime < '2015-01-01' 
   OR tpep_dropoff_datetime > '2025-12-31'
UNION ALL
SELECT 
    'GREEN',
    COUNT(*)
FROM green_data
WHERE lpep_pickup_datetime < '2015-01-01'
   OR lpep_dropoff_datetime > '2025-12-31';


-- CHECK FOR TIMESTAMP ANOMALIES
---------------------------------------------------------------
SELECT
    'YELLOW' AS dataset,
    COUNT(*) AS invalid_timestamps
FROM yellow_data
WHERE tpep_dropoff_datetime < tpep_pickup_datetime
UNION ALL
SELECT
    'GREEN',
    COUNT(*)
FROM green_data
WHERE lpep_dropoff_datetime < lpep_pickup_datetime;

-- DUPLICATE VALIDATION
---------------------------------------------------------------
-- Detect and summarize duplicate trips that share identical pickup,
-- dropoff, location IDs, and total amount (excluding VendorID).
-- This helps ensure data uniqueness across vendor sources.

CREATE OR REPLACE TABLE duplicate_summary AS

-- Yellow dataset duplicates
SELECT
  'YELLOW' AS dataset,
  COUNT(*) AS duplicate_groups,
  SUM(duplicate_count) AS duplicate_rows
FROM (
  SELECT
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    PULocationID,
    DOLocationID,
    total_amount,
    COUNT(*) AS duplicate_count
  FROM yellow_data
  GROUP BY 1,2,3,4,5
  HAVING COUNT(*) > 1
) AS y_dups

UNION ALL

-- Green dataset duplicates
SELECT
  'GREEN' AS dataset,
  COUNT(*) AS duplicate_groups,
  SUM(duplicate_count) AS duplicate_rows
FROM (
  SELECT
    lpep_pickup_datetime,
    lpep_dropoff_datetime,
    PULocationID,
    DOLocationID,
    total_amount,
    COUNT(*) AS duplicate_count
  FROM green_data
  GROUP BY 1,2,3,4,5
  HAVING COUNT(*) > 1
) AS g_dups;

-- Review duplicate summary
SELECT * FROM duplicate_summary;


-- VALIDATION SUMMARY
-- Summarize all validation checks (counts, missing data, invalids)
-- into one report for easier tracking across datasets.

CREATE OR REPLACE TABLE validation_summary AS
SELECT 
    CURRENT_DATE AS run_date,
    'YELLOW' AS dataset,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE fare_amount IS NULL OR trip_distance IS NULL) AS missing_key_fields,
    COUNT(*) FILTER (WHERE fare_amount <= 0 OR trip_distance <= 0) AS invalid_fare_values,
    COUNT(*) FILTER (WHERE tpep_dropoff_datetime < tpep_pickup_datetime) AS invalid_timestamps,
    COUNT(*) FILTER (WHERE tpep_pickup_datetime NOT BETWEEN '2015-01-01' AND '2025-12-31'
                     OR tpep_dropoff_datetime NOT BETWEEN '2015-01-01' AND '2025-12-31') AS invalid_date_rows,
    (SELECT duplicate_rows FROM duplicate_summary WHERE dataset = 'YELLOW') AS duplicate_rows
FROM yellow_data

UNION ALL
SELECT 
    CURRENT_DATE,
    'GREEN',
    COUNT(*),
    COUNT(*) FILTER (WHERE fare_amount IS NULL OR trip_distance IS NULL),
    COUNT(*) FILTER (WHERE fare_amount <= 0 OR trip_distance <= 0),
    COUNT(*) FILTER (WHERE lpep_dropoff_datetime < lpep_pickup_datetime),
    COUNT(*) FILTER (WHERE lpep_pickup_datetime NOT BETWEEN '2015-01-01' AND '2025-12-31'
                     OR lpep_dropoff_datetime NOT BETWEEN '2015-01-01' AND '2025-12-31'),
    (SELECT duplicate_rows FROM duplicate_summary WHERE dataset = 'GREEN')
FROM green_data;

-- Review validation summary
SELECT * FROM validation_summary;



