/*

Functions vs Stored procedures ####################################################
-------------------------------

1. A user defined functions (create function..) cannot execute 'transactions'
	i.e Inside a function, you cannot start a transaction

2. Stored procedure support transactions

3. Stored procdures does not return values,so you cannot use 'Return';
	However, you can use the return statement without the expression to stop the stored procedure 
	immediately INOUT mode can be used to return a value from stored procedure

4. can not be executed or called from within a select statment.

5.you can call a procedure as often as you like.

6.They are compiled object.

7. Procedures may or may not use parameters (argument values).

8. Execution :
	-Explicit execution. Execute command, along with specific sp name and optional parameters.
	- Implicit execution using only sp name. Call procedure_name ()

	*/

--lets create table 

CREATE TABLE IF NOT EXISTS t_accounts(
	recid SERIAL PRIMARY KEY,
	name VARCHAR NOT NULL,
	balance dec(15,2) NOT NULL
);

--inserting some data into the table

INSERT INTO t_accounts(name,balance)
VALUES
	('Adam',100),
	('Linda',100);

--view the data 

SELECT *
FROM t_accounts;

--create stored procedure


CREATE OR REPLACE PROCEDURE pr_money_transfer(
	sender VARCHAR,receiver VARCHAR,amount DECIMAL
)

AS
$$
	BEGIN
	--removing amouint from the sender account
		UPDATE t_accounts
		set balance = balance - amount
		WHERE name = sender;
	--adding money to the reciever account

		UPDATE t_accounts
		SET balance = balance + amount
		WHERE name = receiver;
	COMMIT;
	END;
$$
LANGUAGE PLPGSQL;

CALL pr_money_transfer('Adam','Linda',5);


SELECT * 
FROm t_accounts;


/*

UNDERSTANDING WHY TO USE THE STORED PROCEDURE #######################################

1. To ensure data consistency by not requiring that a series of steps to be run or created over and over
	also if all the DBAs/developers and even applications use the same stored procedures,then the same code 
	will always be used

2. To simply complex operations and encapsulating that into a single easy to use unit

3. To simply overall 'change managment' i.e if tables, columns or bussiness logic needs to be changed then
	only the stored procedure nees to be updated of all changes at every level.

4. To ensure security i.e restricting accesss to uderlying data via stored procedures will reduce the 
	chances to datat corruption and more.

5. To fully utlize 'transaction and its all benefits for data integrity and much more'

6. Performance. the code is compiled only when crteated, meaning no need to require at runtime,
	unless you change the program (stored procedure)
stored procedures are compiled objects 
*/


-- returning a value in a stored procedure  through INOUT parameter

CREATE OR REPLACE PROCEDURE pr_orders_count (INOUT total_count INTEGER DEFAULT 0)
AS 
$$
	BEGIN
		SELECT COUNT(*)
		INTO total_count
		FROM fruits;
	END;
$$
LANGUAGE PLPGSQL;

CALL pr_orders_count();

-- working on a execise on stored procedure  created a stored procedure to insert the data into the table and 
--all the dependency tables


CREATE OR REPLACE PROCEDURE pr_insert_new_customer(
	p_store_id SMALLINT ,
	p_first_name TEXT,
	p_last_name TEXT,
	p_email TEXT,
	p_address TEXT,
	p_address_2 TEXT,
	p_district TEXT,
	p_city TEXT,
	p_postal_code TEXT,
	p_phone TEXT,
	p_country TEXT
)
AS
$$
	DECLARE 
		v_country_id INT := 0 ;
		v_city_id INT := 0;
		v_active SMALLINT:= 1;
		v_address_id INT:= 0;
	BEGIN
		--lets insert the data into the country table
		IF NOT EXISTS(SELECT 1 FROM country WHERE country ILIKE p_country)
			THEN
				INSERT INTO country (country,country_id)
				SELECT UPPER(LEFT(p_country, 1)) || LOWER(SUBSTRING(p_country, 2)),NEXTVAL('country_country_id_seq')
				RETURNING country_id INTO v_country_id;
				RAISE NOTICE 'Country did not exist creating the '
		ELSE
			SELECT country_id
			FROM country
			INTO v_country_id
			WHERE country ILIKE p_country;
		END IF;

		--lets insert the values in the city table

		IF NOT EXISTS (SELECT 1 FROM city WHERE city ILIKE p_city)
			THEN 
				INSERT INTO city(city,country_id,city_id)
				SELECT 
					UPPER(LEFT(p_city, 1)) || LOWER(SUBSTRING(p_city, 2)),v_country_id,NEXTVAL('city_city_id_seq')
				RETURNING city_id INTO v_city_id;
		ELSE
			SELECT city_id
			FROM city
			INTO v_city_id
			WHERE city ILIKE p_city;
		END IF;
			
		--lets insert the data into the table address
		
		INSERT INTO address(
			address_id,
			address,
			address2,
			district,
			city_id,
			postal_code,
			phone
		)
		VALUES(
				nextval('address_address_id_seq')
				p_address,
				p_address_2,
				p_district,
				v_city_id,
				p_postal_code,
				p_phone
				)
				RETURNING address_id INTO v_address_id; --inserting the address id into the variable

		
				
		-- lets insert the customer data into the table

		INSERT INTO customer(customer_id,
			store_id,
			first_name,
			last_name,
			email,
			address_id,
			active
		)
		VALUES (
			nextval('customer_customer_id_seq'), --if we wanted to insert the value according to the 
			p_store_id,
			p_first_name,
			p_last_name,
			p_email,
			v_address_id,
			v_active
		);
	END;
$$
LANGUAGE PLPGSQL;




-- calling and adding the insert values to the procedure

	CALL pr_insert_new_customer(
	    1 :: SMALLINT,          
	    'John',     
	    'Doe',      
	    'john.doe@example.com', 
	    '123 Main St',        
	    NULL,                 
	    'Downtown',           
	    'Frisco',               
	    '75034',                
	    '555-1212',             
	    'United States'     
	);

