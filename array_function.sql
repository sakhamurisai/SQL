-- Array function in postgres 

/*int4range	integer (aka int4)	Range of 32-bit integers,
int8range	bigint (aka int8)	Range of 64-bit integers,
numrange	numeric	Arbitrary-precision numeric range,
tsrange	timestamp without time zone	Timestamp range,
tstzrange	timestamp with time zone	Timestamp range with timezone,
daterange	date	Date range*/


/*
	Creating the ranges for the array 
	 Range Types Support:
Overlap: &&

Contains: @> or <@

Equality: =

Adjacency: -|-

Efficient indexing with GIST/BTREE
*/


SELECT 
	INT4RANGE(1,6) AS "DEFAULT [( = Closed - opened",
	NUMRANGE(1.4215,6.2584,'[]') AS "closed - closed",
	DATERANGE('20100101','20200101','()') AS " open - open ",
	TSRANGE(LOCALTIMESTAMP , LOCALTIMESTAMP + INTERVAL '8 DAYS','(]')

-- Constructing a array, if you not specify the datatype in the array postgres wil automatically will assign one

SELECT 
	ARRAY[1,2,3] AS "INT ARRAYS",
	ARRAY[2.2451 :: FLOAT] AS "Flaoting numbers with putting explicit typing",
	ARRAY[CURRENT_DATE , CURRENT_DATE + 5],
	ARRAY[1,2] AS "CLOSED - OPEN" ;


-- using the comparision operator

SELECT 
	ARRAY[1,2,3,4] = ARRAY[1,2,3,4],
	ARRAY[1,2,3,4] = ARRAY[5,2,3,4],
	ARRAY[1,2,3,4] <> ARRAY[2,3,4],
	ARRAY[1,2,3,4] > ARRAY[2,3,4,5],
	ARRAY[1,2,3,4] < ARRAY[2,3,4,5],
	ARRAY[1,2,3,4] <= ARRAY[1,2,3,4],
	ARRAY[1,2,3,4] >= ARRAY[1,2,3,4];

-- make a note that shorter array in postgres is less than the longer array

--######################################################################################
-- INCLUSION operators on range functions and arrays contains ,overlap operatorson range functions

SELECT 
	INT4RANGE(1,4) @> INT4RANGE(2,3) AS "contains",
	DATERANGE(CURRENT_DATE,CURRENT_DATE + 30) @> CURRENT_DATE + 15 AS "contains date",
	NUMRANGE(1.245,9.6326) && NUMRANGE(2,4);


SELECT 
	ARRAY[1,2,3,4] @> ARRAY[1,2,3,4],
	ARRAY[1,2,3,4] @> ARRAY[5,2,3,4],
	ARRAY[1,2,3,4] && ARRAY[2,3,4,5],
	ARRAY[1,2,3,4] <@ ARRAY[2,3,4,5];


-- CONSTRUCTING array using the concatination and the other function

SELECT 
	ARRAY[1,2,3] || ARRAY[6,7,8,9] AS "using the concte operator | ",
	ARRAY_CAT(ARRAY[1,2,3] , ARRAY[6,7,8,9]) AS "Concating the array using the array_cat operator ",
	4 || ARRAY[1,2,3] AS "Adding the array",
	ARRAY[1,2,3] || 4 AS "Adding the array",
	ARRAY_PREPEND (4,ARRAY[1,2,3]) AS "using the prepend function",
	ARRAY_APPEND (ARRAY[1,2,3],4) AS "using the Append function";

-- Array metadata function #################################
--Array_ndims gives the dimensions of an array like how many elemetns it contains  alwasy return an integer


SELECT 
	ARRAY_NDIMS(ARRAY[[1],[2]]) AS "Dimensions",
	ARRAY_NDIMS(ARRAY[[1,2,3],[1,4,5]]);

--ARRAY_DIM(array)
--return the text representation of arrays dimension return type = text

SELECT 
	ARRAY_DIMS(ARRAY[[1],[2]]);

--ARRAY_LENGTH (array,dimension)
--return the length of the requested array dimension. return type = int


-- for 1 dimesnion array
SELECT 
	ARRAY_LENGTH(ARRAY[1,2,3],1);

-- for 2 dimesnion array
SELECT 
	ARRAY_LENGTH(ARRAY[[1,2,3,5,9],[3,4,5,5,6]],2);

SELECT 
	ARRAY_LENGTH(ARRAY[] :: INTEGER[],2);

-- Array_lowwer(array,dimension)
--retunrs lower bound of the requested array dimension return type int

SELECT 
	ARRAY_LOWER(ARRAY[1,2,3,5,9],1);

-- Array_upper(array,dimension)
--retunrs upper bound of the requested array dimension return type int

SELECT 
	ARRAY_UPPER(ARRAY[1,2,3,5,9],1);


-- Cardinality  (array)
-- returns the cardinality of the array dimension or total number of elements in an array

SELECT 
	CARDINALITY(ARRAY[[1],[2],[3],[4]]),
	CARDINALITY(ARRAY[1,2,3,4,5,6]);

-- ARRAY search functions 
--################################################################################

/*
	ARRAY_POSITION(ARRAY,element),
	ARRAY_POSITION(ARRAY,element,start_position)
	retunrs the subscript of the first occurence of the second argument in the array, starting at the element
	indicated by the hird argument or at the first element
	The array must be one dimensioonal
*/

SELECT 
	ARRAY_POSITION(ARRAY['Jan','Feb','Mar','Apr'],'Feb');

SELECT
	ARRAY_POSITION(ARRAY[1,2,2,3,4],2,3);

-- HOW ABOUT if we have multiple macthing values in an array

--ARRAY_POSITIIONS(anyarray,anyelement)

SELECT
	ARRAY_POSITIONS(ARRAY[1,2,2,3,4],2);


--ARRAY MODICFICATION FUNCTIONS
--ARRAY_CAT(array,array)

SELECT 
	ARRAY_CAT(ARRAY['jan','feb'],ARRAY['March','April']);
	ARRAY_PREPEND (4,ARRAY[1,2,3]) AS "using the prepend function",
	ARRAY_APPEND (ARRAY[1,2,3],4) AS "using the Append function";

--REMOVING A aeeay element
-- ARRAY_REMOVE(anyarray,anyelement)
-- Function is used to remove ALL ELEMENTS equal to the given value from the array
-- array must be one dimensional

SELECT 
	ARRAY_REMOVE(ARRAY[1,2,3,4,5,6,6],6);

--REPLAING 
--ARRAY_REPLACE(anyarray,element to be replaced,element that you want in the array)
--function is used to replace each array equal to the given value with a new value.(array must be one dimensional)

SELECT 
	ARRAY_REPLACE(ARRAY[1,2,3,4,5,5,6,7,8,8,9],5,99)

--ARRAY COMPARISIONS #####################################################################
/* expresion in (value[,...])
the right hand side is a paranthesized list of scalar expression
the result is 'true' id the left hand expressioin result is equal to ANY of the right hand expression
this is a short hand notation for 
Expression = value 1
or
expression = value2...
*/

SELECT 
	20 IN (1,2,0,2,1,5,10,20) AS "RESULT !",
	30 IN (1,2,0,2,1,5,10,20) ;

	
/* expresion NOT in (value[,...])
the right hand side is a paranthesized list of scalar expression
the result is 'true' if the left hand expressioin result is NOTEQUAL to ALL of the right hand expression
this is a short hand notation for 
Expression <> value 1
AND
expression <> value2...
*/

SELECT 
	20 NOT IN (1,2,0,2,1,5,10,20) AS "RESULT !",
	30 NOT IN (1,2,0,2,1,5,10,20) ;

--ALL operator 
--################################################################################################

/*
	expression operator ALL (array expression)
	the right hand side is a paranthesized expression , which must yeild an array value. the left hand expressioin is
	evaluated and compared to each element of the array using the given operator, whih must yeild a boolean result

	The result of all is true if all comparisions yield true (including the case where the array has zero elemets)
	the result is false if any false result is found
*/

SELECT 
	20 = ALL (ARRAY[1,2]) AS "RESULT !",
	30 = ALL (ARRAY[30]) ;

-- ANY OPERATOR 

SELECT 
	20 != ALL (ARRAY[1,2,20]) AS "RESULT !",
	30 = ALL (ARRAY[30]) ;

--some operator

SELECT 
	20 = SOME(ARRAY[1,2,20]) AS "RESULT !",
	30 = SOME(ARRAY[30]) ;

--Formatting and converting arrays
--##############################################################
/*
	string to array 
	function is used to split a string into array elements using supplied delimiter and optional null string
	string_to_array(text,text[,text])
*/
-- STRING TO text array

SELECT 
	STRING_TO_ARRAY('1,2,3,4,5',',');

--setting a value to null 

SELECT 
	STRING_TO_ARRAY('1,2,3,4,ABC',',','ABC');

--setting an empty value to null

SELECT 
	STRING_TO_ARRAY('1,2,3,,4',',','');

--array to string value

SELECT 
	ARRAY_TO_STRING(ARRAY[1,2,3,4],',')

-- USING ARRAYS IN A TABLE
--########################################
/*
	1 POSTGRESQL allows you to define a column to be an array of any valid data type including 
		-built - in type,
		-user defined type or enumerated type
	2 Every dat type has its own comparision array type
		integer has an integer[] array type,
		character has character [] array type etc

		Basically we add brackets [] to the base data type to make it an array!

		e.g.
			name varchar(100)[]

*/


-- creating a table with a column array

CREATE TABLE teachers(
	teacher_id SERIAL PRIMARY KEY,
	name VARCHAR(150),
	phones TEXT[]
);

SELECT *
FROM teachers;

CREATE TABLE teachers1(
	teacher_id SERIAL PRIMARY KEY,
	name VARCHAR(150),
	phones TEXT ARRAY
);

SELECT *
FROM teachers1;

--INSERTING DATA INTO A ARRAY
/*
	we use single quotes to wrap the array or use array function

	For non-text data , we can use curly braces {}
	'{value1,value2}' or ARRAY[value 1, value 2]

	FOR text data we use double quotes
	'{"value1"}' or ARRAY['value1']
*/

INSERT INTO teachers (name,phones)
VALUES
	(
		'ram',ARRAY['111-222-333','99899994']
	);

INSERT INTO teachers (name,phones)
VALUES
	('jenny','{"333-555-999-5"}'),
	('bunny','{"555-555-999-5"}');

SELECT *
FROM teachers;

--Querying data from array

SELECT 
	phones
FROM 
	teachers;

-- how to access a element within the array
-- we can accessit with the [] like in python
-- the array start with the 1 not with the zero

SELECT 
	phones[1]
FROM
	teachers;

-- using filters in array


SELECT 
	phones
FROM 
	teachers
WHERE phones[1] = '111-222-333';

-- Modify array contents 
--########################################################

SELECT *
FROM teachers;

UPDATE teachers
SET phones [2] = '(800)-55588-778896'
WHERE teacher_id = 1;

--Displaying all the elements in an array ##########################################

SELECT 
	teacher_id,
	name,
	UNNEST(phones)
FROM teachers ;



-- CREATING a multi dimensional array
--############################################################################
/*
	creating a multi deimnesional array for the students table where er use the 
	column types as [][] 
*/

CREATE TABLE students(
	student_id SERIAL PRIMARY KEY,
	student_name VARCHAR(100),
	student_grade INTEGER [] []
);

-- iNSERTING INTO the table

INSERT INTO students(student_name,student_grade)
VALUES
	('math','{90,2020}');

SELECT *
FROM students;


UPDATE students
SET student_name = 's1'
WHERE student_id = 1;

INSERT INTO students(student_name,student_grade)
VALUES 
	('s2','{50,2015}'),
	('s3','{70,2018}'),
	('s4','{80,2014}'),
	('s5','{40,2016}'),
	('s6','{10,2019}'),
	('s7','{90,2020}');

--Searching for the data using two methods 

SELECT *
FROM students 
WHERE student_grade @> '{2020}';

SELECT *
FROM students
WHERE 2020 = ANY (student_grade);

