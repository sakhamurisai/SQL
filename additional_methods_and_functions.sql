--	SELECT INTO ####################################################################################

SELECT 
	column_list
INTO new_table
FROM original_tablename
WHERE
	conditions

SELECT *
INTO stock_market
FROM stocks_prices
WHERE 
	symbol_id = 1;



SELECT *
FROM stock_market;

--creating a duplicate table

--this is with all the data

CREATE TABLE new_table_name AS (SELECT * FROM original_table);

--this is without the data

CREATE TABLE new_table_name AS (SELECT * FROM origiinal_table) WITH NO DATA;


--IMPORTING DATA FROM A CSV FILE #########################################################################

--create table

CREATE TABLE countries_iso_codes
(
	country_id SERIAL PRIMARY KEY,
	country_name VCARCHAR (255),
	iso_code_2 VARCHAR(2),
	iso_code_3 VARCHAR(3),
	region VARCHAR(200),
	subregion VARCHAR(200)
);

--lets import the data using the terminal

\copy countries_iso_codes(country_name,iso_code_2,iso_code_3,region,subregion)
FROM 'countries_iso_codes.csv' DELIMITER ',' CSV HEADER;

--lets Export data to a csv file #######################################################################

COPY table_name TO 'location\file_name' DELIMITER ',' CSV HEADER;

--e.g copy all the daat from countries_iso_codes to a new file called "my_countries_iso_codes"

\copy countries_iso_codes TO 'my_countries_iso_codes' DELIMITER ',' CSV HEADER;

--lets view the auto_vaccum process by query 

SELECT 
	relname,
	last_vacuum,
	last_autovacuum,
	vacuum_count,
	last_analyze,
	last_autoanalyze
FROM pg_stat_all_tables
WHERE 
	relname = 'table_vacuum'


	--using the vaccum manually 

VACUUM[FULL][FREEZE][VERBOSE][TABLE_NAME];

ANALYZE table_name [ (col1,col2,....col_n)];

/*

FULL 		Optional.It specified, the database writes the full contents of the table into a new file.This claims 
			all unused soace and requires an exclusive lock on each table that is vaccumed.

FREEZE		Optional. If specifioed, the tuples are aggressively frozen when the tables is vaccumed. This is the 
			default behavior when full is specified, so it is redundant to specify both FULL and FREEZE.

VERBOSE 	Optional.If specified, an activity report will be printed detailing the vaccum activity for each table.

ANALYZE		Optional.If specified, the statistics used by the planner will be updated. These statistics are used to 
			determined the most efficient plan for executing a particular query.

*/

VACUUM FULL table_vaccum;

SELECT pg_size_prety(pg_total_relation_size('table_vacuum')); --table vaccum is a table name


--Geberated columns ###################################################

/*
Generated columns as "computed columns" or "virtual columns"

A generated column is sort of like a view , but for columns
*/

CREATE TABLE IF NOT EXISTS  t(
	w REAL,
	h REAL,
	area REAL GENERATED ALWAYS AS (w*h) STORED
);

SELECT *
FROM t

--insret some data

INSERT INTO t(w,h) VALUES(1,2);

--lets again query the data

SELECT *
FROM t;

UPDATE t
SET w = 10
WHERE w = 1;


--CREATING a aggregate function #######################################################################

CREATE AGGREGATE aggregate_name(p1,p2...)
(
	INITCOND = n,
	STYPE = type-name,
	SFUNC = function_name,
	FINALFUNC = final_function_name
);