-- Cursors ##############################################################################################

/*
	A cursor in PostgreSQL is a database object used to retrieve query results row by row,
	instead of getting the entire result set at once. It's especially useful when you're working
	with large datasets or need to process records sequentially in PL/pgSQL.

🧠 Why Use a Cursor?
Normally, SQL queries return all rows at once. But sometimes you:

Need to handle one row at a time

Want to loop through results inside a function

Are processing large datasets that can't fit in memory

That’s where a cursor helps — it keeps a pointer to the result set, allowing you to fetch rows incrementally.




Using cursor with the procedural language
-----------------------------------------

1. Cursor are very valuable if you want to retrieve selected ROWS from a table

2. Once retrieved, you can check the contents of the reults sets, and perform different operations on those contents.

3. However, Please note SQL can't perform this sequence of operations by itself. SQL can retrieve the rows, but ideally 
	the operations should be done by procedural languages based on contents

4. Procedural and non-procedural languages
	In PROCEDURAL languages, the program code is written as a sequence f instructions. User has to specify "what to do"
	and also "how to do" (step by step procedure). These instructions are executed in the sequential order. These 
	instructions are written to solve specific problems.

5. Cursor can retrieve and then feed the contents / results sets to procedural language for furthur processing 
	CURSOR - > result set -> procedural langugae -> operations (add/edit/delete)
*/


--Steps to create a cursor #################################################################

/*
	Before using the cursor, following steps are required;

	1. Declare 
		A cursor must be declared before it is to be used
		this doesnot retieve the data , it just defines the select statment to be used and any other cursor options.

	2.OPEN
		Once it is declare, it must be opened for use.
		This process retireves the data using the define select statment.

	3. Fetch 

		With the cursor populated with data, individual rows can be fetched (retrieved ) as per needed.
		
	4.	CLOSE

		When you do not need the cursor,it must be closed
		this operation then deallocated memory etc back to the DBMS

	5. Once a cursor is declared, it may be opened, fetched and close as often as needed

	6. So the steps are;

		DECLARE -> OPEN -> FETCH -> CLOSE
*/		

--Creating a Cursor ##################################################################################

--1. Declare a cursor using refcursor data type (postgres provides you with a special type called REFCURSOR to declare a cursor variable)

DECLARE cursor_name REFCURSOR;

--2. Create a cursor that bounds to a query expression

cursor-name [cursor-scrollability] CURSOR [(name DATATYPE,name DATATYPE,..............)]
FOR
	QUERY EXPRESSION


--cursor - scrollability		scroll or no scroll (default) NO SCROLL mean the cursor cannot scroll backward
-- Query - expression		You can use any legal SELECT statment as a query expression. The resultsets rows are considered as scope of cursor.

DECLARE
	cur_all_movies CURSOR
	FOR 
		SELECT movie_name FROM movies;


--Creating a cursor with teh query parameters 
--lets create a cursor which works on the result set of the query returning all movies released in year 2010

DECLARE 
	cur_all_movies_by_year_2010 CURSOR(custom_year INTEGER)
	FOR
		SELECT 
			movie_name,
			movie_length
		FROM movies
		WHERE EXTRACT('YEAR' FROM release_date ) = custom_year


-- they are two types of cursors Bound and unbound cursors

--Opening an unbound cursor

OPEN unbound_curso_varibale [[No]SCROLL] FOR QUERY;

--lets look at a example for this using the directors table

OPEN cur_directors_us
FOR
	SELECT 
		first_name,
		last_name,
		date_of_birth
	FROM directors
	WHERE 
		nationality = 'American'

--opening a unbound cursor with dynamic query


OPEN unbound_cursor_variable [[NO]SCROLL]
FOR EXECUTE
	QUERY_expression [using expression[,........]];


--seting a varibale

my_query := 'SELECT DISTINCT (nationality) FROM directors ORDER BY $1';

OPEN cur_directors_nationality
FOR EXECUTE 
	my_query USING sort_field;


--Opening a bound cursor 
-- AS they are bounds to a query when we declared it, so when we open it , we just need to pass the argumument to the query if necessary

OPEN cursor_varibale [name:=value,name:=value.........];
OPEN cur_all_movies;

--lets try to understand the bound cursor

DECLARE 
	cur_all_movies_by_year_2010 CURSOR(custom_year INTEGER)
	FOR
		SELECT 
			movie_name,
			movie_length
		FROM movies
		WHERE EXTRACT('YEAR' FROM release_date ) = custom_year

		OPEN cur_all_movies_by_year_2010(custom_year := 2010)
		

--Using CURSORS ############################################################################

--1.Following operatioins can be done once a cursor is open FETCH, MOVE, UPDATE, or DELTE statment.

--2. FETCH statment
FETCH [direction {FROM | IN}] cursor_varibale
INTO target_varibale;

FETCH cur_all_movies INTO row_movie;


--By default, a cursor gets the next row if you don't specify the direction explicitly.

/*
	NEXT
	LAST
	PRIOR
	FIRST
	ABSOLUTE count
	RELATIVE count
	FORWARD
	BACKWARD	

*/

--if we enable the SCROLL at the declaration of the cursor, they can only you can use;

FORWARD
BACKWARD

-- If you want to move the cursor only without retrieving any row you will use the MOVE statment

MOVE [direction {FROM | IN}] cursor_varible;

--Moving the cursor if we want to move teh cursor only without retrieving any row, you will use the move statment

MOVE [direction {FROM | IN}] cursor_varibale;

MOVE cur_all_movies;
MOVE LAST FROM cur_all_movies;
MOVE relative -1 FROM cur_all_movies
MOVE FORWARD 4 FROM cur_all_movies


--updating the data using cursor #############################################################################
/*

Once a cursor is positioned, we can delete or update row identifying by the cursor using the following statment

	DELETE WHERE CURRENT OF OR
	UPDATE WHERE CURRENT OF
*/

UPDATE movies
SET YEAR (release_date) = custom_year
WHERE 
	CURRENT OF cur_all_movies;


--closing a cursor #################################################################################

CLOSE cursor_variable

-- Close statment release resources or frees up cursor variable to allow it to be opened again using OPEN statment.

CLOSE cur_all_movies;
OPEN cur_all_movies;


--Pl/pgSQL cursor #################################################################################

--1. lets use the cursor to list all movies names

DO
$$
	DECLARE 
		output_text TEXT DEFAULT '';
		rec_movie RECORD;

		cur_all_movies CURSOR
		FOR 
			SELECT * FROM movies;

	BEGIN

		OPEN cur_all_movies;

		LOOP
			FETCH cur_all_movies INTO rec_movie;
			EXIT WHEN NOT FOUND;

			output_text := output_text || ',' || rec_movie.movie_name;
		END LOOP;

		RAISE NOTICE 'All Movies names %',output_text;
	END;
$$
LANGUAGE PLPGSQL;


--Using cursor with a function ####################################################################

/*
	Lets create a function where we will use the cursor to loop through the all movies rows and concatenate the movie
	title and release date year of movie that has the title contains say the word 'star'
*/

SELECT * FROM movies ORDER BY movie_name;

CREATE OR REPLACE FUNCTION fn_get_movie_names_by_year(custom_year INTEGER)
RETURNS TEXT
AS
$$
	DECLARE 
		rec_movie RECORD;
		movie_name TEXT DEFAULT '';

		cur_all_movies_by_year CURSOR (custom_year INTEGER)

		FOR 
			SELECT 
				movie_name,
				EXTRACT ('YEAR' FROM release_date) AS release_year
			FROM movies
			WHERE 
				EXTRACT ('YEAR' FROM release_date) = custom_year;

	BEGIN
		OPEN cur_all_movies_by_year(custom_year);

		LOOP
			FETCH cur_all_movies_by_year INTO rec_movie;
			EXIT WHEN NOT FOUND;

			IF rec_movie.movie_name LIKE '%Star%' THEN
				movie_name := movie_names || ',' || rec_movie.movie_name || ':'|| rec.movie_release_year ;
			END IF;
		END LOOP;
		CLOSE cur_all_movies_by_year;
		RETURN movie_names;
	END;
$$
LANGUAGE PLPGSQL;

SELECT cur_all_movies_by_year(1977); --showing error correct the code 