/*
1.
Show all customers whose last names start with T. 
Order them by first name from A-z
*/

SELECT *
FROM customer
WHERE last_name LIKE 'T%'
ORDER BY first_name;


/*
Show all customer data but only for those whose last_name begins with the letter T
Sorted alphabetically by first_name
*/

/*
2.
Show all rentals returned from 5/28/2005 to 6/1/2005
*/

SELECT *
FROM rental
WHERE return_date BETWEEN '2005-05-28' AND '2005-06-01'
—This also returns the same results
--WHERE return_date >= '2005-05-28'
--AND return_date <= '2005-06-01’;

/*
Returns 330 rentals from 5/28/2005 and 6/1/2006 with return_date data
*/

/*
3.
How would you determine which movies are rented the most?
*/
SELECT film.title, COUNT(inventory.inventory_id) AS "rental_count"
FROM rental
JOIN inventory
	ON inventory.inventory_id = rental.inventory_id
JOIN film
	ON film.film_id = inventory.film_id
GROUP BY film.title
ORDER BY COUNT(*) DESC
Limit 50

/*
This way was discussed in class, my code above also works, so I’m commenting
this out.
*/

SELECT f.title, f.film_id, COUNT(*)
FROM film f
JOIN inventory i
	ON f.film_id = i.film_id
JOIN rental r
	ON r.inventory_id = i.inventory_id
GROUP BY f.film_id
ORDER BY COUNT(*) DESC;


/* 
Table of the 50 most popular movies based on number of times rented in most to least rented.
I’m not really sure how this all works.  But I find the class example to be cleaner that what I did.
*/

/*
4.
Show how much each customer spent on movies (for all time) . Order them from least to most.
*/

SELECT payment.customer_id, customer.last_name, SUM(payment.amount)
FROM payment
JOIN customer
ON payment.customer_id = customer.customer_id
GROUP BY payment.customer_id, customer.last_name
ORDER BY SUM(amount) DESC;

/* 
6.4
Explain 

"Sort  (cost=1616.49..1652.98 rows=14596 width=41)"
"  Sort Key: (sum(payment.amount)) DESC"
"  ->  HashAggregate  (cost=424.49..606.94 rows=14596 width=41)"
"        Group Key: payment.customer_id, customer.last_name"
"        ->  Hash Join  (cost=22.48..315.02 rows=14596 width=15)"
"              Hash Cond: (payment.customer_id = customer.customer_id)"
"              ->  Seq Scan on payment  (cost=0.00..253.96 rows=14596 width=8)"
"              ->  Hash  (cost=14.99..14.99 rows=599 width=11)"
"                    ->  Seq Scan on customer  (cost=0.00..14.99 rows=599 width=11)"


	#	Node
1.	Sort
2.	Aggregate
3.	Hash Inner Join
Hash Cond: (payment.customer_id = customer.customer_id)
4.	Seq Scan on payment as payment
5.	Hash
6.	Seq Scan on customer as customer

The graph maybe made a bit more sense - like when the calls are to the database tables.
*/

/*
5.
Which actor was in the most movies in 2006 (based on this dataset)? 
Be sure to alias the actor name and count as a more descriptive name. Order the results from most to least.
*/

SELECT actor.first_name AS "Actor First Name",
actor.last_name AS "Actor Last Name", COUNT(film_actor.film_id), 
film.release_year
FROM actor
JOIN film_actor
	ON film_actor.actor_id = actor.actor_id
JOIN film
	ON film.film_id = film_actor.film_id
GROUP BY actor.first_name, actor.last_name, film.release_year
HAVING film.release_year = 2006
ORDER BY COUNT(film_actor.film_id) DESC
LIMIT 1

/*
All films where released in 2006

By LIMIT 1, I only returned the top answer, but I couldn’t use MAX without an error.


6.5 EXPLAIN

"Limit  (cost=255.69..255.69 rows=1 width=25)"
"  ->  Sort  (cost=255.69..256.01 rows=128 width=25)"
"        Sort Key: (count(film_actor.film_id)) DESC"
"        ->  HashAggregate  (cost=253.77..255.05 rows=128 width=25)"
"              Group Key: actor.first_name, actor.last_name, film.release_year"
"              ->  Hash Join  (cost=85.50..199.15 rows=5462 width=19)"
"                    Hash Cond: (film_actor.film_id = film.film_id)"
"                    ->  Hash Join  (cost=6.50..105.76 rows=5462 width=15)"
"                          Hash Cond: (film_actor.actor_id = actor.actor_id)"
"                          ->  Seq Scan on film_actor  (cost=0.00..84.62 rows=5462 width=4)"
"                          ->  Hash  (cost=4.00..4.00 rows=200 width=17)"
"                                ->  Seq Scan on actor  (cost=0.00..4.00 rows=200 width=17)"
"                    ->  Hash  (cost=66.50..66.50 rows=1000 width=8)"
"                          ->  Seq Scan on film  (cost=0.00..66.50 rows=1000 width=8)"
"                                Filter: ((release_year)::integer = 2006)"


Not really sure of any of this - but it looks like it only counted 2006 films

*/

/*
7.
What is the average rental rate per genre?
*/
SELECT ROUND(AVG(film.rental_rate), 2) AS "Average Film Rental Rate", 
category.name AS "Genre"
FROM film
JOIN film_category
	ON film_category.film_id = film.film_id
JOIN category
	ON category.category_id = film_category.category_id
GROUP BY category.name
ORDER BY category.name

/*
Rounded the rental rate to 2 decimal points to make the number look more like $x.xx
Ordered the result table alphabetically by Genre
*/

/*
8.
How many films were returned late? Early? On time?
*/

SELECT 
CASE 
	WHEN rental_duration > date_part('day', return_date - rental_date) 
	THEN 'returned early'
	WHEN rental_duration = date_part('day', return_date - rental_date)
	THEN 'returned on time'
	ELSE 'returned late' END
 	AS return_status,
	COUNT (*) AS number_of_films
FROM film f
JOIN inventory i
	ON f.film_id = i.film_id
JOIN rental r
	ON i.inventory_id = r.inventory_id
GROUP BY return_status


/*
While most films were returned early or on-time, a very significant number was returned late.

/*
9.
What categories are the most rented and what are their total sales?
*/

SELECT ca.name film_category, count(r.rental_id) times_rented,	
	SUM(p.amount) AS revenue
FROM rental r
	JOIN inventory i
		ON r.inventory_id = i.inventory_id
	JOIN film f
		ON i.film_id = f.film_id
	JOIN film_category fc
		ON f.film_id = fc.film_id
	JOIN category ca
		ON fc.category_id = ca.category_id
	JOIN payment p
		ON r.rental_id = p.rental_id
GROUP BY ca.name
ORDER BY revenue DESC, times_rented DESC;

/*
Times rented does not completely correspond to revenue generated by category.
*/

10.

CREATE VIEW return_time_status AS
SELECT 
CASE 
	WHEN rental_duration > date_part('day', return_date - rental_date) 
	THEN 'returned early'
	WHEN rental_duration = date_part('day', return_date - rental_date)
	THEN 'returned on time'
	ELSE 'returned late' END
 	AS return_status,
	COUNT (*) AS number_of_films
FROM film f
JOIN inventory i
	ON f.film_id = i.film_id
JOIN rental r
	ON i.inventory_id = r.inventory_id
GROUP BY return_status

CREATE VIEW timesrented_rev_by_cat AS
SELECT ca.name film_category, count(r.rental_id) times_rented,	
	SUM(p.amount) AS revenue
FROM rental r
	JOIN inventory i
		ON r.inventory_id = i.inventory_id
	JOIN film f
		ON i.film_id = f.film_id
	JOIN film_category fc
		ON f.film_id = fc.film_id
	JOIN category ca
		ON fc.category_id = ca.category_id
	JOIN payment p
		ON r.rental_id = p.rental_id
GROUP BY ca.name
ORDER BY revenue DESC, times_rented DESC;

