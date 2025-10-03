---create and connect to a new database. This duckdb database stores my tables/makes them persist.
.open 'C:/Users/HP/OneDrive/Desktop/SANDY/MasterclassSQL/Assignments/wk3_hw/wk3_tables.duckdb'

.output 'C:/Users/HP/OneDrive/Desktop/SANDY/MasterclassSQL/Assignments/wk3_hw/sandra_wk3_part2resultsB.txt'

SHOW TABLES;

--- Borough with highest revenue in 2023

    (SELECT 'Yellow' AS taxi_type, --- creates column to identify yellow taxi type
    tl.borough,ROUND(SUM(y.total_amount), 2) AS total_revenue --- rounding total revenue to 2 decimal places
    FROM yellow_2023 y
    JOIN taxi_lookup tl ON y.PULocationID = tl.LocationID
    GROUP BY tl.borough
    ORDER BY total_revenue DESC
    LIMIT 1) --- limiting to top borough based on revenue
    
    UNION ALL --- combining results from both taxi types

    (SELECT 'Green' AS taxi_type, --- creates column to identify green taxi type
    tl.borough,ROUND(SUM(g.total_amount), 2) AS total_revenue --- rounding total revenue to 2 decimal places
    FROM green_2023 g
    JOIN taxi_lookup tl ON g.PULocationID = tl.LocationID
    GROUP BY tl.borough
    ORDER BY total_revenue DESC
    LIMIT 1);

--- top 5 drop off zones for yellow and green taxi types based on trip count in the year 2023.

    (SELECT 'Yellow' AS taxi_type,tl.zone,COUNT(*) AS trip_count
    FROM yellow_2023 y
    JOIN taxi_lookup tl ON y.DOLocationID = tl.LocationID
    GROUP BY tl.zone
    ORDER BY trip_count DESC
    LIMIT 5) --- getting top 5 drop off zones for yellow taxis
    
    UNION ALL --- combining results from both taxi types

    (SELECT 'Green' AS taxi_type,tl.zone,COUNT(*) AS trip_count
    FROM green_2023 g
    JOIN taxi_lookup tl ON g.DOLocationID = tl.LocationID
    GROUP BY tl.zone
    ORDER BY trip_count DESC
    LIMIT 5); --- getting top 5 drop off zones for green taxis  

    --- result set showcasing the preferred payment matrix based on the available payment types and the count of trips for each of them.

   WITH taxi_payments AS (
    SELECT 'Yellow' AS taxi_type,
        CASE
            WHEN payment_type = 1 THEN 'Credit card'
            WHEN payment_type = 2 THEN 'Cash'
            ELSE 'Other'
        END AS payment_label
    FROM yellow_2023

    UNION ALL --- combining payment labels from both yellow and green taxi
    
    SELECT 'Green' AS taxi_type,
        CASE
            WHEN payment_type = 1 THEN 'Credit card'
            WHEN payment_type = 2 THEN 'Cash'
            ELSE 'Other'
        END AS payment_label
    FROM green_2023
)
SELECT taxi_type, payment_label, COUNT(*) AS trip_count
FROM taxi_payments
GROUP BY taxi_type, payment_label
ORDER BY taxi_type, trip_count DESC;

--- drop off zones utilized by both yellow and green taxi types

SELECT DISTINCT tl.Zone AS dropoff_zone
FROM yellow_2023 y
JOIN taxi_lookup tl ON y.DOLocationID = tl.LocationID

INTERSECT --- returns drop off zones common to both taxi types

SELECT DISTINCT tl.Zone AS dropoff_zone
FROM green_2023 g
JOIN taxi_lookup tl ON g.DOLocationID = tl.LocationID
ORDER BY dropoff_zone;

--- pickup zones that were utilized by the yellow taxi types and NOT the green taxi types.

SELECT DISTINCT tl.Zone AS pickup_zone
FROM yellow_2023 y
JOIN taxi_lookup tl ON y.PULocationID = tl.LocationID

EXCEPT --- returns pickup zones unique to yellow taxis only

SELECT DISTINCT tl.Zone AS pickup_zone
FROM green_2023 g
JOIN taxi_lookup tl ON g.PULocationID = tl.LocationID
ORDER BY pickup_zone;

--- the top 50 days where the revenue generated was greater than the average fare for yellow taxi types.

SELECT trip_date, daily_revenue
FROM (
    SELECT 
        DATE(tpep_pickup_datetime) AS trip_date,
        ROUND(SUM(total_amount), 2) AS daily_revenue
    FROM yellow_2023
    GROUP BY DATE(tpep_pickup_datetime)
        ) rev_subquery
WHERE daily_revenue > (SELECT AVG(fare_amount) FROM yellow_2023)
ORDER BY daily_revenue DESC
LIMIT 50;

--- alternative approach using CTEs to find top 50 days where daily revenue exceeded OVERALL AVERAGE REVENUE for yellow taxis in 2023
WITH daily_revenue AS (
    SELECT 
        DATE(tpep_pickup_datetime) AS trip_date,
        ROUND(SUM(total_amount), 2) AS daily_revenue
    FROM yellow_2023
    GROUP BY DATE(tpep_pickup_datetime)
),--- CTE to calculate daily revenue
overall_avg_rev AS (
    SELECT
        trip_date,
        daily_revenue,
        AVG(daily_revenue) OVER () AS avg_rev --- window function to calculate overall averagerevenue
    FROM daily_revenue
) --- CTE to calculate overall average revenue and stores it for reference later
--- final selection of top 50 days where daily revenue exceeded overall average revenue for yellow taxis in 2023
SELECT 
    ROW_NUMBER() OVER (ORDER BY daily_revenue DESC) AS rank_no, --- ranking days based on daily revenue
    trip_date,
    daily_revenue,
FROM overall_avg_rev
WHERE daily_revenue > avg_rev
ORDER BY daily_revenue DESC
LIMIT 50;

--- For yellow taxis in 2023, identify the top 5 days in each calendar month ranked by the daily average total_amount. 
WITH daily_avg AS (
    SELECT
        DATE(tpep_pickup_datetime) AS trip_date,
        EXTRACT(MONTH FROM tpep_pickup_datetime) AS month_num,
        STRFTIME(tpep_pickup_datetime, '%B') AS month_name,
        ROUND(AVG(total_amount), 2) AS avg_daily_total
    FROM yellow_2023
    GROUP BY DATE(tpep_pickup_datetime), EXTRACT(MONTH FROM tpep_pickup_datetime), STRFTIME(tpep_pickup_datetime, '%B') --- we do not use aliases in GROUP BY because of logical processing order
),--- CTE extracts date, month number, month name, avg daily total amount.
ranked_days AS (
    SELECT
        month_num,
        month_name,
        trip_date,
        avg_daily_total,
        DENSE_RANK() OVER (PARTITION BY month_num ORDER BY avg_daily_total DESC) AS day_rank
    FROM daily_avg
) --- CTE ranks days based on avg daily total amount within each month 
--- final selection of top 5 days per month based on rank for yellow taxis in 2023
SELECT month_num, month_name, trip_date, avg_daily_total, day_rank
FROM ranked_days
WHERE day_rank <= 5
ORDER BY month_num, month_name, day_rank, trip_date;

.output stdout
