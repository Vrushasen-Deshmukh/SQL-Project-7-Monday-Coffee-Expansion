-- MONDAY COFFEE DATA ANALYSIS


SELECT * FROM city
SELECT * FROM customers
SELECT * FROM products
SELECT * FROM sales


-- 1. Coffee Consumers Count.
--    How many people in each city are estimated to consume coffee, given that 25% of the population does?
SELECT city_name,
	(population * 0.25)/1000000 AS coffee_consumers_in_millions,
	city_rank
FROM city
ORDER BY population DESC



-- 2. Total Revenue from Coffee Sales.
--	  What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
SELECT * FROM sales
SELECT * FROM city

SELECT 
	SUM(total) AS total_revenue
FROM sales
WHERE 
	YEAR(sale_date) = 2023
	AND
	DATEPART(QUARTER, sale_date) = 4;

SELECT
	ci.city_name,
	SUM(s.total) AS total_revenue
FROM sales AS s
JOIN customers AS c ON s.customer_id = c.customer_id
JOIN city AS ci ON ci.city_id = c.city_id
WHERE
	YEAR(s.sale_date) = 2023
	AND
	DATEPART(quarter, s.sale_date) = 4
GROUP BY ci.city_name
ORDER BY total_revenue DESC



-- 3. Sales Count for Each Product.
--    How many units of each coffee product have been sold?
SELECT p.product_name, COUNT(s.sale_id) AS total_orders
FROM products AS p
LEFT JOIN sales AS s ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_orders DESC



-- 4. Average Sales Amount per City.
--    What is the average sales amount per customer in each city?
SELECT
	ci.city_name,
	SUM(s.total) AS total_revenue,
	COUNT(DISTINCT s.customer_id) AS total_cx,
	ROUND(SUM(s.total)/COUNT(DISTINCT s.customer_id),3) AS avg_sale_per_cx
FROM sales AS s
JOIN customers AS c ON s.customer_id = c.customer_id
JOIN city AS ci ON ci.city_id = c.city_id
GROUP BY ci.city_name
ORDER BY total_revenue DESC


-- 5. City Population and Coffee Consumers.
--    Provide a list of cities along with their populations and estimated coffee consumers.
WITH city_table AS (
	SELECT 
		city_name,
		ROUND((population * 0.25) / 1000000.0, 2) AS coffee_consumers
	FROM city
),
customers_table AS (
	SELECT 
		ci.city_name,
		COUNT(DISTINCT c.customer_id) AS unique_cx
	FROM sales AS s
	JOIN customers AS c ON c.customer_id = s.customer_id
	JOIN city AS ci ON ci.city_id = c.city_id
	GROUP BY ci.city_name
)
SELECT 
	ct.city_name,
	ct.coffee_consumers AS coffee_consumer_in_millions,
	cust.unique_cx
FROM city_table ct
JOIN customers_table cust ON ct.city_name = cust.city_name;



-- 6. Top Selling Products by City.
--    What are the top 3 selling products in each city based on sales volume?
SELECT * 
FROM (
	SELECT 
		ci.city_name,
		p.product_name,
		COUNT(s.sale_id) AS total_orders,
		DENSE_RANK() OVER (
			PARTITION BY ci.city_name 
			ORDER BY COUNT(s.sale_id) DESC
		) AS rank
	FROM sales AS s
	JOIN products AS p ON s.product_id = p.product_id
	JOIN customers AS c ON c.customer_id = s.customer_id
	JOIN city AS ci ON ci.city_id = c.city_id
	GROUP BY ci.city_name, p.product_name
) AS t1
WHERE rank <= 3;



-- 7. Customer Segmentation by City.
--    How many unique customers are there in each city who have purchased coffee products?
SELECT * FROM products;

SELECT 
	ci.city_name,
	COUNT(DISTINCT c.customer_id) AS unique_cx
FROM city AS ci
LEFT JOIN customers AS c ON c.city_id = ci.city_id
JOIN sales AS s ON s.customer_id = c.customer_id
WHERE s.product_id IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14)
GROUP BY ci.city_name;



-- 8. Average Sale vs Rent.
--    Find each city and their average sale per customer and avg rent per customer
WITH city_table AS (
	SELECT 
		ci.city_name,
		SUM(s.total) AS total_revenue,
		COUNT(DISTINCT s.customer_id) AS total_cx,
		ROUND(
			CAST(SUM(s.total) AS decimal(18, 2)) / 
			CAST(COUNT(DISTINCT s.customer_id) AS decimal(18, 2)), 
		2) AS avg_sale_pr_cx
	FROM sales AS s
	JOIN customers AS c ON s.customer_id = c.customer_id
	JOIN city AS ci ON ci.city_id = c.city_id
	GROUP BY ci.city_name
),
city_rent AS (
	SELECT 
		city_name, 
		estimated_rent
	FROM city
)
SELECT 
	cr.city_name,
	cr.estimated_rent,
	ct.total_cx,
	ct.avg_sale_pr_cx,
	ROUND(
		CAST(cr.estimated_rent AS decimal(18, 2)) / 
		CAST(ct.total_cx AS decimal(18, 2)), 
	2) AS avg_rent_per_cx
FROM city_rent AS cr
JOIN city_table AS ct ON cr.city_name = ct.city_name
ORDER BY ct.avg_sale_pr_cx DESC;



-- 9. Monthly Sales Growth.
--    Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).
WITH monthly_sales AS (
	SELECT 
		ci.city_name,
		MONTH(s.sale_date) AS month,
		YEAR(s.sale_date) AS year,
		SUM(s.total) AS total_sale
	FROM sales AS s
	JOIN customers AS c ON c.customer_id = s.customer_id
	JOIN city AS ci ON ci.city_id = c.city_id
	GROUP BY ci.city_name, MONTH(s.sale_date), YEAR(s.sale_date)
),
growth_ratio AS (
	SELECT
		city_name,
		month,
		year,
		total_sale AS cr_month_sale,
		LAG(total_sale, 1) OVER (PARTITION BY city_name ORDER BY year, month) AS last_month_sale
	FROM monthly_sales
)
SELECT
	city_name,
	month,
	year,
	cr_month_sale,
	last_month_sale,
	ROUND(
		CAST((cr_month_sale - last_month_sale) AS decimal(18,2)) / 
		CAST(last_month_sale AS decimal(18,2)) * 100, 
	2
	) AS growth_ratio
FROM growth_ratio
WHERE last_month_sale IS NOT NULL;



-- 10. Market Potential Analysis.
--	   Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer
WITH city_table AS (
	SELECT 
		ci.city_name,
		SUM(s.total) AS total_revenue,
		COUNT(DISTINCT s.customer_id) AS total_cx,
		ROUND(
			CAST(SUM(s.total) AS decimal(18, 2)) / 
			CAST(COUNT(DISTINCT s.customer_id) AS decimal(18, 2)), 
		2) AS avg_sale_pr_cx
	FROM sales AS s
	JOIN customers AS c ON s.customer_id = c.customer_id
	JOIN city AS ci ON ci.city_id = c.city_id
	GROUP BY ci.city_name
),
city_rent AS (
	SELECT 
		city_name, 
		estimated_rent,
		ROUND(CAST(population * 0.25 AS decimal(18, 6)) / 1000000.0, 3) AS estimated_coffee_consumer_in_millions
	FROM city
)
SELECT 
	cr.city_name,
	ct.total_revenue,
	cr.estimated_rent AS total_rent,
	ct.total_cx,
	cr.estimated_coffee_consumer_in_millions,
	ct.avg_sale_pr_cx,
	ROUND(
		CAST(cr.estimated_rent AS decimal(18, 2)) / 
		CAST(ct.total_cx AS decimal(18, 2)), 
	2) AS avg_rent_per_cx
FROM city_rent AS cr
JOIN city_table AS ct ON cr.city_name = ct.city_name
ORDER BY ct.total_revenue DESC;




-- Recomendations
/* 
City 1: Pune
	1.Average rent per customer is very low.
	2.Highest total revenue.
	3.Average sales per customer is also high.

City 2: Delhi
	1.Highest estimated coffee consumers at 7.7 million.
	2.Highest total number of customers, which is 68.
	3.Average rent per customer is 330 (still under 500).

City 3: Jaipur
	1.Highest number of customers, which is 69.
	2.Average rent per customer is very low at 156.
	3.Average sales per customer is better at 11.6k.
*/