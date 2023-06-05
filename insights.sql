-- 1.1 Top 10 Domestic districts

SELECT 
    district, Round(SUM(visitors) / 1000000, 2) AS total_count_visitors
FROM
    dom_visitors
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- 1.2 Top 10 foreign disticts. 

SELECT 
    district, SUM(visitors) / 1000 AS total_count_visitors
FROM
    for_visitors
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- 2.1 Top-3 domestic districts based on compounded annual growth.
WITH cte1 AS (
SELECT 
    district, year, SUM(visitors) AS total_visitors
FROM
    dom_visitors
GROUP BY 1 , 2
ORDER BY 1),
cte2 AS (
SELECT 
	*, 
	FIRST_VALUE(total_visitors) OVER(PARTITION BY district ORDER BY year RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS fst_val,
	LAST_VALUE(total_visitors) OVER(PARTITION BY district ORDER BY year RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS lst_val,
	COUNT(year) OVER(PARTITION BY district) AS time_period
FROM 
	cte1)

SELECT  
	DISTINCT district,
    ROUND((POW((lst_val / fst_val), (1 / time_period)) - 1) * 100, 2) AS CAGR
FROM 
	cte2
WHERE (POW((lst_val / fst_val), (1 / time_period)) - 1) * 100 IS NOT NULL
ORDER BY 2 DESC
LIMIT 3;

-- 2.2 Top-3 foriegn districts based on compounded annual growth.
WITH cte1 AS (
SELECT 
    district, year, SUM(visitors) AS total_visitors
FROM
    for_visitors
GROUP BY 1 , 2
ORDER BY 1),
cte2 AS (
SELECT 
	*, 
	FIRST_VALUE(total_visitors) OVER(PARTITION BY district ORDER BY year RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS fst_val,
	LAST_VALUE(total_visitors) OVER(PARTITION BY district ORDER BY year RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS lst_val,
	COUNT(year) OVER(PARTITION BY district) AS time_period
FROM 
	cte1)

SELECT  
	DISTINCT district,
    ROUND((POW((lst_val / fst_val), (1 / time_period)) - 1) * 100, 2) AS CAGR
FROM 
	cte2
WHERE (POW((lst_val / fst_val), (1 / time_period)) - 1) * 100 IS NOT NULL
ORDER BY 2 DESC
LIMIT 3;


-- 3.1 Bottom-3 domestic districts based on compounded annual growth.
WITH cte1 AS (
SELECT 
    district, year, SUM(visitors) AS total_visitors
FROM
    dom_visitors
GROUP BY 1 , 2
ORDER BY 1),
cte2 AS (
SELECT 
	*, 
	FIRST_VALUE(total_visitors) OVER(PARTITION BY district ORDER BY year RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS fst_val,
	LAST_VALUE(total_visitors) OVER(PARTITION BY district ORDER BY year RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS lst_val,
	COUNT(year) OVER(PARTITION BY district) AS time_period
FROM 
	cte1)

SELECT  
	DISTINCT district,
    ROUND((POW((lst_val / fst_val), (1 / time_period)) - 1) * 100, 2) AS CAGR
FROM 
	cte2
WHERE (POW((lst_val / fst_val), (1 / time_period)) - 1) * 100 IS NOT NULL
ORDER BY 2 ASC
LIMIT 3;


-- 3.2 Bottom-3 foriegn districts based on compounded annual growth.
WITH cte1 AS (
SELECT 
    district, year, SUM(visitors) AS total_visitors
FROM
    for_visitors
GROUP BY 1 , 2
ORDER BY 1),
cte2 AS (
SELECT 
	*, 
	FIRST_VALUE(total_visitors) OVER(PARTITION BY district ORDER BY year RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS fst_val,
	LAST_VALUE(total_visitors) OVER(PARTITION BY district ORDER BY year RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS lst_val,
	COUNT(year) OVER(PARTITION BY district) AS time_period
FROM 
	cte1)

SELECT  
	DISTINCT district,
    ROUND((POW((lst_val / fst_val), (1 / time_period)) - 1) * 100, 2) AS CAGR
FROM 
	cte2
WHERE (POW((lst_val / fst_val), (1 / time_period)) - 1) * 100 IS NOT NULL
ORDER BY 2 ASC
LIMIT 3;


-- 4.1 Peak and Low season monthns for Hyderabad. (dom_visitors)


SELECT 
    district, month, ROUND(SUM(visitors) / 1000000, 2) AS total_visitors
FROM
    dom_visitors
WHERE
    district = 'Hyderabad'
GROUP BY district, month;


-- 4.2 Peak and Low season monthns for Hyderabad. (for_visitors)


SELECT 
    district, month, SUM(visitors) AS total_visitors
FROM
    for_visitors
WHERE
    district = 'Hyderabad'
GROUP BY district , month;


-- 5. Top & Bottom 3 districts with domestic-foreign tourist ratio. 

SELECT 
    d.district,
    ROUND(SUM(d.visitors) / SUM(f.visitors), 2) AS ratio
FROM
    dom_visitors d
        JOIN
    for_visitors f ON d.district = f.district
GROUP BY d.district
HAVING (SUM(d.visitors) != 0
    AND SUM(f.visitors) != 0)
ORDER BY 2 DESC
LIMIT 3;

SELECT 
    d.district,
    ROUND(SUM(d.visitors) / SUM(f.visitors), 2) AS ratio
FROM
    dom_visitors d
        JOIN
    for_visitors f ON d.district = f.district
GROUP BY d.district
HAVING (SUM(d.visitors) != 0
    AND SUM(f.visitors) != 0)
ORDER BY 2
LIMIT 3;

-- 6.1 Tourist to Popupation Footfall Ratio (Top 5)
WITH d_visitors AS (
SELECT 
    district, SUM(visitors) AS visitors
FROM
    dom_visitors
WHERE year = 2019
GROUP BY district),
f_visitors AS  (
SELECT 
    district, SUM(visitors) AS visitors
FROM
    for_visitors
WHERE year = 2019
GROUP BY district),
total_visitors AS (
SELECT 
    d.district, (d.visitors + f.visitors) AS total_visitors_2019
FROM
    d_visitors d
        INNER JOIN
    f_visitors f ON d.district = f.district
WHERE (d.visitors + f.visitors) >= 0)

SELECT 
    dv.district,
    ROUND(dv.total_visitors_2019 / p.population, 2) AS footfall
FROM
    total_visitors dv
        JOIN
    population_data p ON dv.district = p.district
ORDER BY 2 DESC
LIMIT 5;  

-- 6.2 Tourist to Popupation Footfall Ratio (Bottom 5)

WITH d_visitors AS (
SELECT 
    district, SUM(visitors) AS visitors
FROM
    dom_visitors
WHERE year = 2019
GROUP BY district),
f_visitors AS  (
SELECT 
    district, SUM(visitors) AS visitors
FROM
    for_visitors
WHERE year = 2019
GROUP BY district),
total_visitors AS (
SELECT 
    d.district, (d.visitors + f.visitors) AS total_visitors_2019
FROM
    d_visitors d
        INNER JOIN
    f_visitors f ON d.district = f.district
WHERE (d.visitors + f.visitors) >= 0)

SELECT 
    dv.district,
    ROUND(dv.total_visitors_2019 / p.population, 2) AS footfall
FROM
    total_visitors dv
        JOIN
    population_data p ON dv.district = p.district
ORDER BY 2 ASC
LIMIT 5;  

-- 7.1 Avg growth rate of dom_visitors. 

WITH year_wise_dom_visitors AS  (
SELECT 
    district, year, SUM(visitors) as visitors
FROM
    dom_visitors
WHERE
    district = 'Hyderabad'
GROUP BY 1 , 2)

SELECT ROUND(AVG(growth_rate), 2) * 100 AS avg_growth_rate FROM (
SELECT 
	*, 
	(visitors - LAG(visitors, 1) OVER(ORDER BY year)) / (LAG(visitors, 1) OVER(ORDER BY year)) AS growth_rate
FROM 
	year_wise_dom_visitors) a
WHERE growth_rate IS NOT NULL;    

-- 7.2 Avg growth rate of for_visitors.

WITH year_wise_for_visitors AS  (
SELECT 
    district, year, SUM(visitors) as visitors
FROM
    for_visitors
WHERE
    district = 'Hyderabad'
GROUP BY 1 , 2)

SELECT ROUND(AVG(growth_rate), 2) * 100 AS avg_growth_rate FROM (
SELECT 
	*, 
	(visitors - LAG(visitors, 1) OVER(ORDER BY year)) / (LAG(visitors, 1) OVER(ORDER BY year)) AS growth_rate
FROM 
	year_wise_for_visitors) a
WHERE growth_rate IS NOT NULL;


-- Revenue Forecast

SELECT 
    year, ROUND((SUM(visitors) * 1200) / 1000000000) as total_revenue
FROM
    dom_visitors
WHERE
    district = 'Hyderabad'
GROUP BY 1;


SELECT 
    year, ROUND((SUM(visitors) * 5200) / 1000000000, 2) as total_revenue
FROM
    for_visitors
WHERE
    district = 'Hyderabad'
GROUP BY 1