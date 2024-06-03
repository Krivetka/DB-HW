-- task 1
-- Remove a previously inserted film from the inventory and all corresponding rental records
WITH film_to_remove AS (
    SELECT film_id 
    FROM film 
    WHERE title = 'Pirates of the Caribbean: The Curse of the Black Pearl'
)
DELETE FROM inventory
WHERE inventory_id IN (
    SELECT inventory_id 
    FROM inventory 
    WHERE film_id IN (SELECT film_id FROM film_to_remove)
);

-- task 2
-- Remove any records related to you (as a customer) from all tables except "Customer" and "Inventory"

WITH your_customer AS (
    SELECT customer_id
    FROM customer
    WHERE first_name = 'Ivan' AND last_name = 'Kuliashov'
),
rental_ids AS (
    SELECT rental_id
    FROM rental
    WHERE customer_id = (SELECT customer_id FROM your_customer)
),
payment_ids AS (
    SELECT payment_id
    FROM payment
    WHERE customer_id = (SELECT customer_id FROM your_customer)
)

DELETE FROM payment
WHERE payment_id IN (SELECT payment_id FROM payment_ids);

DELETE FROM rental
WHERE rental_id IN (SELECT rental_id FROM rental_ids);


