-- CREATING an index 
--Index and the unique index 
--CReating a regular index

--naming convention for the unique and the globally accessible eg

CREATE INDEX idx_table_name_column_name_col2

CREATE UNIQUE INDEX idx_u_table_name_column_name


-- creating index on single column

SELECT *
FROM students;

SELECT *
FROM t_grades;

CREATE INDEX idx_students_student_id ON students(student_id);

CREATE UNIQUE INDEX idx_T_grades_course_id ON t_grades(course_id);

-- creating index on multile columns

/*
	It is important to note that , when creating mutli - column indexes, you should always place the most selective columns first.
	Postgres will consider a multi - column index from the first column onwards, so if the first column are the most selective 
	the index access method will be the cheapest
*/



SELECT *
FROM students;

CREATE INDEX idx_students_student_id_student_name ON students(student_id,student_name);

-- Creating a unique index for a table make sure u keep th eu in the name it will stand out while referning

SELECT *
FROM teachers;

CREATE UNIQUE INDEX idx_teachers_teacher_id ON teachers(teacher_id);

-- Pgindexes  this is where postgres store all the indexes 

SELECT 
	*
FROM 
	pg_indexes
WHERE 
	schemaname = 'public'

--searching the indexes on table

SELECT 
	*
FROM 
	pg_indexes
WHERE 
	tablename = 'sample';


-- Checking the size of an index

SELECT 
	pg_indexes_size('sample');

SELECT 
	pg_size_pretty(pg_indexes_size('sample'));

--getting all the stats of the 

SELECT *
FROM pg_stat_all_indexes;

--for a schema

SELECT *
FROM pg_stat_all_indexes
WHERE schemaname = 'public';



Hash index#################################################################

for equality operator (Only simple equality comparision = )

Not for range nor disequality operator,

larger than b tree indexes

*/

SELECT *
FROM aa;

CREATE INDEX idx_aa_id ON aa USING hash(id);

EXPLAIN SELECT id FROM aa WHERE id = 3;

--BRIN INDEX #################################################################

/*
	block range index

data block -> min to max valuye

smaller index

less costly to maintain than btree index

can be used on alarge table vs btree index

used linear sort order e.g. customer -> order_date


GIN INDEX ##############################################################################

generalized inverted indexs

point to multiple tuples

used with array type data 

used in full text - search

used when we have multiple values stored in a single column


*/

--Indexes for sorted output ###################

EXPLAIN ANALYZE SELECT *
FROM aa
ORDER BY name DESC
LIMIT 10;


-- Using a multiple indexes ################

EXPLAIN ANALYZE
SELECT 
*
FROM 
aa
WHERE 
	id = 58454 OR id = 254541


-- Execution plans depends on input values #########################################################

CREATE INDEX idx_aa_name ON aa (name);


EXPLAIN (FORMAT JSON) SELECT *
FROM aa
WHERE id = 1528 AND name = 'Name_685265';

-- using the organised vs random data 

EXPLAIN (ANALYZE true , BUFFERS true, TIMING true)
SELECT *
FROM aa
WHERE id <10;

CREATE TABLE a_big (
	id INT PRIMARY KEY ,
	name VARCHAR (100)
);

INSERT INTO a_big(id,name)
SELECT id, name 
FROM aa
ORDER BY RANDOM();


SELECT *
FROM a_big
LIMIT 10;

CREATE INDEX idx_a_big_id ON a_big (id);

EXPLAIN ANALYZE SELECT *
FROM a_big
WHERE id < 100
ORDER BY id;


EXPLAIN ANALYZE SELECT *
FROM a_big 
WHERE id > 500
ORDER BY id;

VACUUM ANALYZE a_big;

EXPLAIN (ANALYZE true , BUFFERS true, TIMING true)
SELECT *
FROM a_big
WHERE id BETWEEN 561 AND 3542;

-- partial index : tom imrove the perfomance of the query while reducing the index size.
--#########################################################################################################


CREATE INDEX index_name ON table_name
WHERE condition 

--EXPRESSION INDEXES ########################################################################

/*- 
	 An index created based on the 'expression' eg
	 	upper (column_name)
		cos(column_name)
		...
		EXTRACT (day FROM date_column)

validating the index and concurrently creating the index 

invalidating the index  

*/

SELECT 
	oid,
	relname,
	relpages,
	reltuples,
	i.indisunique,
	i.indisclustered,
	i.indisvalid,
	pg_catalog.pg_get_indexdef(i.indexrelid,0,true)

FROM pg_class AS c JOIN pg_index AS i ON c.oid = i.indrelid
WHERE c.relname = 'aa';

--reseting the value


UPDATE pg_index
SET indisvalid = true
WHERE indexrelid = (SELECT oid FROM pg_class
						WHERE relkind = 'i'
						AND relname = 'idx_aa_id')

--rebuilding the index ######################################################################

REINDEX [(VERBOSE)] {INDEX | TABLE |SCHEMA |DATABASE | SYSTEM} [CONCURRENTLY ] NAME

REINDEX (VERBOSE ) TABLE CONCURRENTLY aa; 