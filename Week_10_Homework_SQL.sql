USE sakila;

#1a
SELECT first_name, last_name
FROM actor;

#1b
ALTER TABLE actor
ADD actor_name varchar(50);

UPDATE actor SET actor_name = CONCAT(first_name, ' ', last_name);

#2a
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe';

#2b
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE '%gen%';

#2c
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE '%li%'
ORDER BY last_name, first_name;

#2d
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

#3a
ALTER TABLE `sakila`.`actor` 
CHANGE COLUMN `middle_name` `middle_name` VARCHAR(50) NULL DEFAULT NULL AFTER `actor_id`;

#3b
ALTER TABLE `sakila`.`actor`  
CHANGE COLUMN `middle_name` `middle_name` BLOB;

#3c
#ALTER TABLE "table_name" DROP COLUMN "column_name";
ALTER TABLE `sakila`.`actor`  
DROP COLUMN `middle_name`;

#4a) List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) FROM actor
WHERE last_name IN (
SELECT DISTINCT last_name
FROM actor
) group by last_name;

#4b) List last names of actors and the number of actors who have that last name, 
#but only for names that are shared by at least two actors

SELECT last_name, COUNT(last_name) FROM actor 
WHERE last_name IN 
 (SELECT last_name FROM actor 
  GROUP BY last_name HAVING COUNT(last_name) >1)
GROUP BY last_name;

#4c) Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, write a query to fix the record.
UPDATE 
    actor
SET 
    first_name= REPLACE(first_name, 'GROUCHO', 'HARPO') 
WHERE 
    first_name LIKE '%GROUCHO%';
    
#4d) Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that 
#GROUCHO was the correct name after all! In a single query, if the first name of the actor 
#is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, 
#as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE 
#THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)

UPDATE 
    actor
SET 
    first_name= REPLACE(first_name, 'HARPO', 'GRUCHO') 
WHERE 
    first_name LIKE '%HARPO%';
    
#5a) You cannot locate the schema of the address table. Which query would you use to re-create it?
CREATE SCHEMA address;

/**select *
from INFORMATION_SCHEMA.TABLES
where TABLE_NAME='address';**/


#6a) Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT staff.first_name, staff.last_name, address.address
FROM staff 
JOIN address
ON staff.address_id=address.address_id;

/**SELECT column-names
  FROM table-name1 FULL OUTER JOIN table-name2 
    ON column-name1 = column-name2
 WHERE condition**/

/**SELECT column_name(s)
FROM table1
INNER JOIN table2 ON table1.column_name = table2.column_name;**/

/**SELECT table1.column1,table1.column2,table2.column1,....
FROM table1 
FULL JOIN table2
ON table1.matching_column = table2.matching_column;**/

#6b) Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT staff.first_name, staff.last_name, payment.staff_id, SUM(payment.amount) as 'Total Amount Rung'
FROM staff 
JOIN payment
ON staff.staff_id=payment.staff_id
WHERE payment_date LIKE '2005-08%'
GROUP BY staff_id;

#6c) List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT film.title, COUNT(film.film_id) AS '# of actors'
FROM film
INNER JOIN film_actor ON film.film_id = film_actor.film_id
GROUP BY film.film_id;

/**
SELECT column_name(s)
FROM table1
INNER JOIN table2 ON table1.column_name = table2.column_name;
**/

#6d) How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT film.title, film.film_id, inventory.inventory_id
FROM film
JOIN inventory
WHERE film.film_id = inventory.film_id AND film.title = 'Hunchback Impossible';

#6e) Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
#List the customers alphabetically by last name:

SELECT customer.first_name, customer.last_name, payment.rental_id, SUM(payment.amount) AS 'total_paid'
FROM payment
JOIN customer ON customer.customer_id = payment.customer_id
GROUP BY customer.customer_id
ORDER BY last_name;

#7a) The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with 
#the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q 
#whose language is English.

SELECT title, language_id
FROM sakila.film
WHERE title LIKE 'K%' or title LIKE 'Q%';
(SELECT language_id, name
FROM language
WHERE language_id = '1');

/**
SELECT Name
FROM AdventureWorks2008R2.Production.Product
WHERE ListPrice =
    (SELECT ListPrice
     FROM AdventureWorks2008R2.Production.Product
     WHERE Name = 'Chainring Bolts' );
**/

#7b) Use subqueries to display all actors who appear in the film Alone Trip.
SELECT actor_name
FROM actor
WHERE actor_id IN
	(SELECT actor_id
	FROM film_actor
	WHERE film_id IN
		(SELECT film_id
		FROM film
		WHERE title = 'Alone Trip'));

#7c) You want to run an email marketing campaign in Canada, for which you will need the names and email addresses 
#of all Canadian customers. Use joins to retrieve this information.

SELECT customer.customer_id, customer.address_id, customer.first_name, customer.last_name, customer.email, country.country	
FROM customer
	INNER JOIN address ON customer.address_id = address.address_id
	INNER JOIN city ON address.city_id = city.city_id
	INNER JOIN country ON city.country_id = country.country_id
		WHERE country = 'Canada';

#7d) Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
#Identify all movies categorized as famiy films.

SELECT film.title
FROM category
LEFT JOIN film_category ON category.category_id = film_category.category_id 
LEFT JOIN film ON film_category.film_id = film.film_id
	WHERE name = 'Family';

#7e) Display the most frequently rented movies in descending order.
######## How do I rewrite this query to show the rented movies in descending order BY their number of times rented?? Instead of alphabetically first and then by number of times rented ####
SELECT f.film_id, f.title, COUNT(p.rental_id) AS 'Number of Rentals'
FROM film f
	JOIN inventory USING (film_id) 
    JOIN rental USING (inventory_id)
    JOIN payment p USING (rental_id)
GROUP BY f.film_id
ORDER BY 'Number of Rentals' DESC;

#7f) Write a query to display how much business, in dollars, each store brought in.
SELECT store_id, concat('$', format(SUM(p.amount), 2)) as 'Store Revenue'
FROM store
	JOIN staff USING (store_id)
	JOIN payment p USING (staff_id)
GROUP BY store_id;

#7g) Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city.city, country.country
FROM store
	JOIN address USING (address_id)
    JOIN city USING (city_id)
    JOIN country USING (country_id);

#7h) List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name, concat('$', format(SUM(p.amount),2)) AS 'Gross Revenue'
FROM film_category f
	JOIN category c USING (category_id)
	JOIN inventory USING (film_id) 
    JOIN rental USING (inventory_id)
    JOIN payment p USING (rental_id)
GROUP BY f.category_id
ORDER BY 'Gross Revenue' DESC
LIMIT 5;

#8a) In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
#Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW Top_Five_Genres AS
SELECT c.name, concat('$', format(SUM(p.amount),2)) AS 'Gross Revenue'
FROM film_category f
	JOIN category c USING (category_id)
	JOIN inventory USING (film_id) 
    JOIN rental USING (inventory_id)
    JOIN payment p USING (rental_id)
GROUP BY f.category_id
ORDER BY 'Gross Revenue' DESC
LIMIT 5;

#8b) How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;

#8c) You find that you no longer need the view top_five_genres. Write a query to delete it.
#DROP VIEW name_of_view;
DROP VIEW top_five_genres;

