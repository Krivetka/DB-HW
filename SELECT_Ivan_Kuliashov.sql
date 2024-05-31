-- ******** task 1 *********

-- using CTEs
WITH yearly_sales AS (
    SELECT
        p.staff_id,
        s.store_id,
        SUM(p.amount) AS total_revenue
    FROM
        payment p
    JOIN
        staff s ON p.staff_id = s.staff_id
    WHERE
        EXTRACT(YEAR FROM p.payment_date) = 2017
    GROUP BY
        p.staff_id, s.store_id
),
max_revenue_per_store AS (
    SELECT
        store_id,
        MAX(total_revenue) AS max_revenue
    FROM
        yearly_sales
    GROUP BY
        store_id
)
SELECT
    ys.store_id,
    st.first_name,
    st.last_name,
    ys.total_revenue
FROM
    yearly_sales ys
JOIN
    max_revenue_per_store mrs
ON
    ys.store_id = mrs.store_id AND ys.total_revenue = mrs.max_revenue
JOIN
    staff st
ON
    ys.staff_id = st.staff_id;





-- using Subqueries
SELECT
    ys.store_id,
    st.first_name,
    st.last_name,
    ys.total_revenue
FROM
    (SELECT
        p.staff_id,
        s.store_id,
        SUM(p.amount) AS total_revenue
    FROM
        payment p
    JOIN
        staff s ON p.staff_id = s.staff_id
    WHERE
        EXTRACT(YEAR FROM p.payment_date) = 2017
    GROUP BY
        p.staff_id, s.store_id) AS ys
JOIN
    (SELECT
        store_id,
        MAX(total_revenue) AS max_revenue
    FROM
        (SELECT
            p.staff_id,
            s.store_id,
            SUM(p.amount) AS total_revenue
        FROM
            payment p
        JOIN
            staff s ON p.staff_id = s.staff_id
        WHERE
            EXTRACT(YEAR FROM p.payment_date) = 2017
        GROUP BY
            p.staff_id, s.store_id) AS yearly_sales
    GROUP BY
        store_id) AS mrs
ON
    ys.store_id = mrs.store_id AND ys.total_revenue = mrs.max_revenue
JOIN
    staff st
ON
    ys.staff_id = st.staff_id;



-- ******** task 2 *********

-- using CTEs
WITH rental_counts AS (
    SELECT
        i.film_id,
        COUNT(*) AS rental_count
    FROM
        rental r
    JOIN
        inventory i ON r.inventory_id = i.inventory_id
    GROUP BY
        i.film_id
),
top_rentals AS (
    SELECT
        film_id,
        rental_count
    FROM
        rental_counts
    ORDER BY
        rental_count DESC
    LIMIT 5
),
film_ratings AS (
    SELECT
        f.film_id,
        f.title,
        f.rating,
        CASE 
            WHEN f.rating = 'G' THEN 0
            WHEN f.rating = 'PG' THEN 10
            WHEN f.rating = 'PG-13' THEN 13
            WHEN f.rating = 'R' THEN 17
            WHEN f.rating = 'NC-17' THEN 18
            ELSE 0
        END AS expected_age
    FROM
        film f
    WHERE
        f.film_id IN (SELECT film_id FROM top_rentals)
)
SELECT
    fr.title,
    tr.rental_count,
    fr.expected_age
FROM
    top_rentals tr
JOIN
    film_ratings fr ON tr.film_id = fr.film_id
ORDER BY
    tr.rental_count DESC;

-- using Subqueries
SELECT
    fr.title,
    rc.rental_count,
    fr.expected_age
FROM
    (SELECT
        i.film_id,
        COUNT(*) AS rental_count
    FROM
        rental r
    JOIN
        inventory i ON r.inventory_id = i.inventory_id
    GROUP BY
        i.film_id
    ORDER BY
        rental_count DESC
    LIMIT 5) rc
JOIN
    (SELECT
        f.film_id,
        f.title,
        f.rating,
        CASE 
            WHEN f.rating = 'G' THEN 0
            WHEN f.rating = 'PG' THEN 10
            WHEN f.rating = 'PG-13' THEN 13
            WHEN f.rating = 'R' THEN 17
            WHEN f.rating = 'NC-17' THEN 18
            ELSE 0
        END AS expected_age
    FROM
        film f) fr ON rc.film_id = fr.film_id;




-- Window Functions
WITH ranked_rentals AS (
    SELECT
        i.film_id,
        COUNT(*) AS rental_count,
        RANK() OVER (ORDER BY COUNT(*) DESC) AS rank
    FROM
        rental r
    JOIN
        inventory i ON r.inventory_id = i.inventory_id
    GROUP BY
        i.film_id
)
SELECT
    f.title,
    rr.rental_count,
    CASE 
        WHEN f.rating = 'G' THEN 0
        WHEN f.rating = 'PG' THEN 10
        WHEN f.rating = 'PG-13' THEN 13
        WHEN f.rating = 'R' THEN 17
        WHEN f.rating = 'NC-17' THEN 18
        ELSE 0
    END AS expected_age
FROM
    ranked_rentals rr
JOIN
    film f ON rr.film_id = f.film_id
ORDER BY
    rr.rental_count DESC
LIMIT 5;


-- ******** task 3 *********


-- using CTEs
WITH last_acted AS (
    SELECT
        a.actor_id,
        a.first_name,
        a.last_name,
        MAX(f.release_year) AS last_acting_year
    FROM
        actor a
    JOIN
        film_actor fa ON a.actor_id = fa.actor_id
    JOIN
        film f ON fa.film_id = f.film_id
    GROUP BY
        a.actor_id,
        a.first_name,
        a.last_name
),
current_year AS (
    SELECT EXTRACT(YEAR FROM NOW())::INT AS year
),
longest_gap AS (
    SELECT
        la.actor_id,
        la.first_name,
        la.last_name,
        la.last_acting_year,
        (cy.year - la.last_acting_year) AS years_since_last_act
    FROM
        last_acted la,
        current_year cy
)
SELECT
    actor_id,
    first_name,
    last_name,
    last_acting_year,
    years_since_last_act
FROM
    longest_gap
ORDER BY
    years_since_last_act DESC


-- using CTEs + Window Functions
WITH last_acted AS (
    SELECT
        a.actor_id,
        a.first_name,
        a.last_name,
        MAX(f.release_year) AS last_acting_year
    FROM
        actor a
    JOIN
        film_actor fa ON a.actor_id = fa.actor_id
    JOIN
        film f ON fa.film_id = f.film_id
    GROUP BY
        a.actor_id,
        a.first_name,
        a.last_name
),
current_year AS (
    SELECT EXTRACT(YEAR FROM NOW())::INT AS year
),
years_since_last_act AS (
    SELECT
        la.actor_id,
        la.first_name,
        la.last_name,
        la.last_acting_year,
        (cy.year - la.last_acting_year) AS years_since_last_act
    FROM
        last_acted la,
        current_year cy
),
ranked_gaps AS (
    SELECT
        actor_id,
        first_name,
        last_name,
        last_acting_year,
        years_since_last_act,
        RANK() OVER (ORDER BY years_since_last_act DESC) AS rank
    FROM
        years_since_last_act
)
SELECT
    actor_id,
    first_name,
    last_name,
    last_acting_year,
    years_since_last_act
FROM
    ranked_gaps
ORDER BY
    years_since_last_act DESC

