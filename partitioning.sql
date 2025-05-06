--Partitioning ################################################################################
/*
	Partition is splitting one table into 

	- multiple smaller,
	- logically divided and
	- more managable pieces tables

	partition leads to a huge perfomance boost.

	Postgres is able to exclude partitionsthat,for sure,won't affected by the data we are reading or writing
	read/write only what is needed

	Partitioned tables can improve query perfomance by allowing the database query optimizer to sacn only the data 
	neede to satisfy a given query instead of scanning all the contents of a large table.



When to use the partition

	1. when we have a large table or is the table is large wnough?

		- Large fact table aree good candidiates for table partitiong. If you have millions or billions of records in
			a table

		-Don't think about partitiong before reaching several millions of records, as there would be no gain in perfomance
			,beacuse postgres have a robust enginbe that can query through a few million records without needing a partition

		- Also, For smaller tables with only a few thousand rows or less(that is not what we wanted partition tables to be)
			, the administrative over head of maintaing the partitions will overweigh any perfomance benefits you might see.

	2. Your table qualify top be able to logically divide into smaller chucks
		
		-e.g sever logs, where you can split them by 'date' having all the records related to the same day in the same partition.
			Bulk operation like deleting old logs would be as single as dropping a partition.

	3. Experencing unsatisfactory perfomance / slow queries?

		- Although always first check the query plans, respective indices to solve first 

		- Test with partition table to see if the query execution times incresed after the partition or not 

	4. To aviod scanning the entire table, and have fast query processing

		- Review indices on large table i.e primary, foreign keys and composite indices before partitiong 

	5. In a large table, some columns are frequently occuring in where clause

		- Examine the where clause of your query worload and look for table columns that are consisitently used
			to access data 

		- Partition based on most frequent query condition e.g.

			Query looks by dates		Partition by date e.g. Weekly, monthly tables etc.
			Query looks by region		Partition by each region type etc.

	6. Table can't fit into memory

		- Strongly advice not to reach this limit, Usually when a table hits the size of some gb it is time to partition

		- Always try to acheive the effiecient usage of memory

	7. Bussiness requirement for maintaining historical data 

		- Your data warehouse needs to maintain a window of historical data 

		- Past data is important but may not be neede for query

		- For example , your data warehouse may require that you keep data for the past twleve months.
			If the data is partitioned by month, you can easily drop the oldest monthly partition from
			the ware house and load current data into the most recently partition

	8. Is your data can be divided into say equal parts based on some good criteria 

		- When partitioning, try to divide your data as evenly as possible 
		- Partitions containing a relatively equal number of records will boost query execution perfomance

	9. Do not create more partitions than are needed.

		- Having too many partitions means over head on managmanet/maintainance tasks like;
			- vacumming
			- recovering segmanets,
			- expanding the cluster,
			- cheking disk usage and many more

	10. Queries that scan every partition run slower than if the table were not partitioned correctly.

table inheritance #####################################################################################

1. Inheritance is an object-oreiented concept when a subclass inherits the proprtites of its parent class

2. In postgres, a table inherits from its parent table

3. An example : master -> master_child

*/

-- practce for the table inhertance

-- Parent table
CREATE TABLE vehicle (
    id SERIAL,
    type TEXT,
    manufacturer TEXT
);

-- Child table inheriting from vehicle
CREATE TABLE car (
    num_doors INT
) INHERITS (vehicle);

-- Insert into child
INSERT INTO car (type, manufacturer, num_doors)
VALUES ('Sedan', 'Toyota', 4);

-- Query parent (includes child rows)
SELECT * FROM vehicle;



-- lets create a table

CREATE TABLE master(
	pk INTEGER PRIMARY KEY,
	tag TEXT,
	parent INTEGER
);

--creating a child table

CREATE TABLE master_child() INHERITS (master);

--adding constraint to the child table

ALTER TABLE master_child
ADD CONSTRAINT master_pk PRIMARY KEY (pk);

--viewing the table

SELECT * FROM master;

SELECT * FROM master_child;

--The child table inherits all the fields from the parent table.
--by using this \d+ table_name in the terminal window we can see teh information about the parent and child table

--inserting data into the table

--inserting into parent master table

INSERT INTO master(pk,tag,parent)
VALUES (1,'pencil',0);

--inserting into child table 

INSERT INTO master_child (pk,tag,parent)
VALUES (2,'notebook',0);

--lets check the data inserted into the table

SELECT *
FROM master;


SELECT *
FROM master_child;

--using the for ONLY to get the only inserted records from the table

SELECT * FROM ONLY master;

SELECT * FROM ONLY master_child;

--lets update the master table and we will check the child table

UPDATE master
SET tag = 'monitor'
WHERE pk = 2;


SELECT *
FROM master;


SELECT *
FROM master_child;


--droping the master table

DROP TABLE master; -- because they are are having dependecies we cannot delete the master with this command

DROP TABLE master CASCADE; -- This will delete all the child tables that are depending on the master table


-- Types of partition ##############################################################################

/*
	-- high level over view
	
	1. Range 	The table is partitioned into "ranges" defined by a key column or set of columns,
				with no overlap between the ranges of values assigned to different partitions.

	2. List		The table is partitioned by explicitly listing which key values apper in each partition.

	3. Hash		The table is partitioned by specific a modulus and a remainder for each partition. Each partition
				will hold the rows for which the hash value of the partition key divided by the specificed modulus
				produce the specified remainder.

*/

--partition by range ################################

/*
	- The table is partitioned into "ranges" defined by a key column or set of columns, with no overlap between
		the ranges of values assigned to different partitions

	- Useful when working with dates e.g Daily/weekly/montly/yearly partitions

	- Consider partitioning by the most granular level.

		-for example, for a table partitioned by date, you can partition by;

			a. day and have 365 daily patitions or

			b. partition by year then subpartition by month then subpartition by day or
					YEAR
						MONTH
							DAY

			c. partition by month and then subpartition by day 
					MONTH 
						DAY
			d. MONTH partition

	- A multi - level design can reduce query plainning time, but a flat partition design runs faster.

*/
		
-- 1. Lets create the master table 'employees_range'
--PARTITION BY RANGE(field)

CREATE TABLE employees_range(
	id BIGSERIAL,
	birth_date DATE NOT NULL,
	country_code VARCHAR(2) NOT NULL
)PARTITION BY RANGE (birth_date);


--2. view the table

SELECT * FROM employees_range;

-- for partitioning on date one think we have to keep in mind is that we have to keep date + 1 day b

--syntax to create a partition table

CREATE TABLE partition_table_name PARTITION OF master_table
FOR VALUES FROM value1 TO value2

--creating a partition table for the year 2000

CREATE TABLE employees_range_y2000 PARTITION OF employees_range
FOR VALUES FROM ('2000-01-01') TO ('2001-01-01');


--creating a partition table for the year 2001

CREATE TABLE employees_range_y2001 PARTITION OF employees_range
FOR VALUES FROM ('2001-01-01') TO ('2002-01-01');


--lets insert some data into the master table employees_range

INSERT INTO employees_range (birth_date,country_code) VALUES
('2000-01-01','US'),
('2000-01-02','US'),
('2000-12-31','US'),
('2001-01-01','US'),
('2001-02-01','US'),
('2001-01-05','US'),
('2000-09-01','US');


-- View contents of master table

SELECT * FROM employees_range; --able to see the data

--checking the data only in the table

SELECT * FROM ONLY employees_range; -- no data, becuase we have partitioned the data entered as entered data is with
										-- in the partiitions values it will be stored in the patitions table

-- lets check the partitioned table

SELECT * FROM ONLY employees_range_y2000;

SELECT * FROM ONLY employees_range_y2001;


--UPDATE operations ##############################################################################

--remember we should never update partitioned table we should only bupdate the master table

UPDATE employees_range
SET birth_date = '2001-01-08'
WHERE id = 1;


--checking the QUERY PLIANNINGS

EXPLAIN SELECT *
FROM employees_range;

/* IN the above query we didi not specify WHERE condition, so postgresql doesn't know which partition to scan,
	so it scans all patitions. This is same as un-partitioned tables, as the query is not using any partition.
*/


EXPLAIN SELECT *
FROM employees_range
WHERE birth_date = '2000-01-02';

--if we try to insert the values that are out of partition range then it will show this error

/*ERROR:  no partition of relation "employees_range" found for row
Partition key of the failing row contains (birth_date) = (2010-01-01). */


INSERT INTO employees_range(birth_date,country_code)
VALUES
	('2010-01-01','ES');

--PARTITION by LIST #########################################################################################

/*
	1. The table is partitioned by explicitly listing which key values appear in each partition.

	2. A list partitioned table can use any data type column that allows equality comparisions as its partition key 
		column.

	3. can also have a multi - column (composite) partition key

	4. Ideal for conditions when you know (kknown values of partition key)
		e.g.
			country code , US,UK etc
			month_name jan,feb,march
			Etc
	5. We create partition by list when we want to create a partition on a list of values e.g

		we have a employee_table in that we are having employee with thier nationality
		like USA,UK 
		for that we create a list of country code 
*/

--lets create a master table 
--PARTITION BY LIST (field)

CREATE TABLE employees_list(
	id BIGSERIAL,
	birth_date DATE NOT NULL,
	country_code VARCHAR(2) NOT NULL
) PARTITION BY LIST (country_code);


--Create the indivdual partition tables based on field values

--syntax 

CREATE TABLE partition_table_name PARTITION OF table_name
FOR VALUES IN (field);

CREATE TABLE employees_list_us PARTITION OF employees_list
FOR VALUES IN ('US');

--now creating a table for a country list

CREATE TABLE employees_list_eu PARTITION OF employees_list
FOR VALUES IN ('UK','DE','IT','FR','ES');

--first lets look intoi the master table

INSERT INTO employees_list(birth_date,country_code)
VALUES
	('2000-01-01','US'),
	('2000-01-02','UK'),
	('2000-12-31','DE'),
	('2001-01-01','IT'),
	('2001-02-01','US'),
	('2001-01-05','FR'),
	('2000-09-01','US');

--quering through the table 

SELECT * FROM employees_list;

SELECT *
FROM employees_list_us;

SELECT *
FROM employees_list_eu;


SELECT * FROM ONLY employees_list;

SELECT *
FROM ONLY employees_list_us;

 
--lets update the table 

UPDATE employees_list
SET country_code = 'US'
WHERE id = 2;



--PARTITION BY HASH(field)

/*
	1. The table is partitioned by specifying a modulus and a remainder for each partition.

	2. This type is useful when we can't logically divide your data.

	3. use this type if ou want to reduce the table size by spreading rows into many smaller partitions.

	4. Lets divide our employees_hash master table to 3 (almost) equally # of data rows
*/

CREATE TABLE employees_hash(
	id BIGSERIAL,
	birth_date DATE NOT NULL,
	country_code VARCHAR(2) NOT NULL
) PARTITION BY HASH (id);

-- we will create individual partition tables based on field values


--syntax
CREATE TABLE partition_table PARTITION OF master_table
FOR VALUES WITH (MODULUS m, REMAINDER n);

CREATE TABLE employees_hash_1 PARTITION OF employees_hash
	FOR VALUES WITH (MODULUS 3, REMAINDER 0);

CREATE TABLE employees_hash_2 PARTITION OF employees_hash
	FOR VALUES WITH (MODULUS 3,REMAINDER 1);

CREATE TABLE employees_hash_3 PARTITION OF employees_hash
	FOR VALUES WITH (MODULUS 3, REMAINDER 2);


--we are not diving the data in logical matter

--insert the data into the table

INSERT INTO employees_hash(birth_date,country_code)
VALUES
	('2000-01-01','US'),
	('2000-01-02','UK'),
	('2000-12-31','DE'),
	('2001-01-01','IT'),
	('2001-02-01','US'),
	('2001-01-05','FR'),
	('2000-09-01','US');

--lets query that data 

SELECT * FROm employees_hash;

SELECT * FROM employees_hash_1;

SELECT * FROM employees_hash_2;

SELECT * FROM employees_hash_3;

--lkets update the table employees_hash

UPDATE employees_hash
SET country_code = 'US'
WHERE id = 3;

SELECT *
FROM employees_hash
WHERE id = 1;

--DEFAULT PARTITION ############################################################################

--when we try to insert the record or data that can't fit into any partition then we use the defualt table to store

CREATE TABLE partition_table_name PARTITION OF parent_table DEFAULT;


CREATE TABLE employees_list_default PARTITION OF employees_list DEFAULT;

-- now lets try to insert the data that is not in the parition list

INSERT INTO employees_list (birth_date,country_code)
VALUES
	('2000-01-01','JP');


SELECT *
FROM employees_list


SELECT *
FROM ONLY employees_list_default;


-- Sub Partitioning #########################################################################################
/*
	1. A single partition can also be a partitioned table

	2. CAUTION:

	parent table
		partition 1
			partition 1.1
			partition 1.2
		partition 2
			patition 2.1

			
			When you create multi level partition specially on ranges, it is easy to create a large number of 
			subpartitions, some containing little or no data.

			This can add many entries to the system tables, which increases the time and memory required to optimize
			and execute queries. In such cases, try to increase the range interval or choose a different partitioning 
			startegy to reduce the number of subpartition created.

	3. Sub partition naming conventions played a vital role here, so plan the naming conventions

*/

SELECT *
FROm employees_list;

--creating a master table

CREATE TABLE employees_master(
	id BIGSERIAL,
	birth_date DATE NOT NULL,
	country_code VARCHAR(2) NOT NULL
) PARTITION BY LIST (country_code);

--lets create partitions 

CREATE TABLE employees_master_us PARTITION OF employees_master --this creates a parent partition for us country code
	FOR VALUES IN ('US');

-- in the below code we are partitioing by employees_master and furthure we are partitiong with id

CREATE TABLE employees_master_eu PARTITION OF employees_master
	FOR VALUES IN ('UK','DE','IT','FR','ES')
	PARTITION BY HASH(id);

-- creating a sub partitions for the partition table eu

CREATE TABLE employees_master_eu_1 PARTITION OF employees_master_eu
	FOR VALUES WITH (MODULUS 3, REMAINDER 0);

CREATE TABLE employees_master_eu_2 PARTITION OF employees_master_eu
	FOR VALUES WITH (MODULUS 3,REMAINDER 1);

CREATE TABLE employees_master_eu_3 PARTITION OF employees_master_eu
	FOR VALUES WITH (MODULUS 3, REMAINDER 2);


--searching for the relation in the pg catalog

SELECT c.relname, c.relkind
FROM pg_catalog.pg_stat_all_tables AS st
JOIN pg_catalog.pg_class AS c ON st.relid = c.oid
WHERE c.relname = 'employees_master_eu_1';

SELECT viewname
FROM pg_catalog.pg_views
WHERE viewname = 'employees_master_eu_1';

SELECT indexname
FROM pg_catalog.pg_indexes
WHERE indexname = 'employees_master_eu_1';

SELECT pg_sequences.sequencename
FROM pg_catalog.pg_sequences
WHERE pg_sequences.sequencename = 'employees_master_eu_1';

SELECT matviewname
FROM pg_catalog.pg_matviews
WHERE matviewname = 'employees_master_eu_1';



--inserting some data into the tables

INSERT INTO employees_master(birth_date,country_code)
VALUES
	('2000-01-01','US'),
	('2000-01-02','UK'),
	('2000-12-31','DE'),
	('2001-01-01','IT'),
	('2001-02-01','US'),
	('2001-01-05','FR'),
	('2000-09-01','US');


--querying through the data 

SELECT * FROM employees_master;

SELECT * FROM employees_master_us;

SELECT * FROM employees_master_eu;



SELECT * FROM ONLY employees_master;

SELECT * FROM ONLY employees_master_us;

SELECT * FROM ONLY employees_master_eu;

--querying through the sub partition

SELECT * FROM ONLY employees_master_eu_1;

SELECT * FROM ONLY employees_master_eu_2;

SELECT * FROM ONLY employees_master_eu_3;


--Partition maintanance ###################################################################

--Attaching a new partition

--adding a new partition to the employees_master for the new country code simgapore

CREATE TABLE employees_list_sp PARTITION OF employees_list
	FOR VALUES IN ('SP');

-- Insert some values in to the table for singapore

INSERT INTO employees_list(birth_date,country_code)
VALUES
	('2000-01-01','SP');

--querying through the data 

SELECT * FROM employees_list;


SELECT * FROM ONLY employees_list_us;

SELECT * FROM ONLY employees_list_eu;

SELECT * FROM ONLY employees_list_sp;


--Detaching the partition to the table

--Syntax

ALTER TABLE table_n DETACH PARTITION partition_table_name;

--detaching the employees sp partition

ALTER TABLE employees_list DETACH PARTITION employees_list_sp;


--de atching the employees us partition from the employees_list_us

ALTER TABLE employees_list DETACH PARTITION employees_list_us;


--altering the bounds of a partition ###############################################################

CREATE TABLE t1(a INT , b INT ) PARTITION BY RANGE (a);

--creating partitions to the t1

CREATE TABLE t1p1 PARTITION OF t1 FOR VALUES FROM (0) TO (100);

CREATE TABLE t1p2 PARTITION OF t1 FOR VALUES FROM (200) TO (300);

--lets insert into the tables

INSERT INTO t1(a,b) VALUES (150,150);

-- if we want to alter the partition for the specific range then we have to make sure we follow these steps

--Begin transaction
	--Detach the partition table from the master table
	--alter the partition 
	--re attach the partition
--commit the transaction

BEGIN TRANSACTION;
	ALTER TABLE t1 DETACH PARTITION t1p1;
	ALTER TABLE t1 ATTACH PARTITION t1p1 FOR VALUES FROM (0) TO (200);
COMMIT;

--Partition INDEXING #####################################################################
/*
Guidelines
----------

	1.	Creating an index on the master / parent table will automatically create same indexes to every
		attached (partition this is good)

	2.	Postgresql does not allow a way to create a SINGLE INDEX covering evry partition of the parent table
		you have to create an index for each and evry partition.
		
	3.	The primary key , or any other unique index, must include the columns used on the partition by statment.
		we have to provide the column resposible for the partition key 
*/

CREATE UNIQUE INDEX idx_uniq_employees_list_id ON employees_list (id);

CREATE UNIQUE INDEX idx_uniq_employees_list_id_country_code ON employees_list (id,country_code);


--Switching partitions pruning ON/OFF ########################################################################

/*

Partition pruning is an optimization technique where PostgreSQL skips scanning partitions that are not needed
to satisfy a query's condition.

Partition pruning improves performance by reducing the number of scanned partitions, especially when dealing with
large partitioned tables.

*/

-- looking that is partition prunning is on or off

SHOW enable_partition_pruning;

--when partition prunning is on, then the partition key is used to identify which partition the query should scan

SET enable_partition_pruning = ON;

SELECT *
FROM employees_list
WHERE country_code = 'DE';

--Determine a key field to partition over ###################################################################

/*
1. Review and understand raw data 
	- get a good history if not all history for actual and sample data
	-understand the upper and lower level ranges
	-possible quieres that a user will need it from this data
	-make sure to consider this data to be added with other data sets

	-- review all the possible queries
		-list all the quires for table, multi joins etc
		-ranke queries in terms of simple to advanced
		-put advanced queries on top to consider
2. collect common fields in each queries
3. Rankk each common fields, so that you can see the top 10keys
	for example 
		Rank		Field
		---- 		-----
		1			orderdate
		2			country code
		3 			status
		.....		.....
4. Analyze the range of the data on each of the above keys
5. pick youir best candisate for teh field to partition over from the top 5  / 10 fields
6. consider what fields are used in the where clauses



Sizing the partition ##########################################################################

1. Get high, low numbers of your key field
*/
SELECT 
	MIN(order_date),
	MAX(order_date)
FROM orders;

--2.get unique values of key field 

SELECT 
	DISTINCT (order_date)
FROM orders

--3. get the totoal counts for your key field this will help you to evenly split your partitions


-- 4. Make calculations of partition size if you were to do with range, list or hash partitions

--5. Always make a future buffer in terms of data expansions

/*
	e.g see total daily data insert operations 

	monthly data = Daily INSERT operations * 28 days

	And calculate atleast 2-5 years of data needs in advance and then create the partitions accordingly in advanced

*/
advantages
/*
| Benefit                        | Explanation                                                                              |
| ------------------------------ | ---------------------------------------------------------------------------------------- |
| **Improved Query Performance** | PostgreSQL can scan only the relevant partitions (partition pruning), reducing I/O.      |
| **Faster Maintenance**         | You can `DROP`, `TRUNCATE`, or `ARCHIVE` individual partitions without affecting others. |
| **Scalability**                | Efficient handling of large datasets (e.g., logs, time-series, sales data).              |
| **Parallelism**                | PostgreSQL can scan partitions in parallel during queries.                               |
| **Better Index Management**    | Smaller indexes per partition can be faster and use less memory.                         |
| **Data Isolation**             | Logical separation of data can reduce locking and contention.                            |
*/

/*
| Drawback                           | Explanation                                                                           |
| ---------------------------------- | ------------------------------------------------------------------------------------- |
| **Complex Setup**                  | Requires extra planning and SQL to define parent/child structure correctly.           |
| **Manual Indexing**                | Indexes, constraints, and triggers must be created on each partition individually.    |
| **Query Planner Limitations**      | Certain queries may fail to trigger partition pruning, leading to full scans.         |
| **Increased Maintenance Overhead** | More objects (tables, indexes) to manage and monitor.                                 |
| **Constraint Enforcement Issues**  | `UNIQUE` and `PRIMARY KEY` constraints across partitions are not enforced by default. |
| **Cannot Modify Partition Key**    | You can't update the value of a partition key unless you move the row.                |

*/


/*

few more advantages 

1.	the average number of index blocks you'll have to navigate in order to find a row goes down

2.	No sequential scan anymore. Having smaller blocks of your data might alter when the database can
	consider a squential scan of a range a useful technique.

3. You can Drop an individual partition, to erase all of the data that ranges.

4. Pruning historical data out of a partitioned table Avoids VACCUM cleanup work that delete leaves behind

5. Another advantages is that REINDEX operations will happen in a fraction of the time vs a single giant index to build

6.your INSERT/ UPDATE / DELETE operations will be fast

7. BULK upload of data will be quite fast in partitions.
*/