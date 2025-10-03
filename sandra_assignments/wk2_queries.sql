--- WEEK 2 ASSIGNMENT QUERIES AND OUTPUTS BY SANDRA ATIENO

--- save results to a  text file
.output 'C:/Users/HP/OneDrive/Desktop/SANDY/MasterclassSQL/Assignments/wk2_hw/sandra_wk2_results.txt'

---create database and test
.open 'C:/Users/HP/OneDrive/Desktop/SANDY/MasterclassSQL/Assignments/wk2_hw/quarter_sales.duckdb'

SELECT CURRENT_TIME;
SELECT CURRENT_DATE;

DROP TABLE IF EXISTS yellow_quarter1_2025; --- drop the table if it already exists when running code
DROP TABLE IF EXISTS green_quarter1_2025; --- drop the table if it already exists when running code 
DROP TABLE IF EXISTS yellow_quarter1_2025_1; --- drop the table if it already exists when running code
DROP TABLE IF EXISTS green_quarter1_2025_1; --- drop the table if it already exists when running code
--- create tables for quarter 1
CREATE TABLE yellow_quarter1_2025 AS
SELECT * FROM read_parquet(['https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2025-01.parquet',
'https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2025-02.parquet',
'https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2025-03.parquet']);

CREATE TABLE green_quarter1_2025 AS
SELECT * FROM read_parquet(['https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2025-01.parquet',
'https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2025-02.parquet',
'https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2025-03.parquet']);

PRAGMA database_list; --cheks the database we created
SHOW TABLES; ---- lists all tables

--- sort by trip distance
SELECT tpep_pickup_datetime, tpep_dropoff_datetime, passenger_count, trip_distance, total_amount
FROM yellow_quarter1_2025
ORDER BY trip_distance DESC
LIMIT 10;

SELECT lpep_pickup_datetime, lpep_dropoff_datetime, passenger_count, trip_distance, total_amount
FROM green_quarter1_2025
ORDER BY trip_distance DESC
LIMIT 10;

--- Jan 2025 trips
SELECT COUNT (*) AS yellow_jan2025_trips
FROM yellow_quarter1_2025
WHERE tpep_pickup_datetime >= '2025-01-01 00:00:00' AND tpep_dropoff_datetime <= '2025-01-31 23:59:59';

SELECT COUNT (*) AS green_jan2025_trips
FROM green_quarter1_2025
WHERE lpep_pickup_datetime >= '2025-01-01 00:00:00' AND lpep_dropoff_datetime <= '2025-01-31 23:59:59';

--- passenger count of null and zero trips
SELECT COUNT (*) AS yellow_ZN_passengercount
FROM yellow_quarter1_2025
WHERE passenger_count IS NULL OR passenger_count = 0;

SELECT COUNT (*) AS green_ZN_passengercount
FROM green_quarter1_2025
WHERE passenger_count IS NULL OR passenger_count = 0;


--- days with highest count of trips in quarter 1
SELECT
DATE_TRUNC('DAY', lpep_dropoff_datetime) AS dropoff_days,
COUNT(*) AS trips
FROM green_quarter1_2025
GROUP BY dropoff_days
ORDER BY trips DESC
LIMIT 10;

SELECT
DATE_TRUNC('DAY', tpep_dropoff_datetime) AS dropoff_days,
COUNT(*) AS trips
FROM yellow_quarter1_2025
GROUP BY dropoff_days
ORDER BY trips DESC
LIMIT 10;

--- monthly revenues in quarter 1
SELECT 
DATE_PART('MONTH', tpep_dropoff_datetime) AS month_num,
SUM(total_amount) AS total_revenue
FROM yellow_quarter1_2025
GROUP BY month_num
ORDER BY total_revenue DESC
LIMIT 5;

SELECT
DATE_PART('MONTH', lpep_dropoff_datetime) AS month_number,
SUM(total_amount) AS total_revenue
FROM green_quarter1_2025
GROUP BY month_number
ORDER BY total_revenue DESC
LIMIT 5;

--- from the monthly revenues query output i noticed the months  are written as numbers and the totall revenue has several decimal places.
--- clean up.

SELECT 
DATE_PART('month', lpep_pickup_datetime) AS month_num, --- extracts the month number
STRFTIME(lpep_pickup_datetime, '%B')     AS month_name, --- formats the month number to text
printf('%,.2f', SUM(total_amount))  AS total_revenue --- formats the total amount to include commas and 2 decimal places
FROM green_quarter1_2025
GROUP BY 1,2 --- groups by month number and month name
ORDER BY SUM(total_amount) DESC;

SELECT 
DATE_PART('month', tpep_pickup_datetime) AS month_num, --- extracts the month number
STRFTIME(tpep_pickup_datetime, '%B')     AS month_name, --- formats the month number to text
printf('%,.2f', SUM(total_amount))  AS total_revenue --- formats the total amount to include commas and 2 decimal places
FROM yellow_quarter1_2025
GROUP BY 1,2 --- groups by month number and month name
ORDER BY SUM(total_amount) DESC;

--- average tip amount by hour of day
SELECT LPAD(EXTRACT(HOUR FROM tpep_pickup_datetime)::VARCHAR, 2, '0') || ':00 HRS' AS hour_label,
AVG(tip_amount) AS avg_tip_amount
FROM yellow_quarter1_2025
GROUP BY hour_label
ORDER BY avg_tip_amount DESC;

SELECT LPAD(EXTRACT(HOUR FROM lpep_pickup_datetime)::VARCHAR, 2, '0') || ':00 HRS' AS hour_label,
AVG(tip_amount) AS avg_tip_amount
FROM green_quarter1_2025
GROUP BY hour_label
ORDER BY avg_tip_amount DESC;

SHOW TABLES;