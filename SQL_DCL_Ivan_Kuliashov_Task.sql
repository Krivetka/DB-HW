-- 1
CREATE USER rentaluser WITH PASSWORD 'rentalpassword';
GRANT CONNECT ON DATABASE dvdrental TO rentaluser;

-- 2
GRANT SELECT ON TABLE customer TO rentaluser;

SELECT * FROM customer;

-- 3
CREATE ROLE rental;
GRANT rental TO rentaluser;

-- 4
GRANT INSERT, UPDATE ON TABLE rental TO rental;

INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
VALUES (current_timestamp, 1, 1, NULL, 1, current_timestamp);

UPDATE rental
SET return_date = current_timestamp
WHERE rental_id = 10000;

-- 5
REVOKE INSERT ON TABLE rental FROM rental;

INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
VALUES (current_timestamp, 1, 1, NULL, 1, current_timestamp);

-- 6

DO $$
DECLARE
    first_name TEXT;
    last_name TEXT;
    role_name TEXT;
BEGIN
    SELECT c.first_name, c.last_name INTO first_name, last_name 
    FROM customer c 
    WHERE c.customer_id = 1;
    
    role_name := 'client_' || first_name || '_' || last_name;
    
    EXECUTE 'CREATE ROLE ' || role_name;
    
    EXECUTE 'GRANT CONNECT ON DATABASE dvdrental TO ' || role_name;
    
    EXECUTE 'GRANT SELECT ON TABLE customer TO ' || role_name;

    EXECUTE 'GRANT SELECT ON rental TO ' || role_name;
    EXECUTE 'GRANT SELECT ON payment TO ' || role_name;
    EXECUTE 'GRANT USAGE ON SCHEMA public TO ' || role_name;

    EXECUTE 'ALTER TABLE rental ENABLE ROW LEVEL SECURITY';
    EXECUTE 'ALTER TABLE payment ENABLE ROW LEVEL SECURITY';

    EXECUTE 'CREATE POLICY rental_policy ON rental FOR SELECT USING (customer_id = 1)';
    EXECUTE 'CREATE POLICY payment_policy ON payment FOR SELECT USING (customer_id = 1)';

    EXECUTE 'ALTER TABLE rental FORCE ROW LEVEL SECURITY';
    EXECUTE 'ALTER TABLE payment FORCE ROW LEVEL SECURITY';
END $$;


SELECT * FROM rental WHERE customer_id = 1;
SELECT * FROM payment WHERE customer_id = 1;





