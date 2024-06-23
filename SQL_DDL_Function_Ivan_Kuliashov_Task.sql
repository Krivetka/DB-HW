-- 1

CREATE OR REPLACE VIEW sales_revenue_by_category_qtr AS
WITH date_cte AS (
	SELECT CURRENT_DATE AS date  -- I put it in a separate variable so that it would be easier to change it in the future and for debag
),
current_quarter AS (
    SELECT 
        date,
        CASE 
            WHEN EXTRACT(MONTH FROM date) IN (1, 2, 3) THEN DATE_TRUNC('quarter', date) 
            WHEN EXTRACT(MONTH FROM date) IN (4, 5, 6) THEN DATE_TRUNC('quarter', date) 
            WHEN EXTRACT(MONTH FROM date) IN (7, 8, 9) THEN DATE_TRUNC('quarter', date)
            WHEN EXTRACT(MONTH FROM date) IN (10, 11, 12) THEN DATE_TRUNC('quarter', date) 
        END AS start_date,
        CASE 
            WHEN EXTRACT(MONTH FROM date) IN (1, 2, 3) THEN DATE_TRUNC('quarter', date) + INTERVAL '2 months' + INTERVAL '29 days' 
            WHEN EXTRACT(MONTH FROM date) IN (4, 5, 6) THEN DATE_TRUNC('quarter', date) + INTERVAL '2 months' + INTERVAL '29 days' 
            WHEN EXTRACT(MONTH FROM date) IN (7, 8, 9) THEN DATE_TRUNC('quarter', date) + INTERVAL '2 months' + INTERVAL '30 days' 
            WHEN EXTRACT(MONTH FROM date) IN (10, 11, 12) THEN DATE_TRUNC('quarter', date) + INTERVAL '2 months' + INTERVAL '30 days' 
        END AS end_date
    FROM date_cte
)
SELECT 
    c.name AS category,
    SUM(p.amount) AS total_revenue
FROM 
    payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film_category fc ON i.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
JOIN current_quarter cq ON r.rental_date BETWEEN cq.start_date AND cq.end_date
GROUP BY 
    c.name
HAVING 
    SUM(p.amount) > 0;

-- 2

CREATE OR REPLACE FUNCTION get_sales_revenue_by_category_qtr(quarter_start DATE)
RETURNS TABLE (category TEXT, total_revenue NUMERIC) AS $$
BEGIN
    RETURN QUERY
    WITH current_quarter AS (
        SELECT 
            quarter_start AS start_date,
            CASE 
                WHEN EXTRACT(MONTH FROM quarter_start) IN (1, 2, 3) THEN quarter_start + INTERVAL '2 months' + INTERVAL '29 days'
                WHEN EXTRACT(MONTH FROM quarter_start) IN (4, 5, 6) THEN quarter_start + INTERVAL '2 months' + INTERVAL '29 days'
                WHEN EXTRACT(MONTH FROM quarter_start) IN (7, 8, 9) THEN quarter_start + INTERVAL '2 months' + INTERVAL '30 days'
                WHEN EXTRACT(MONTH FROM quarter_start) IN (10, 11, 12) THEN quarter_start + INTERVAL '2 months' + INTERVAL '30 days'
            END AS end_date
    )
    SELECT 
        c.name AS category,
        SUM(p.amount) AS total_revenue
    FROM 
        payment p
    JOIN rental r ON p.rental_id = r.rental_id
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film_category fc ON i.film_id = fc.film_id
    JOIN category c ON fc.category_id = c.category_id
    JOIN current_quarter cq ON r.rental_date BETWEEN cq.start_date AND cq.end_date
    GROUP BY 
        c.name
    HAVING 
        SUM(p.amount) > 0;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_sales_revenue_by_category_qtr(CURRENT_DATE);

-- 3

CREATE OR REPLACE FUNCTION new_movie(movie_title TEXT)
RETURNS VOID AS $$
DECLARE
    new_film_id INTEGER;
    klingon_language_id INTEGER;
    current_year INTEGER := EXTRACT(YEAR FROM CURRENT_DATE);
BEGIN
    SELECT language_id INTO klingon_language_id
    FROM language
    WHERE name = 'Klingon';

    IF klingon_language_id IS NULL THEN
        RAISE EXCEPTION 'Language Klingon does not exist in the language table';
    END IF;

    SELECT MAX(film_id) + 1 INTO new_film_id FROM film;

    INSERT INTO film (film_id, title, rental_rate, rental_duration, replacement_cost, release_year, language_id, last_update)
    VALUES (
        new_film_id,
        movie_title,
        4.99,
        3,
        19.99,
        current_year,
        klingon_language_id,
        CURRENT_TIMESTAMP
    );
END;
$$ LANGUAGE plpgsql;

SELECT new_movie('Pirates of the Caribbean 2024');



