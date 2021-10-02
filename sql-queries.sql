/*QUESTION SET #1

1. Our CEO wants to increase inventory of the two most popular family categories. he following categories are considered family movies: 
Animation, Children, Classics, Comedy, Family and Music. Which two categories have the most rentals? 
Create a query that lists each movie, the film category it is classified in, and the number of times it has been rented out.
*/

SELECT c.name AS category, COUNT(r.rental_id) AS num_rentals
FROM film f
JOIN film_category fc
ON f.film_id = fc.film_id
JOIN category c
ON fc.category_id = c.category_id
JOIN inventory i
ON f.film_id = i.film_id
JOIN rental r
ON r.inventory_id = i.inventory_id
GROUP BY 1
HAVING c.name = 'Animation' OR c.name = 'Children' OR c.name = 'Classics' OR c.name = 'Comedy' OR c.name = 'Family' OR c.name = 'Music'
ORDER BY num_rentals DESC;

/*
2. Provide a table with the family-friendly film category, each of the quartiles, and the corresponding count of movies 
within each combination of film category for each corresponding rental duration category. The resulting table should have three columns:

Category
Rental length category
Count
*/
SELECT t1.category, 
	CASE WHEN t1.quarter = 1 THEN '1'
		WHEN t1.quarter = 2 THEN '2'
		WHEN t1.quarter = 3 THEN '3'
		ELSE '4' END AS quartile, 
	COUNT(*) AS count 
FROM
	(SELECT f.title AS title, c.name AS category, COUNT(r.rental_id) AS num_rentals, f.rental_duration AS rental_duration, 
	NTILE(4) OVER (ORDER BY rental_duration) AS quarter
	FROM film f
	JOIN film_category fc
	ON f.film_id = fc.film_id
	JOIN category c
	ON fc.category_id = c.category_id
	JOIN inventory i
	ON f.film_id = i.film_id
	JOIN rental r
	ON r.inventory_id = i.inventory_id
	GROUP BY 1, 2, 4
	HAVING c.name = 'Animation' OR c.name = 'Children' OR c.name = 'Classics' OR c.name = 'Comedy' OR c.name = 'Family' OR c.name = 'Music') t1
GROUP BY 1, 2
ORDER BY category, quartile;

/*
3. We want to find out how the two stores compare in their count of rental orders during every month for all the years we have data for. 
Write a query that returns the store ID for the store, the year and month and the number of rental orders each store has fulfilled for that month. 
Your table should include a column for each of the following: year, month, store ID and count of rental orders fulfilled during that month.
*/
SELECT sto.store_id, CONCAT(DATE_PART('month', r.rental_date), '/', DATE_PART('year', r.rental_date)) AS date, COUNT(r.rental_id) 
FROM store sto
JOIN staff sta
ON sto.store_id = sta.store_id
JOIN payment p
ON sta.staff_id = p.staff_id
JOIN rental r
ON r.rental_id = p.rental_id
GROUP BY 1, 2
ORDER BY count DESC;

/*
4. To try to regain our top prior customers who are no longer active, we have been asked to generate a table of inactive customers that fall 
into the top half in terms of the amount of payments they have made. Columns include, customer name, amount spent, and if they fall into the top half 
of inactive customers.
*/

SELECT t2.customer_name, 
	t2.amount_spent, 
	t2.active_cust, 
	CASE WHEN t2.half = 2 THEN 'Yes' ELSE 'No' END AS top_half 
FROM
	(SELECT t1.customer_name, 
	CASE WHEN t1.cust_active = 0 THEN 'Not Active' ELSE 'Active' END AS active_cust, t1.amount_spent, 
	t1.num_rentals, 
	NTILE(2) OVER (ORDER BY t1.amount_spent) AS half
FROM
	(SELECT CONCAT(c.first_name, ' ', c.last_name) AS customer_name, 
	c.active AS cust_active, COUNT(r.rental_id) AS num_rentals, 
	SUM(p.amount) AS amount_spent
FROM customer c
JOIN rental r
ON c.customer_id = r.customer_id
JOIN payment p
ON r.rental_id = p.rental_id
GROUP BY 1, 2) t1
WHERE t1.cust_active = 0
ORDER BY amount_spent DESC) t2
WHERE t2.half = 2;
