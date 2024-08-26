-- -----------STORED PROCEDURE------------------------

-- ***************************************************
-- --------------- QUESTİON 50 -----------------------
-- ***************************************************

-- 50.Create a stored procedure that takes a customer's last name as 
-- an input parameter and returns all the details of customers with that last name.
-- This procedure should allow easy retrieval of customer information by their last name.
DELIMITER //
CREATE PROCEDURE customer_details (IN last_nm VARCHAR(25))
BEGIN
	DECLARE total_rentals INT;
    DECLARE total_payment INT;
    DECLARE customer_address TEXT;
    
    SELECT COUNT(rental.rental_id) 
	FROM rental 
    RIGHT JOIN customer
		ON customer.customer_id = rental.customer_id
	WHERE customer.last_name = last_nm
    INTO total_rentals;
    
    
    SELECT SUM(payment.amount)
    FROM payment
    RIGHT JOIN customer
		ON customer.customer_id = payment.customer_id
	WHERE customer.last_name = last_nm
    INTO total_payment;
    
    SELECT CONCAT(country.country, ", " , address.district,", ", city.city,
				  ", " , address.address,", " , address.postal_code)
	FROM customer 
    JOIN address 
		ON customer.address_id = address.address_id
	JOIN city
		ON city.city_id = address.city_id
	JOIN country
		ON country.country_id = city.country_id
	WHERE customer.last_name = last_nm
    INTO customer_address;
    
	SELECT 
	first_name,
    last_name, 
    customer_address,    
    ifnull(total_rentals,0) as total_rentals,
    ifnull(total_payment,0) as total_payment,
    active    
    FROM customer 
	WHERE customer.last_name = last_nm;
    
END //
DELIMITER ;

CALL customer_details("SMITH");
DROP PROCEDURE customer_details;


select * from customer;


-- ***************************************************
-- --------------- QUESTİON 51 -----------------------
-- ***************************************************

-- 51.	Create a stored procedure that takes a film category name 
-- as an input parameter and returns a list of all films in that category. 
-- The procedure should include the film title, description, and rental rate.
DELIMITER // 
CREATE PROCEDURE films_by_category (IN category_name VARCHAR(25))
BEGIN 
	SELECT film.title, 
    film.description,
    film.rental_rate
    FROM film
    JOIN film_category
		ON film.film_id = film_category.film_id
	JOIN category 
		ON category.category_id = film_category.category_id    
    WHERE category.name = category_name;

END //
DELIMITER ;

CALL films_by_category("Action");




-- ***************************************************
-- --------------- QUESTİON 52 -----------------------
-- ***************************************************
-- 52. Create a stored procedure that takes a customer ID and a new email address 
-- as input parameters and updates the email address of the specified customer. 
-- This procedure should help in easily updating customer contact information\

DELIMITER //
CREATE PROCEDURE update_customer_contact(IN cust_id INT, IN new_email VARCHAR(50))
BEGIN
	DECLARE existing_email INT;
	
    SELECT COUNT(customer_id) FROM 
    customer 
    WHERE email = new_email 
    INTO existing_email;
    
    IF existing_email > 0 THEN
		SIGNAL SQLSTATE "45000"
        SET MESSAGE_TEXT = "Email already exists";
	ELSE 
		UPDATE customer 
        SET email = new_email
        WHERE customer_id = cust_id;
	END IF;

END // 
DELIMITER ;

CALL update_customer_contact(370,"WAYNE.TRUNG@sakilacustomer.org" );
SELECT * FROM customer;


-- ***************************************************
-- --------------- QUESTİON 53 -----------------------
-- ***************************************************
DELIMITER //
CREATE PROCEDURE Rental_Count_Calculations (IN store_id INT)
BEGIN
	SELECT 
    store.store_id,
    COUNT(rental.rental_id) AS total_rentals
    FROM store
    JOIN inventory
		ON inventory.store_id = store.store_id
	JOIN rental
		ON rental.inventory_id = inventory.inventory_id
	WHERE store.store_id = store_id
    GROUP BY 1
    ;

END //

DELIMITER ;
CALL Rental_Count_Calculations(1);
DROP PROCEDURE Rental_Count_Calculations;





-- ***************************************************
-- --------------- QUESTİON 54 -----------------------
-- ***************************************************
DELIMITER //
CREATE PROCEDURE films_by_language (IN lang_id INT)
BEGIN
	SELECT 
    language.name,
    film.title
    FROM film
    JOIN language 
		ON film.language_id = language.language_id
	WHERE language.language_id = lang_id;
END // 
DELIMITER ;

CALL films_by_language(1);
DROP PROCEDURE films_by_language;




-- ***************************************************
-- --------------- QUESTİON 55 -----------------------
-- ***************************************************
DELIMITER //
CREATE PROCEDURE city_citizens (IN city_idd INT)
BEGIN
	SELECT city.city,
    COUNT(customer_id) AS number_of_citizens
    FROM city
    JOIN address 
		ON city.city_id = address.city_id
	JOIN customer
		ON customer.address_id = address.address_id
	WHERE city.city_id = city_idd
    GROUP BY 1;
END //
DELIMITER ;

CALL city_citizens(5);
DROP PROCEDURE city_citizens;





-- ***************************************************
-- --------------- QUESTİON 56 -----------------------
-- ***************************************************

DELIMITER //
CREATE PROCEDURE total_revenue_by_month (IN monthh INT, IN yearr INT )
BEGIN
	

	SELECT 
    YEAR(payment_date) as given_year,
    MONTH(payment_date) as given_month,
    SUM(amount) AS total_payment 
    FROM payment 
    WHERE YEAR(payment_date) = yearr AND 
		  MONTH(payment_date) = monthh          
	GROUP BY 1,2;
END // 
DELIMITER ;

CALL total_revenue_by_month(6,2005);  
DROP PROCEDURE total_revenue_by_month;

SELECT SUM(AMOUNT) from payment;





-- ***************************************************
-- --------------- QUESTİON 57 -----------------------
-- ***************************************************
DELIMITER //
CREATE PROCEDURE  categorize_the_customer (IN cust_id INT, OUT customer_status VARCHAR(20))
BEGIN
	DECLARE total_rentals INT;
    
    SELECT COUNT(rental.rental_id) INTO total_rentals
    FROM rental
    JOIN customer
		ON customer.customer_id = rental.customer_id
	WHERE customer.customer_id = cust_id;
    
    IF total_rentals >= 25 THEN
        SET customer_status = "VIP";
	ELSE 
		SET customer_status = "Standard" ;
	END IF;

END //
DELIMITER ;

CALL categorize_the_customer(3, @customer_status);
SELECT @customer_status;
DROP PROCEDURE categorize_the_customer;

SELECT * FROM customer_rental_history;




-- ***************************************************
-- --------------- QUESTİON 58 -----------------------
-- ***************************************************

DELIMITER //
CREATE PROCEDURE check_available_films (IN flm_id INT, OUT is_available VARCHAR(25))
BEGIN
	DECLARE all_films INT;
    DECLARE rented_films INT;
    
    SELECT 
    COUNT(inventory_id)
    FROM inventory
    WHERE inventory.film_id = flm_id
    INTO all_films ;
    
    SELECT 
    COUNT(rental.rental_id)
    FROM rental
    LEFT JOIN inventory
		ON rental.inventory_id = inventory.inventory_id
        AND rental.return_date IS NULL
    WHERE inventory.film_id = flm_id
    INTO rented_films ;
    
    IF all_films - rented_films > 0 THEN 
		SET is_available = CONCAT("Available: ",all_films - rented_films, " copies") ; 
	ELSE 
		SET is_available = "Out of stock" ;
    
    END IF;
END //

DELIMITER ;

CALL check_available_films (3,@is_available);
SELECT @is_available;
DROP PROCEDURE check_available_films;





-- ***************************************************
-- --------------- QUESTİON 59 -----------------------
-- ***************************************************
DELIMITER //
CREATE PROCEDURE customer_full_name (IN cust_id INT, OUT full_name VARCHAR(100))
BEGIN
	DECLARE fullname VARCHAR(100);
    
	SELECT 
    CONCAT(customer.first_name, " ", customer.last_name)
    INTO fullname
    FROM customer
    WHERE customer_id = cust_id;
    
    SET full_name = fullname;
END //
DELIMITER ;

CALL customer_full_name(1, @fullname);
SELECT @fullname;





-- ***************************************************
-- --------------- QUESTİON 60 -----------------------
-- ***************************************************

DELIMITER //
CREATE FUNCTION count_of_films_in_category (categ_id INT)
RETURNS VARCHAR(100)
READS SQL DATA
BEGIN 
    DECLARE nm_of_films INT;
    DECLARE result VARCHAR(100);
    
    -- Count the number of films in the given category
    SELECT COUNT(film_id) INTO nm_of_films
    FROM film_category
    WHERE category_id = categ_id;
    
    -- Create the result string
    SET result = CONCAT(nm_of_films, ' available films in category_id = ', categ_id);
    
    -- Return the result
    RETURN result;
END //

DELIMITER ;

SELECT count_of_films_in_category(1);
DROP FUNCTION count_of_films_in_category;


-- END OF THE PROJECT -- 


