-- CREATING a VIEW ################################################
--View can be a normal SELECT,SELECT with subqueries, SELCT with joins,pretty much anything you run via select made into view


CREATE OR REPLACE VIEW v_movie_quick AS
SELECT 
	movie_name,
	movie_lang,
	release_date
FROM movies
ORDER BY release_date;

-- creating a view using a join in select statment

CREATE OR REPLACE VIEW v_movie_directors AS
SELECT 
	m.movie_id,
	m.movie_name,
	m.movie_length,
	m.movie_lang,
	m.age_certificate,
	m.release_date,
	m.director_id,
	
	d.first_name,
	d.last_name,
	d.date_of_birth,
	d.nationality
	
FROM movies AS m
LEFT JOIN directors AS d ON m.director_id = d.director_id;


--rename a view

ALTER VIEW v_movie_quick RENAME TO v_movie_r;

--Delete a view

DROP VIEW v_movie_r;


--CREATING s view using a filter
CREATE OR REPLACE VIEW v_movies_decade_2000_2010 AS 
SELECT *
FROM movies
WHERE release_date BETWEEN '2000-01-01' AND '2010-12-31'
ORDER BY release_date ;


--querying through the view

SELECT *
FROM v_movies_decade_2000_2010;


-- CREATING a view using SELECT and UNION with multiple tables
--#########################################################################################################

CREATE OR REPLACE VIEW v_actor_director AS
SELECT first_name,last_name,'actor' AS from_table
FROM actors
UNION
SELECT first_name,last_name,'director' AS from_table
FROM directors;


SELECT *
FROM v_actor_director
WHERE first_name LIKE '%k' AND from_table = 'director';

--connecting multiple tables with a single view
--#########################################################################################################

CREATE OR REPLACE VIEW v_movies_directors_reveneue AS
SELECT 
	m.movie_id,
	m.movie_name,
	m.movie_length,
	m.movie_lang,
	m.age_certificate,
	m.release_date,
	m.director_id,
	
	d.first_name,
	d.last_name,
	d.date_of_birth,
	d.nationality,

	r.revenue_id,
	r.revenues_domestic,
	r.revenues_international
	
FROM movies AS m
INNER JOIN directors AS d ON m.director_id = d.director_id
INNER JOIN movies_revenues AS r ON r.movie_id = m.movie_id;


SELECT *
FROM v_movies_directors_reveneue
WHERE age_certificate = '12';


--changing views __ can i rearrange a column to an existing view
--###########################################################################

-- the way is to delete the exisiting view and then create a new view for re-arranging the columns

--adding a new column to a view can append anew column to a view but cann ot change an existing column

SELECT *
FROM movies_revenues;

SELECT *
FROM v_revenue;

CREATE OR REPLACE VIEW v_revenue AS
SELECT revenues_domestic,
revenues_international,
movie_id
FROM movies_revenues;



-- a regular view donot store data physically

/*
	updatable view allows you to update the data on the underlying data . However , there are some rules to 
	follow
	1. the query must have one from entry ehich can be either a table or anaother updatable view
	2.the query cannot contain ,Distinct,Group by ,With,limit,offset,union,intersect,except,having
	3.you cannot use sum,count,avg,min,max in the select selection list
	4.these operations can we use if it passes all the above three consitions insert,update,delete
*/

CREATE OR REPLACE VIEW v_u_directors AS
SELECT 
	first_name,
	last_name
FROM directors;

-- adding data to a view it will update the underlayingtable too

INSERT INTO v_u_directors (first_name,last_name)
VALUES
	('mark','anthony'),
	('daya','karunakar');

SELECT *
FROM v_u_directors;

SELECT *
FROM directors;

--deleting the records from the view it will be deleted from the underlying table

DELETE FROM v_u_directors
WHERE first_name = 'mark';

DELETE FROM v_u_directors
WHERE first_name = 'daya';

SELECT *
FROM directors;

SELECT *
FROM v_u_directors;

--updatable views using the with checkoption ##############################################################

/* with checkoption clause ensures that the changes to the base tables through the view satisfy the 
	view_defining condition it provides a good added benefits as a security measures.
*/

CREATE TABLE countries(
	country_id SERIAL PRIMARY KEY,
	country_code VARCHAR(4),
	city_name VARCHAR(100)
);

INSERT INTO countries (country_code,city_name)
VALUES
	('US','New York'),
	('US','New Jersey'),
	('UK','London');

SELECT *
FROM countries;

-- creating a simple view called v_cities_us to list all the us based cities

CREATE OR REPLACE VIEW v_cities_us AS
SELECT 
	country_id,
	country_code,
	city_name
FROM countries
WHERE country_code = 'US';

---inserting the values into the view 

INSERT INTO v_cities_us(country_code,city_name)
VALUES 
	('US','California');

-- adding the uk based locaion city to the view

INSERT INTO v_cities_us (country_code, city_name)
VALUES ('UK','Greater Manchester');

SELECT *
FROM v_cities_us;

SELECT *
FROM countries;

--updating the view with the check option #######################################################################
/*
The primary goal of WITH CHECK OPTION is to maintain data integrity and consistency when modifying data through views
that restrict the visible data.It prevents accidental or intentional modifications that violate the view's defining
conditions.

The WITH CHECK OPTION clause in PostgreSQL (and other SQL databases) is used when defining a view that is intended to be updatable.
It enforces a constraint that ensures any data modification (inserts or updates) performed through the view must result in rows
that are still visible through the view itself.

*/

CREATE OR REPLACE VIEW v_cities_us AS
SELECT 
	country_id,
	country_code,
	city_name
FROM countries
WHERE country_code = 'US'
WITH CHECK OPTION;

--now trying to ad the uk based city leeds

INSERT INTO v_cities_us (country_code,city_name)
VALUES ('UK','Leeds'); -- it is working

--lets try the update operation on views

SELECT *
FROM v_cities_us;

UPDATE v_cities_us
SET country_code = 'UK'
WHERE city_name = 'New York';

--lets add the us based city

INSERT INTO v_cities_us (country_code,city_name)
VALUES 
	('US','Chicago');

-- Using the local and cascaded in with check options
--lets create a new view

CREATE OR REPLACE VIEW v_cities_c AS
SELECT 
	country_id,
	country_code,
	city_name
FROM countries
WHERE 
	city_name LIKE 'C%';

SELECT *
FROM v_cities_c;

--nesting our views within views ##########################################################################


CREATE OR REPLACE VIEW v_cities_c_us AS
SELECT 
	country_id,
	country_code,
	city_name
FROM v_cities_c
WHERE 
	country_code = 'US'
WITH LOCAL CHECK OPTION;

--lets insert the data for a us city

INSERT INTO v_cities_c_us (country_code,city_name) 
VALUES ('US','Connecticut');

SELECT *
FROM v_cities_c_us;

INSERT INTO v_cities_c_us (country_code,city_name) 
VALUES ('US','Los Angles');


-- The local conditions are satisfied within the current view i.e v_cities_c_us
-- The data must be of country_code = 'US' For all data 

CREATE OR REPLACE VIEW v_cities_c_us AS
SELECT 
	country_id,
	country_code,
	city_name
FROM v_cities_c
WHERE 
	country_code = 'US'
WITH CASCADED CHECK OPTION;

--now trying to insert the data

INSERT INTO v_cities_c_us (country_code,city_name) 
VALUES ('US','Boston'); --cascades is working

INSERT INTO v_cities_c_us (country_code,city_name) 
VALUES ('US','Cincinnati');

-- With CASCADED check option clause , the postgresql checks not only the conditions for thecurrent views
--c_cities_c_us , but also all the underlying views, in this case , it is the v_cities_us

--MATERIALIZED VIEW ##############################################################################
/* 
	stores the result of a query physically and update the data periodically.

	A materialized view caches the result of a complex expensive query and then allow you to refresh this result 
	periodically

	A materialized view executes the query once and then holds onto those results for your viewing pleasure until
	you refresh the materialized again
*/


CREATE MATERIALIZED VIEW IF NOT EXISTS view_name AS 
query
WITH [NO] DATA ;


--creating a materialized view with the directors table

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_directors AS
SELECT
	first_name,
	last_name
FROM directors
WITH DATA ;


SELECT *
FROM mv_directors;

--creating a materialized view without the data

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_directors_no_data AS
SELECT
	first_name,
	last_name
FROM directors
WITH NO DATA ;

-- With no data, the view is flagged as unreadable. it means that you cannot query dat from theview untill you load
-- the data into the view

SELECT *
FROM mv_directors_no_data;

--droping a materialized view

DROP MATERIALIZED VIEW mat_view;

-- refreshing a materialized view

REFRESH MATERIALIZED VIEW CONCURRENTLY mat_view;

--chaniging material view data 
-- updating the materialized view

SELECT *
FROM mv_directors;

--all the crud operation must be done to the underlying table 

--how to check the materialized view is populated or not 

SELECT relispopulated FROM pg_class WHERE relname = 'mat_VIEW_NAME'

--how to refresh data in a materialized view

--pleae note that when you refresh the data for a materilized view , postgres locks the entire table therefor you cannot
--query data against it

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_directors_us AS
SELECT 
	first_name,
	last_name,
	nationality
FROM directors 
WHERE nationality = 'American'
WITH NO DATA ;


SELECT *
FROM mv_directors_us;

REFRESH MATERIALIZED VIEW mv_directors_us;

--refresh materialized view concurrently view_name
/*
	concurrently allows for the update of the materialized view without locking it;
	with concurrently option, postgresql crteates a temporary updated version of the materilized view,
	compares two versions , and performs INSERT and UPDATE only the differences
	you can query against the materialized view while it is being updated 
	one requirement for using the concurrently option is that the materialized view must have a unique index
*/

REFRESH MATERIALIZED VIEW CONCURRENTLY mv_mydata;


--list all materialized views  ####################################################

SELECT oid::regclass::text
FROm pg_class
WHERE relkind = 'm';

--listing all the materialized view without the unique index ###################################################

WITH matviews_with_no_unique_keys AS(
	SELECT c.oid,c.relname,c2.relname AS idx_name
	FROM pg_catalog.pg_class AS c,pg_catalog.pg_class AS c2, pg_catalog.pg_index AS i
	LEFT JOIN pg_catalog.pg_constraint AS con
	ON (
			conrelid = i.indrelid AND conindid = i.indexrelid AND contype IN ('p','u')

	)
	WHERE 
	c.relkind = 'm'
	AND c.oid = i.indrelid
	AND i.indexrelid = c2.oid
	AND indisunique
)

SELECT c.relname AS materialized_view_name
FROm pg_class AS c
WHERE c.relkind = 'm'
EXCEPT
SELECT mwk.relname
FROM matviews_with_no_unique_keys AS mwk;

 --1. Query whether a materialized view exists:


SELECT count(*) > 0 FROM pg_catalog.pg_class c

JOIN pg_namespace n ON n.oid = c.relnamespace

WHERE

c.relkind = 'm'

AND n.nspname = 'some_schema'

AND c.relname = 'some_mat_view';



--2. Query whether a materialized view exists:


SELECT view_definition

FROM information_schema.views

WHERE

table_schema = 'information_schema'

AND table_name = 'views';



--3. To list all materialized views:


select * from pg_matviews;

select * from pg_matviews where matviewname = 'view_name';