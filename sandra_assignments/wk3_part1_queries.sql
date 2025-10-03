---create and connect to WEEK 3 DuckDB database
.open 'C:/Users/HP/OneDrive/Desktop/SANDY/MasterclassSQL/Assignments/wk3_hw/wk3_tables.duckdb'

--- save results to a  text file
.output 'C:/Users/HP/OneDrive/Desktop/SANDY/MasterclassSQL/Assignments/wk3_hw/sandra_wk3_part1results.txt'

SHOW TABLES;

-- Yellow taxi summary table.'; 

SELECT 
    CASE 
        WHEN tpep_pickup_datetime >= '2023-01-01' AND tpep_pickup_datetime < '2023-04-01' THEN 'Q1'
        WHEN tpep_pickup_datetime >= '2023-04-01' AND tpep_pickup_datetime < '2023-07-01' THEN 'Q2'
        WHEN tpep_pickup_datetime >= '2023-07-01' AND tpep_pickup_datetime < '2023-10-01' THEN 'Q3'
        WHEN tpep_pickup_datetime >= '2023-10-01' AND tpep_pickup_datetime < '2024-01-01' THEN 'Q4'
END AS quarter,
COUNT (*) AS total_trips,
SUM(total_amount) AS total_revenue,
AVG(trip_distance) AS avg_trip_distance,
AVG(passenger_count) AS avg_passenger_count
FROM yellow_2023
GROUP BY quarter
ORDER BY total_revenue DESC;

-- Green taxi summary table.'; 
SELECT 
    CASE 
        WHEN lpep_pickup_datetime >= '2023-01-01' AND lpep_pickup_datetime < '2023-04-01' THEN 'Q1'
        WHEN lpep_pickup_datetime >= '2023-04-01' AND lpep_pickup_datetime < '2023-07-01' THEN 'Q2'
        WHEN lpep_pickup_datetime >= '2023-07-01' AND lpep_pickup_datetime < '2023-10-01' THEN 'Q3'
        WHEN lpep_pickup_datetime >= '2023-10-01' AND lpep_pickup_datetime < '2024-01-01' THEN 'Q4'
END AS quarter,
COUNT (*) AS total_trips,
SUM(total_amount) AS total_revenue,
AVG(trip_distance) AS avg_trip_distance,
AVG(passenger_count) AS avg_passenger_count
FROM green_2023
GROUP BY quarter
ORDER BY total_revenue;

-- Yellow taxi top 5 pick up zones
-- We need to join the taxi_lookup table to get the pickup location and boroughnames.
-- We join yellow_2023.PULocationID with taxi_lookup.LocationID. 
-- I interpreted top performing as the highest revenue generating locations.

PRAGMA table_info(taxi_lookup); --- to check the column names and data in taxi_lookup table

SELECT tl.Borough AS Yellow_Taxi_Borough, tl.Zone AS Yellow_Taxi_Zone, 
COUNT(*) AS total_trips,
SUM(total_amount) AS total_revenue
FROM yellow_2023 y
JOIN taxi_lookup tl ON y.PULocationID = tl.LocationID
WHERE total_amount IS NOT NULL AND total_amount > 0
GROUP BY tl.Borough, tl.Zone
ORDER BY total_revenue DESC 
LIMIT 5;

-- Green taxi top 5 pick up zones

SELECT tl.Borough AS Green_Taxi_Borough, tl.Zone AS Green_Taxi_Zone,
COUNT(*) AS total_trips,
SUM(total_amount) AS total_revenue
FROM green_2023 g
JOIN taxi_lookup tl ON g.PULocationID = tl.LocationID
WHERE g.total_amount IS NOT NULL AND g.total_amount > 0
GROUP BY tl.Borough, tl.Zone
ORDER BY total_revenue DESC
LIMIT 5;

-- Yellow taxi zonal summary table
SELECT tl.Borough AS Yellow_Taxi_Borough, SUM(y.total_amount) AS total_revenue, COUNT(*) AS total_trips
FROM yellow_2023 y
JOIN taxi_lookup tl ON y.PULocationID = tl.LocationID
WHERE y.total_amount IS NOT NULL AND y.total_amount > 0
GROUP BY tl.Borough
ORDER BY total_revenue DESC;

-- Green taxi zonal summary table

SELECT tl.Borough AS Green_Taxi_Borough, SUM(g.total_amount) AS total_revenue, COUNT(*) AS total_trips
FROM green_2023 g
JOIN taxi_lookup tl ON g.PULocationID = tl.LocationID
WHERE g.total_amount IS NOT NULL AND g.total_amount > 0
GROUP BY tl.Borough
ORDER BY total_revenue DESC;

--- Customer spending behavior analysis for Yellow Taxi in 2023.  

SELECT
'Yellow' AS taxi_type,
    fare_range,
    COUNT(*) AS num_trips, --- number of trips in each fare range
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percent_trips, --- percentage of trips in each fare range based on the sum of trips in each fare range
    SUM(total_amount) AS total_revenue, --- total revenue in each fare range
    ROUND(100.0 * SUM(total_amount) / SUM(SUM(total_amount)) OVER (), 2) AS percent_revenue, --- percentage of revenue in each fare range based on the sum of revenue in each fare range
    ROUND(AVG(trip_distance), 2) AS avg_distance_miles, --- average trip distance in each fare range
FROM (
    SELECT total_amount, trip_distance,
         CASE
            WHEN total_amount BETWEEN 0 AND 9.99 THEN '0-9.99 (Neighborhood trips)'
            WHEN total_amount BETWEEN 10 AND 19.99 THEN '10-19.99 (Intra-city trips)'
            WHEN total_amount BETWEEN 20 AND 49.99 THEN '20-49.99 (Standard trips)'
            WHEN total_amount >= 50 THEN '50+ (Premium trips)'
        END AS fare_range  --- this subquery categorizes fare ranges
    FROM yellow_2023
    WHERE total_amount IS NOT NULL AND total_amount > 0
) bucketed_trips
GROUP BY fare_range
ORDER BY fare_range;

-- Customer spending behavior analysis for Green Taxi in 2023.

SELECT 
'Green' AS taxi_type,
fare_range, COUNT(*) AS num_trips, --- this gives the number of trips in each fare range
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percent_trips, ---- this gives the percentage of trips in each fare range based on the sum of trips in each fare range
    SUM(total_amount) AS total_revenue, --- this gives the total revenue in each fare range
    ROUND(100.0 * SUM(total_amount) / SUM(SUM(total_amount)) OVER (), 2) AS percent_revenue, --- this gives the percentage of revenue in each fare range based on the sum of revenue in each fare range
    ROUND(AVG(trip_distance), 2) AS avg_distance_miles, --- this gives the average trip distance in each fare range
FROM (
    SELECT total_amount,trip_distance,
            CASE
            WHEN total_amount BETWEEN 0 AND 9.99 THEN '0-9.99 (Neighborhood  trips)'
            WHEN total_amount BETWEEN 10 AND 19.99 THEN '10-19.99 (Intra-city trips)'
            WHEN total_amount BETWEEN 20 AND 49.99 THEN '20-49.99 (Standard trips)'
            WHEN total_amount >= 50 THEN '50+ (Premium trips)'
        END AS fare_range  --- this subquery categorizes fare ranges
    FROM green_2023
    WHERE total_amount IS NOT NULL AND total_amount > 0 --- filtering out invalid or zero fare amounts
) bucketed_trips
GROUP BY fare_range
ORDER BY fare_range;

--- close the output file
.output stdout 

--- ROUND () function is used to round off the decimal values to x decimal places, as specified, for better readability. If number of decimal places is not specified, it rounds off to the nearest integer.
--- PRAGMA table_info() is used to check the column names and data in a table.
--- I interpreted top performing as the highest revenue generating locations.
--- I joined the taxi_lookup table to get the pickup location and borough names.
--- I filtered out invalid or zero fare amounts to ensure the accuracy of the analysis.
--- I used descriptive aliases for columns to enhance clarity in the output.
--- I included comments throughout the code to explain the purpose of each section and the reasoning behind certain decisions.
