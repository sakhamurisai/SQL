-- common table expression (CTE's) #####################################################################

/*
	cte is a temporaray result taken from SQL statment

	A secondary appraoch to create temporary tables for query data instead of using subqueries in a from clause

	A goog alternative of subqueries

	using the CTE's you can define one or more tables upfront with subqueries

	Unlike subqueries, CTE can be refrence multiple times in multiple places in query statment

	CTE can be used to improve readability and interpretability of the code

	CTE are non-recursive by default

	the life span of a CTE is the life span of the query

	MATERIALIZED perform a cte that materializes a temporaryresult set
	NOT MATERIALIZED Do not materialize a temporary result set (default option)

	CTE's are used to simplify the complex joins and subqueries

	Ability to create recursive queries
*/

-- creating a cte generate series from 1 to 10

WITH cte AS (
	SELECT * 
	FROM GENERATE_SERIES(1,10) AS id
)
SELECT * FROM cte;

--List all movies by director_id = 1

SELECT *
FROM movies
LIMIT 10;

WITH director_cte AS (
	SELECT *
	FROM movies
	WHERE director_id = 1
)
SELECT *
FROM director_cte;

--view all movies where leng of the movie is greater than 120

WITH movies_long AS (
	SELECT 
		movie_name,
		movie_length,
		movie_lang,
		release_date
	FROM movies
	WHERE movie_length > 120
)
SELECT *
FROM movies_long;

--combining cte with the a table #######################################################################
-- calculate total revenues for each directors

SELECT *
FROM movies_revenues;

WITH director_revenue AS (
	SELECT 
		d.director_id,
		SUM(COALESCE(revenues_domestic,0) + COALESCE(revenues_international,0)) AS total_revenue
	FROM directors AS d
	INNER JOIN movies AS m ON d.director_id = m.director_id
	INNER JOIN movies_revenues ON movies_revenues.movie_id = m.movie_id
	GROUP BY d.director_id
	)
	
SELECT 
	d.first_name,
	d.last_name,
	dr.total_revenue
FROM director_revenue AS dr
INNER JOIN directors AS d ON d.director_id = dr.director_id;


--simultaneous Delete , insert via cte ####################################

--creating a article table

CREATE TABLE articles(
	article_id SERIAL PRIMARY KEY,
	title VARCHAR(100)
);

--creating a delete article table

CREATE TABLE articles_delete AS SELECT * FROM articles LIMIT 0;

--Insert some data in the articles

INSERT INTO articles(title) 
VALUES
	('Article 1'),
	('Article 2'),
	('Article 3'),
	('Article 4'),
	('Article 5'),
	('Article 6'),
	('Article 7');

SELECT *
FROM articles;

--creating a cte to insert the data that is deleted in the article table

WITH cte_delete_articles AS
(
	DELETE FROM articles
	WHERE article_id = 1
	RETURNING *
)
INSERT INTO articles_delete 
SELECT *
FROM cte_delete_articles;

SELECT *
FROM articles_delete;

--moving one table data into another table

WITH cte AS
(
	DELETE FROM articles
	RETURNING *
)
INSERT INTO articles_delete
SELECT * FROM cte;

SELECT *
FROM articles_delete;

-- Recursive CTE ##################################################Very very important#################

/*

	cte that calls itself untill a condition is met

	can be used to work with the hierarchical data

	the traditional solution would invovle some kind of iteration, probably by means of a cursor that iterates one
	tuple at a time over the whole result set.

	the logic of recursive cte is like a for loop in programming language

	When we use CTE it is important to avoid infinete loops. these can haapen if the recursion does not end properly

	With recursive cte_name AS
	(
		 -- non recursive statemnt
		Unioin or UNION ALL
		 --recursive statment
		exist condition
	)
*/

--small example for recursive cte creating the series with the recursive cte

WITH RECURSIVE series(num) AS
(
	SELECT 10

	UNION ALL

	SELECT num + 5 FROM series
	WHERE num + 5 <= 50 -- EXIT condition
)
SELECT *
FROM series;

--parent - child relation example ###################################################################

--lets create our sample table which all conatins some heirarchical data 

CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    manager_id INTEGER REFERENCES employees(employee_id), -- Self-referencing foreign key
    department VARCHAR(50)
);

INSERT INTO employees (name, manager_id, department) VALUES
('Alice', NULL, 'CEO Office'), -- Top-level manager
('Bob', 1, 'Sales'),
('Charlie', 1, 'Marketing'),
('David', 2, 'Sales Team A'),
('Eve', 2, 'Sales Team A'),
('Frank', 3, 'Marketing Analytics'),
('Grace', 3, 'Content Creation'),
('Heidi', 4, 'Sales Representative'),
('Ivan', 4, 'Sales Representative'),
('Judy', 6, 'Analytics Specialist');

SELECT *
FROM employees;

-- creating a praent child relation ship using the recursive cte 

WITH RECURSIVE cte(name ,employee_id) AS
(
	--non - recursive statment
	SELECT 
		name :: VARCHAR AS name,
		employee_id
	FROM employees
	WHERE 
	manager_id IS NULL
	
	UNION ALL
	--recursive statment
	SELECT 
		(c.name || '->' || e.name)  AS hierachy,
		manager_id
	FROM cte AS c
	INNER JOIN employees AS e ON c.employee_id = e.manager_id
)

SELECT *
FROM cte;