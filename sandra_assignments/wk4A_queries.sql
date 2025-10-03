.open 'C:/Users/HP/OneDrive/Desktop/SANDY/MasterclassSQL/Assignments/wk3_hw/wk3_tables.duckdb'
.output 'C:/Users/HP/OneDrive/Desktop/SANDY/MasterclassSQL/Assignments/wk4_hw/Sandra_wk4_results.txt'
SHOW TABLES;

--- Q1. Data Cleaning and Standardization for yellow_2023 table
SELECT *
FROM pragma_table_info('yellow_2023')
WHERE name IN ('total_amount', 'trip_distance', 'passenger_count'); --- to check the data types of the columns used in the queries
--- columns of interest are total_amount, trip_distance and passenger_count. They are all numeric types (DOUBLE), hence duckdb treats the empty strings as NULLs by default

WITH valid_data AS (
SELECT *
FROM yellow_2023
WHERE 
EXTRACT(YEAR FROM tpep_pickup_datetime) = 2023 --- filtering for trips in 2023
AND total_amount IS NOT NULL AND total_amount > 0
AND trip_distance IS NOT NULL AND trip_distance > 0
AND passenger_count IS NOT NULL AND passenger_count > 0
LIMIT 20
),
standardized_data AS (
    SELECT VendorID,
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    ROUND(total_amount, 3) AS total_amount,
    ROUND(trip_distance, 3) AS trip_distance,
    passenger_count,
    CASE
         WHEN store_and_fwd_flag IS NULL OR TRIM(store_and_fwd_flag) = '' THEN NULL --- treats empty strings as NULLs
         WHEN UPPER(TRIM(store_and_fwd_flag)) = 'Y' THEN 'Y' --- trim spaces and convert to uppercase before comparison
         WHEN UPPER(TRIM(store_and_fwd_flag)) = 'N' THEN 'N' --- trim spaces and convert to uppercase before comparison
         ELSE NULL
        END AS store_and_fwd_flag
    FROM valid_data
),
labelled_data AS (
    SELECT *,
    CASE
        WHEN passenger_count = 1 THEN 'Solo'
        WHEN passenger_count BETWEEN 2 AND 3 THEN 'Small Group'
        WHEN passenger_count BETWEEN 4 AND 6 THEN 'Medium Group'
        WHEN passenger_count > 6 THEN 'Large Group'
        ELSE 'Unknown'
    END AS tripsize_label
    FROM standardized_data
)

SELECT VendorID,
tpep_pickup_datetime,
tpep_dropoff_datetime,
passenger_count,
tripsize_label,
trip_distance,
total_amount,
store_and_fwd_flag,
FROM labelled_data
LIMIT 20;

--- Q2.Create clean table from stanadardized data in Q1 and export to CSV file
DROP TABLE IF EXISTS cleaned_yellow_2023; --- drop the table if it already exists when running code

CREATE TABLE cleaned_yellow_2023 AS
WITH valid_data AS 
                    (
                        SELECT *
                        FROM yellow_2023
                        WHERE total_amount IS NOT NULL AND total_amount > 0
                        AND trip_distance IS NOT NULL AND trip_distance > 0
                        AND passenger_count IS NOT NULL AND passenger_count > 0
             ),
standardized_data AS 
                    (
                        SELECT VendorID,
                        tpep_pickup_datetime,
                        tpep_dropoff_datetime,
                        ROUND(total_amount, 3) AS total_amount,
                        ROUND(trip_distance, 3) AS trip_distance,
                        passenger_count,
                CASE
                        WHEN store_and_fwd_flag IS NULL OR TRIM(store_and_fwd_flag) = '' THEN NULL --- treats empty strings as NULLs
                        WHEN UPPER(TRIM(store_and_fwd_flag)) = 'Y' THEN 'Y' --- trim spaces and convert to uppercase before comparison
                        WHEN UPPER(TRIM(store_and_fwd_flag)) = 'N' THEN 'N' --- trim spaces and convert to uppercase before comparison
                        ELSE NULL
                        END AS store_and_fwd_flag
                        FROM valid_data
                    ),
labelled_data AS 
                    (
                         SELECT *,
                         CASE
                         WHEN passenger_count = 1 THEN 'Solo'
                         WHEN passenger_count BETWEEN 2 AND 3 THEN 'Small Group'
                         WHEN passenger_count BETWEEN 4 AND 6 THEN 'Medium Group'
                         WHEN passenger_count > 6 THEN 'Large Group'
                         ELSE 'Unknown'
                         END AS tripsize_label
                         FROM standardized_data
                    )
SELECT * FROM labelled_data; --- creates the cleaned_yellow_2023 table with cleaned and standardized data

COPY  (
        SELECT * FROM cleaned_yellow_2023) TO 
        'C:/Users/HP/OneDrive/Desktop/SANDY/MasterclassSQL/Assignments/wk4_hw/cleaned_yellow_2023.csv'
         WITH (HEADER, DELIMITER ','
    ); --- copy table to csv file.

--- monthly revenue report with previous month comparison for cleaned_yellow_2023 table
WITH monthly_revenue AS (
    SELECT
        LPAD(CAST(EXTRACT(MONTH FROM tpep_pickup_datetime) AS VARCHAR), 3, '0') AS month_number, --- extracts the month, casts it as VARCHAR then pads with leading zero  to 3 characters
        strftime('%B', tpep_pickup_datetime) AS month_name,  --- formats the month number to text
        ROUND(SUM(total_amount),2) AS monthly_revenue
    FROM cleaned_yellow_2023
    GROUP BY month_number, month_name
),
prev_monthly_revenue AS (
    SELECT
        month_number,
        month_name,
        monthly_revenue,
        LAG(monthly_revenue) OVER (ORDER BY month_number) AS previous_month_revenue --- gets the previous month's revenue
    FROM monthly_revenue
)
SELECT *
FROM prev_monthly_revenue
ORDER BY month_number;

--- monthly revenue report grouped by VendorID
WITH monthly_vendor_revenue AS (
    SELECT
        LPAD(CAST(strftime('%m', tpep_pickup_datetime) AS VARCHAR), 3, '0') AS month_number,
        strftime('%B', tpep_pickup_datetime) AS month_name,
        VendorID,
        ROUND(SUM(total_amount), 2) AS monthly_revenue
    FROM cleaned_yellow_2023
    GROUP BY month_number, month_name, VendorID
)
SELECT
    month_number,
    month_name,
    VendorID,
    monthly_revenue,
    ROUND(SUM(monthly_revenue) OVER (PARTITION BY VendorID),2) AS vendor_total_revenue,
    ROUND(
            ((monthly_revenue / SUM(monthly_revenue) OVER (PARTITION BY VendorID)) * 100),2 --- calculates the monthly revenue percentage for each vendor
         ) AS vendor_revenue_percentage
FROM monthly_vendor_revenue
ORDER BY VendorID, month_number;



