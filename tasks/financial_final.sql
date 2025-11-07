-- ===============================================================
-- STEP 4: FINANCIAL ANALYSIS (Using CTEs & Window Functions)
-- Author: Sandra Atieno
-- Description:
-- Calculates annual revenue from yellow taxi data using a CTE, 
-- and compares each year's revenue with the previous year's 
-- using the LAG() window function.
-- ===============================================================

WITH yearly_revenue AS (
    SELECT 
        year,
        ROUND(SUM(total_amount), 2) AS annual_revenue
    FROM yellow_data_clean
    GROUP BY year
)

SELECT 
    year,
    annual_revenue,
    LAG(annual_revenue) OVER (ORDER BY year) AS previous_year_revenue,
    ROUND(
        ((annual_revenue - LAG(annual_revenue) OVER (ORDER BY year)) 
        / LAG(annual_revenue) OVER (ORDER BY year)) * 100, 2
    ) AS revenue_growth_percentage
FROM yearly_revenue
ORDER BY year;
