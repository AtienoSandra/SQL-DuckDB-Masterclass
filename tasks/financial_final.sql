-- ===============================================================
-- FINANCIAL ANALYSIS QUERIES
-- Author: Sandra Atieno
-- Date: 2025-11-08
-- Description: Complete financial analysis for NYC Yellow Taxi.
-- Includes monthly revenue, payment type analysis, borough-level metrics,
-- annual revenue with previous year comparison, and table explanation.
-- ===============================================================

-- ===============================================================
-- Q1: Monthly revenue breakdown
-- Summarizes fare, surcharge, tips, and total revenue by year and month
-- ===============================================================
SELECT
    EXTRACT(YEAR FROM tpep_pickup_datetime) AS year,
    EXTRACT(MONTH FROM tpep_pickup_datetime) AS month,
    ROUND(SUM(fare_amount), 2) AS total_fare,
    ROUND(SUM(extra + mta_tax + improvement_surcharge), 2) AS total_surcharge,
    ROUND(SUM(tip_amount), 2) AS total_tips,
    ROUND(SUM(total_amount), 2) AS total_revenue
FROM yellow_data_clean
GROUP BY 1, 2
ORDER BY 1, 2;

-- ===============================================================
-- Q2: Revenue by payment type
-- Shows total trips and revenue by payment type per year
-- ===============================================================
SELECT
    EXTRACT(YEAR FROM tpep_pickup_datetime) AS year,
    CASE payment_type
        WHEN 1 THEN 'Credit Card'
        WHEN 2 THEN 'Cash'
        WHEN 3 THEN 'No Charge'
        WHEN 4 THEN 'Dispute'
        WHEN 5 THEN 'Unknown'
        WHEN 6 THEN 'Voided Trip'
    END AS payment_type,
    COUNT(*) AS total_trips,
    ROUND(SUM(total_amount), 2) AS total_revenue
FROM yellow_data_clean
GROUP BY 1, 2
ORDER BY 1, total_revenue DESC;

-- ===============================================================
-- Q3: Borough-level revenue and metrics
-- Total revenue, fares, tips, average revenue per mile, and average tip by borough and year
-- ===============================================================
SELECT
    EXTRACT(YEAR FROM tpep_pickup_datetime) AS year,
    t.Borough AS borough,
    ROUND(SUM(y.total_amount), 2) AS total_revenue,
    ROUND(SUM(y.fare_amount), 2) AS total_fares,
    ROUND(SUM(y.tip_amount), 2) AS total_tips,
    ROUND(SUM(y.total_amount)/SUM(y.trip_distance), 2) AS avg_revenue_per_mile,
    ROUND(AVG(y.tip_amount), 2) AS avg_tip
FROM yellow_data_clean y
LEFT JOIN taxi_zone_lookup t
    ON y.PULocationID = t.LocationID
GROUP BY 1, 2
ORDER BY 1, borough;

-- ===============================================================
-- Q4: Annual revenue with previous year comparison
-- Uses CTE and LAG window function to calculate revenue growth percentage
-- ===============================================================
WITH annual_rev AS (
    SELECT
        EXTRACT(YEAR FROM tpep_pickup_datetime) AS year,
        ROUND(SUM(total_amount), 2) AS annual_revenue
    FROM yellow_data_clean
    GROUP BY 1
)
SELECT
    year,
    annual_revenue,
    prev_year_revenue,
    CASE 
        WHEN prev_year_revenue IS NOT NULL 
        THEN (annual_revenue - prev_year_revenue)/prev_year_revenue*100
        ELSE NULL
    END AS revenue_growth_percentage
FROM (
    SELECT
        year,
        annual_revenue,
        ROUND(LAG(annual_revenue) OVER (ORDER BY year), 2) AS prev_year_revenue
    FROM annual_rev
) t
ORDER BY year;
