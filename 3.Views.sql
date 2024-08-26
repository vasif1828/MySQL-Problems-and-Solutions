-- VIEW QUESTIONS -- 

-- QUESTION 25 
-- 25.	Create a view that lists all customers 
-- who have spent more than $100 in total on rentals
CREATE VIEW rich_customers AS
	SELECT customer.first_name, 
    customer.last_name, 
    SUM(payment.amount)  AS total_payment
    FROM customer 
    JOIN payment	
		ON customer.customer_id = payment.customer_id	
	GROUP BY 1,2
    HAVING (SUM(payment.amount)  > 100)
    ORDER BY 3;
    
SELECT * FROM rich_customers;

SELECT MAX(rental.rental_date) FROM rental;

-- QUESTION 26
-- 26. Write a query that lists films rented in the last 30 days using a subquery
CREATE VIEW rentals_last_30days AS
	SELECT film_id, title, rental_date 
	FROM
		(SELECT film.film_id, film.title, rental.rental_date 
		FROM film 
		JOIN inventory 
			on inventory.film_id =  film.film_id 
		JOIN rental 
			ON rental.inventory_id = inventory.inventory_id
		ORDER BY 3 DESC) AS films
		
	WHERE datediff('2006-03-03 00:00:00',rental_date) < 30 ;

SELECT * FROM rentals_last_30days;


-- '2006-03-03 00:00:00'


-- QUESTION 27
-- 27.	Create a view that lists all available films in the inventory, 
-- including the film title, category, and store location
CREATE VIEW available_films AS
	SELECT film.title, category.name, 
    CONCAT(country.country , ", " , city.city, ", ", address.address) AS store_location
    FROM film
	JOIN film_category 
		ON film_category.film_id = film.film_id
	JOIN category 
		ON category.category_id = film_category.category_id
    JOIN inventory	
		ON film.film_id = inventory.inventory_id 
	JOIN store
		ON store.store_id = inventory.store_id
	JOIN address
		ON store.address_id = address.address_id
	JOIN city
		ON address.address_id = city.city_id
	JOIN country
		ON city.country_id = country.country_id;
    
SELECT * FROM available_films ; 



-- QUESTİON 28
-- 28.	Create a view that lists all customer first names, last names, and email addresses. 
-- This view will allow easy access to customer contact information.

CREATE VIEW customer_info AS
	SELECT customer.first_name, customer.last_name, customer.email
    FROM customer;
    
SELECT * FROM customer_info;


-- QUESTION 29
-- 29.	Create a view that displays the title 
-- and description of all films in the database. This will be useful for quickly referencing film details
CREATE VIEW film_detail AS
	SELECT title, description
	FROM film;
SELECT * FROM film_detail;

CREATE OR REPLACE VIEW film_detail AS
	SELECT film_id, title, description
    FROM film;
    

-- QUESTION 30 
-- 30.	Create a view that lists the first 
-- and last names of all actors in the database. T
-- his view will provide a simple way to retrieve actor information

CREATE VIEW actor_info AS 
	SELECT actor_id, first_name, last_name
    FROM actor;
    
SELECT * FROM actor_info;


-- QUESTION 31
-- 31. Create a view that 
-- shows the addresses of all stores in the database, 
-- including city and postal code information

CREATE VIEW store_info AS 
	SELECT 
		store_id,     
		CONCAT(country.country,", ", city.city, ", ",
			address.address, ", ", address.postal_code) AS address
	FROM store 
    JOIN address
		ON store.address_id = address.address_id
	JOIN city
		ON city.city_id = address.city_id
	JOIN country
		ON city.country_id = country.country_id
	;
    
SELECT * FROM store_info; 
        


-- QUESTION 32 
-- 32. Create a view that displays the title of each film along with the 
-- language it is available in. This view will help in quickly finding out 
-- which films are available in specific languages.

CREATE VIEW film_languages AS 
	SELECT 
		language.name,
		film.title        
	FROM film
    JOIN language 
		ON film.language_id = language.language_id;
		
SELECT * FROM film_languages;







-- QUESTION 33
-- 33.	Create a view that shows a summary of each customer's rental history. 
-- The view should include the customer's first name, last name, 
-- total number of rentals, and the total amount spent on rentals


-- how many rentals do we have for each customer
SELECT customer.first_name,  customer.last_name,
	COUNT(rental.rental_id) AS Total_Rentals
FROM customer
LEFT JOIN rental
	ON customer.customer_id = rental.customer_id
GROUP BY 1,2;


-- How much total amount spent by each customer? 
SELECT customer.first_name,  customer.last_name,
	SUM(payment.amount) AS Total_Amount_Spent
FROM customer
LEFT JOIN payment
	ON customer.customer_id = payment.customer_id
GROUP BY 1,2;


-- COMBINE THESE TWO QUERIES AS TWO SUBQUERIES
-- Solution with Subqueries
CREATE VIEW customer_rental_history AS
	SELECT customer.first_name, customer.last_name, 
			Total_Rentals,
			Total_Amount_Spent
	FROM customer

	LEFT JOIN (
			SELECT customer.customer_id, 
				COUNT(rental.rental_id) AS Total_Rentals
			FROM customer
			LEFT JOIN rental
				ON customer.customer_id = rental.customer_id
			GROUP BY 1) AS Rental_Calculation
	ON customer.customer_id = Rental_Calculation.customer_id
		
	LEFT JOIN (
			SELECT customer.customer_id,
				SUM(payment.amount) AS Total_Amount_Spent
			FROM customer
			LEFT JOIN payment
				ON customer.customer_id = payment.customer_id
			GROUP BY 1) AS Payment_Calculation
	ON customer.customer_id = Payment_Calculation.customer_id

	ORDER BY 4 DESC;
    
SELECT * FROM customer_rental_history;


-- -------SOLUTION WITH CTE --------

CREATE VIEW customer_rental_history_CTE AS 
WITH  Rental_Calculations AS (
	SELECT
	customer.customer_id,
	COUNT(rental.rental_id) AS Total_Rentals
	FROM customer
	JOIN rental
		ON customer.customer_id = rental.customer_id
	GROUP BY 1
),

Payment_Calculations AS (
	SELECT
	customer.customer_id,
	SUM(payment.amount) AS Total_Amount_Spent
	FROM customer
	JOIN payment
		ON customer.customer_id = payment.customer_id
	GROUP BY 1
)

SELECT customer.first_name,
	customer.last_name,
	Total_Rentals,
	Total_Amount_Spent

FROM customer
LEFT JOIN Rental_Calculations
	ON customer.customer_id = Rental_Calculations.customer_id
LEFT JOIN Payment_Calculations 
	ON customer.customer_id = Payment_Calculations.customer_id
ORDER BY 4 DESC;

SELECT * FROM customer_rental_history_CTE;

-- NOTE: if you will apply aggregate functions to columns
-- from the different tables, then you must firstly, apply AGGREGATION 
-- to each column in each table, separately (with subqueries or CTEs),
-- then apply join statements.
-- if you apply join, then do aggregation, multiple duplicate rows will
-- cause the wrong results in aggregation. 





-- *****************************************
-- -------- QUESTION 34 --------------------
-- *****************************************
-- 34.	Create a view that lists each film category along with the 
-- total number of films in that category and the average rental rate for films in that category

-- number_of_films calculation from the film table
-- average_rental_rate calculation from the film table
-- We will use same table for AGGREGATION, therefore one CTE is enough. 


-- Film_Calculation CTE calculates how many films are there in each category 

-- Solution with CTE ------------------
CREATE VIEW film_category_statistics AS
WITH Film_Calculation AS (
	SELECT
	category.category_id,
    COUNT(film.film_id) AS number_of_films,
    ROUND(AVG(film.rental_rate),2) AS average_rental_rate
    FROM category
	LEFT JOIN film_category
		ON film_category.category_id = category.category_id 
	LEFT JOIN film 
		ON film.film_id = film_category.film_id
	GROUP BY 1
)
SELECT category.name,
	number_of_films, 
    average_rental_rate
FROM category
JOIN Film_Calculation 
	ON category.category_id = Film_Calculation.category_id
ORDER BY number_of_films
;

SELECT * FROM film_category_statistics;
	

-- Simple Solution -- 
SELECT category.name,
	IFNULL(COUNT(film.film_id),0) AS number_of_films,
    IFNULL(AVG(film.rental_rate),0) AS average_rental_rate
    FROM category
	LEFT JOIN film_category
		ON film_category.category_id = category.category_id 
	LEFT JOIN film 
		ON film.film_id = film_category.film_id
	GROUP BY 1;
    


-- *****************************************
-- -------- QUESTION 35 --------------------
-- *****************************************

-- 35.Create a view that provides a performance summary for each staff member. 
-- The view should include the staff member's first name, last name, total rentals processed, 
-- and the total revenue generated by that staff member

-- total_rentals from rental table
-- total_revenue from payment table
-- two aggregations --> therefore use two CTEs 

-- Rental_Calculation CTE will calculate the number_of_rentals for each staff
CREATE VIEW staff_members_info AS 
WITH Rental_Calculation AS (
	SELECT staff.staff_id, 
    COUNT(rental.rental_id) AS number_of_rentals
    FROM staff
    JOIN rental
		ON rental.staff_id = staff.staff_id 
	GROUP BY 1
),
-- Revenue_Calculation CTE will calculate the total_revenue earned by each staff
Revenue_Calculation AS (
	SELECT staff.staff_id, 
    SUM(payment.amount) AS total_revenue
    FROM staff
    JOIN payment
		ON payment.staff_id = staff.staff_id 
	GROUP BY 1
)
SELECT staff.first_name, staff.last_name,
	number_of_rentals,
    total_revenue
FROM staff 
LEFT JOIN Rental_Calculation 
	ON Rental_Calculation.staff_id = staff.staff_id
LEFT JOIN Revenue_Calculation
	ON Revenue_Calculation.staff_id = staff.staff_id;

SELECT * FROM staff_members_info;



-- *****************************************
-- -------- QUESTION 36 --------------------
-- *****************************************

-- 36.	Create a view that lists all films with a rental rate above a certain threshold (e.g., $3.99). 
-- The view should include the film title, rental rate, and release year
CREATE VIEW high_rental_rated_films AS
SELECT film.title, film.rental_rate, film.release_year 
FROM film 
	WHERE film.rental_rate > 3.99
;
SELECT * FROM high_rental_rated_films;



-- *****************************************
-- -------- QUESTION 37 --------------------
-- *****************************************

-- 37.	Create a view that shows the current availability of films in the inventory. 
-- The view should include the film title, the total number of copies available,
--  and the number of copies currently rented out.


SELECT * FROM film; 
SELECT * FROM inventory;
SELECT * FROM rental ORDER BY inventory_id;

-- total_copies will be calculated by Copies_Count CTE 
-- rented_copies will be calculated by Rented_Count CTE 
-- Use the calculated results
WITH Copies_Count AS 
(	SELECT
	film.film_id, 
    
    COUNT(inventory_id) AS Total_Copies
    FROM film
    LEFT JOIN inventory
		ON inventory.film_id = film.film_id
	GROUP BY 1
),
Rented_Count AS 
(	SELECT 
	inventory.film_id,
	COUNT(rental_id) AS rented_copies
	FROM inventory 
    LEFT JOIN rental
		ON inventory.inventory_id = rental.inventory_id
        AND rental.return_date IS NULL
    GROUP BY 1
)
SELECT film.film_id,
	ifnull(Total_Copies,0) AS total_copies,
    ifnull(rented_copies,0) AS rented_copies
FROM film
LEFT JOIN Copies_Count 
	ON Copies_Count.film_id = film.film_id
LEFT JOIN Rented_Count
	ON Rented_Count.film_id = film.film_id
GROUP BY 1;
	




-- *****************************************
-- -------- QUESTION 38 --------------------
-- *****************************************

-- 38.Create a view that calculates the lifetime value of each customer. 
-- The view should include the customer's first name, last name, total number of rentals, 
-- total amount spent, and the average amount spent per rental. 
-- Additionally, include the date of the customer's first rental and their most recent rental. 
-- This view will provide a comprehensive overview of customer value and behavior over time


-- ---------Problem Analysis------------------
-- first_name, last_name --> from customer table
-- number_of_rentals --> from rental table. This will be calculated by Rental_Calculation CTE
-- total_amount_spent --> from payment table. This will be calculated by Payment_Calculation CTE
-- avg_payment_per_rental --> from payment table. This also will be calculated by Payment_Calculation CTE
-- first_rental_date --> from rental table. This will be calculated by Rental_Calculation CTE
-- last_rental_date --> from rental table. This will be calculated by Rental_Calculation CTE
-- Briefly, we should have two CTEs - Rental_Calculations and Payment_Calculations

-- Rental_Calculations will find number_of_rentals, first_rental_date and last_rental_date
-- Payment_Calculations will find total_amount_spent, avg_payment_per_rental

CREATE VIEW customer_overview AS
WITH Rental_Calculations AS 
(	SELECT
	customer.customer_id, 
    COUNT(rental.rental_id) AS number_of_rentals,
    MIN(rental.rental_date) AS first_rental_date,
    MAX(rental.rental_date) AS last_rental_date
	FROM customer
    LEFT JOIN rental
		ON rental.customer_id = customer.customer_id
	GROUP BY 1
),
Payment_Calculations AS 
(	SELECT
	customer.customer_id, 
    SUM(payment.amount) AS total_amount_spent,
    AVG(payment.amount) AS avg_payment_per_rental
    FROM customer
    LEFT JOIN payment
		ON payment.customer_id = customer.customer_id
	GROUP BY 1
)
SELECT 
    customer.first_name,
	customer.last_name, 
    number_of_rentals,
    IFNULL(total_amount_spent, 0) AS total_amount_spent,
    IFNULL(avg_payment_per_rental,0) AS avg_payment_per_rental,
    first_rental_date,
    last_rental_date
FROM customer
	LEFT JOIN Rental_Calculations
		ON customer.customer_id = Rental_Calculations.customer_id
	LEFT JOIN Payment_Calculations
		ON customer.customer_id = Payment_Calculations.customer_id
ORDER BY 4 DESC;

SELECT * FROM customer_overview;




-- *****************************************
-- -------- QUESTION 39 --------------------
-- *****************************************

-- 39. Create a view that provides detailed statistics for each film, 
-- including the title, category, total number of times rented, total revenue generated, 
-- average rental duration, and the number of distinct customers who have rented the film. 
-- The view should also include the film's replacement cost and calculate the 
-- profitability of each film by subtracting the total rental revenue from the replacement cost. 
-- This view will offer insights into the performance and profitability of each film in the inventory


-- ---------Problem Analysis------------------
-- film.title, category.name, total_rentals, total_revenue, avg_rental_duration, number_of_customers,
-- replacement_cost, profitability (total_revenue - replacement_cost)

-- film table: title, replacement_cost, avg_rental_duration
-- category: name
-- rental: total_rentals 
-- payment: total_revenue, 
-- customer: number_of_customers
-- profitability

CREATE VIEW films_detailed_statistics AS
WITH Rental_Calculations AS 
( 	SELECT 
	film.film_id,
	COUNT(rental.rental_id) AS total_rentals
    FROM film
    LEFT JOIN inventory
		ON film.film_id = inventory.film_id
	LEFT JOIN rental
		ON inventory.inventory_id = rental.inventory_id
	GROUP BY 1
),
Payment_Calculations AS (
	SELECT
	film.film_id,
    SUM(payment.amount) AS total_revenue,
	count(distinct payment.customer_id) AS number_of_customers
    FROM film
    LEFT JOIN inventory
		ON film.film_id = inventory.film_id 
	LEFT JOIN rental
		ON rental.inventory_id = inventory.inventory_id 
	LEFT JOIN payment
		ON rental.rental_id = payment.rental_id
	GROUP BY 1
)
SELECT 
	film.film_id,
	film.title, 
    category.name,
    ifnull(Rental_Calculations.total_rentals,0) as total_rentals,
    ifnull(Payment_Calculations.total_revenue,0) as total_revenue,
	film.rental_duration AS avg_rental_duration,
    ifnull(Payment_Calculations.number_of_customers,0) as number_of_customers,
    film.replacement_cost,
    ifnull(total_revenue - film.replacement_cost,0) AS profitability
FROM film
LEFT JOIN film_category 
	ON film.film_id = film_category.film_id
LEFT JOIN category 
	ON film_category.category_id = category.category_id
LEFT JOIN Rental_Calculations 
	ON Rental_Calculations.film_id = film.film_id
LEFT JOIN Payment_Calculations 
	ON Payment_Calculations.film_id = film.film_id
GROUP BY 1,2,3,4,5,6,7,8,9;
    
SELECT * FROM films_detailed_statistics;






-- *****************************************
-- -------- QUESTION 40 --------------------
-- *****************************************

-- 40.	Create a view that compares the performance of each store.
-- The view should include the store's address, total number of rentals, 
-- total revenue, the average revenue per rental, the number of distinct 
-- customers served, and the top 3 most rented films at each store. 
-- This view will allow for a side-by-side comparison of store performance 
-- and help identify trends or patterns in rental activity across different locations


-- Rental Calculation returns: total_rentals,  number_of_customers
CREATE VIEW store_detailed_statistics AS
WITH Rental_Calculations AS 
(	SELECT 
	store.store_id,
    COUNT(rental.rental_id) AS total_rentals,
    COUNT(DISTINCT rental.customer_id) AS number_of_customers
    FROM store     
    LEFT JOIN inventory
        ON inventory.store_id = store.store_id
    LEFT JOIN rental
        ON rental.inventory_id = inventory.inventory_id
	GROUP BY 1
),

-- Address Finder returns: whole address
Address_Finder AS (
	SELECT 
    store.store_id, 
    CONCAT(country.country, ", ", address.district, ", ", city.city,
			", ", address.address, ", ", address.postal_code) AS store_address
	FROM store
    JOIN address
		ON store.address_id = address.address_id 
	JOIN city
		ON address.city_id = city.city_id
	JOIN country
		ON city.country_id = country.country_id  
	GROUP BY 1
 ),

-- Payment_Calculation returns:  total_revenue
Payment_Calculation AS (
	SELECT
	store.store_id,
    SUM(payment.amount) AS total_revenue
    FROM store 
    LEFT JOIN inventory
		ON inventory.store_id = store.store_id
	LEFT JOIN rental
		ON rental.inventory_id = inventory.inventory_id
	LEFT JOIN payment
		ON payment.rental_id = rental.rental_id
	GROUP BY 1
),

Most_Rented_3_Films AS 
(	SELECT
	store.store_id,
    film.title,
    COUNT(rental.rental_id) as rental_count,
    ROW_NUMBER() OVER (PARTITION BY store.store_id ORDER BY COUNT(rental.rental_id)  DESC) AS rank_of_films
    FROM film
    LEFT JOIN inventory
		ON inventory.film_id = film.film_id
	LEFT JOIN rental
		ON rental.inventory_id = inventory.inventory_id
	LEFT JOIN store
		ON store.store_id = inventory.store_id
	GROUP BY 1,2
)

SELECT store.store_id,
	   af.store_address,
       ifnull(rc.total_rentals,0) AS total_rentals,
       ifnull(pc.total_revenue,0) total_revenue,
       ifnull(pc.total_revenue/rc.total_rentals,0) AS avg_revenue_per_rental,
       ifnull(rc.number_of_customers,0) AS number_of_customers,
       GROUP_CONCAT(mf.title ORDER BY mf.rank_of_films DESC separator ', ') AS three_most_rented_films
FROM store
	LEFT JOIN Address_Finder af
		on af.store_id = store.store_id
	LEFT JOIN Rental_Calculations rc
		on rc.store_id = store.store_id
	LEFT JOIN Payment_Calculation pc
		on pc.store_id = store.store_id
	LEFT JOIN Most_Rented_3_Films mf
		ON mf.store_id = store.store_id
        AND mf.rank_of_films <= 3
        
GROUP BY 1,2,3,4,5,6;
	
SELECT * FROM store_detailed_statistics;
       
       
       
	













































































