.open 'C:/Users/HP/OneDrive/Desktop/SANDY/MasterclassSQL/Assignments/wk3_hw/wk3_tables.duckdb'
.output 'C:/Users/HP/OneDrive/Desktop/SANDY/MasterclassSQL/Assignments/wk4_hw/Sandra_wk4B_results.txt'

----- QUESTION 1

WITH trip_duration_mins AS (
    SELECT *,
        ROUND(EXTRACT(EPOCH FROM (tpep_dropoff_datetime - tpep_pickup_datetime)) / 60, 2) AS trip_duration_minutes, --- EPOCH gets the time difference in seconds, we then convert to min.
        EXTRACT(MONTH FROM tpep_pickup_datetime) AS month_number,
        strftime('%B', tpep_pickup_datetime) AS month_name,
        -- calculation for average trip duration per vendor per month
        AVG(ROUND(EXTRACT(EPOCH FROM (tpep_dropoff_datetime - tpep_pickup_datetime)) / 60, 2))
            OVER (PARTITION BY EXTRACT(MONTH FROM tpep_pickup_datetime), vendorid) AS avg_trip_duration_minutes
    FROM yellow_2023
    WHERE EXTRACT(YEAR FROM tpep_pickup_datetime) = 2023 --- ensures data is only from 2023
),

validated_trips AS (
    SELECT *
    FROM trip_duration_mins
    WHERE 
        tpep_dropoff_datetime > tpep_pickup_datetime --- ensures validity
        AND tpep_pickup_datetime IS NOT NULL
        AND tpep_dropoff_datetime IS NOT NULL
        AND trip_duration_minutes >= 1 AND trip_duration_minutes <= 1440 --- filters out trips less than one minute and more than 24hrs
),

ranked_trips AS (
    SELECT *,
        DENSE_RANK() OVER (
            PARTITION BY month_number, VendorID ORDER BY trip_duration_minutes DESC
        ) AS trip_rank
    FROM validated_trips
)

SELECT
    month_number,
    month_name,
    VendorID,
    trip_rank,
    trip_duration_minutes,
    avg_trip_duration_minutes
FROM ranked_trips
WHERE trip_rank <= 5
ORDER BY month_number, vendorid, trip_rank;

------- QUESTION 2

WITH valid_tips AS (
    SELECT *,
        EXTRACT(MONTH FROM tpep_pickup_datetime) AS month_number,
        strftime('%B', tpep_pickup_datetime) AS month_name,
        -- calculation for percentile rank of tip_amount per month
        PERCENT_RANK() OVER (
            PARTITION BY EXTRACT(MONTH FROM tpep_pickup_datetime)
            ORDER BY tip_amount
        ) AS percentile_tips,
        ROW_NUMBER() OVER (
            PARTITION BY EXTRACT(MONTH FROM tpep_pickup_datetime)
            ORDER BY tip_amount DESC
        ) AS row_num ---- added the ROW_NUMBER() to help with limiting output because PERCENT_RANK() alone returns thousands of rows.
    FROM yellow_2023
    WHERE EXTRACT(YEAR FROM tpep_pickup_datetime) = 2023
      AND tip_amount >= 0
      )

SELECT
    month_number,
    month_name,
    row_num,
    tip_amount,
    ROUND(percentile_tips, 2) AS percentile_tips
FROM valid_tips
WHERE percentile_tips >= 0.9 AND row_num <=10 ---- tips in the 90th percentile i.e top 10% trips every month in terms of trips
ORDER BY month_number, percentile_tips DESC;

