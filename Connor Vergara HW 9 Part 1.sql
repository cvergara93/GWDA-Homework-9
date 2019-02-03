USE sakila;

-- 1a. Display the first and last names of all actors from the table actor.

SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

ALTER TABLE actor ADD COLUMN `Actor Name` varchar(50);
UPDATE actor SET `Actor Name` = UPPER(CONCAT(first_name, ' ', last_name));
SELECT `Actor Name` FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

SELECT 
	actor_id,
    first_name,
    last_name
FROM actor 
WHERE first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:

SELECT
	actor_id,
    first_name,
    last_name
FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

SELECT
	actor_id,
    first_name,
    last_name
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT
	country_id,
	country 
FROM country 
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).

ALTER TABLE actor ADD COLUMN Description blob;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.

ALTER TABLE actor DROP COLUMN Description;

-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT 
	last_name,
    COUNT(last_name) AS Last_Name_Count
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors.

SELECT
	last_name,
    COUNT(last_name) AS Last_Name_Count
FROM actor
GROUP BY last_name
HAVING (COUNT(last_name) >= 2 );

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.

UPDATE actor SET first_name = 'HARPO', `Actor Name` = 'HARPO WILLIAMS'  WHERE `Actor Name` = 'GROUCHO WILLIAMS';
SELECT actor_id, first_name, last_name, `Actor Name` FROM actor WHERE `Actor Name` = 'HARPO WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.

UPDATE actor SET first_name = 'GROUCHO' WHERE first_name = 'HARPO';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

DESCRIBE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

SELECT
	first_name,
    last_name,
    address
FROM
	staff s
    INNER JOIN address a
    ON s.address_id = a.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

SELECT
	s.first_name,
    s.last_name,
    SUM(p.amount) AS Total_Sold
FROM
	staff s
    INNER JOIN payment p
    ON s.staff_id = p.staff_id
WHERE 
	payment_date LIKE '2005-08-%'
GROUP BY p.staff_id;
    
-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

SELECT 
    title AS Film_Title,
    COUNT(actor_id) AS Actor_Count
FROM
    film f
	INNER JOIN film_actor a
    ON f.film_id = a.film_id
GROUP BY title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT 
    title AS Film_Title,
    COUNT(inventory_id) AS Inventory_Count
FROM
    film f
	INNER JOIN inventory i 
    ON f.film_id = i.film_id
WHERE
    title = 'Hunchback Impossible';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:

SELECT 
    last_name,
    first_name,
    SUM(amount) AS Total_Paid
FROM
    payment p
	INNER JOIN customer c
    ON p.customer_id = c.customer_id
GROUP BY p.customer_id
ORDER BY last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

SELECT title
FROM film
WHERE language_id IN
	(SELECT language_id 
	FROM `language`
	WHERE name = 'English')
AND (title LIKE 'K%') OR (title LIKE 'Q%');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT last_name, first_name
FROM actor
WHERE actor_id IN
	(SELECT actor_id FROM film_actor
	WHERE film_id IN 
		(SELECT film_id FROM film
		WHERE title = 'Alone Trip'));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT 
    c.last_name, 
    c.first_name,
    c.email
FROM
    customer c
	INNER JOIN customer_list l
    ON c.customer_id = l.ID
WHERE
    l.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
                
SELECT 
    title
FROM
    film
WHERE
    film_id IN (
		SELECT film_id
        FROM film_category
        WHERE category_id IN (
			SELECT category_id
			FROM category
			WHERE name = 'Family'));
                    
-- 7e. Display the most frequently rented movies in descending order.

SELECT 
    f.title,
    COUNT(*) AS 'Rental_Count'
FROM
    film f,
    inventory i,
    rental r
WHERE
    f.film_id = i.film_id
	AND r.inventory_id = i.inventory_id
GROUP BY i.film_id
ORDER BY COUNT(*) DESC, f.title;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT 
    s.store_id,
    SUM(amount) AS Store_Revenue
FROM
    store s
	INNER JOIN staff st
    ON s.store_id = st.store_id
	INNER JOIN payment p
    ON p.staff_id = st.staff_id
GROUP BY s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT 
    s.store_id,
    c.city,
    co.country
FROM
    store s
	INNER JOIN address a
    ON s.address_id = a.address_id
	INNER JOIN city c 
    ON a.city_id = c.city_id
	INNER JOIN country co 
    ON c.country_id = co.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT 
    `name`,
    SUM(p.amount) AS Genre_Gross_Revenue
FROM
    category c
	INNER JOIN film_category f
    ON f.category_id = c.category_id
	INNER JOIN inventory i 
    ON f.film_id = i.film_id
	INNER JOIN rental r 
    ON r.inventory_id = i.inventory_id
	RIGHT JOIN payment p 
    ON p.rental_id = r.rental_id
GROUP BY `name`
ORDER BY Genre_Gross_Revenue DESC;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

DROP VIEW IF EXISTS Top_Five_Genres;
CREATE VIEW Top_Five_Genres AS
	SELECT 
		`name`,
		SUM(p.amount) AS Genre_Gross_Revenue
	FROM
		category c
		INNER JOIN film_category f
		ON f.category_id = c.category_id
		INNER JOIN inventory i 
		ON f.film_id = i.film_id
		INNER JOIN rental r 
		ON r.inventory_id = i.inventory_id
		RIGHT JOIN payment p 
		ON p.rental_id = r.rental_id
	GROUP BY `name`
	ORDER BY Genre_Gross_Revenue DESC;

-- 8b. How would you display the view that you created in 8a?

SELECT * FROM Top_Five_Genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW Top_Five_Games;