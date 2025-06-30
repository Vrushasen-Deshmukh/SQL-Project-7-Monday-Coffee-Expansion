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
-- 33.00.00



-- 6. Top Selling Products by City.
--    What are the top 3 selling products in each city based on sales volume?



-- 7. Customer Segmentation by City.
--    How many unique customers are there in each city who have purchased coffee products?



-- 8. Average Sale vs Rent.
--    Find each city and their average sale per customer and avg rent per customer



-- 9. Monthly Sales Growth.
--    Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).



-- 10. Market Potential Analysis.
--	   Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer