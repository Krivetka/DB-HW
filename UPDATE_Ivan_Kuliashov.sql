-- task 1
-- Alter the rental duration and rental rates of the film you inserted before to three weeks and 9.99, respectively.

UPDATE film
SET rental_duration = 21, rental_rate = 9.99
WHERE title = 'Pirates of the Caribbean: The Curse of the Black Pearl';

-- task 2
-- Alter any existing customer in the database with at least 10 rental and 10 payment records. Change their personal data to yours (first name, last name, address, etc.). You can use any existing address from the "address" table. Please do not perform any updates on the "address" table, as this can impact multiple records with the same address.

WITH eligible_customers AS (
    SELECT c.customer_id
    FROM customer c
    JOIN rental r ON c.customer_id = r.customer_id
    JOIN payment p ON c.customer_id = p.customer_id
    GROUP BY c.customer_id
    HAVING COUNT(r.rental_id) >= 10 AND COUNT(p.payment_id) >= 10
    LIMIT 1
)

UPDATE customer
SET first_name = 'Ivan', 
    last_name = 'Kuliashov', 
    email = 'ivan.kuliashov@student.ehu.lt', 
    address_id = (SELECT address_id FROM address LIMIT 1)
WHERE customer_id = (SELECT customer_id FROM eligible_customers);


-- task 3
-- Change the customer's create_date value to current_date.

UPDATE customer
SET create_date = CURRENT_DATE
WHERE email = 'ivan.kuliashov@student.ehu.lt';

