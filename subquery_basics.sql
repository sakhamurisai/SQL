--subquery #####################

/*
	A subquery allows you to construict a complex query
	A subquery is nested inside another query
	typically, it's used for a calculation or logical test that provides a value or set of data to be passed into 
	the main portion of the query
	The syntax is simple. just enclose the subquery in a() and use it where needed
	can also be used after from or where 
*/

--subquery with multiple records subquery with the in operator

SELECT 
	movie_name,
	movie_lang
FROM movies
WHERE movie_id 
IN(
	SELECT movie_id
	FROM movies_revenues
	WHERE 
		revenues_domestic > 200)

-- Find all movies where domestic revenues are higher than the international revenues

SELECT *
FROM movies
WHERE movie_id
IN
(SELECT 
	movie_id
FROM movies_revenues 
WHERE revenues_domestic > revenues_international);

--subquery with joins @#####################################################

--this is teh code ei have written 

SELECT 
	first_name ,
	last_name,
	director_id 
FROM directors 
WHERE director_id 
	IN 
	(
		SELECT 
			director_id 
		FROM movies AS m
		INNER JOIN movies_revenues AS r ON m.movie_id = r.movie_id
		WHERE (revenues_domestic+revenues_international) > (SELECT AVG(revenues_domestic+revenues_international)
															FROM movies_revenues)
			AND 
			movie_lang = 'English'
	);

--this is the better version of the code where the code is not expecting the null values so we use the coalsce to change any null values to 0

SELECT 
	first_name ,
	last_name,
	director_id 
FROM directors 
WHERE director_id 
	IN 
	(
		SELECT 
			director_id 
		FROM movies AS m
		INNER JOIN movies_revenues AS r ON m.movie_id = r.movie_id
		WHERE (COALESCE(revenues_domestic, 0)+COALESCE(revenues_international, 0)) > 
				(SELECT AVG((COALESCE(revenues_domestic, 0)+COALESCE(revenues_international, 0)))
				FROM movies_revenues)
			AND 
			movie_lang = 'English'
	);


-- this is the query returninng the revenue too

SELECT
        d.director_id,
        SUM(COALESCE(r.revenues_domestic,0) + COALESCE(r.revenues_international,0)) AS "totaL_reveneues"
    FROM directors d
    INNER JOIN movies mv ON mv.director_id = d.director_id
    INNER JOIN movies_revenues r ON r.movie_id = mv.movie_id
    WHERE
        COALESCE(r.revenues_domestic,0) + COALESCE(r.revenues_international,0) >
        (
            SELECT
                AVG(COALESCE(r.revenues_domestic,0) + COALESCE(r.revenues_international,0)) as "avg_total_reveneues"
            FROM movies_revenues r
            INNER JOIN movies mv ON mv.movie_id = r.movie_id
            WHERE mv.movie_lang = 'English'
        )
    GROUP BY d.director_id
    ORDER BY 2 DESC, 1 ASC

--order entries in a union without order by 

SELECT *
FROM 
	(
		SELECT first_name,0 AS myorder,'actor' AS actor FROM actors
		UNION
		SELECT first_name,1,'director' AS director FROM directors
	)
ORDER BY myorder;

--SELECT in select statment

SELECT 
	(
		SELECT MAX(revenues_domestic) FROM movies_revenues
	);

--Corelated subqueries ###########################################################################################
--###############################################################################################################

/*
	-A corelated subquery is a subquery that contains a reference to a table (in the parent query) that
	also appears in the outer query
	-postgresql evaluates from inside to outside

*/

SELECT 
	mv1.movie_name,
	mv1.movie_lang,
	mv1.movie_length,
	mv1.age_certificate
FROM movies AS mv1
WHERE 
	mv1.movie_length > 
		(
			SELECT 
				MIN(movie_length)
			FROM movies AS mv2
			WHERE mv1.age_certificate = mv2.age_certificate
		)
ORDER BY mv1.movie_length ASC;

-- list first_name ,last_name and date of birth for the oldest actors for each gender

SELECT *
FROM actors;

SELECT 
	a1.first_name,
	a1.last_name,
	a1.date_of_birth,
	a1.gender
FROM actors AS a1
WHERE EXTRACT(YEAR FROM date_of_birth) >
		(SELECT MIN(EXTRACT(YEAR FROM date_of_birth))
		FROM actors AS a2
		WHERE a1.gender = a2.gender)
ORDER BY 4;

--using the any statment in subquery

SELECT column_list
FROM tablename
WHERE 
	column_name OPERATOR EXPRESSIon ANY (select statment)

-- using all with subquery 


SELECT column_list
FROM tablename
WHERE 
	column_name OPERATOR EXPRESSIon ALL (select statment)

--operator expressions that can be used above  =,!=,<,>,<=,>=

/* 
	With ANY, any rows with the filter criterial (coluimnname operator expression) are selected 
	With ALL, all rows returning from subquery must bea wauall to filter criterial (column operator expression)
*/

--subquery using the exists

SELECT *
FROM suppliers
WHERE EXISTS (
	SELECT *
	FROM products
	WHERE 
		unit < 100 --order by unit_price desc
		AND products.supplier_id = supplier.supplier_id
);