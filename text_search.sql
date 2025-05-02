-- TEXT search ####################################################################################

--LIKE and ILIKE

SELECT * 
FROM movies 
WHERE movie_name ILIKE '%star%';

/*
--Full text search 
	A full text search refres to techniques for searching a single computer - stored document or a collection in a full
	text database.

	Distinguished from searches based on metadata or on parts of the original texts represented in databases (such as 
	titles, abstarcts, selected sections, or bibliographical references)

	problem:
		In other words, imagine you have a set of text docummnets stored in a database. These documents are not just meta
		data items like an author name or a country of origin, but rather an abstarct for an article, or full_text articles themselves and
		you want to find out if certain words are present or not in them.


		they are similar number of problems for the like and i like 

		for example if i want to search a word about like dog if i am using the like function it will along with the 
		dog word it will give me the dogville if it is present 

		so if i am searching for the query if the word that is present in the text is queries it wont return anything

		Solution:

			A more effective way to approach this problem is by getting a "SEMANTIC VECTOR" for all of the words conatained 
			in a documnet , that is , a language - specific representation of such words


INTRODUCTION TO " tsvector"

	POSTGRESQL comes with a powerful full text search engine that give us more options when searching for information
	in large scale of text.

FULL TEXT DATA TYPES
---------------------

lets start with data types unique to full text search .
	tsvector		text to be searched and stored in optimized format
	tsquery			represent the search terms and operations

	tsvector
	--------
		- Reduce text to a sorted list of 'lexemes', which are units of meaning in language.

		- 'lexemes' : words without the variations created by suffixes.
					E.g tsvector will store words : washes , washed and washing as 'wash'
		- remove 'stop words' like 'the','it' etc that usually don't play a role in a search


*/

-- to_vector() function
--------------------------
-- to_tsvector for creating a list of tokens (the tsvector data type, where 'ts' stands for text search)

SELECT to_tsvector('washes');

SELECT to_tsvector('washing');

SELECT to_tsvector('washed');

SELECT TO_TSVECTOR('the qucik brown fox jumped over the lazy dog');

--the qucik brown fox jumped over the lazy dog
-- 1	2		3	4	5		6	7	8	 9

-- the output of thge query is "'brown':3 'dog':9 'fox':4 'jump':5 'lazi':8 'qucik':2"


/*
- By default , every word is normalized as a lexeme in english (eg; "jumped becomes jump")

- The above return a vector where;

	-every token is a lexeme (unit of lexical meaning) with

	- pointers (the positions in the documents ), and

	-Where words that carry little meaning, such as articles (the) and conjunctions (and or) are conventionely
	ommited 

	-orders the words alphabetically, and number following each colon indicates its position in original text

*/

---to_tsquery(text);
--to_tsquery() accepsts a  list of words that will be checked against the normalized vector we created with to_tsvector
--operators
------------
/*
@@	match operators

&	AND

|	or

!	NOT

<->	search for adjacent words or words a certain distance apart 

*/


SELECT TO_TSVECTOR('THIS IS A LAMP') @@ TO_TSQUERY('lamp');


--using the match operator @@ ##############################################################################
-- we will use the @@ operator to check if tsquery matches in our ts vector data.


SELECT TO_TSVECTOR('the qucik brown fox jumped over the lazy dog') @@ TO_TSQUERY('foxes');

--lets try the jumping

SELECT TO_TSVECTOR('the qucik brown fox jumped over the lazy dog') @@ TO_TSQUERY('jumping');

--using the | means the or opereator

SELECT TO_TSVECTOR('the qucik brown fox jumped over the lazy dog') @@ TO_TSQUERY('foxes|tiger');

-- fox and dog or tiger and not king

SELECT TO_TSVECTOR('The quick brown fox jumped over the lazy dog') @@ TO_TSQUERY('fox & (dog|tiger) & !king');


--full text search within the table #######################################################################

--creating a table

CREATE TABLE IF NOT EXISTS docs(
	doc_id SERIAL PRIMARY KEY,
	doc_text TEXT,
	doc_text_search TSVECTOR
);


--inserting data into the table

INSERT INTO docs(doc_text)
VALUES
	('The five boxing wizards jump quickly.'),
	('Pack my box with five dozen pepsi jugs.'),
	('How vexingly quick daft zebras jump!'),
	('Jackdaws love my big sphinx of quartz.'),
	('Sphinx of black quartz, judge my vow.'),
	('Bright vixens jump; dozy fowl quack.');

SELECT *
FROM docs;

UPDATE docs
SET doc_text_search = TO_TSVECTOR(doc_text);

--lets search within our doc_text_search column

SELECT 
	doc_id,
	doc_text
FROM docs
WHERE doc_text_search @@ TO_TSQUERY('jump & quick');


-- <-> find words next to each otherjump,quick

SELECT 
	doc_id,
	doc_text
FROM docs
WHERE doc_text_search @@ TO_TSQUERY('jump <-> quick');


--using the distance between the two numbers

SELECT 
	doc_id,
	doc_text
FROM docs
WHERE doc_text_search @@ TO_TSQUERY('Sphinx <3> quartz');


--setup presidenst speeches data ###########################################################################
--lets create a sampple table for presidents speeches

CREATE TABLE docs_presidents(
	docs_id SERIAL PRIMARY KEY,
	president VARCHAR(100) NOT NULL,
	title VARCHAR(250) NOT NULL,
	speech_date DATE NOT NULL,
	speech_text TEXT NOT NULL,
	speech_text_search TSVECTOR
);

--Inserting the data into the table using the downloaded csv file where delimieter is '|' and quote '@'
-- executing the code in the command line proimt

\copy docs_presidents(president,title,speech_date,speech_text)
FROM 'Downloaded file path .csv'
WITH (FORMAT CSV ,DELIMITER '|', HEADER OFF , QUOTE '@');

--verifying the data 

SELECT *
FROM docs_presidents;


--updating the data into the 

SELECT *
FROM docs_presidents
WHERE 1 = 2;

UPDATE docs_presidents
SET speech_text_search = TO_TSVECTOR(speech_text)

SELECT *
FROM docs_presidents
LIMIT 2;

--Creating a GIN INDEX for the tsvector column because we will not be able to get teh fast query 

CREATE INDEX idx_docs_presidents_speech_text_search ON docs_presidents USING GIN(speech_text_search);



--Analyzing teh presidents index

SELECT 
	president,
	title,
	speech_date
FROM docs_presidents
WHERE 
	speech_text_search @@ to_tsquery('war & peace');


--ts_headline

SELECT 
	president,
	title,
	speech_date,
	ts_headline(speech_text,to_tsquery('military <-> defense'))
FROM docs_presidents
WHERE 
	speech_text_search @@ to_tsquery('war & peace');


--ts_rank  ranking the query matches ###########################################################################

SELECT 
	president,
	title,
	speech_date,
	ts_rank(speech_text_search,to_tsquery('military <-> defense'))
FROM docs_presidents
WHERE 
	speech_text_search @@ to_tsquery('military <-> defense');
