--Pg_security

/*
	paramerters that we can pass for creating a role or user

	| Parameter          | Description                                                         |
| ------------------ | ------------------------------------------------------------------- |
| `LOGIN`            | Allows the role to log in (i.e., acts like a user).                 |
| `PASSWORD 'pass'`  | Sets the role’s password.                                           |
| `CREATEDB`         | Allows the role to create databases.                                |
| `CREATEROLE`       | Allows the role to create, alter, and drop other roles.             |
| `SUPERUSER`        | Grants superuser privileges (all access).                           |
| `INHERIT`          | Allows the role to inherit privileges from roles it is a member of. |
| `NOREPLICATION`    | Denies replication privileges (default).                            |
| `CONNECTION LIMIT` | Limits number of concurrent connections for the role.               |
| `VALID UNTIL`      | Sets an expiration date/time for the role's password.               |



*/

CREATE ROLE role_name
WITH
  LOGIN
  PASSWORD 'your_password'
  CREATEDB
  CREATEROLE
  INHERIT
  CONNECTION LIMIT 5
  VALID UNTIL '2025-12-31';


  CREATE USER john_doe
  WITH
  LOGIN
  PASSWORD 'securePassword123'
  CREATEDB
  CREATEROLE
  CONNECTION LIMIT 3
  VALID UNTIL '2026-01-01';

--INSTANCE level security ############################################################################

/*
	Instance-level security in PostgreSQL (and in databases generally) refers to security controls
	applied at the level of the entire PostgreSQL server instance, rather than at the level of individual
	databases, schemas, or tables. These controls determine who can connect to the PostgreSQL server and
	what operations they can perform across all databases hosted by that instance.

*/

-- Create user and grant access
CREATE USER analyst WITH PASSWORD 'securepass';
GRANT CONNECT ON DATABASE sales_db TO analyst;


 -- Allow user to use the schema and create objects
GRANT USAGE, CREATE ON SCHEMA marketing TO analyst;

-- Read-only access to a table
GRANT SELECT ON sales TO analyst;

-- Read-only access to a table
GRANT SELECT ON sales TO analyst;

-- Allow access to only some columns
GRANT SELECT (customer_name, total_amount) ON sales TO analyst;


-- Enable RLS
ALTER TABLE employee ENABLE ROW LEVEL SECURITY;

-- Create a policy for user-specific access
CREATE POLICY emp_policy ON employee
  FOR SELECT
  USING (user_id = current_user);

/*

SCHEMA LEVEL security ##################

Create 	can create what and all lies in the schema
USAGE	can use the schema like view the schema objects

*/

REVOKE ALL ON SCHEMA public FROM public;

CREATE ROLE sales NOSUPERUSER NOCREATEDB NOCREATEROLE LOGIN PASSWORD	'WELCOME';


GRANT PERMISSIONS ON SCHEMA SCHEMA_NAME to ROLE;

GRANT USAGE ON SCHEMA public TO tech;

GRANT USAGE ON SCHEMA PUBLIC TO tech;


GRANT CONNECT ON DATABASE database_NAME TO ROLE;

GRANT CONNECT ON DATABASE hr TO tech;

GRANT CONNECT ON DATABASE hr TO sales;


/*

TABLE LEVEL SECURITY  ###################################################################

table level privilages
-----------------------

SELECT		read data/rows from table

INSERT		insert data into table

UPDATE		update data into the table

DELETE		delete data into the table

TRUNCATE 	remove all delete at once (very fast operations , be careful)

TRIGGER		create triggers on tables (high level access)

REFRENCES	Ability to create foregin key constraints

*/

-- To apying on all table 

GRANT PERMISSION ON ALL TABLES IN SCHEMA schema_name TO role_name;

--TO apply on indiviual table

GRANT permission_name ON TABLE table_name TO ROLE_NAME;


-- give sales role select all on tables in schema -> public

GRANT SELECT ON ALL TABLES IN SCHEMA public TO sales;

--give text select,insert,update,delete

GRANT SELECT ON ALL TABLES IN SCHEMA public TO tech;

GRANT UPDATE ON ALL TABLES IN SCHEMA PUBLIC TO tech;

GRANT DELETE ON ALL TABLES IN SCHEMA PUBLIC TO tech;

GRANT INSERT ON ALL TABLES IN SCHEMA PUBLIC TO tech;


GRANT INSERT ON TABLE employees TO tech;

GRANT UPDATE ON TABLE employees TO tech;

GRANT DELETE ON TABLE employees TO tech;


--column level securtiy ###########################################################################
/*

SELECT		read data from column

INSERT		insert data into column

UPDATE		update data in column

REFERENCE 	Ability to refer the column as foregin key

*NO DELETE*

*/	

GRANT permission_name (TABLE_COL1,TABLE_COL2,.......) ON TABLE_NAME TO role_name;

--	restricts employees table -> phone_number,salary info etc to be see by sales group

GRANT SELECT (employee_id,first_name) ON employees TO TECH;

--ROW LEVEL SECURITY ##########################################################################
/*

1.	Must be enable at table level, not enable by default

	ALTER TABLE table_name ENABLE ROW LEVEL SECURITY

2.	AFTER enable the row level policy, the default values is : DENY ALL

*/

--lets setup the row level security

GRANT SELECT ON TABLE jobs TO tech;

ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;


--STEP 2 CREATE A ROW LEVEL POLICY

CREATE POLICY POLICY_NAME ON TABLE_NAME 
FOR SELECT |INSERT|UPDATE|DELETE 
TO ROLE_NAME 
USING (EXPRESSION)



--CREATING a policy where sales can be only view all jobs where max_salary >= 1000

CREATE POLICY p_jobs_sales_max_salary_10000 ON jobs
FOR SELECT 
TO sales
USING (max_salary >= 10000);

/*

You can create multiple row level policies 

- more data is added at the final result
- USING (expressions) or conditions are all combined with OR operator

*/


-- for example if we create the another policy with min salary >= 4000

CREATE POLICY p_jobs_sales_min_salary_4000 ON jobs
FOR SELECT 
TO sales
USING (min_salary >= 4000)

--the output get combined with the 
SELECT * FROM jobs WHERE (max_salary >= 10000) OR
SELECT * FROM jobs WHERE (min_salary >= 4000)


--this is happening in the backend of postgtres



--Using CURRENT_USER with RLS ######################################################################

ALTER TABLE t_user_data ENABLE ROW LEVEL SECURITY;

--now lets setup the new policy we can use teh curent user
SELECT CURRENT USER;

CREATE POLICY rls_t_users_data_by_username ON t_user_data -- t_user_data is a table name
FOR ALL TO PUBLIC
USING(username = CURRENT_USER)

--row level security for application user 

/*

1. While creating policies for users we have used current_user and matched it with the users entry present in the table.

2. But there are cases where there are too many users, like web applications, and its not feasible to create an explicit 
	role for each application user.

3. Our objective remains the same:
	a user should only be able to view their own data and not others

4. One solution may be;

	Insted of using the current_user, we can changethe poilicy to use a current sesion varibale

	sesion varibale can be initialized each time a new user tries to see data.

*/

GRANT SELECT ON t_user_data TO PUBLIC;

DROP POLICY rls_t_users_data_by_username ON t_user_data;

CREATE POLICY rls_t_users_data_by_username_session ON t_user_data
FOR ALL TO PUBLIC
USING (username = current_setting ('rls.username'));

--Droping a row level policy ###########################################################################

DROP POLICy IF EXISTS policy_name ON table_name ;

/*

	1. Note that if the last-policy is removed for a table and the table still has row level securtiy enabled via
		alter table, then the default - deny policy will be used.

	2. ALTER TABLE.... DIABLE ROW LEVEL SECURITY can be used to disable row level security for a table, Whether 
		policies for the table exists or not

*/

DROP POLICY rls_t_users_data_by_username_session ON t_user_data;


 ALTER TABLE t_user_data DIABLE ROW LEVEL SECURITY


 --row level security perfomance


/*

	ROW level security via USING (expression) means
		-adding a where clause in every query

	A policy is basically mandatory Where clause;
		- Which is added to every query to ensure that the scope of a user is limited to the desired suset of data

	To pass through row -level security, each row must satisfy this where clause to pass

	More row level security policies means more WHEN's checks!

	RLS implementation strives to execute policy checks before user provided predicate checks so as to avoid leaking
	protected data.

	the perfomance of the queires that join several large RLS protected tables must be addressed

*/

/*

Column level encryption in data ##############################################################################

*/

--enable the extension name pgcrypto

CREATE EXTENSION pgcrypto;

--Lets create a sample table

CREATE TABLE PUBLIC.e_users(
	id SERIAL PRIMARY KEY,
	email VARCHAR NOT NULL UNIQUE
);

INSERT INTO e_users(email)
VALUES
	(pgp_sym_encrypt('a1@b1.com','longsecretencryptionkey')),
	(pgp_sym_encrypt('a2@b2.com','longsecretencryptionkey'));

SELECT *
FROM PUBLIC.e_users;

--lets decrypt the data 

SELECT pgp_sym_decrypt(email::bytea,'longsecretencryptionkey') FROM PUBLIC.e_users;