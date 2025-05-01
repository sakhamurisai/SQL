/*

windopw function is mainly of two scopes 

frames and partitions

frame - type : computation: row access al;l function on that are 
									FIRST_value - first frame value,
									last_value - last frame value,
									nth_value -n th frame value

partition  - type: row aces: lag - row before current, 
							lead - row after current,
							row_number current row number
							
			type:ranking: cume_dist - cumulative distribution
							Dense_rank - rank without gaps
							Ntile - rank in n partititons
							percent_rank - percent rank
							Rank - rank in gaps
*/
/*
	using a aggregate function data is flattened through aggregation into single row

	using a window function ########################################################

	Create aggreagtion without flattening the data into single rows*/

-- create our trades table

CREATE TABLE trades(
	region TEXT,
	country TEXT,
	year INT,
	imports NUMERIC(50,0),
	exports NUMERIC(50,0)
);

SELECT *
FROM trades;

SELECT MIN(year) ,MAX(year) FROM trades;

-- USING the aggregate function ###############################

SELECT 
	MIN(imports),
	MAX(imports),
	AVG(imports)
FROM trades;

-- import/export by region

SELECT 
	region,
	MIN(imports),
	MAX(imports),
	AVG(imports)
FROM trades
GROUP BY region;


SELECT 
	region,
	MIN(exports),
	MAX(exports),
	AVG(exports)
FROM trades
GROUP BY region;

--lets see which countries are contributing for the north america export

SELECT *
FROM trades;

SELECT DISTINCT country
FROM trades
WHERE region = 'NORTH AMERICA';

--Using the GROUP with ROLLUP ###################################################################

--ROLLUP helps calculate subtotals and grand totals by grouping data in a hierarchy — top-down.

/*
	example for the rollup

	(c1, c2, c3)
(c1, c2, NULL)
(c1, NULL, NULL)
(NULL, NULL, NULL)

*/

SELECT 
	region,
	ROUND(AVG(imports)/1000000000,2)
FROM trades
GROUP BY ROLLUP (region);

--grouping multiple columns with roll up and cube

SELECT 
	region,
	country,
	ROUND(AVG(imports)/1000000000,2)
FROM trades
GROUP BY ROLLUP (region,country);


--Using the group by cube function ######################################################################
/*
	the cube allows you to generate multiple grouping sets.

	group by cube (col1,col2...)

	The query generates all possible grouping sets based on the dimesion columns specified in cube.


	 generates all possible combinations of the grouping columns — not just hierarchical like ROLLUP

	(c1, c2, c3)
(c1, c2, NULL)
(c1, NULL, c3)
(c1, NULL, NULL)
(NULL, c2, c3)
(NULL, c2, NULL)
(NULL, NULL, c3)
(NULL, NULL, NULL)

*/

SELECT 
	region,
	country,
	ROUND((AVG(imports/100000000)),2)
FROM trades
WHERE 
	country IN ('USA','France','Gremany','Brazil')
GROUP BY 
	CUBE (region,country);

/* ###########################################################################################################

	GROUPING SETS : A grouping set is a set of columns by which you group by using the group by clause.
	GROUPING SETS clause,you can also explicitly list the aggregates you want 
*/

SELECT 
	region,
	country,
	ROUND((AVG(imports/100000000)),2)
FROM trades
WHERE 
	country IN ('USA','France','Germany','Brazil')
GROUP BY 
	GROUPING SETS (
	(),
	(region),
	(country)
	);

--Query perfomance analysis ####################################################################

EXPLAIN
SELECT 
	region,
	country,
	ROUND((AVG(imports/100000000)),2)
FROM trades
WHERE 
	country IN ('USA','France','Germany','Brazil')
GROUP BY 
	GROUPING SETS (
	(),
	(region),
	(country)
	);

--Using FILTER clause #################################################################################
-- THIS IS A PRETTY POWERFUL FUNCTIONALITY ############################################################

/*
	Filter clause allows you to do a 'Selective aggregate'

	It aggregate the group sets based on a filter condition

	aggregate function FILTER (where concdition)

	allows you to selectively pass data to those aggregates 

	the FILTER clause is used with aggregate functions to apply
	a condition to specific rows before aggregation — without using
	a WHERE clause that affects the whole query.

*/

-- using the filter use case
-- Get average exposrts per each region for all period,for period year< 1995 is old >= 1995 as latest
SELECT *
FROm trades;

SELECT 
	region,
	AVG(exports),
	AVG(exports) FILTER (WHERE year < 1995) AS old,
	AVG(exports) FILTER (WHERE year >= 1995) AS new
FROM trades
GROUP BY ROLLUP (region) ;


/*
	USING the window function ##########################################################################
	(Aggregates function -- take many rows and turn them into fewer aggregated rows flatten the data)()

	**A window function** -- It compares teh current row with all rows in the group

	aggregate function OVER (PARTITION BY group name)

*/

--simple window function
SELECT 
	country,
	year,
	imports,
	exports,
	AVG(exports) OVER() AS avg_exports
FROM trades;

--partitiong the data in the over clause

SELECT 
	country,
	year,
	imports,
	exports,
	AVG(exports) OVER(PARTITION BY country) AS avg_exports
FROM trades;

--Filtering data in partition by ###########################################################################

SELECT 
	country,
	year,
	imports,
	exports,
	AVG(exports) OVER(PARTITION BY year < 2000) AS avg_exports
FROM trades;


--converting the imports and the exports into the 

UPDATE trades
SET imports = ROUND(imports / 1000000,0),
	exports = ROUND(exports / 1000000,0);


SELECT *
FROM trades;


-- in this query we are grouping byh country and arranginn the data in th egroup according to the year in asc


SELECT 
	country,
	year,
	exports,
	MIN(exports) OVER (PARTITION BY country ORDER BY year)
FROM trades
WHERE year > 2001 AND country = 'USA';


--sliding dynamic window {moving window} ############################################################################



SELECT 
	country,
	year,
	exports,
	MIN(exports) OVER (PARTITION BY country ORDER BY year ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS AVG
FROM trades
WHERE year BETWEEN 2001 AND 2010
AND country = 'USA';


--excluding the current rows in th window


SELECT 
	country,
	year,
	exports,
	MIN(exports) OVER (PARTITION BY country ORDER BY year ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING EXCLUDE CURRENT ROW ) AS AVG
FROM trades
WHERE year BETWEEN 2001 AND 2010
AND country = 'USA';

--on more example for the sliding dynamic window

SELECT 
  student,
  test_date,
  score,
  AVG(score) OVER (
    PARTITION BY student 
    ORDER BY test_date 
    ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
  ) AS running_avg
FROM test_scores;


--understanding the window frames ################################################################################

/*

	1.window frames are used to indicate how amny rows around the current row, the window function should include

	2.Specific window frame via 
	
	Rows or range - indicators
	BETWEEN - start of the frame and the end of the frame 

	3.Window frames in window functions use unbounded preceding by default

	RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW

	4.possible frames combinations

		UNBOUNDED	everything

		UNBOUNDED PRECEDING -- everything before the current line
		1 PRECEDING

		UNBOUNDED FOLLOWING - everything after the current line
		1 FOLLOWING
		0 FOLLOWING

		CURRENT ROW


		ROWS BETWEEN  UNBOUNDED PRECEDING AND CURRENT ROW 
*/

--by default the postgres will be using the UNBOUNDED PRECEDING AND CURRENT ROW this is the example for that
SELECT 
	*,
	ARRAY_AGG(x) OVER (ORDER BY x ROWS BETWEEN  UNBOUNDED PRECEDING AND CURRENT ROW)
FROM generate_series(1,3) AS x; --here the window frame is taking the above value for example 1,2 at integer two

--UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING

SELECT 
	*,
	ARRAY_AGG(x) OVER (ORDER BY x ROWS BETWEEN  UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
FROM generate_series(1,3) AS x;

--CURRENT ROW AND UNBOUNDED FOLLOWING

SELECT 
	*,
	ARRAY_AGG(x) OVER (ORDER BY x ROWS BETWEEN  CURRENT ROW AND UNBOUNDED FOLLOWING)
FROM generate_series(1,3) AS x;

SELECT 
	*,
	ARRAY_AGG(x) OVER (ORDER BY x ROWS BETWEEN  UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
FROM generate_series(1,3) AS x;


/*
This is an alias for the table and column:

t → is the table alias (temporary name for the subquery/table)

x → is the column alias (name for the column coming from generate_series)

So this means:
"Treat the result of generate_series(1, 3) as a table named t with one column named x."

*/

SELECT 
	*,
	ARRAY_AGG(x) OVER (),
	SUM(x) OVER(),
	x::FLOAT / SUM(x) OVER() 
FROM generate_series(1,3) AS t(x);

-- ROWS AND RANGE indicators ################################################################################

/*
	1.RANGE can only be used with unbounded

	2.ROWS can actually be used for all of the options

	3.How aggregations are treated differently

	If the field you use for ORDER BY does not contain unique values for each row, Then RANGE will combine all the 
	rows it comes across for non - unique values rather than processing them one at a time.

	ROWS will include al of the rows in the non-unique bunch but process each of them seperately

	RANGE take enteire group of duplicates

*/


SELECT
	*,
	x/3 AS y,
	ARRAY_AGG(x) OVER (ORDER BY x ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS rows1,
	ARRAY_AGG(x) OVER (ORDER BY x RANGE BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS range1,
	ARRAY_AGG(x/3) OVER (ORDER BY (x/3) ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS rows2,
	ARRAY_AGG(x/3) OVER (ORDER BY (x/3) RANGE BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS range2 -- RANGE takes entire duplicates as a array
FROM GENERATE_SERIES(1,10) AS x;


--WINDOW FUNCTION ###########################################################################################

/*
	1. window function allows us to add columns to the result set that has been calculated on the fly

	2. Allows to pre-defined a result set and used it anywhere (even multiple places) in a query

	3. Using multiple window in a query
		SELECT 
			wf1() over(...........)
			wf2() over(..........)
			FROM table
	
*/

--Get min and max exports per year per each country say from year 2000 onwards in  a single query

SELECT 
	country,
	year,
	exports,
	MIN(exports) OVER (PARTITION BY country ORDER BY year > 2000) AS min_exports,
	MAX(exports) OVER (PARTITION BY country ORDER BY year > 2000) AS max_exports
FROM trades;

--A window defines the "frame" of rows relative to the current row, over which a calculation (like average, sum, rank, etc.) is performed.

SELECT 
	country,
	year,
	exports,
	MIN(exports) OVER (w) AS min_exports,
	MAX(exports) OVER (w) AS max_exports
FROM trades
WHERE 
	country = 'USA'
	AND year >2000
WINDOW w AS (ORDER BY year); --main advantage by defining the window at the bottom is we can change it any timeeasily

SELECT 
	country,
	year,
	exports,
	MIN(exports) OVER w AS min_exports, --we won't use the paranthesis if we define the frame at the bottom
	MAX(exports) OVER w AS max_exports
FROM trades
WHERE 
	country = 'USA'
	AND year >2000
WINDOW w AS (ORDER BY year ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW);


--RANK and DENSE_RANK functions #############################################################################


/*
	1. RANK() function returns the number of the current roe within its window.start from 1

	2. The RANK column will number tuples in your dataset

	3. for RANK(), based on your dat , you might encounter duplicates ranks

	4. to avoid duplicate ranks, we use the DENSE_RANK() function
*/

--look at top 10 exports by year for usa

SELECT 
	year,
	exports,
	RANK() OVER(w)
FROM trades
WHERE 
	country = 'USA'
WINDOW w AS (ORDER BY exports DESC);


-- NTILE function###############################################################
/*
	1. NTILE will split data into ideally equal groups 

	2. Divide ordered rows in the partition into a specified number of ranked buckets.

	3. Bucket number for each group starts with 1

	4. NTILE (buckets) OVER (partition by partition expression[ORDER BY sort expression [ASC|DSC]])

	5. If the number of rows is not divisible by the buckets ,function returns groups of two sizes with the difference by one
*/

--get the exports from year 2000 into 4 buckets

SELECT 
	year,
	exports,
	NTILE(4) OVER(w)
FROM trades
WHERE 
	country = 'USA' AND year > 2000
WINDOW w AS (ORDER BY exports DESC);


-- trying to gourp by country and then again create buckets in that group

SELECT 
	country,
	year,
	exports,
	NTILE(4) OVER(w)
FROM trades
WHERE 
	country IN ('USA','France','Belgium') AND year > 2000
WINDOW w AS (PARTITION BY country ORDER BY exports DESC);


-- creating a NTILE using the year

SELECT 
	country,
	year,
	exports,
	NTILE(4) OVER(w)
FROM trades
WHERE 
	country IN ('USA','France','Belgium') AND year > 2000
WINDOW w AS (PARTITION BY year ORDER BY exports DESC);


-- LEAD and LAG function ##############################################################

/*
	1. LEAD and LAG functions allows you to move lines within the resultsets

	2. very useful fuction to compare the dat of CURRENT ROW with any other rows (going back ward LAG and forward LEAD)

	3. LEAD function access a row that follows the current row, at a specific physical offset.

		- AFTER the current row 

			LEAD (expression , offset [,default_value])
	4. LAG function to access a row which aomes before the current row at a specific physical offset.

		-Before the CURRENT ROW

		LAG(expression,offset[,default_value])
*/

--calculate teh differnece from on year to another year

SELECT 
	year,
	country,
	exports,
	LEAD(exports,1) OVER (ORDER BY year) --in this function number 1 is a offset
FROM
	trades
WHERE country = 'USA';

--lag means going up

SELECT 
	year,
	country,
	exports,
	LEAD(exports,1) OVER (ORDER BY year) --in this function number 1 is a offset
FROM
	trades
WHERE country = 'USA';

--looking at a example with the two or more countries

SELECT 
	year,
	country,
	exports,
	LEAD(exports,1) OVER (PARTITION BY country ORDER BY year) --in this function number 1 is a offset
FROM
	trades
WHERE country IN ('USA','Belgium');


--FIRST_VALUE(),NTH_VALUE(), and LAST_VALUE() functions ####################################################

/*
	FIRST_VALUE() - returns the first value in a sorted partition of a result set.
	LAST_VALUE() - returns the last value in a sorted partition of a result set.
	NTH_VALUE - returns the value from the Nth row of a result set 
*/


SELECT 
	year,
	country,
	exports,
	FIRST_VALUE(exports) OVER (ORDER BY year) --Takes the first value of a result set 
FROM
	trades
WHERE country = 'USA';


SELECT 
	year,
	country,
	exports,
	FIRST_VALUE(exports) OVER (ORDER BY year ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) --Takes the first value of a result set 
FROM
	trades
WHERE country = 'USA';

--LAST_VALUE() function

SELECT 
	year,
	country,
	exports,
	LAST_VALUE(exports) OVER w 
FROM
	trades
WHERE country = 'USA'
--WINDOW w AS (ORDER BY year)
WINDOW w AS (ORDER BY year ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING);


-- using the NTH_VALUE function in the postgres


SELECT 
	year,
	country,
	exports,
	NTH_VALUE(exports,2) OVER (ORDER BY year) 
FROM	trades
WHERE country = 'USA';

SELECT 
	year,
	country,
	exports,
	NTH_VALUE(exports,5) OVER (ORDER BY year ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) 
FROM	trades
WHERE country = 'USA';


--using the multiple countries 

--first value function
SELECT 
	year,
	country,
	exports,
	FIRST_VALUE(exports) OVER (PARTITION BY country ORDER BY year) 
FROM	trades
WHERE country IN ('USA','Belgium');

--Last value function

SELECT 
	year,
	country,
	exports,
	LAST_VALUE(exports) OVER (PARTITION BY country ORDER BY year) 
FROM	trades
WHERE country IN ('USA','Belgium');

--nth value

SELECT 
	year,
	country,
	exports,
	NTH_VALUE(exports,4) OVER (PARTITION BY country ORDER BY year) 
FROM	trades
WHERE country IN ('USA','Belgium');


--ROW_NUMBER() function ##################################################################################

/*
	1. can simply be used to return a virtual Id

	2. assign a unique integer value to each row in a result set starting with 1

*/

-- Assign rows to all imports for a country France

SELECT 
	year,
	country,
	ROW_NUMBER() OVER (ORDER BY year)
FROM trades
WHERE country = 'USA';


--finding CORRELATIONS ######################################################################################
/*
	corr
	-1 to 1
	+ve up and up
	-ve up and down
*/

SELECT 
	country,
	CORR(imports,exports)
FROM trades
GROUP BY country
ORDER BY 2 DESC NULLS LAST;


/*

PARTITION BY :
	The PARTITIOPN BY clause divides the window into smaller sets or partitions. If we specify the partition by clause,
	the row nummber each partition starts with 1 and increments by +1

	partition by clause is optional 

	if we donot use the partition by then the function will treat the whole window as a single partition or one partiotion

*/
/*we can use the row number for complex pagination 

Pagination is the technique of splitting a large set of query results into smaller, more manageable chunks or pages. 
It's commonly used in applications (like websites or APIs) to only show a limited number of records at a time 
(e.g., 10 results per page).
*/

/*

	planning tips on using the window functions

	Do you want to split / partition the dataset use teh partition by

	DO you want to order the partition then use the order 

	how do you want to handle you rows with the same order by values
		range or rows
		rank or dense rank
	Do you need to define window frame

	window function they handle their own
*/