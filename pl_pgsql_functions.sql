--introduction to PL/PGSQL language ###########################################################

/*
PL/pgSQL (Procedural Language/PostgreSQL Structured Query Language) is PostgreSQL’s native procedural
programming language. It allows you to write complex logic directly inside the database using control 
structures like loops, conditionals, and variables — similar to other procedural languages like PL/SQL
in Oracle.

| Feature                   | Description                                    |
| ------------------------- | ---------------------------------------------- |
| **Variables**             | Declare and use local variables                |
| **Control Flow**          | Use `IF`, `CASE`, `LOOP`, `WHILE`, `FOR`, etc. |
| **Exception Handling**    | Handle errors with `EXCEPTION` blocks          |
| **Tight SQL Integration** | Use regular SQL seamlessly inside blocks       |
| **Security**              | Can be executed with definer or invoker rights |


	1. PL/pgsql is a powerful SQL scripting language that is heavily influenced by oracle PL/SQL
	2. PL/pgsql is a full-fledged SQL development language
	3. Originally designed for simple scaler functions, and now providing;

		- Full PostgreSQL internals,
		- Control structure 
		- Variable structure
		- Expression
		- Loops
		- Cursor and much more
		-complex functions
		-new data types
		-stored procedures and more
		
	Avaliable by default on postgreSQL


Quick comparision between the PL/pgSQL vs SQL ####################################################################

SQL is a query language, but can only execute SQL statment INDIVIDUALLY

- PL/pgSQL will;
	- Wrap multiple statments in an object
	- store that object on the server
	- insted of sending multiple statments to the server one by one, we can send one statment
	to execute the 
		'object' stored in the server
	-reduced round trips to server for each statment to execute
	-provide transactional integrity and much more


Do blocks in postgres

In PostgreSQL, the DO block is used to execute anonymous PL/pgSQL code without the need to
create a function. It's a convenient way to run procedural logic in a one-off fashion without
creating a reusable function. The DO block is primarily used for tasks like running scripts, 
testing logic, or performing data manipulation where a return value is not necessary.

Key Features of DO Blocks
Anonymous Code Execution:

A DO block is anonymous, meaning it does not require a function name. It's a quick way to execute
PL/pgSQL logic without having to create a named function.

No Return Value:

Unlike a function, a DO block does not return a value. Its primary use is for executing logic or
performing actions, such as modifying tables, raising notices, or executing queries.

Can Contain Variables:

Variables can be declared within a DO block using the DECLARE keyword. These variables are only
accessible within the block.

Used for One-time Tasks:

The DO block is designed for one-time tasks. It executes immediately and then ends without persisting
any code in the database.
*/

CREATE OR REPLACE FUNCTION function_name (p1 TYPE,p2 TYPE,.....)
RETURNS return_type
AS
$$
	BEGIN
			RETURN -- in general SQL syntax SELECT but in plpgsql RETURN
	END
$$
LANGUAGE plpgsql;

-- get teh maximum price of teh product

SELECT *
FROM products;

CREATE OR REPLACE FUNCTION fn_product_maximum_prize ()
RETURNS REAL
AS
$$
	BEGIN
		RETURN SELECT MAX(unit_price)
		FROM products;
	END;
$$
LANGUAGE plpgsql;

SELECT fn_product_maximum_prize();

--PL/pgSQL block structure #######################################################################

/*
	1. PL/pgSQL function or store procedure is organized into blocks 

	2. Block structure syntax 

		[<<label>>]
		[ DECLARE
			Declarations;
		]
		BEGIN 	
			statments;
		END; [label];

*/

-- DECLARING variables ###############################################################################
-- 1. A variable holds a value that can be changed through the block
--2. Before using a variable, you must declare it in the declaration section

DECLARE 
	varaibale_name data_type [:= EXPRESSION];
...
BEGIN
	...
END;

--example for declaring the variables 

DECLARE 
	mynum	INTEGER := 1;
	first_name VARCHAR := 'jhon';
	hire_date	DATE := '2020-01-01';
	start_time TIMESTAMP := NOW();
	emptyvar	INTEGER;

BEGIN
	..
END;

--lets take an example of declare and intialize variables
-- USE the block structure

DO
$$
DECLARE 
	mynum	INTEGER := 1;
	first_name VARCHAR := 'jhon';
	hire_date	DATE := '2020-01-01';
	start_time TIMESTAMP := NOW();
	emptyvar	INTEGER;
BEGIN 
	RAISE NOTICE 'values: %,%,%,%,%',
	mynum,
	first_name,
	hire_date,
	start_time,
	emptyvar;
END $$ ;


--declaring variables with the ALIAS ###########################################################


CREATE OR REPLACE FUNCTION function_name (int,int) 
RETURNS INT 
AS
$$
	DECLARE 
		x ALIAS FOR $1;
		y ALIAS FOR $2;
	BEGIN 
		...
	END;
$$
LANGUAGE PLPGSQL;

--Declaring varaiables in functions #############################################################
--using the position numbers $1 , $2

CREATE OR REPLACE FUNCTION fn_my_sum_plpgsql(INTEGER,INTEGER)
RETURNS INTEGER
AS
$$
	DECLARE 
		ret INTEGER;
	BEGIN
		ret := $1 +$2;
		RETURN ret;
	END;
$$
LANGUAGE PLPGSQL;


SELECT fn_my_sum_plpgsql(1,2);


--Declaring variables via ALIAS

CREATE OR REPLACE FUNCTION fn_my_sum_plpgsql(a INTEGER,b INTEGER)
RETURNS INTEGER
AS
$$
	DECLARE 
		ret INTEGER;
	BEGIN
		ret := a + b;
		RETURN ret;
	END;
$$
LANGUAGE PLPGSQL;

SELECT fn_my_sum_plpgsql(2,3);


--using the variables in teh declare statment

CREATE OR REPLACE FUNCTION fn_my_sum_plpgsql1(INTEGER,INTEGER)
RETURNS INTEGER
AS
$$
	DECLARE 
		ret INTEGER;

		x ALIAS FOR $1;
		y ALIAS FOR $2;
	BEGIN
		ret := x + y;
		RETURN ret;
	END;
$$
LANGUAGE PLPGSQL;

SELECT fn_my_sum_plpgsql1(4,3);

--variable intitlization timming ###################################################


/*
	Using the perform function
	In PostgreSQL's PL/pgSQL, the PERFORM keyword is used to execute a SQL statement
	that returns a value, but where the result is not needed.

	You're calling a function or expression for its side effect, not its return value.

	You want to execute a query but don't need to store or display the result.
*/
DO
$$
	DECLARE 
		start_time TIME := NOW();
	BEGIN
		RAISE NOTICE 'starting_time : %',start_time;
		PERFORM pg_sleep(2);
		RAISE NOTICE 'starting_time : %',start_time;
	END;
$$
LANGUAGE PLPGSQL;

--copying data types #######################################################

/*
	%TYPE refers to data type of a table column or another varaiable

	variable_name table_name.column_name%type;
*/

DO
$$
	DECLARE 
		variable_name table_name.column_name%TYPE; 

		empl_first_name employees.first_name%TYPE;
	BEGIN
		...
	END;
$$
LANGUAGE PLPGSQl

--Assigning variables from query ##################################################

SELECT expression INTO variable_name

--keep in mind must return only single resultset

--some example

SELECT * FROM products INTO product_row LIMIT 1; --why we used limit means we can only use single resultset

SELECT product_row.product_name INTO product_type;


--complete example for reference

DO
$$
	DECLARE 
		product_title products.product_name%TYPE;
	BEGIN
		SELECT 
			product_name
		FROM products
		INTO product_title
		WHERE product_id =1;

		RAISE NOTICE 'your product name is %',product_title;
	END;
$$
LANGUAGE PLPGSQL;


--checking the another example with all the row data int her variable

DO
$$
	DECLARE 
		row_product RECORD; --record is a datatype
	BEGIN
		SELECT 
			*
		FROM products
		INTO row_product
		WHERE product_id =1;

		RAISE NOTICE 'your product name is %',row_product.product_name;
	END;
$$
LANGUAGE PLPGSQL;

--USing the IN . OUT without the returns #########################################

CREATE OR REPLACE FUNCTION function_name() RETURNS return_type AS

-- We used the returns clause in the first row of the function definition,however
-- we can use IN, OUT, INOUT parameters modes

IN varaiable_name DATATYPE
OUT VARIABLE_name DATATYPE
INOUT varaiable_name DATATYPE

--lets create a function to calculate a sum of three integers

CREATE OR REPLACE FUNCTION fn_my_sum_3 (IN x INTEGER,IN y INTEGER,OUT z INTEGER,OUT a INTEGER)
AS
$$
	BEGIN
		z := x+y;
		a := x*y;
	END;
$$
LANGUAGE PLPGSQL;


SELECT fn_my_sum_3 (1,2);

--Variables in block and subblock ##############################################################

DO
$$
	<<parent>>
	DECLARE 
		counter INTEGER := 0;
	BEGIN
		counter := counter + 1;

		RAISE NOTICE 'The current value of the counter is %',counter;

		<<child>>
		DECLARE 
			counter INTEGER := 0;
		BEGIN
			counter := counter + 5;

			RAISE NOTICE 'The current value of the parent counter = %',parent.counter;
			RAISE NOTICE 'The current value of the child counter = %',child.counter;
		END child;
	END parent;
$$
LANGUAGE PLPGSQL;

/*
RESULTS FOR THE ABOVE QUERY

NOTICE:  The current value of the counter is 1
NOTICE:  The current value of the parent counter = 1
NOTICE:  The current value of the child counter = 5
*/

--How to return the query results ####################################################

--Syntax for that

CREATE OR REPLACE FUNCTION function_name RETURNS SETOF table_name AS
$$
BEGIN 
--statment
RETURN QUERY SELECT --query
END;
$$
LANGUAGE PLPGSQL;


--example create a function that takes all the latest orders in the table

CREATE OR REPLACE FUNCTION fn_api_orders_latest_top_10_orders()
RETURNS SETOF orders 
AS
$$
	BEGIN
		RETURN QUERY
		SELECT *
		FROM orders
		ORDER BY order_date DESC
		LIMIT 10;
	END;
$$
LANGUAGE PLPGSQL;

SELECT *
FROM fn_api_orders_latest_top_10_orders();



--Control structures ###########################################################

/*
	POSTGRESQL prvides three conditional statments 
	-Conditional statments
	-loop statments
	-exception handlers 

	CONDITIIONAL STATMENTS
	----------------------

	- IF

		IF boolean expression THEN
			.....	block
		ENDIF

		IF THEN
		IF THEN ELSE 
		IF THEN ELSE IF


		IF EXPRESSION THEN
			statment..
		ELSIF expression THEN
			statment..
		ELSIF expression THEN
			statment..
		ELSE
			statment.....
		END IF;
*/

--lets see a small example for the if statment

CREATE OR REPLACE FUNCTION fn_value_checker(x INTEGER, y INTEGER)
RETURNS VARCHAR
AS 
$$
	BEGIN
		IF x > y THEN
			RETURN 'x > y';
		ELSIF x = y THEN
			RETURN 'x = y';
		ELSE
			RETURN 'x < y';
		END IF;
	END;
$$
LANGUAGE PLPGSQL;

SELECT fn_value_checker(5, 5);


--using the if condition with the table data

CREATE OR REPLACE FUNCTION fn_api_products_category (price REAL) 
RETURNS TEXT 
AS
$$
	BEGIN
		IF price > 50 THEN
			RETURN 'high';
		ELSIF price > 25 THEN
			RETURN 'medium';
		ELSE
			RETURN 'sweet_spot';
		END IF;
	END;
$$
LANGUAGE PLPGSQl;


SELECT fn_api_products_category(unit_price),*
FROM products;

-- CASE statment ##############################################################################
/*
simple	if we have to make a choice from a list of values
searched we have t choose from a range of  values 


CASE search_expression
WHEN expression,[exppression] THEN
statments
[WHEN expression [,expression[..]]] THEN
statments ...]
[ELSE
	STATEMENTS]
END CASE;

*/

--lets look at one basic example for the case statment

CREATE OR REPLACE FUNCTION fn_my_value_check(x INTEGER)
RETURNS TEXT
AS
$$
	BEGIN
		CASE x
			WHEN 10 THEN 
				RETURN 'x = 10';
			WHEN 20 THEN
				RETURN	'x = 20';
			ELSE
				RETURN 'x is nor 10 neither 20';
		END CASE;
	END;
$$
LANGUAGE PLPGSQl;


SELECT fn_my_value_check(50);


--lets implement the case statemnts in the table
--nows in teh orders table we have the shipped via column use the case and name the shipped via
SELECT *
FROM shippers;

CREATE OR REPLACE FUNCTION fn_shipped_via_orders(x SMALLINT)
RETURNS TEXT
AS
$$
    DECLARE
        results TEXT; 
    BEGIN
        CASE x
            WHEN 1 THEN
                SELECT company_name INTO results  
                FROM shippers
                WHERE shipper_id = 1;
            WHEN 2 THEN
                SELECT company_name INTO results
                FROM shippers
                WHERE shipper_id = 2;
            WHEN 3 THEN
                SELECT company_name INTO results
                FROM shippers
                WHERE shipper_id = 3;
            WHEN 4 THEN
                SELECT company_name INTO results
                FROM shippers
                WHERE shipper_id = 4;
            WHEN 5 THEN
                SELECT company_name INTO results
                FROM shippers
                WHERE shipper_id = 5;
            ELSE
                SELECT company_name INTO results
                FROM shippers
                WHERE shipper_id = 6;
            END CASE;
        RETURN results;
    END;
$$
LANGUAGE PLPGSQL;

	
SELECT *
FROM orders;

DROP FUNCTION fn_shipped_via_orders(x smallint);

SELECT fn_shipped_via_orders(ship_via)
FROM orders;


--searched CASE statment #########################################################################

DO
$$
	DECLARE 
		total_amount NUMERIC;
		order_type VARCHAR(50);
	BEGIN
		SELECT 
			SUM((unit_price * quantity) - discount) INTO total_amount
		FROM order_details
		WHERE 
			order_id = 10248;

		IF FOUND THEN
			CASE 
				WHEN total_amount > 200 THEN
					order_type = 'platinum';
				WHEN total_amount > 100 THEN
					order_type = 'gold';
				ELSE
					order_type = 'silver';
			END CASE;
			RAISE NOTICE 'order amount ,order type %,%',total_amount,order_type;
		ELSE
			RAISE NOTICE 'no order was found.';
		END IF;
	END;
$$
LANGUAGE PLPGSQL;

--LOOP statments ############################################################

/*
LOOP
	STATMENT
	EXIT
END LOOP;

LOOP
	STATMENT
	EXIT WHEN CNDITIION MET;
END LOOP;

LOOP
	STATMENT
	IF CONDITION THEN 
		EXIT;
	END IF;
END LOOP;

*/

DO
$$
	DECLARE 
		i_counter INTEGER := 0;
	BEGIN
		LOOP
			RAISE NOTICE '%',i_counter;
				i_counter := i_counter +1;
			EXIT WHEN 
				i_counter = 5;
		END LOOP;
	END;
$$
LANGUAGE PLPGSQL;

/*
	for exiting loop we give condition to teh loop

	for continueing or skiping a expression we use the continue
*/

--FOR loops ################################################################################
/*
FOR loop is used to iterate over a set of values (such as rows in a query or a predefined range).

FOR [counter_name] IN [reverse] [start value] .. [end value] [By steeping]
LOOP
	[statments];
END LOOP;

*/

--creating a block for the demonstartion of the loop

DO
$$
BEGIN
	FOR counter IN 1..10
	LOOP
		RAISE NOTICE 'counter: %',counter;
	END LOOP;
END;
$$
LANGUAGE PLPGSQL;

--creating the loop in reverse

DO
$$
BEGIN
	FOR counter IN REVERSE 10..1
	LOOP
		RAISE NOTICE 'counter: %',counter;
	END LOOP;
END;
$$
LANGUAGE PLPGSQL;

--stepping (it is nothing but the skipping )


DO
$$
BEGIN
	FOR counter IN 1..10 BY 2
	LOOP
		RAISE NOTICE 'counter: %',counter;
	END LOOP;
END;
$$
LANGUAGE PLPGSQL;


--For loops iterating over the result set ###############################

DO
$$
	DECLARE 
		rec RECORD;
	BEGIN
		FOR rec IN SELECT order_id,customer_id FROM orders LIMIT 10
		LOOP 
			RAISE NOTICE '%,%',rec.order_id,rec.customer_id;
		END LOOP;
	END;
$$
LANGUAGE PLPGSQL;


-- CONTINUE statament

CONTINUE [LOOP_LABEL] [WHEN CONDITION]

--lets print odd numbers only from 1 to 20;

DO 
$$
	DECLARE
		i_counter INTEGER := 0;
	BEGIN
		LOOP
			i_counter = i_counter + 1;
			EXIT 
				WHEN i_counter > 20;
			CONTINUE 
				WHEN MOD(i_counter ,2) = 1;
			RAISE NOTICE 'i_counter : %',i_counter; 
		END LOOP;
	END;
$$
LANGUAGE PLPGSQL;

--FOR EACH IN ARRSY function helps us to iterate over a array

DO
$$
	DECLARE 
		arr1 INT[] := ARRAY[1,2,3,4];
		i INT;
	BEGIN
		FOREACH i IN ARRAY arr1
		LOOP
			RAISE NOTICE 'i : %',i;
		END LOOP;
	END;
$$
LANGUAGE PLPGSQL;


-- concating two loops


DO
$$
	DECLARE 
		arr1 INT[] := ARRAY[1,2,3,4];
		arr2 INT[] := ARRAY[5,6,7,8,9];
		i INT;
	BEGIN
		FOREACH i IN ARRAY arr1 || arr2
		LOOP
			RAISE NOTICE 'i : %',i;
		END LOOP;
	END;
$$
LANGUAGE PLPGSQL;

-- writing loop for two arrays


DO
$$
	DECLARE 
		arr1 INT[] := ARRAY[1,2,3,4];
		arr2 INT[] := ARRAY[5,6,7,8,9];
		i INT;
	BEGIN
		FOREACH i IN ARRAY arr1
		LOOP
			RAISE NOTICE 'i : %',i;
		END LOOP;
		BEGIN
			FOREACH i IN ARRAY arr2
			LOOP
				RAISE NOTICE 'i : %',i;
			END LOOP;
		END;
	END;
$$
LANGUAGE PLPGSQL;

--WHILE loops ####################################################################

--trying the while loop with a basic example

CREATE OR REPLACE FUNCTION fn_while_loop_sum (x INTEGER)
RETURNS INTEGER
AS
$$
	DECLARE 
		counter INTEGER := 1;
		sum_all INTEGER := 0;
	BEGIN
		WHILE counter <= x
		LOOP
			sum_all = sum_all + counter;
			counter = counter + 1;
		END LOOP;
		RETURN sum_all;
	END;
$$
LANGUAGE PLPGSQL;
			


SELECT fn_while_loop_sum (4);

--creating a table and inserting values using the while loop

CREATE OR REPLACE FUNCTION fn_create_table (x INTEGER)
RETURNS SETOF t_table
AS
$$
	DECLARE 
		counter INTEGER := 1;
	BEGIN
		--creating a table
		EXECUTE ('CREATE TABLE IF NOT EXISTS t_table(id INTEGER)');
		WHILE counter <= x
		LOOP
			--inserting the data into the table
			INSERT INTO t_table (id) VALUES (counter);
			counter = counter + 1;
		END LOOP;
		RETURN QUERY SELECT * FROM t_table;
	END;
$$
LANGUAGE PLPGSQL;


DROP FUNCTION fn_create_table (x INTEGER);

SELECT (fn_create_table(8)).id;


--RETURN NEXT FUNCTION 


CREATE OR REPLACE FUNCTION fn_get_all_orders_greater_than() 
RETURNS SETOF order_details 
AS
$$
	DECLARE 
		r RECORD;
	BEGIN
		FOR r IN
			SELECT * FROM order_details WHERE unit_price > 100
		LOOP
			RETURN NEXT r;
		END LOOP;
		RETURN;
	END;
$$
LANGUAGE PLPGSQL;


SELECT *
FROM fn_get_all_orders_greater_than();

--ERROR HANDLING #####################################################################


--using the DATA_NOT_FOUND exception function
DO
$$
	DECLARE
		rec RECORD;
		orderid SMALLINT = 1;
	BEGIN
		SELECT 
			customer_id,
			order_date
		FROM orders
		INTO STRICT rec --It helps optimize performance and avoids unnecessary function executions 
		--when you know that NULL input should always result in NULL output.
		WHERE order_id = orderid;
		EXCEPTION 
			WHEN NO_DATA_FOUND THEN
				RAISE EXCEPTION 'No order id was found %',orderid;
	END;
$$
LANGUAGE PLPGSQL;


-- using the TOO_MANY_ROWS function

DO
$$
	DECLARE 
		rec RECORD;
	BEGIN
		SELECT 
			customer_id,
			company_name
		FROM customers
		INTO STRICT rec
		WHERE company_name LIKE 'A%';
		EXCEPTION
			WHEN TOO_MANY_ROWS THEN
				RAISE EXCEPTION 'Your query returns too many rows';
	END;
$$
LANGUAGE PLPGSQL;


--using the exception code for the exception handiling like SQLSTATE 'P0002'

DO
$$
	DECLARE 
		rec RECORD;
	BEGIN
		SELECT 
			customer_id,
			company_name
		FROM customers
		INTO STRICT rec
		WHERE company_name LIKE 'A%';
		EXCEPTION
			WHEN SQLSTATE 'P0003' THEN
				RAISE EXCEPTION 'Your query returns too many rows';
	END;
$$
LANGUAGE PLPGSQL;

--Creating a function for the exception of divisible by zero using rise info 

CREATE OR REPLACE FUNCTION fn_div_exception (x REAL,y REAL)
RETURNS REAL 
AS
$$
	DECLARE 
		ret REAL;
	BEGIN
		RET := x /y;
		RETURN ret;
	EXCEPTION
		WHEN division_by_zero THEN
		RAISE INFO 'Division by zero';
		RAISE INFO 'Error %,%',SQLSTATE, SQLERRM;
	END;
$$
LANGUAGE PLPGSQL;

SELECT fn_div_exception(5,0);