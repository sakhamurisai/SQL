--Creating a crosstabs reports  ##############################################################################

/*
	A typical relational database table contains multiple rows, quite often with duplicate values in some values in
	some columns. Data in such a table is usually stored in random order. By running a query to select data from a database
	table, you can perform filtering, sorting, grouping, selection, and other operations with data 


	Nevertheless, the results of that kind of query (data) will still be displayed downwards, which may complicate the
	analysis. Pivot tables (inverted tables) extended the data across, rather than downwad. In this way, the query results
	are much easier to perceive, compare, analyze, and filter.


	A 'pivot table' or a crosstab report is an effective technique for calculating, compiling and analyzing data bound to 
	simplify the search for patterns and trends. Pivot tables can help you aggregtate, sort , organize, reorganize, group,
	sum or average data stored in a database to understand data relations and dependecies in the best possible way.


	Pivot table/Crosstab Reports/Cross tabulation provide a simple way to summerize and compare variables by displaying them 
	in a table layout or in a matrix format.

	IN MATRIX:
		rows		represents ONE variable
		columns 	represents ANOTHER varaiable
		cell		represents where a row and column intersects to hold a value
*/



--Installing the crosstab()function ########################################################################

-- Inorder to used the cross tab function, we have to install an additional PostgreSQL extension module called 'tablefunc'

--Install the extension

CREATE EXTENSION IF NOT EXISTS tablefunc;

--confirm the extension is installed

SELECT *
FROM pg_extension;


--using the crosstab function #########################################################################

--lest create a sample table called scores

CREATE TABLE scores(
	score_id SERIAL PRIMARY KEY,
	name VARCHAR(100),
	subject VARCHAR(100),
	score NUMERIC(4,2),
	score_date DATE
);

--inserting data into the table

INSERT INTO scores(
	name,
	subject,
	score,
	score_date
)
VALUES
	('Adam','Math',10,'2020-01-01'),
	('Adam','English',8,'2020-02-01'),
	('Adam','History',7,'2020-03-01'),
	('Adam','Music',9,'2020-04-01'),
	('Linda','Math',12,'2020-01-01'),
	('Linda','English',10,'2020-02-01'),
	('Linda','History',8,'2020-03-01'),
	('Linda','Music',6,'2020-04-01');

--lets view the data 

SELECT * FROM scores;

--cross tab function syntax

SELECT * FROM crosstab
(
	$$
	select -query-expression
	$$
) AS alias -name
(
	col1 type,
	col2 type,
	....
)
/*
--The select must return 3 columns (X,Y,V)

IDENTIFIER			ROWS			Y

CATEGORIES			columns			X

VALUE 				cell			V



The first column in the SELECT will be the IDENTIFIER of every row in the pivot table or Final reult.

The second column in the SELECT represents the CATEGORIES in the pivot table

The third column in the select represents the value to be assigned to each cell of the pivot table.


*/

/*

Y:Name
X:Subject
V:score 

According to the above table

*/

--letrs build the first cross tab

SELECT * FROM crosstab
(

	$$
		SELECT 
			name,
			subject,
			score
		FROM scores
		ORDER BY 1,2
	$$
)AS ct
(
	name VARCHAR,
	English NUMERIC,
	History NUMERIC,
	Math NUMERIC,
	Music NUMERIC
);
--always check the data after pivoting because order is the most important factor and the columns how we are arranging

--EXAMING rainfall_data##############################


SELECT *
FROM rainfalls;

-- Y: location
-- X: year
-- V: SUM(raindays)


SELECT * FROM crosstab( --Always make sure the input datatype matches teh output 
  $$
    SELECT 
      location,
      year,
      SUM(raindays)::INT -- in this case after summing the datatype apperas to be big int type casted to int
    FROM rainfalls
    GROUP BY location, year
    ORDER BY location, year
  $$
) AS ct (
  location TEXT,
  "2012" INT,
  "2013" INT,
  "2014" INT,
  "2015" INT,
  "2016" INT,
  "2017" INT
);

--Matrix report via a query #######################################################################

--Nothing but pivoting using the regular select statment

SELECT 
	name,
	MIN(case
		WHEN 
			subject = 'English' THEN score END) AS English,
	MIN(case
		WHEN 
			subject = 'Math' THEN score END) AS Math,
	MIN(case
		WHEN 
			subject = 'History' THEN score END) AS History,
	MIN(case
		WHEN 
			subject = 'Music' THEN score END) AS Music

FROM scores
GROUP BY name;

--Aggregate over filter ###############################################################################

-- we can use aggregate and filter function to get our pivot table over too..

SELECT 
	location,
	SUM(raindays) FILTER (WHERE year = '2012') AS "2012",
	SUM(raindays) FILTER (WHERE year = '2013') AS "2013",
	SUM(raindays) FILTER (WHERE year = '2014') AS "2014",
	SUM(raindays) FILTER (WHERE year = '2015') AS "2015",
	SUM(raindays) FILTER (WHERE year = '2016') AS "2016",
	SUM(raindays) FILTER (WHERE year = '2017') AS "2017"
FROM rainfalls
GROUP BY location;


--static dynamic pivots ######################################################################

--static pivots
----------------

/*
	We have  seen in both the crosstab and the traditional query form have the drawback that the;

		- Output columns must be explicitly enumerated
		- They must be added manually to the list

	These queries also lack flexibility;

		-To change the order of the columns, or transpose a different column of the source data (for instance have 
		 cities on the horizontal axis instead of years), they need to be written.

	Also, some pivots may have hundreds of columns, so listing them manually in sql is too tedious.


	Dynamic pivots
	--------------

	A polymorphic query thta would autmoatically have tow values transposed into columns without the need to edit
	the sql statment.

*/

--CREATINTG a dynamic PIVOT query 
-----------------------------------

/*

	The difficulty of a creating a dynamic pivot is:

		In an SQL query, the oyput columns must be determined before execution, but to know which columns are formed 
		from transposing rows, we'd to need to execute the query first.

		One solution may be to have pivoted part encapsulated inside a 'single' column with a composite or array type
		style we can use json to solve this problem
*/



SELECT 
	location,
	json_object_agg (year,raindays ORDER BY year) as "mydata"
FROM rainfalls
GROUP BY location
ORDER BY location;


--creating a pivot table using teh subquery

SELECT
	location,
	json_object_agg(year,total_raindays ORDER BY year) AS "mydata"
FROM
(

	SELECT
		location,
		year,
		sum(raindays) AS total_raindays
	FROM rainfalls
	GROUP BY
		location,
		year
) AS s
GROUP BY location


--Dynamic pivot table columns #########################################################################

/*
	IDEA
		To prepare a function which will return the full crosstab query

		we will prepare teh following

			we will create a syntax for 

			-master query 		SELECT * FROM .........GROUP BY
			-headers columns query 		SELECT DISTINCT(column_name ) FROM............


	FOR dynamic columns we will have them lower case, add a prefix as '_', so that to make them unique too
	e.g _english, _history...

	The final output syntax 

	SELECT * FROM crosstab(
		'master_query',
		'header_columns_query'
	) AS newtable
	(
		row_column_name VARCHAR,
		_col1,
		_col2,
		..
	)

*/



CREATE OR REPLACE FUNCTION pivotcode (
	tablename VARCHAR,
	myrow VARCHAR,
	mycol VARCHAR,
	mycell VARCHAR,
	celldatatype VARCHAR
)
RETURNS VARCHAR
LANGUAGE PLPGSQL AS
$$
	DECLARE
		
		dynsql1 VARCHAR;
		dynsql2 VARCHAR;
		columnlist VARCHAR;
		
	BEGIN
		
		-- 1 retrive list of all DISTINCT column name
			
			-- SELECT DISTINCT(column_name) FROM table_name
			
			dynsql1 = 'SELECT STRING_AGG(DISTINCT ''_''||'||mycol||'||'' '||celldatatype||''','','' ORDER BY ''_''||'||mycol||'||'' '||celldatatype||''') FROM '||tablename||';';
		
			EXECUTE dynsql1 INTO columnlist;
			
		-- 2. setup the crosstab query 
			
		dynsql2 = 'SELECT * FROM crosstab (
		 ''SELECT '||myrow||','||mycol||','||mycell||' FROM '||tablename||' GROUP BY 1,2 ORDER BY 1,2'',
		 ''SELECT DISTINCT '||mycol||' FROM '||tablename||' ORDER BY 1''
	 	)
	 	AS newtable (
		 '||myrow||' VARCHAR,'||columnlist||'
		 );';
					
		-- 3. return the query
	
		RETURN dynsql2;
		
	END
$$


--interactive Client - side pivot ######################################################################

/*
	1. psql offers a client - side approach for pivots through the following command 

		\crosstabview

	2. In INERACTIVE use, this method is probably the quickest way to visualize pivoted representation

*/

--run this query ion teh psql terminal

SELECT 
	year,
	location,
	SUM(raindays),
	RANK() OVER (ORDER BY SUM (raindays))
	FROM rainfalls
	GROUP BY location,year
	HAVING SUM(raindays) > 100
	ORDER BY year
	\CROSSTABVIEW year location sum rank


