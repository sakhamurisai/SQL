/*

TRIGGER #######################################################################################
-------

1. A trigger is defined as any event that sets a course of action in a motion.

2. A postgreSQL trigger is a function invoked automatically whever 'an event' associated with a table or
	view occurs

3. An event could be any of the following:

	-INSERT 
	-UPDATE
	-DELETE
	-TRUNCATE

4. A trigger can be associate with a specified 
	-Table,
	-vie or
	-Foreign table

5. A trigger is a special 'user defined function'

6. The diffferences between a trigger and a user - defined function is that a trigger is automatically 
	invoked when a triggering event occurs.

7. we can create trigger 

	-BEFORE 
		- If the trigger is invoked before an event, it can skip the operation for the current row or even
			change the row being updated or inserted
	- After 
		- All changes are avilable to the trigger.
	-INSTEAD
		- of an event /operation.

8. If there are more than one triggers on a table, then they are fired in alphabaticall order. First, all
	of those before triggers happen in alphabetical order. Then, postgreSQL performs the row operation that
	the trigger has been fired for, and continues executing after the triggers in alphabetical order.

9. Triggers can modify data before or after teh actual modicfications has happened. In general, this is a 
	good way to verify data and to error out if some custom restrictions are violated.

10. There are two main characteristics that make triggers different than stored procedures.
	- Triggers cannot be manually executed by the user.
	- There is no chance for triggers to recieve parameters.


	** make sure when you are creating a unlimited triggers beacuse all the riggers will be executed 
		alaphabetaically keep in my the execution order of the triggers;***

*/

/*

types of triggers #######################################################################

1. Row level trigger 
	If the trigger is marked FOR EACH ROW then the trigger function will be called for each row that is 
	getting modified by the events.

	e.g., If we update 20 rows in the table, the UPDATE trigger function will be called 20 times, Once
	for each updated row.

2. Statment level trigger

	The FOR EACH STATMENT option will call the trigger function only ONCE for each statment,regardless of
	the number of the rows getting modified.

	When to use which trigger at what event (insert, update, delete, truncate)
************************************************************************************************************
*	When 				Event				row_level					statment-level
*	-----				------				---------					----------------
*						Insert/update		Tables						Tables and views
*						Delete
*				
*Before					Truncate 			-							tables
*
*						INSERT /UPDATE/
*						Delete 				Tables						tables and views
*
*AFTER 					TRUNCATE 			-							Tables
*	
*						INSERT /UPDATE/
*						DELETE				Views							-
*
*
*INSTEAD OF 			TRUNCATE			-								-
***********************************************************************************************************


✅ Advantages of Triggers:
Automation: Automatically execute actions like logging, validation, or data modification without
needing manual intervention.

Data Integrity: Enforce business rules directly within the database, ensuring consistency across
all applications interacting with it.

Auditability: Easily track and log changes (inserts, updates, deletes) to sensitive data for
auditing purposes.

Decoupling Logic: Business logic can be embedded in the database, reducing the complexity of
application-level code.

Custom Validation: Automatically validate data before insertion or update, ensuring data quality.

Cascading Operations: Triggers can automatically update related data across tables, improving consistency.

Efficiency: Reduces the need for additional application-level processes (like data checks) to be
executed separately.

❌ Disadvantages of Triggers:
Performance Overhead: Can slow down data operations, especially for row-level triggers, as they
execute for each affected row.

Complex Debugging: Troubleshooting trigger-related issues can be difficult since they are executed
automatically and may not be immediately visible to developers.

Hidden Logic: Business logic inside triggers can make the system harder to understand, especially
for new developers or those unfamiliar with the database design.

Unintended Side Effects: Incorrect or overly broad triggers can lead to unexpected behavior, such
as cascading actions that are hard to track.

Difficulty in Testing: Triggers can complicate unit testing, as their behavior is often implicit
in database operations and might not be easily isolated.

Limited Flexibility: Complex workflows or operations might be better handled in the application
layer, as triggers may not provide the same flexibility as code written in a full programming language.

Error Handling: Triggers do not have as sophisticated error handling as application code, making
complex recovery or rollback situations harder to manage.




TRIGGER KEY POINTS ###############################################################################################


1. No triggers on selectt statment, because SELECT does not modify any rows in such cases lets use views

2. Multiple tirggers can be used in alphabetyical orders

3. UDF (user defined functions) are allowed in triggers

4. A single trigger can support Multiple actions i.e single -> many 


*/


--Triggere creation process ###########################################################

--To create a new trigger in postgreSQL, you follow these steps:
	-- first, Create a trigger function using CREATE FUNCTION statment.
	-- second, bind the trigger function to a table by using create function statment.


--creating a function called by a trigger syntax

CREATE FUNCTION trigger_function()
RETURNS TRIGGER 
AS
$$
BEGIN
	--trigger logic
END;
$$
LANGUAGE PLPGSQL;


CREATE TRIGGER triiger_name
{BEFORE |AFTER} {event}
ON TABLE_NAME 
	[FOR [EACH] {ROW | STATEMENT} ]
	EXECUTE PROCEDURE trigger_function


--Data auditing with trigger
----------------------------

--creating a players table 

CREATE TABLE players(
	player_id SERIAL PRIMARY KEY,
	name VARCHAR(100)
);


--lets create a players table audit 


CREATE TABLE players_audits(
	player_audit_id SERIAL PRIMARY KEY,
	player_id INT NOT NULL,
	name VARCHAR(100) NOT NULL,
	edit_date TIMESTAMP NOT NULL
);

SHOW search_path;

SET SEARCH_PATH TO public;


SELECT * FROM players;

SELECT * FROM players_audits;
--First lets create a function after that we can bind the function to that trigger

--Creating a function that checks the new name with the old name and then adds the old dat to the table

CREATE OR REPLACE FUNCTION fn_name_check()
RETURNS TRIGGER
AS
$$
	BEGIN
		IF NEW.name <> OLD.name THEN
		INSERT INTO players_audits (player_id, name, edit_date)
		VALUES (
			OLD.player_id,
			OLD.name,
			NOW()
		);
		END IF;
		RETURN NEW;
	END;
$$
LANGUAGE PLPGSQL;

--Creating a trigger binding this function to the trigger
--thgis trigger is is only works on update function

CREATE TRIGGER trg_players_name_changes
	BEFORE UPDATE OF name --of is on,y valid for the update statments
	ON players
	FOR EACH ROW
	EXECUTE PROCEDURE fn_name_check();


--inserting some data into the table players

INSERT INTO players (name) 
VALUES
	('Adam'),
	('Linda');

--lets update the data in the table

UPDATE players
SET name = 'Linda_3'
WHERE player_id = 2;


--querying through the table

SELECT * FROM players_audits;

SELECT * FROM players;

--Modify the dat at the insert event ############################################################
/*
	Triggers can modify data BEFORE and AFTER the ACTUAL modifications has happened. This is a good way
	to varify data and error out data mistakes and more.

	Lets demonstrate the use of trigger to

	a. check the inserted data and 
	b. Then change it needed as per teh logic

*/

--lets create table

CREATE TABLE t_temperature_log (
	id_temperature_log SERIAL PRIMARY KEY,
	add_date TIMESTAMP,
	temperature NUMERIC
);


--creating a function that modifys teh inserting data into the tabel 
--the function we wanted to create is what ever the temperature that is -30 degrees then it is zero

SELECT * FROM t_temperature_log;


CREATE OR REPLACE FUNCTION fn_temperature_log_checker()
RETURNS TRIGGER
AS
$$
	BEGIN 
		IF NEW.temperature < -30 THEN
			NEW.temperature := 0;
		END IF;
		RETURN NEW;
	END;
$$
LANGUAGE PLPGSQL;


-- Lets bind our function to our table

CREATE OR REPLACE TRIGGER trg_temperature_log
	BEFORE INSERT 
	ON t_temperature_log
	FOR EACH ROW
	EXECUTE PROCEDURE fn_temperature_log_checker();



--Inserting the data

INSERT INTO t_temperature_log (add_date, temperature)
VALUES 
	('2020-01-01',100),
	('2021-01-01',-350);


SELECT * FROM t_temperature_log;



CREATE OR REPLACE FUNCTION fn_trigger_variables_display()
RETURNS TRIGGER
AS
$$
	BEGIN
		RAISE NOTICE 'TG_NAME: %',TG_NAME;
		RAISE NOTICE 'TG_RELNAME: %',TG_RELNAME;
		RAISE NOTICE 'TG_TABLE_SCHEMA: %',TG_TABLE_SCHEMA;
		RAISE NOTICE 'TG_TABLE_NAME: %',TG_TABLE_NAME;
		RAISE NOTICE 'TG_WHEN: %',TG_WHEN;
		RAISE NOTICE 'TG_LEVEL: %',TG_LEVEL;
		RAISE NOTICE 'TG_OP: %',TG_OP;
		RAISE NOTICE 'TG_NARGS: %',TG_NARGS;
		RAISE NOTICE 'TG_ARGV: %',TG_ARGV;
	RETURN NEW;
	END;
$$
LANGUAGE PLPGSQL;

--lets bind this function to the table

CREATE TRIGGER trg_trigger_variables_display
	AFTER INSERT 
	ON t_temperature_log
	FOR EACH ROW
	EXECUTE PROCEDURE fn_trigger_variables_display();


--Disallowing DELETE ######################################################################

/*
	In some cases the data can only be added and modified but not deleted 

	One way of doing this is to revoke the delete operations for the table another is to use 
	the triggers!!!!!!!!!!!!
*/


--lets create a test table

CREATE TABLE IF NOT EXISTS test_delete(
	id INT
);

--Creating a function 

CREATE OR REPLACE FUNCTION fn_delete_blocker()
RETURNS TRIGGER
AS
$$
	BEGIN
		IF TG_WHEN = 'AFTER' THEN --TG_when contains teh data like AFTER , BEFORE like that it is a triger variable
		
		RAISE EXCEPTION 'You are not allowed TO % rows in %.%',
		TG_OP,TG_TABLE_SCHEMA, TG_TABLE_NAME;
		END IF;
	RAISE NOTICE  '% On rows in %.% won''t happen', TG_OP,TG_TABLE_SCHEMA, TG_TABLE_NAME;

	RETURN NULL;
	END;
$$
LANGUAGE PLPGSQL;

-- Creating the trigger and binding the trigger funcion to that

CREATE TRIGGER trg_disallow_delete
	AFTER DELETE
	ON test_delete
	FOR EACH ROW
	EXECUTE PROCEDURE fn_delete_blocker();

--Now lets try to delete a field and check the data 

DELETE FROM test_delete WHERE id = 1;

SELECT * FROM test_delete;

--inserting into the data 

INSERT INTO test_delete
VALUES(1),(2),(3),(4);


--Disallowing the TRUNCATE function 

/*

	- PostgreSQL TRUNCATE quickly removes all rows from a set of tables . It has the same effect as an unqualified 
	DELETE on each table, but since it does not actually scan the tables it is faster.Furthur more, it reclaims disk
	space immediatley,rather than requiring a subsequent VACCUM opearation.This is most useful on large tables.


	problem: In the previous example, a user can still delete the record using the TRUNCATE !

			TRUNCATE test_delete;

			So we will work on disallowing TRUNCATE here.

	Solution: While we cannot simply skip TRUNCATE by returning NULL as opposed to the row - level BEFORE triggers,
			however, we can still make it impossible by rasing an error if TRUNCATE is attempted
	

*/

TRUNCATE test_delete;


INSERT INTO test_delete(id)
VALUES 
	(1),(2),(3),(4);


CREATE OR REPLACE TRIGGER trg_diallow_truncate
AFTER TRUNCATE
ON test_delete
FOR EACH STATEMENT
EXECUTE PROCEDURE fn_delete_blocker();



--the audit trigger #################################################################################

/*
	1. One of the most common use of triggers is to log data changes to tables in a consistent and transparant manner.

	2.When creating a audit trigger, we first must decide what we want to log.

	3. A logical set of things that can be loggged are;
		- Who changed the data,
		- When the data was changed,
		- and which operation changed the data 
*/

--lets create a master table
CREATE TABLE IF NOT EXISTS audit(
	id INT
);


--creating an audit log table

CREATE TABLE IF NOT EXISTS audit_log(
	username TEXT,
	add_time TIMESTAMP,
	table_name TEXT,
	operation TEXT,
	row_before JSON,
	row_after JSON
);

/*

we will popu;ate the above table audit log with some internal valirabl;es


username 		session user like for example: POSTGRES,sai,other user..

add_time 		Event time converted into utc (universl time coordinated ) with day light saving etc.
				CURRENT_TIMESTAMP AT TIME ZONE 'UTC'

table_name 		TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME example public.audit 

operation 		TG_OP 		INSERT , UPDATE, DELETE

row_before		Finally, the before and after images of rows are stored as rows converted as json
row_after 		which is avilable as its own datatype

*/


--lets create a function
--please note that new and old are not null for teh delete and teh insert triggers correspondingly


CREATE OR REPLACE FUNCTION fn_audit_log()
RETURNS TRIGGER
AS
$$
	DECLARE 
		old_row JSON := NULL;
		new_row JSON := NULL;
	BEGIN
		IF TG_OP IN('UPDATE','DELETE') THEN --if the operation is update or delete
			old_row = ROW_TO_JSON(OLD);
		END IF;

		IF TG_OP IN ('INSERT','UPDATE') THEN --if the operation is insert or update
			new_row = ROW_TO_JSON(NEW);
		END IF;
		--lets insert the data into the audit log table

		INSERT INTO audit_log(
			username ,
			add_time ,
			table_name ,
			operation ,
			row_before ,
			row_after 
		)

		VALUES (
			SESSION_USER,
			CURRENT_TIMESTAMP AT TIME ZONE 'UTC',
			TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME,
			TG_OP,
			old_row,
			new_row
		);
	RETURN NEW;
	END;
$$
LANGUAGE PLPGSQL;

--lets create a trigger and bind the function to the trigger

CREATE TRIGGER trg_audit
AFTER INSERT OR UPDATE OR DELETE
ON audit
FOR EACH ROW
EXECUTE PROCEDURE fn_audit_log();


--lests test and insert teh data into teh audit table

INSERT INTO audit
VALUES(1),(2);


SELECT *
FROM audit;


SELECT *
FROM audit_log;


UPDATE audit
SET id = 3
WHERE id = 2;

SELECT *
FROM audit_log;

--Creating a conditional triggers #####################################################################
/*
	1. We can use the conditional triggers by using a generic when clause 

	2. With a WHEN clause, you write some conditions except a subquery (because subquery tested before the trigger
		function is called )

	3. The WHEN expression should result into boolean value. If the value is FALSE or NULL (which is automatically 
		converted to FALSE ), the trigger function is not called.


		for example we want to enforce "no INSERT / UPDATE/DELETE" on friday afternoon

		We will use 
			-- WHEN condition
			-- we will use FOR EACH STATMENT
			-- we will pass a 'parameter' to EXECUTE PROCEDURE function_name(parameter)
*/

-- letys first create a table

CREATE TABLE IF NOT EXISTS mytask(
	task_id SERIAL PRIMARY KEY,
	task TEXT
);

-- we will create a geneic function which will show a message and return null.

CREATE OR REPLACE FUNCTION fn_cancel_with_message()
RETURNS TRIGGER
AS
$$
	BEGIN
		RAISE EXCEPTION '%', TG_ARGV[0];
		RETURN NULL;
	END;
$$
LANGUAGE PLPGSQL;


-- lets create a trigger statment we will be running this on statment level 

CREATE TRIGGER trg_no_update_on_friday_afternoon
BEFORE INSERT OR UPDATE OR DELETE OR TRUNCATE 
ON mytask
FOR EACH STATEMENT
WHEN
	(
		EXTRACT ('DOW' FROM CURRENT_TIMESTAMP) = 2 AND CURRENT_TIME > '11:00' --updated teh data for testing
	)
EXECUTE PROCEDURE fn_cancel_with_message('NO updates are allowed today so chill');


--testing the trigger
INSERT INTO mytask(task) VALUES('test');

-- Event triggers ##############################################################################

/*
event triggers are a special type of trigger that respond to DDL (Data Definition
Language) events, such as CREATE, ALTER, DROP, etc., instead of data changes like INSERT, UPDATE, or DELETE.


| Regular Trigger                                      | Event Trigger                                                       |
| ---------------------------------------------------- | ------------------------------------------------------------------- |
| Fires on data changes (`INSERT`, `UPDATE`, `DELETE`) | Fires on **schema changes** (`CREATE TABLE`, `DROP FUNCTION`, etc.) |
| Attached to a specific table                         | Not attached to a specific table                                    |
| Uses `BEFORE`, `AFTER`, or `INSTEAD OF`              | Uses event types like `ddl_command_start`, `ddl_command_end`, etc.  |




--creating a event trigger

/*
Requirements of event trigger
------------------------------

1. Before creating an event trigger, we must have a function that the trigger will execute

2. The function must return a special type called EVENT_TRIGGER

3. This function need not (and may not ) return a value ; the return type serves merely as a signal that the function
	is to be invoked as an event trigger

in case of the multiple trigger
-----------------------------------

They are also executed alphabetically order

EVENT TRIGGERS  (like other functions) cannot be executed in an aborted transaction
---------------------------------------------------------------------------------------

i.e if a DDL command fails with an eror, any associated ddl_command_end triggers will not be executed 

Conversely, If a ddl-command_start triggers fails with an error, no furthur event triggers will fire, and no attempt 
will be made to execute the command itself.

Similarly, if a ddl_command_end trigger fails with an error, the effects of the DDl statements will be rolled back,
just as they woul be in any other case where the containing transaction aborts.



EVENT triggers events 
----------------------

ddl_command_start			This event occurs just before a create, alter, or drop DDL command is executed

ddl_command_end				This event occurs just AFTER a create, alter, or drop command has finished executing

table_rewrite				This event occurs just before a table is rewritten by some actions of the commands alter
							table and alter type

sql_drop 					This event occurs just before the ddl_command_end event for teh commands that frop database
							objects


Event Triggers Variables
-------------------------

TG_TAG	this variable contains the tag or the command for which the trigger is executed.this variable does not contain
		the full command string, but just a tag such as create table, DROP table , alter table and so on.

TG_EVENT	This variable contains the event name, which can be ddl_command_start, ddl_comman_end, and sql_drop

*/

--Creating an audit trail event trigger
*/

CREATE TABLE audit_ddl(
	audit_ddl_id SERIAL PRIMARY KEY,
	username TEXT,
	ddl_event TEXT,
	ddl_command TEXT,
	ddl_add_time TIMESTAMPTZ
);

-- Creating a event trigger function
/*
By default, when a user executes a function in PostgreSQL, the function runs with the privileges
of the user callingit.
But if you declare a function with SECURITY DEFINER, the function instead runs with the privileges
of the function's creator (definer).
*/

CREATE OR REPLACE FUNCTION fn_event_audit_ddl()
RETURNS EVENT_TRIGGER
SECURITY DEFINER 
AS
$$
	BEGIN
		--insert the data into the audit ddl

		INSERT INTO audit_ddl(
			username,
			ddl_event,
			ddl_command,
			ddl_add_time
		)

	VALUES (
		session_user,
		TG_EVENT,
		TG_TAG,
		NOW()
	);

	--Rasie a notice 
	RAISE NOTICE 'DDL activity is added !!';
	END;
$$
LANGUAGE PLPGSQL;

--creating event trigger statment 

--using the without condition

CREATE EVENT TRIGGER trg_event_audit_ddl
ON ddl_command_start
WHEN 
	TAG IN ('CREATE TABLE')
EXECUTE PROCEDURE fn_event_audit_ddl();


SELECT *
FROM audit_ddl;


CREATE TABLE ddl_audit_checker(id INT);


--Prevent schema changes #####################################################################

/*
	Lets implement a policy;
	'No' table are allowed to be created during 9 am and 4pm time
*/

--lets create our trigger 

CREATE OR REPLACE FUNCTION fn_event_abort_create_table()
RETURNS EVENT_TRIGGER
SECURITY DEFINER
AS
$$
	DECLARE 
		current_hour INT = EXTRACT('hour' FROM NOW());
	BEGIN
		IF current_hour BETWEEN 9 AND 16 THEN
			RAISE EXCEPTION 'tables are not allowed to becreated between 9 - 4';
		END IF;
	END;
$$
LANGUAGE PLPGSQL;

--lest create a trigger even

CREATE EVENT TRIGGER trg_event_abort_create_table_function
ON ddl_command_start
WHEN 	TAG IN ('CREATE TABLE')
EXECUTE PROCEDURE fn_event_abort_create_table();

--test the trigger

CREATE TABLE ddl_t2(i int);
