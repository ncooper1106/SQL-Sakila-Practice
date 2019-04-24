-- SQL HOMEWORK

-- Grab the sakila database
use sakila;

-- 1a. Display the first and last names of all actors from the table actor.
select first_name, last_name from sakila.actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
alter table sakila.actor add column Actor_Name varchar(100);
UPDATE sakila.actor SET Actor_Name = CONCAT(first_name, ' ', last_name);

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM sakila.actor
where first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN
SELECT *
from sakila.actor
where last_name LIKE '%gen%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT *
FROM sakila.actor
WHERE last_name LIKE "%LI%"
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country   
FROM sakila.country
WHERE country IN ('Afghanistan' , 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
alter table sakila.actor add column description blob;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column
alter table sakila.actor drop column description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(last_name)
FROM sakila.actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, count(last_name) as 'Number'
FROM sakila.actor
group by last_name
having Number > 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
SET SQL_SAFE_UPDATES = 0;  -- Turn off safe updates
UPDATE sakila.actor
SET first_name = 'HARPO',
	last_name = 'WILLIAMS',
    Actor_Name = 'HARPO WILLIAMS'
WHERE Actor_Name = 'GROUCHO WILLIAMS';
    
-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE sakila.actor
SET first_name = 'GROUCHO',
    Actor_Name = 'GROUCHO WILLIAMS'
WHERE first_name = 'HARPO';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
CREATE TABLE sakila.address(
	address_id smallint(5) AUTO_INCREMENT NOT NULL,
    address varchar(50) NOT NULL,
    address2 varchar(50),
    district varchar(20),
    city_id smallint(5) NOT NULL,
    postal_code varchar(10),
    phone varchar(20),
    location geometry,
    last_update timestamp,
    primary key (address_id)
);
    
-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select s.first_name, s.last_name, a.address from sakila.staff s
join sakila.address a on (s.address_id = a.address_id);

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select s.first_name, s.last_name, sum(p.amount) as 'August 2005 Total' from sakila.staff s
join sakila.payment p on (s.staff_id = p.staff_id)
where p.payment_date between '2005-08-01' and '2005-08-31'
group by s.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select f.title, count(fa.actor_id) as 'Number of Actors' from sakila.film f
inner join sakila.film_actor fa on (f.film_id = fa.film_id)
group by f.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select f.title, count(i.inventory_id) as 'Number in Inventory' from sakila.inventory i
join sakila.film f on (f.film_id = i.film_id)
where f.title = 'Hunchback Impossible';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select c.first_name, c.last_name, sum(p.amount) as 'Total Paid' from sakila.customer c
join sakila.payment p on (c.customer_id = p.customer_id)
group by c.first_name, c.last_name
order by c.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select title from film
where 
	(title like "Q%" OR  
    title like "K%") AND
    language_id in
	(select language_id
	from language
	where name = "English")
;

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select first_name, last_name 
from actor
where actor_id in
(
    select actor_id
    from film_actor
	where film_id in
	(
		select film_id
		from film
		where title = "Alone Trip"
	)
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select cu.first_name, cu.last_name, cu.email
from sakila.customer cu
	join sakila.address a on (cu.address_id = a.address_id)
    join sakila.city c on (c.city_id = a.city_id)
    join sakila.country co on (co.country_id = c.country_id)
where co.country = "Canada";

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select f.title 
from sakila.film f
	join sakila.film_category fc on (f.film_id = fc.film_id)
    join sakila.category c on (c.category_id = fc.category_id)
where c.name = "Family";

-- 7e. Display the most frequently rented movies in descending order.
select f.title, count(r.rental_id) as 'Number of Times Rented'
from sakila.film f
	join sakila.inventory i on (i.film_id = f.film_id)
    join sakila.rental r on (r.inventory_id = i.inventory_id)
group by f.title
order by count(r.rental_id) desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select s.store_id, sum(p.amount)
from sakila.store s
	join sakila.staff st on (s.store_id = st.store_id)
    join sakila.payment p on (p.staff_id =st.staff_id)
group by s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select s.store_id, ci.city, co.country
from sakila.store s
	join sakila.address a on (a.address_id = s.address_id)
    join sakila.city ci on (ci.city_id = a.city_id)
    join sakila.country co on (co.country_id = ci.country_id);
    
--  7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select c.name, sum(p.amount)
from sakila.payment p 
	join sakila.rental r on (r.rental_id = p.rental_id)
    join sakila.inventory i on (i.inventory_id = r.inventory_id)
    join sakila.film_category fc on (fc.film_id = i.film_id)
    join sakila.category c on (c.category_id = fc.category_id)
group by c.name
order by sum(p.amount) DESC limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create view sakila.TopFiveGenres AS
	select c.name, sum(p.amount)
	from sakila.payment p 
		join sakila.rental r on (r.rental_id = p.rental_id)
		join sakila.inventory i on (i.inventory_id = r.inventory_id)
		join sakila.film_category fc on (fc.film_id = i.film_id)
		join sakila.category c on (c.category_id = fc.category_id)
	group by c.name
	order by sum(p.amount) DESC limit 5;
    
-- 8b. How would you display the view that you created in 8a?
select * from sakila.TopFiveGenres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view sakila.TopFiveGenres;