-- Requête 1
SELECT first_name FROM actor;

-- Requête 
SELECT last_name FROM actor;

-- Brief Réalisez des requêtes SQL pour la direction

-- Liste des titres de films

SELECT title FROM film;

-- Nombre de films par catégorie

SELECT name, COUNT(film_id)
FROM film_category
JOIN category ON film_category.category_id = category.category_id 
GROUP BY name; 

-- Liste des films dont la durée est supérieure à 120 minutes
SELECT title, length 
FROM film
WHERE length > 120;


-- Liste des films de catégorie "Action" ou "Comedy"
SELECT title, name
FROM film_category
JOIN film ON film_category.film_id  = film.film_id 
JOIN category ON film_category.category_id = category.category_id 
WHERE name = "Action" OR name = "Comedy";


-- Nombre total de films : définissez l'alias 'nombre de film' pour la valeur calculée
SELECT COUNT(title) AS nombre_de_film 
FROM film;

-- Les notes moyennes par catégorie, JOIN = INNER JOIN
SELECT name, AVG(rental_rate) AS average_rental_rate
FROM film
JOIN film_category ON film.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id 
GROUP BY name;

-- Liste des 10 films les plus loués
SELECT title, COUNT(rental_id) AS number_locations
FROM film
JOIN inventory ON film.film_id = inventory.film_id 
JOIN rental ON inventory.inventory_id = rental.inventory_id
GROUP BY title
ORDER BY number_locations DESC
LIMIT 10;


-- Acteurs ayant joué dans le plus grand nombre de films. Liste décroissante avec le nom/prénom et le nombre de films.
SELECT first_name, last_name, COUNT(film_id) AS number_films
FROM film_actor
JOIN actor ON film_actor.actor_id = actor.actor_id 
GROUP BY film_actor.actor_id 
ORDER BY number_films DESC;

-- Revenu total généré par chaque magasin par mois pour l'année en cours. JOIN, SUM, GROUP BY, DATE functions
SELECT STRFTIME('%Y-%m', payment_date), store_id, SUM(amount)
FROM payment
JOIN rental ON payment.rental_id = rental.rental_id 
JOIN customer ON rental.customer_id = customer.customer_id
WHERE STRFTIME('%Y', payment_date) = "2005" -- "on doit mettre les guillemets car c'est variable string"
GROUP BY STRFTIME('%Y-%m', payment_date), store_id ;


-- Les clients les plus fidèles, basés sur le nombre de locations. SELECT, COUNT, GROUP BY, ORDER BY
SELECT first_name, last_name, COUNT(rental_id) AS number_of_locations
FROM rental
JOIN customer ON rental.customer_id = customer.customer_id 
GROUP BY first_name, last_name
ORDER BY number_of_locations DESC;


-- Films qui n'ont pas été loués au cours des 6 derniers mois.
SELECT title, DATE('2006-02-14', rental_date, '-6 months'), rental_date
FROM rental
JOIN inventory ON rental.inventory_id = inventory.inventory_id 
JOIN film ON inventory.film_id = film.film_id 
WHERE title NOT BETWEEN DATE('2006-02-14',rental_date,'-6 months') AND '2006-02-14'
GROUP BY title, DATE('2006-02-14', rental_date, '-6 months');


-- Le revenu total de chaque membre du personnel à partir des locations.
SELECT rental.staff_id, SUM(amount)
FROM rental
JOIN payment ON rental.rental_id = payment.rental_id 
GROUP BY rental.staff_id;


-- Catégories de films les plus populaires parmi les clients. 
SELECT name, COUNT(customer_id) AS most_popular_categories
FROM film
JOIN inventory ON film.film_id = inventory.film_id 
JOIN rental ON inventory.inventory_id = rental.inventory_id
JOIN film_category ON film.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id 
GROUP BY name
ORDER BY most_popular_categories DESC;


-- Durée moyenne entre la location d'un film et son retour. 
SELECT rental_date, return_date, AVG(JULIANDAY(return_date) - JULIANDAY(rental_date)) AS duree_moyenne_location
FROM rental;


-- Acteurs qui ont joué ensemble dans le plus grand nombre de films.Afficher l'acteur 1, l'acteur 2 et le nombre de films en
-- commun. Trier les résultats par ordre décroissant. Attention aux répétitons. (JOIN, GROUP BY, ORDER BY, Self-join)

-- Première méthode (moins simple que la deuxième)

SELECT A.actor_id AS acteur1, B.actor_id AS acteur2, COUNT(A.film_id) AS number_films
FROM film_actor A, film_actor B
WHERE A.actor_id  < B.actor_id 
AND A.film_id  = B.film_id
GROUP BY A.actor_id, B.actor_id 
ORDER BY number_films DESC;


-- Deuxième méthode (plus simple) et avec les noms
SELECT a1.first_name, a1.last_name, a2.first_name, a2.last_name, COUNT() AS number_films
FROM film_actor AS fa1
JOIN film_actor AS fa2 ON fa1.film_id = fa2.film_id 
JOIN actor AS a1 ON fa1.actor_id = a1.actor_id 
JOIN actor AS a2 on fa2.actor_id = a2.actor_id 
WHERE a1.actor_id < a2.actor_id 
GROUP BY a1.actor_id, a2.actor_id 
ORDER BY number_films DESC;

-- Clients qui ont loué des films mais n'ont pas d'autres locations dans les 30 jours qui suivent. (JOIN, WHERE, DATE functions, Sub-query)


WITH intervalle_location AS (
SELECT  r1.rental_date AS R1_date, r2.rental_date as R2_date, (JULIANDAY(DATE(r2.rental_date)) - JULIANDAY(DATE(r1.rental_date))) AS diff_date , r1.customer_id 
FROM rental r1
JOIN rental r2 ON r1.customer_id  = r2.customer_id AND DATE(r2.rental_date) > DATE(r1.rental_date )
WHERE r2.rental_date NOT BETWEEN DATE(r1.rental_date, '+15 days') AND r1.rental_date AND STRFTIME("%Y-%m",r1.rental_date) ="2005-08"
ORDER BY diff_date
)
SELECT * 
FROM intervalle_location as il
GROUP BY il.customer_id
HAVING diff_date > 15;




