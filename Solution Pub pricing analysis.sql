/*1. How many pubs are located in each country?? */
SELECT country, count(pub_id) as no_of_pubs
FROM pubs
GROUP BY country;

/*2. What is the total sales amount for each pub, including the beverage price and quantity sold?*/

SELECT pub_name,  sum(price_per_unit*quantity) as Total_sales
FROM pubs
JOIN sales USING (pub_id)
JOIN beverages USING (beverage_id)
GROUP BY pub_id, pub_name;

/*3. Which pub has the highest average rating?*/

SELECT pub_id, pub_name, ROUND(AVG(rating),2) AS avg_rating
FROM ratings
JOIN pubs USING (pub_id)
GROUP BY pub_id, pub_name 
ORDER BY avg_rating DESC;

/*4. What are the top 5 beverages by sales quantity across all pubs?*/
SELECT beverage_id, beverage_name, SUM(quantity) AS Quantity
FROM sales
JOIN beverages USING (beverage_id)
GROUP BY beverage_id, beverage_name
ORDER BY Quantity desc
LIMIT 5;

/*5. How many sales transactions occurred on each date?*/
SELECT transaction_date, count(sale_id) as Num_of_Trnsctn
FROM sales
GROUP BY transaction_date
ORDER BY Num_of_Trnsctn;

/*6. Find the name of someone that had cocktails and which pub they had it in.*/
SELECT customer_name, pub_name
FROM ratings
JOIN Pubs USING (pub_id)
JOIN sales USING (pub_id)
JOIN beverages USING (beverage_id)
WHERE category = "cocktail";

/*7. What is the average price per unit for each category of beverages, excluding the category 'Spirit'?*/
SELECT category, ROUND(AVG(price_per_unit),2) AS Avg_price_per_unit
FROM beverages
WHERE category not in ("Spirit")
GROUP BY category;

/*8. Which pubs have a rating higher than the average rating of all pubs?*/
WITH Cte AS
 (
 SELECT pub_name, rating ,
 dense_rank() over(partition by pub_name order by rating desc) as d_rank
 FROM pubs
 JOIN ratings using (pub_id)
 WHERE 
 (SELECT AVG(rating) FROM ratings) < rating 
 ORDER BY rating DESC
 )
 SELECT * FROM Cte
 WHERE d_rank = 1;


/*9. What is the running total of sales amount for each pub, ordered by the transaction date?*/

WITH cte AS
(
 SELECT pub_name ,transaction_date, 
  SUM((Quantity)*(price_per_unit)) AS sales_amount
 FROM pubs
 JOIN sales USING (pub_id) 
 JOIN beverages USING (beverage_id)
 GROUP BY pub_name,transaction_date
 ) 
 SELECT * , SUM(cte.sales_amount) 
 OVER (PARTITION BY cte.pub_name ORDER BY cte.transaction_date) 
 AS running_total_of_sales_amount
 FROM cte;


/*10. For each country, what is the average price per unit of beverages in each category, and what is the overall average price per unit of beverages across all categories? */

WITH Average_price AS
(
SELECT country, category, ROUND(AVG(price_per_unit),1) AS avg_price
FROM beverages
JOIN sales USING (beverage_id)
JOIN pubs USING (pub_id)
GROUP BY country, category
),
Total_avg_price AS
(
SELECT country, ROUND(AVG(price_per_unit),1) AS total_average_price
FROM pubs
JOIN sales USING (pub_id)
JOIN beverages USING (beverage_id)
GROUP BY country
)
SELECT country, category, avg_price,
 total_average_price
FROM Average_price
JOIN total_avg_price USING (country);

/*11. For each pub, what is the percentage contribution of each category of beverages to the total sales amount, and what is the pub's overall sales amount? */

WITH category_sales_amt AS
(
SELECT pub_name , category , sum(Quantity*price_per_unit) AS catgry_sales_amount
FROM pubs
JOIN sales USING (pub_id)
JOIN beverages USING (beverage_id)
GROUP BY pub_name, category
),
 overall_sale_amt AS
 (
SELECT pub_name, sum(Quantity*price_per_unit) AS total_sales_amount
FROM pubs
JOIN sales USING (pub_id)
JOIN beverages USING (beverage_id)
GROUP BY pub_name
)
SELECT pub_name, category , catgry_sales_amount, total_sales_amount,
 round(sum(catgry_sales_amount/total_sales_amount *100),2) AS percentage_contribution_category
FROM category_sales_amt 
JOIN overall_sale_amt using(pub_name)
GROUP BY pub_name ,category; 
