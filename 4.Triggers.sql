-- ------------TRIGGERS-----------------------

CREATE TABLE customer_copy AS
(	SELECT
	customer_id,
    store_id, 
    first_name,
    last_name,
    address_id,
    active as is_active,
    last_update 
    FROM customer
    WHERE customer_id <= 5
);
SELECT * FROM customer_copy;


CREATE TABLE film_copy AS(
	SELECT
    film_id,
    title,
    description, 
    language_id, 
    rental_duration,
    rental_rate,
    length,
    replacement_cost, 
    rating 
    FROM film
    WHERE film_id < 5
);

CREATE TABLE rental_copy AS
(	SELECT
	rental_id,
    rental_date,
    inventory_id,
    customer_id, 
    return_date,
    staff_id,
    last_update 
    FROM rental
    WHERE rental_id < 5
);

CREATE TABLE payment_copy AS(
	SELECT 
    payment_id, 
    customer_id,
    staff_id,
    rental_id,
    amount,
    payment_date,
    last_update 
    FROM payment
    WHERE rental_id < 8
);


SELECT * FROM payment_copy;

SELECT * FROM film_copy;





-- *******************************************
-- -------------QUESTION 41-------------------
-- *******************************************

-- 41.Create a trigger that automatically sets a default value for the active column 
-- in the customer table to 1 (active) whenever a new customer record is inserted, if the
-- value is not provided. This ensures that all new customers are marked as active by default
DELIMITER //
CREATE TRIGGER set_customer_active 
BEFORE INSERT ON customer_copy
FOR EACH ROW
BEGIN
	IF NEW.is_active IS NULL THEN
		SET NEW.is_active = 1;
	END IF;
END //
DELIMITER ;

INSERT INTO customer_copy (customer_id,store_id,first_name,last_name,address_id)
VALUES (6,2,"Vasif", "Asadov", 12); 

SELECT * FROM customer_copy;





-- *******************************************
-- -------------QUESTION 42-------------------
-- *******************************************
-- 42. Create a trigger that automatically capitalizes the first name of a customer 
-- before it is inserted into the customer table.
-- This ensures that all first names follow a consistent format

DELIMITER //
CREATE TRIGGER capitalize_first_name 
BEFORE INSERT ON customer_copy
FOR EACH ROW
BEGIN
	SET NEW.first_name = CONCAT(UPPER(LEFT(NEW.first_name,1)), LOWER(SUBSTRING(NEW.first_name,2))),
	NEW.last_name = CONCAT(UPPER(LEFT(NEW.last_name,1)), LOWER(SUBSTRING(NEW.last_name,2)));
END //
DELIMITER ;

INSERT INTO customer_copy (customer_id,store_id,first_name,last_name,address_id,is_active)
VALUES (7,1,"aGaMIRza", "fataliYEV", 13, 0);





-- *******************************************
-- -------------QUESTION 43-------------------
-- *******************************************

-- 43.	Create a trigger that logs every new customer added to the 
-- customer table into a customer_log table. The log should record the 
-- customer ID, first name, last name, and the date when the record was inserted


CREATE TABLE customer_log(
	log_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //
CREATE TRIGGER customer_log_info 
AFTER INSERT ON customer_copy
FOR EACH ROW 
BEGIN
	INSERT INTO customer_log (customer_id,first_name,last_name)
    VALUES (NEW.customer_id, NEW.first_name, NEW.last_name) ; 
END //
DELIMITER ;

INSERT INTO customer_copy(customer_id,store_id,first_name,last_name,address_id)
    VALUES (1828, 1, "hAsan", "mucteba",23);

select * from customer_log;





-- *******************************************
-- -------------QUESTION 44-------------------
-- *******************************************

-- 44.	Create a trigger that logs every time a film's rental rate 
-- is increased in the film table. The trigger should store the film ID,
-- old rental rate, new rental rate, and the date of the change into a rental_rate_log table

CREATE TABLE rental_rate_log (
	rental_log_id INT AUTO_INCREMENT PRIMARY KEY,
	film_id INT,
    old_rental_rate DECIMAL(4,2),
    new_rental_rate DECIMAL(4,2),
    date_of_change DATETIME DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //
CREATE TRIGGER store_rental_rate_changes
BEFORE UPDATE ON film_copy
FOR EACH ROW
BEGIN
	INSERT INTO rental_rate_log (film_id, old_rental_rate,new_rental_rate)
    VALUES(NEW.film_id, OLD.rental_rate, NEW.rental_rate);
END //
DELIMITER ;

SELECT * FROM rental_rate_log;
SELECT * FROM film_copy;

UPDATE film_copy 
SET rental_rate = 1.99
WHERE film_id = 1;



-- *******************************************
-- -------------QUESTION 45-------------------
-- *******************************************

-- 45.Create a trigger that automatically updates the last_update column
--  in the customer table every time a customer's record is updated.
-- This ensures that the last_update field always reflects the most recent change to the customer's information.

DELIMITER //
CREATE TRIGGER monitor_last_update
BEFORE UPDATE ON customer_copy
FOR EACH ROW
BEGIN
    SET NEW.last_update = NOW();
END // 
DELIMITER ;

UPDATE customer_copy 
SET store_id = 5
WHERE customer_id = 7;


DROP TRIGGER monitor_last_update;
SELECT * FROM customer_copy;






-- *******************************************
-- -------------QUESTION 46-------------------
-- *******************************************

-- 46.	Create a trigger that logs deletions from the rental table. 
-- When a record is deleted, the trigger should insert a record into a 
-- rental_deletions_log table with details such as the rental ID, 
-- deletion date, and the staff ID who performed the deletion

CREATE TABLE rental_deletions_log (
	deletion_id INT AUTO_INCREMENT PRIMARY KEY,
    rental_id INT,
    deletion_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    staff_id INT    
);


delimiter //
CREATE TRIGGER store_deletions 
AFTER DELETE ON rental_copy
FOR EACH ROW 
BEGIN
	INSERT INTO rental_deletions_log (rental_id, staff_id)
    VALUES (OLD.rental_id, OLD.staff_id);
END //
DELIMITER ;

DELETE FROM rental_copy
WHERE rental_id = 4;

SELECT * FROM rental_copy;
SELECT * FROM rental_deletions_log;



-- *******************************************
-- -------------QUESTION 47-------------------
-- *******************************************

-- 47.Create a trigger that automatically updates the return_date in the rental table 
-- when a payment is recorded in the payment table for a specific rental.
-- This trigger ensures that when a customer makes a payment,the corresponding
-- rental is marked as returned, using the current date as the return date.


INSERT INTO rental_copy 
VALUES(4,"2024-08-22 15:30:00", 5, 122, NULL, 2, "2024-08-23 00:00:00" );

DELIMITER // 
CREATE TRIGGER update_return_rate 
AFTER INSERT ON payment_copy
FOR EACH ROW 
BEGIN
	UPDATE rental_copy 
    jOIN payment_copy
		on rental_copy.rental_id = payment_copy.rental_id
    SET return_date = curdate()
    WHERE rental_copy.rental_id = NEW.rental_id;
END //

DELIMITER ;

SELECT * FROM rental_copy;
SELECT * FROM payment_copy;

INSERT INTO payment_copy 
VALUES (1828,700, 1, 3,5,NOW(),now() );






-- *******************************************
-- -------------QUESTION 48-------------------
-- *******************************************

-- 48. Create a trigger that logs any new film inserted into the 
-- film table with a rental rate above a certain threshold (e.g., $4.99).
-- The trigger should insert a record into a high_rated_films_log table with 
-- details such as the film title, rental rate, and insertion date whenever
-- a film with a high rental rate is added

CREATE TABLE high_rated_films_log(
	high_rated_films_log_id INT AUTO_INCREMENT PRIMARY KEY,
    film_title VARCHAR(100),
    rental_rate DECIMAL(4,2),
    insertion_date DATETIME DEFAULT CURRENT_TIMESTAMP
);


DELIMITER //
CREATE TRIGGER store_high_rated_films
AFTER INSERT ON film_copy
FOR EACH ROW
BEGIN
	IF NEW.rental_rate > 4.99 THEN
		INSERT INTO high_rated_films_log (film_title,rental_rate)
        VALUES (NEW.title, NEW.rental_rate);
	END IF;

END //
DELIMITER ;

SELECT * FROM high_rated_films_log;

INSERT INTO film_copy 
VALUES (1200, "Harry Potter: Azkaban Prisoner", "My Favorite Film", 1, 
	5, 5.99, 120, 15, "PG") ; 
    
INSERT INTO film_copy 
VALUES (1507, "My Daily Routine", "Pyshcological movie", 1, 
	2, 2.99, 90, 5, "G") ; 


drop trigger store_high_rated_films;








-- *******************************************
-- -------------QUESTION 49-------------------
-- *******************************************
 
-- 49.	Create a trigger that logs any changes to a customer's email address 
-- in the customer table. The trigger should capture the old email, the new email,
-- the customer ID, and the date of the change, and store this information in a 
-- customer_email_change_log table

ALTER TABLE customer_copy 
ADD COLUMN email VARCHAR(50);

SELECT * FROM customer_copy;

UPDATE customer_copy
JOIN customer
	ON customer.customer_id = customer_copy.customer_id
    AND customer.customer_id <= 7
SET customer_copy.email = customer.email;


CREATE TABLE customer_email_change_log (
	email_log_id INT AUTO_INCREMENT PRIMARY KEY,
    old_email VARCHAR(50),
    new_email VARCHAR(50),
    customer_id INT, 
    date_of_change DATETIME DEFAULT CURRENT_TIMESTAMP
);
SELECT * FROM customer_email_change_log;

DELIMITER //
CREATE TRIGGER store_email_changes
AFTER UPDATE ON customer_copy
FOR EACH ROW 
BEGIN	
	IF OLD.email != NEW.email THEN
		INSERT INTO customer_email_change_log
        (old_email, new_email, customer_id)
        VALUES (OLD.email, NEW.email, NEW.customer_id);
	END IF;
END //
DELIMITER ;


UPDATE customer_copy
SET store_id = 3
WHERE customer_id = 6;

UPDATE customer_copy
SET email = "Asad.Vasif2000@gmail.com"
WHERE customer_id = 6;

SELECT * FROM customer_copy;







