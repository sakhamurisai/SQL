--Structure of a function
--A function is defined with the following command structure

CREATE OR REPLACE FUNCTION function_name (p1 TYPE, p2 TYPE, .... pn TYPE)
RETURNS return_type 
AS
$$
BEGIN
	RETURN --function logic
END;
$$
LANGUAGE language_name --e.g pl/psql or pl/python or c or sql or java etc for postgres;



/*

CREATE FUNCTION		specify the name of teh function after teh create function keywords.
p1 TYPE 			Make a list of parameters sperated by commas
RETURNS 			specify the return data type after the RETURN keywords.
BEGIN .. END 		For the PL/pgsql language, put some code between the begin and end block but regular sql not required
LANGUAGE 			Defines the language in which the function was written for example any one of the following, say
					-sql
					-plsql
					-plpython
					....
*/

--this is the function for the postgresql plpgsql langauge

CREATE OR REPLACE FUNCTION fn_mysum (a INT,b INT)
RETURNS INT 
LANGUAGE plpgsql
AS
$$
BEGIN
	RETURN $1 + $2;
END;
$$;


--If we are writing the query in the sql

CREATE OR REPLACE FUNCTION fn_mysum_sql (a INT,b INT)
RETURNS INT 
AS
$$
	SELECT $1 + $2;
$$
LANGUAGE SQL;


--using the function
SELECT fn_mysum (1,2);

--using the function on a table 

SELECT fn_mysum(domestic_revenue / 1000,international_revenue /1000) AS total_revenue
FROM movie_revenue;

--Function returning no values #############################################################################
--retunns void

CREATE OR REPLACE FUNCTION fn_employees_update_country() 
RETURNS VOID 
LANGUAGE SQL
AS
$$
	UPDATE employees
	SET country = 'N/A'
	WHERE country IS NULL
$$;

SELECT *
FROM employees
WHERE country = 'N/A';

--updating the data of country to null for the table 

UPDATE employees
SET country = NULL
WHERE employee_id = 1;

--runnning the function 

SELECT fn_employees_update_country();

SELECT *
FROM employees
WHERE country IS NULL;

SELECT *
FROM employees
WHERE country = 'N/A';

--creating another function that replaces teh 'N/A' with the 'USA' in the employees Table

CREATE OR REPLACE FUNCTION fn_employees_country_usa() 
RETURNS VOID
AS
$$
	UPDATE employees
	SET country = 'USA'
	WHERE country = 'N/A'
$$
LANGUAGE SQL;

SELECT fn_employees_country_usa();

SELECT *
FROM employees
WHERE country = 'N/A';


--functioins that return a single value 

--function we want to create is a function should do unit_price * quantity = total_amount
--should return a maximum value

CREATE OR REPLACE FUNCTION fn_order_details_largest_order() 
RETURNS REAL
AS
$$
	SELECT DISTINCT MAX(total_amount)
	FROM(
			SELECT SUM(unit_price * quantity) OVER(PARTITION BY order_id) AS total_amount
			FROM order_details
		) 
$$
LANGUAGE SQL;


SELECT fn_order_details_largest_order();


--for the minmum value

CREATE OR REPLACE FUNCTION fn_order_details_smallest_order() 
RETURNS REAL
AS
$$
	SELECT DISTINCT MIN(total_amount)
	FROM(
			SELECT SUM(unit_price * quantity) OVER(PARTITION BY order_id) AS total_amount
			FROM order_details
		) 
$$
LANGUAGE SQL;


SELECT COUNT(customer_id)
FROM customers;

--create function for thje counting the number of customers

CREATE OR REPLACE FUNCTION fn_customers_total_count()
RETURNS BIGINT
AS
$$
	SELECT COUNT(customer_id)
	FROM customers;
$$
LANGUAGE SQL;

SELECT fn_customers_total_count();


--getting the total count of products from products table

CREATE OR REPLACE FUNCTION fn_products_total_products_count()
RETURNS BIGINT
AS
$$
	SELECT COUNT(product_id)
	FROM products;
$$
LANGUAGE SQL;

SELECT *
FROM product_id

SELECT fn_products_total_products_count();

--getting the total count of orders

CREATE OR REPLACE FUNCTION fn_orders_total_orders_count()
RETURNS BIGINT
AS
$$
	SELECT COUNT(*)
	FROM orders;
$$
LANGUAGE SQL;

--getting the data for total number of customers with empty fax number
-- fn_api_total_customers_empty_fax

SELECT customer_id,fax
FROM customers
WHERE fax IS NULL;

CREATE OR REPLACE FUNCTION fn_api_total_customers_empty_fax ()
RETURNS BIGINT
AS
$$
	SELECT COUNT(*)
	FROM customers
	WHERE fax IS NULL;
$$
LANGUAGE SQL;

SELECT fn_api_total_customers_empty_fax();

--getting the total number of customers with empty region for customers in customer table

CREATE OR REPLACE FUNCTION fn_api_total_customers_empty_region ()
RETURNS BIGINT
AS
$$
	SELECT COUNT(*)
	FROM customers
	WHERE region IS NULL;
$$
LANGUAGE SQL;

SELECT fn_api_total_customers_empty_region();

--functions using the parameters ########################################################

--lets create a mid function with functions with input parameters like string and starting_point

CREATE OR REPLACE FUNCTION fn_substring (p_string VARCHAR ,p_starting_point INTEGER)
RETURNS VARCHAR
AS
$$
	SELECT SUBSTRING(p_string,p_starting_point)
$$
LANGUAGE SQL;

SELECT fn_substring('My name is sai', 2);

--get total customers by city , parameters we passs : p_city ,output: number/big int

CREATE OR REPLACE FUNCTION fn_total_customers_city(p_city VARCHAR)
RETURNS BIGINT 
AS 
$$
	SELECT COUNT(*)
	FROM customers
	WHERE city = p_city;
$$
LANGUAGE SQL;

SELECT fn_total_customers_city('London');

-- getting total customeers by country

CREATE OR REPLACE FUNCTION fn_total_customers_country(p_country VARCHAR)
RETURNS BIGINT 
AS 
$$
	SELECT COUNT(*)
	FROM customers
	WHERE country = p_country;
$$
LANGUAGE SQL;

SELECT fn_total_customers_country('UK');

--get the total orders by a customer input is p_customer_id, function_name: fn_api_customer_total_orders

CREATE OR REPLACE FUNCTION fn_api_customer_total_orders(p_c_id CHARACTER)
RETURNS INTEGER
AS
$$
	SELECT COUNT(*)
	FROM customers AS c
	LEFT JOIN orders AS o ON c.customer_id = o.customer_id
	WHERE c.customer_id = p_c_id
	GROUP BY c.customer_id
$$
LANGUAGE SQL;

SELECT fn_api_customer_total_orders('VINET');


--getting the biggest order amount placed by a customer , function name : fn_api_customer_largest_order
--total_amount = unit_price * quantity - discount

CREATE OR REPLACE FUNCTION fn_api_customer_largest_order(p_c_id CHARACTER)
RETURNS DOUBLE PRECISION
AS
$$
	SELECT MAX(total_amount)
	FROM(
		SELECT o.order_id AS order_id, SUM((od.unit_price * od.quantity) - od.discount) AS total_amount
		FROM orders AS o
		INNER JOIN order_details AS od ON o.order_id = od.order_id
		WHERE o.customer_id = 'ALFKI'
		GROUP BY o.order_id
		) AS sub
$$
LANGUAGE SQL;


SELECT fn_api_customer_largest_order('ALFKI');



--getting the most ordered product by a customer , function name: fn_api_customer_most_ordered_product

CREATE OR REPLACE FUNCTION fn_api_customer_most_ordered_product(p_c_id CHARACTER) 
RETURNS VARCHAR
AS
$$
	SELECT product_name
	FROM(
		SELECT od.product_id,SUM(od.quantity) AS most_ordered_prodcut
		FROM orders AS o
		INNER JOIN order_details AS od ON o.order_id = od.order_id
		WHERE o.customer_id = p_c_id
		GROUP BY od.product_id
		ORDER BY 2 DESC
		LIMIT 1
		) AS products_table
	INNER JOIN products AS p ON products_table.product_id = p.product_id;
$$
LANGUAGE SQL;

SELECT fn_api_customer_most_ordered_product('CACTU');


--Functions returning composite #####################################################
--returns a single row, in the form of an array style

CREATE OR REPLACE FUNCTION fn_api_order_latest()
RETURNS orders 
AS
$$
	SELECT 
		*
	FROM orders
	ORDER BY order_date DESC
	LIMIT 1;
$$
LANGUAGE SQL;

SELECT fn_api_order_latest();

--if we want the out put in a regular table fomrat we use (function_name()).*

SELECT (fn_api_order_latest()).*;

--if we want to select only field name in the table (function_name()).field_name

SELECT (fn_api_order_latest()).order_date;

--there is another way for retieving the column field in the table field_name(function_name())

SELECT order_date(fn_api_order_latest());

--date range function example

CREATE OR REPLACE FUNCTION fn_api_order_lastest_by_date_range(p_from DATE , p_to DATE)
RETURNS orders 
AS
$$
	SELECT 
		*
	FROM orders
	WHERE order_date BETWEEN p_from AND p_to
	ORDER BY order_date DESC
	LIMIT 1;
$$
LANGUAGE SQL;

SELECT order_date (fn_api_order_lastest_by_date_range('1997-01-01','2020-01-01'));

--get teh most recent hire date of an employee from emplopyees table

CREATE OR REPLACE FUNCTION fn_latest_hire_date () 
RETURNS employees
AS
$$
	SELECT *
	FROM employees
	ORDER by hire_date DESC
	LIMIT 1;
$$
LANGUAGE SQL;

SELECT fn_latest_hire_date();

--extarcting the first name 

SELECT (fn_latest_hire_date()).first_name;

--functions returning multiple rows #############################################################


--list all employees hire in a particular year, function_name: fn_api_employees_hire_date_by_year

CREATE OR REPLACE FUNCTION fn_api_employees_hire_date_by_year(p_year INTEGER) 
RETURNS SETOF employees
AS
$$
	SELECT *
	FROM employees
	WHERE 
		EXTRACT(YEAR FROM hire_date) = p_year;
$$
LANGUAGE SQL;


SELECT (fn_api_employees_hire_date_by_year(1993)).*;


--Function as a table source ###############################################################
/*
	we acn use the function as a table source i.e 
	SELECT 
		column_list
	FROM function_name
*/

--function fn_api_employees_hire_date_by_year turned into a table

SELECT *
FROM fn_api_employees_hire_date_by_year(1992);


--function order matters and returning a table 
--returns table (col1,col2,...)
--in the below function if we change teh order of the function not acccording to select query it will throw error

CREATE OR REPLACE FUNCTION fn_api_employees_sample() 
RETURNS TABLE (
	first_name VARCHAR,
	last_name VARCHAR,
	title VARCHAR,
	hire_date DATE
)
AS
$$
	SELECT 
		hire_date,
		last_name,
		first_name,
		title
	FROM employees;
$$
LANGUAGE SQL;

--error occurs as the data type is not matching always try to order the function and the select similarly
SELECT fn_api_employees_sample();


--function parameters with default values ##########################################################

--syntax
CREATE FUNCTION function_name (p1 TYPE DEFAULT v1,p2 TYPE DEFAULT v2)

--lets do sum of three numbers

CREATE OR REPLACE FUNCTION fn_sum_3 (x INT,y INT DEFAULT 10,z INT DEFAULT 10)
RETURNS INTEGER 
AS
$$
	SELECT x+y+z;
$$
LANGUAGE SQL;

SELECT fn_sum_3(1);

--Functions based on views ##########################################################################

SELECT * FROM pg_stat_activity WHERE state = 'active';

CREATE OR REPLACE VIEW v_active_queries AS
SELECT 
	pid,
	usename,
	query_start,
	(current_TIMESTAMP - query_start) AS runtime,
	query
FROM pg_stat_activity
WHERE 
	state = 'active';


--input p_liimit

CREATE OR REPLACE FUNCTION fn_internal_active_queries (p_limit INT) 
RETURNS SETOF v_active_queries
AS
$$
	SELECT *
	FROM v_active_queries
	LIMIT p_limit;
$$
LANGUAGE SQL;

SELECT *
FROM fn_internal_active_queries(10);

--DROP a FUNCTION ###############################################################################

DROP FUNCTION [IF EXISTS] function_name (argument_list) [CASCADE | RESTRICT]

/*
	function name 		try to keep the function name as unique as possible 

	if exists 			Issues a notice insted of an error in case the function does not exists

	argument lists 		Since function can be overloaded, postgres needs to know which function you 
						want to remove by checking the argument list

						for functiond unique to schema , you do not need to specify arguments
	CASCADE 			to drop the function and its dependent object (Be careful)

	Restricts 			Rejects the removal of a function when it has any dependent objects
*/