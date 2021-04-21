
/* 1.	Create a new column called “status” in the 
rental table that uses a case statement 
to indicate if a film was returned late, early, or on time.
*/

SELECT r.*, 
	CASE
	WHEN rental_duration > date_part('day', return_date - rental_date) 
	THEN 'returned early'
	WHEN rental_duration = date_part('day', return_date - rental_date)
	THEN 'returned on time'
	ELSE 'returned late' END
 	AS return_status
FROM rental r
LEFT JOIN inventory i
	ON r.inventory_id = i.inventory_id
LEFT JOIN film f
	ON i.film_id = f.film_id

/*2. Show the total payment amounts for people who live in 
Kansas City or Saint Louis. */

SELECT city, sum(p.amount) AS total_revenue
FROM payment p
LEFT JOIN customer c
	ON p.customer_id = c.customer_id
LEFT JOIN address a
	ON c.address_id = a.address_id
LEFT JOIN city
	ON a.city_id = city.city_id
WHERE city.city = 'Saint Louis' or city.city = 'Kansas City'
GROUP BY city

/*
3.	How many film categories are in each category? 
Why do you think there is a table for category 
and a table for film category?
*/

SELECT count(*) num_films, name
FROM category c
LEFT JOIN film_category f
	ON c.category_id = f.category_id
GROUP BY name
ORDER BY num_films DESC

/*
There are 16 film categories:
74	"Sports"
73	"Foreign"
69	"Family"
68	"Documentary"
66	"Animation"
64	"Action"
63	"New"
62	"Drama"
61	"Sci-Fi"
61	"Games"
60	"Children"
58	"Comedy"
57	"Travel"
57	"Classics"
56	"Horror"
51	"Music"
*/


/*
There are 1000 film ids, but assigning a category is optional.

If you needed to change a film category name, 
it would be easier to do that in a smaller table instead
of changing it in every entry of film_category.

Other than that, I don't know why you might split the information up.
*/


4.	Show a roster for the staff that includes their 
email, address, city, and country (not ids)
*/

SELECT email, address, c1.city, country
FROM staff s
LEFT JOIN address a
	ON s.address_id = a.address_id
LEFT JOIN city c1
	ON a.city_id = c1.city_id
LEFT JOIN country c2
	ON c1.country_id = c2.country_id

/*
5.	Show the film_id, title, and length for the movies 
that were returned from May 15 to 31, 2005
*/

SELECT f.film_id, title, length
FROM rental r
LEFT JOIN inventory i
	ON r.inventory_id = i.inventory_id
LEFT JOIN film f
	ON i.film_id = f.film_id
WHERE return_date BETWEEN '2005-05-15' AND '2005-05-31'


/*
6.	Write a subquery to show which movies are rented
below the average price for all movies. 
*/

SELECT title, rental_rate
FROM rental r
LEFT JOIN inventory i
	USING (inventory_id)
LEFT JOIN film f
	USING (film_id)
WHERE rental_rate <(SELECT AVG(rental_rate)
					FROM inventory 
					LEFT JOIN film 
					USING (film_id) )
GROUP BY title, rental_rate
ORDER BY title

/*
7.	Write a join statement to show which moves are rented 
below the average price for all movies.
*/

SELECT title, rental_rate
FROM rental r
LEFT JOIN inventory i
	USING (inventory_id)
LEFT JOIN film f
	USING (film_id)
JOIN (SELECT AVG(rental_rate)  avg_rental_rate
	  			FROM inventory 
				LEFT JOIN film 
				USING (film_id)) AS f2
	ON f.rental_rate < f2.avg_rental_rate
GROUP BY title, rental_rate
ORDER BY title

/*
8.	Perform an explain plan on 6 and 7, 
and describe what you’re seeing and important ways they differ.



For 6)
"Sort  (cost=811.48..812.32 rows=333 width=21)"
"  Sort Key: f.title"
"  InitPlan 1 (returns $0)"
"    ->  Aggregate  (cost=170.85..170.86 rows=1 width=32)"
"          ->  Hash Left Join  (cost=76.50..159.39 rows=4581 width=6)"
"                Hash Cond: (inventory.film_id = film.film_id)"
"                ->  Seq Scan on inventory  (cost=0.00..70.81 rows=4581 width=2)"
"                ->  Hash  (cost=64.00..64.00 rows=1000 width=10)"
"                      ->  Seq Scan on film  (cost=0.00..64.00 rows=1000 width=10)"
"  ->  HashAggregate  (cost=623.35..626.68 rows=333 width=21)"
"        Group Key: f.title, f.rental_rate"
"        ->  Hash Join  (cost=172.62..596.63 rows=5343 width=21)"
"              Hash Cond: (r.inventory_id = i.inventory_id)"
"              ->  Seq Scan on rental r  (cost=0.00..310.44 rows=16044 width=4)"
"              ->  Hash  (cost=153.55..153.55 rows=1525 width=25)"
"                    ->  Hash Join  (cost=70.66..153.55 rows=1525 width=25)"
"                          Hash Cond: (i.film_id = f.film_id)"
"                          ->  Seq Scan on inventory i  (cost=0.00..70.81 rows=4581 width=6)"
"                          ->  Hash  (cost=66.50..66.50 rows=333 width=25)"
"                                ->  Seq Scan on film f  (cost=0.00..66.50 rows=333 width=25)"
"                                      Filter: (rental_rate < $0)"
"Planning Time: 0.667 ms"
"Execution Time: 23.554 ms"


For 7)

"Sort  (cost=884.51..887.01 rows=1000 width=21) (actual time=12.747..12.773 rows=326 loops=1)"
"  Sort Key: f.title"
"  Sort Method: quicksort  Memory: 49kB"
"  ->  HashAggregate  (cost=824.68..834.68 rows=1000 width=21) (actual time=11.768..11.823 rows=326 loops=1)"
"        Group Key: f.title, f.rental_rate"
"        Batches: 1  Memory Usage: 97kB"
"        ->  Hash Join  (cost=373.85..797.94 rows=5348 width=21) (actual time=4.499..9.054 rows=5652 loops=1)"
"              Hash Cond: (r.inventory_id = i.inventory_id)"
"              ->  Seq Scan on rental r  (cost=0.00..310.44 rows=16044 width=4) (actual time=0.008..1.385 rows=16044 loops=1)"
"              ->  Hash  (cost=354.77..354.77 rows=1527 width=25) (actual time=4.483..4.488 rows=1595 loops=1)"
"                    Buckets: 2048  Batches: 1  Memory Usage: 104kB"
"                    ->  Hash Join  (cost=251.53..354.77 rows=1527 width=25) (actual time=3.081..4.201 rows=1595 loops=1)"
"                          Hash Cond: (i.film_id = f.film_id)"
"                          ->  Seq Scan on inventory i  (cost=0.00..70.81 rows=4581 width=6) (actual time=0.004..0.392 rows=4581 loops=1)"
"                          ->  Hash  (cost=247.37..247.37 rows=333 width=25) (actual time=3.038..3.041 rows=341 loops=1)"
"                                Buckets: 1024  Batches: 1  Memory Usage: 28kB"
"                                ->  Nested Loop  (cost=170.85..247.37 rows=333 width=25) (actual time=2.629..2.977 rows=341 loops=1)"
"                                      Join Filter: (f.rental_rate < (avg(film.rental_rate)))"
"                                      Rows Removed by Join Filter: 659"
"                                      ->  Aggregate  (cost=170.85..170.86 rows=1 width=32) (actual time=2.614..2.616 rows=1 loops=1)"
"                                            ->  Hash Left Join  (cost=76.50..159.39 rows=4581 width=6) (actual time=0.653..2.066 rows=4581 loops=1)"
"                                                  Hash Cond: (inventory.film_id = film.film_id)"
"                                                  ->  Seq Scan on inventory  (cost=0.00..70.81 rows=4581 width=2) (actual time=0.003..0.398 rows=4581 loops=1)"
"                                                  ->  Hash  (cost=64.00..64.00 rows=1000 width=10) (actual time=0.620..0.621 rows=1000 loops=1)"
"                                                        Buckets: 1024  Batches: 1  Memory Usage: 51kB"
"                                                        ->  Seq Scan on film  (cost=0.00..64.00 rows=1000 width=10) (actual time=0.006..0.412 rows=1000 loops=1)"
"                                      ->  Seq Scan on film f  (cost=0.00..64.00 rows=1000 width=25) (actual time=0.010..0.149 rows=1000 loops=1)"
"Planning Time: 0.594 ms"
"Execution Time: 13.013 ms"

In 6 with the subquery, I'm not entirely sure what is going on, but it looks 
like the inventory and film tables are hashed together twice.  Film and
inventory are scannned twice.

In 7 with the join, there is a nested loop inner join that seems to be an extra step
 in the graphical analysis (extra node). Film and inventory are scanned twice.
There is an extra node, and this looks like more computational work.
 
However, 7 took less time than 6 and I have no idea why.  I ran both a few times
got different times for each - they were rather close to each other.
*/

/*
9.	With a window function, write a query that shows the film, 
its duration, and what percentile the duration fits into. 
This may help 
https://mode.com/sql-tutorial/sql-window-functions/#rank-and-dense_rank 
*/

SELECT film_id, title, length duration,
	NTILE(100) OVER
		(ORDER BY length)
		AS percentile_duration
FROM film

/*
10.	In under 100 words, explain what the difference is between 
set-based and procedural programming. 
Be sure to specify which sql and python are. 

Python is procedural programming and SQL is set-based programming.
In procedural programming, the language is telling the computer how to get
something (a set of procedures or instructions).  In set based programming,
the language tells us about the result or what to do and much less,
if any, about the how to get it done.  The database figures out the best way
to get the information.
*/