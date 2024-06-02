-- task 1 
-- Choose one of your favorite films and add it to the "film" table. Fill in rental rates with 4.99 and rental durations with 2 weeks.

INSERT INTO film (
    title, 
    description, 
    release_year, 
    language_id, 
    rental_duration, 
    rental_rate, 
    length, 
    replacement_cost, 
    rating, 
    special_features, 
    last_update
)
VALUES (
    'Pirates of the Caribbean: The Curse of the Black Pearl', 
    'Blacksmith Will Turner teams up with eccentric pirate "Captain" Jack Sparrow to save his love, the governor''s daughter, from Jack''s former pirate allies, who are now undead.', 
    2003, 
    1, 
    14, 
    4.99, 
    143, 
    19.99, 
    'PG-13', 
    '{"Behind the Scenes","Deleted Scenes","Commentaries"}', 
    NOW()
);

-- task 2 
-- Add the actors who play leading roles in your favorite film to the "actor" and "film_actor" tables (three or more actors in total).

INSERT INTO actor (first_name, last_name, last_update)
VALUES
('Johnny', 'Depp', NOW()),
('Orlando', 'Bloom', NOW()),
('Keira', 'Knightley', NOW());

INSERT INTO film_actor (actor_id, film_id, last_update)
VALUES
((SELECT actor_id FROM actor WHERE first_name = 'Johnny' AND last_name = 'Depp'), 
 (SELECT film_id FROM film WHERE title = 'Pirates of the Caribbean: The Curse of the Black Pearl'), 
 NOW()),
((SELECT actor_id FROM actor WHERE first_name = 'Orlando' AND last_name = 'Bloom'), 
 (SELECT film_id FROM film WHERE title = 'Pirates of the Caribbean: The Curse of the Black Pearl'), 
 NOW()),
((SELECT actor_id FROM actor WHERE first_name = 'Keira' AND last_name = 'Knightley'), 
 (SELECT film_id FROM film WHERE title = 'Pirates of the Caribbean: The Curse of the Black Pearl'), 
 NOW());

-- task 3 
-- Add your favorite movies to any store's inventory.

WITH film_id_cte AS (
    SELECT film_id 
    FROM film 
    WHERE title = 'Pirates of the Caribbean: The Curse of the Black Pearl'
)

-- for more than just one movie, if I misunderstood the assignment
	
-- WITH film_ids_cte AS (
--     SELECT film_id 
--     FROM film 
--     WHERE title IN (
--         'Pirates of the Caribbean: The Curse of the Black Pearl',
--         'Pirates of the Caribbean: On Stranger Tides',
--         'Pirates of the Caribbean: Dead Men Tell No Tales'
--     )
-- )

INSERT INTO inventory (film_id, store_id, last_update)
SELECT film_id, 1, NOW()
FROM film_id_cte;


