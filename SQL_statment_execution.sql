
--###############################################################################################
--#################################################################################################
--SQL Execution stages

/*

Parser - handles the textual form of the statment (the sql text ) and verifies correct or not
			disassembles info into tables , columns,clauses etc
			
rewriter - applying any suntatic rules to rewrite the original sql statment  
		The rewriting stage applies various transformations to the query tree to potentially simplify it or optimize it. This can include:
    	* Applying rules defined in the rule system (used for features like views and query rewriting).
    	* Simplifying expressions.
		Output:** A modified query tree. This stage might not always change the query tree significantly.

optimizer - finding the very fastest path to the data that the statment needs

executor - responsible for effectively going to the storage and retriveing (or inserting ) the data gets physical access to the data


*/


-- optimizer
/*		optimizer
	what to use to optimize the data as quickly as possible
		thread
	check all the possible ways and the lowest cost method wins
		nodes
	optimzers divide set of action to pass into the execution , divides into nodes

Nodes types

	nodes are available for ;
		every operations and access methods

	nodes are stackable
		parent Node
			child node 1
			 Child node 2
		the output of a node can be used as the input of another node.

	Types of nodes

	- sequential scan
	- index scan , index only scan, bitmap scan
	-nested loop , hash join , and merge join
	- the gather and merge parallel nodes

	*/

-- to see all thge nodes 

SELECT *
FROM pg_am;

/*
		Sequetnial scan ###################################################################

		Default when no other valuable alternative

		Read from the begining of the dataset 

		filtering clause is not very limiting, so that the ned result will be to get almost the whole table contents 
		- sequential read all operation faster
*/

/*

Index nodes

An index is used to access the dataset

data file and index files aree seperated but they are nearby

index nodes scan type
	index scan  index -> seeking the tupples -> then read again the data 
	index only scan  request index column only -> directly get the dat from index file
	bit map index scan   builds a memory bitmap of where tuples that satisfy the statement clauses
*/


/*
Join nodes ########################################################################################

used when joining the tables

Joins are performed on two tables at a time; if more tables are joined together, 
the output of one join is treated as input to a subsequent join.

When joining a large number of tables, 
the genetic query optimizer settings may affect what coimbination of joins are considered



Types 

Hash Join#########################################
----------

Inner table				Build a hash table from the inner table,keyed by the join key
Outer table 			Then scan the outer table, Checking if a corresponding value is present

SHOW work_mem;####################################

is a PostgreSQL configuration parameter that controls how much memory is allocated for certain internal operations within a query. Think of it as a "workspace" that PostgreSQL uses to perform temporary calculations.

Specifically, work_mem is used for:

Sorting: When you use ORDER BY, DISTINCT, or MERGE JOIN (a type of join operation), 
PostgreSQL needs to sort the data. 
work_mem determines how much memory PostgreSQL can use for this sorting process.
Hash Tables: Hash tables are used in operations like HASH JOIN (another type of join) and grouping (e.g., with GROUP BY). 
work_mem limits the memory available for building these hash tables.


hash tables -> hash joins ,hash - based aggrigatioin and hash_based processing in subquieries

-- Merge join####################################

Joins two children already sorted by thier shared join key. This only needs to scan each relation once,
but both inputs need to be sorted by the join key first (or scanned in a way that produces already -sorted output , like an index
like an index scan matching that required sort order)

-- Nested loop######################

For each row in the outer table, iterate through all the rows in the inner table and see if they match the join condition.
If the inner relation can be scanned with an index, that can improve the perfomance of a nested loop join. This 
is generally an inefficient way to process joins but is always available and some times may be the only option



Index types #################################################################################################


b-tree indexes###################################################

Default index 
Self balancing tree
- SELECT ,INSERT ,DELETE ,and sequential access in logarithmic time
can be used for most operators and column types
supports the unique condition and normally used to build the primary key indexes
uses when columns involves operators like <,>,=,>=,<= between is null not null
Also used when pattern matchiong even for like based queries

One draw back - copy the wholes columns values into the tree structure

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



/*

EXPLAIN statment

it iwll show the query execution plan

shows the lowest cost among evaluated plans

will not execute the statment you enter , just show query only 

show you the execution nodes that the executor will use to provide you wit the dataset.

*/

SELECT COUNT(*)
FROM aa
;

INSERT INTO aa (id, name)
SELECT 7 + seq, 
       'Name_' || FLOOR(random() * 1000000)::TEXT
FROM generate_series(0, 999_992) AS seq;


EXPLAIN SELECT *
FROM aa
WHERE id > 98541
ORDER BY id
;


/*

execution nodes

- scan type | execution nodes table

- every node

cost 
	startup cost  - how much work postgres has to do before it begins executing the node
	final cost - how much effort postgresql has to do to provide the last bit of the dataset

rows - how many tuples the node is expected to provide for final dataset
width - -how many bits every tuples will occupy , as a average

*/

--wherever we have cost then it is a node  when we execute the explain statment
--in the explain statment is the always check from bottom to top where the start cost is zero

/*
explain output options ######################################################################################

(format ,json,text,xml,YAML)

*/

EXPLAIN (FORMAT JSON)
SELECT *
FROM aa
WHERE id > 98888 AND id != 98888 
;

/* result for the above query 

"[
  {
    ""Plan"": {
      ""Node Type"": ""Seq Scan"",
      ""Parallel Aware"": false,
      ""Async Capable"": false,
      ""Relation Name"": ""aa"",
      ""Alias"": ""aa"",
      ""Startup Cost"": 0.00,
      ""Total Cost"": 20405.97,
      ""Plan Rows"": 898897,
      ""Plan Width"": 15,
      ""Filter"": ""((id > 98888) AND (id <> 98888))""
    }
  }
]"*/

/* 

EXPLAIN ANALYZE ##########################################################################

It prints out the best plan to execute the query and it runs the query
also report back some statistical information.

*/

EXPLAIN ANALYZE
SELECT *
FROM aa
WHERE id > 98888 AND id != 98888 
;

/*
Planning Time is how long the database engine spends thinking about your query before actually running it.

During planning, the database:

Figures out what tables you want

Decides which indexes to use

Chooses how to join tables if needed

Optimizes the path to make the query faster*/

SHOW max_parallel_workers_per_gather;

SHOW seq_page_cost;

SHOW cpu_tuple_cost;

SHOW cpu_operator_cost;


/* 

COST formulae######################################
*/
pg_relation_size * seq_page_cost + total_number_of_table_records * 
cpu_tuple_cost+total_number_of_table_records*cpu_operator_cost

-- indexes cost 

EXPLAIN ANALYZE 
SELECT *
FROM aa
WHERE id BETWEEN 18965 AND 548185


SELECT pg_size_pretty(pg_indexes_size('aa'));

SELECT 
	pg_size_pretty(
		pg_total_relation_size('aa')
	);

DROP INDEX idx_aa_id;

