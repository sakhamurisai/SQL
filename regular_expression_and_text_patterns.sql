--using a with clause ##############################

--prepopulating the values in the temp table

WITH t_data (item) AS
(
	VALUES
	(1,'Book'),
	(2,'Pencil')
)

SELECT *
FROM t_data;


--TEXT to structured data ###############################################################


--case formating

SELECT UPPER('hello world'); -- capitilizes the whole letter 

SELECT LOWER('HELLO WORLD'); -- lowercase the entire string

SELECT INITCAP('my name is jhon wick'); -- capitalizes the starting letter of each word


-- character infromation

SELECT CHAR_LENGTH('WORLD peace') -- checks the length of a string including spaces

--removing characters 

SELECT TRIM('         trim           '); --trims the wide spaces from the content



--Using teh regular expression for text patterns #######################################################

/*
	1. regex or regular expression are a type of national language that describes 'text patterns'

	2. regular expression notation basics

	expression						Notes
	-----------					----------------------------------------------------------------------------
	.							A dot is a wild card that fincds any characeter except a new line
	
	[FGz]						Any character in the square barcket [], here is F,G, or z

	[a-z]						A range of characters .here lowercase a to z.

	[^a-z]						the caret negatee the match. Here not lowercase a to z

	\ w 						Any word character or underscore. same as [A-za-z0-9_]

	\d							Any digit

	\t							tab character

	\s							A space

	\n							A new line character

	\r							carriage return character

	^							Match at the start of the string

	$							Match at the end ofg the string

	?							get the following match zero or one time

	*							Get the following match zero or more time

	+							get the following match one or more times

	{m}							get the following match exactly m times
	
	a|b							The pipe |  denotes alternation. Find either a or b

	()							Create and report a capture group or set precedence

	{m,n}						Get the precedind match between the m and n times

	(?: )						negate the reporting of a capture group 

	

	| SQL Operator | Description                          | Case-Sensitive? |
| ------------ | ------------------------------------ | --------------- |
| `~`          | Matches regex                        | ✅ Yes           |
| `~*`         | Matches regex (ignore case)          | ❌ No            |
| `!~`         | Does not match regex                 | ✅ Yes           |
| `!~*`        | Does not match regex (ignore case)   | ❌ No            |
| `SIMILAR TO` | SQL-style regex (like `LIKE` + more) | ✅ Yes           |


| Symbol   | Meaning                             | Example                        |       |                                |
| -------- | ----------------------------------- | ------------------------------ | ----- | ------------------------------ |
| `.`      | Any single character                | `a.c` → matches "abc", "axc"   |       |                                |
| `^`      | Start of string                     | `^abc` → "abcde"               |       |                                |
| `$`      | End of string                       | `abc$` → "xxabc"               |       |                                |
| `*`      | 0 or more of the previous character | `ab*` → "a", "ab", "abb"       |       |                                |
| `+`      | 1 or more of the previous character | `ab+` → "ab", "abb"            |       |                                |
| `?`      | 0 or 1 of the previous character    | `ab?` → "a", "ab"              |       |                                |
| `{n}`    | Exactly n times                     | `a{3}` → "aaa"                 |       |                                |
| `{n,}`   | At least n times                    | `a{2,}` → "aa", "aaa"          |       |                                |
| `{n,m}`  | Between n and m times               | `a{2,4}` → "aa", "aaa", "aaaa" |       |                                |
| `[...]`  | One character from the set          | `[abc]` → "a", "b"             |       |                                |
| `[^...]` | One character *not* in the set      | `[^abc]` → "d", "x"            |       |                                |
| \`       | \`                                  | OR operator                    | \`foo | bar\` → matches "foo" or "bar" |
| `(...)`  | Grouping                            | `(ab)+` → "ab", "abab"         |       |                                |



| Class             | Meaning                | POSIX Alternative |
| ----------------- | ---------------------- | ----------------- |
| `\d` (digit)      | Not supported directly | `[0-9]`           |
| `\w` (word char)  | Not supported directly | `[A-Za-z0-9_]`    |
| `\s` (whitespace) | Not supported directly | `[ \t\r\n]`       |



SIMILAR TO operator


the similar to operator returns true or false depeding on whether its pattern matches the given string

It is similiar to like, except that it interprets the pattern using the sql standard definition of a regular expression

sql regular expression are a curious cross between like notation and common regular exprerssion notation

like LIKE, the SIMILAR TO operator succeds only if its pattern matches the entiore string ; this is unlike the common 
regular expression behavior where the pattern can match any part of the string

Also like LIKE ,SIMILAR TO uses _ and % as wild card characters denoting any single character and any string, respectively
(these are comparable to . and .* in POSIX regular expressions)

*/

-- SIMILAR TO function
--it should match teh entire string ,it won't even consider partial match also

SELECT 'same' SIMILAR TO 'same';

SELECT 'same' SIMILAR TO 'Same';

--Finding th epartial in whole string
-- "|" denotes alternation (either of two alternatives)

SELECT 'same' SIMILAR TO 's%'; -- true

SELECT 'same' SIMILAR TO 'sa%'; --true

SELECT 'same' SIMILAR TO '%(s|a)%';


--POSIX regular expression ############################################################################

/*
	A regular expression  is a single text string used to describe a search pattern

	PostgreSQL supports POSIX (Portable Operating System Interface) regular expressions
	for powerful text pattern matching using SQL.

	- POSIX - style regular expression (BRE's AND ERE's)


	
	| SQL Operator | Description                          | Case-Sensitive? |
| ------------ | ------------------------------------ | --------------- |
| `~`          | Matches regex                        | ✅ Yes           |
| `~*`         | Matches regex (ignore case)          | ❌ No            |
| `!~`         | Does not match regex                 | ✅ Yes           |
| `!~*`        | Does not match regex (ignore case)   | ❌ No            |
| `SIMILAR TO` | SQL-style regex (like `LIKE` + more) | ✅ Yes           |


*/

SELECT 'same' ~ 'same' AS RESULT;

SELECT 'same' ~ 'same' ; --true

SELECT 'same' ~* 'SAMe'; --true

SELECT 'same' !~ 'saMe' ; -- true 

SELECT 'same' !~* 'SAme' ; -- false because they both are same 


--Substring with POSIX regular expression ###################################################################


--the string we will be using as a example is  -- The movie will start at 8 p.m on Dec 10, 2020.

-- Single character 

SELECT SUBSTRING('The movie will start at 8 p.m on Dec 10, 2020.' FROM '.'); --returns teh first character -- '_'

--all characters

SELECT SUBSTRING('The movie will start at 8 p.m on Dec 10, 2020.' FROM '.*'); -- this returns the entire string -- '%'

--any charcater after the movie in the string

SELECT SUBSTRING('The movie will start at 8 p.m on Dec 10, 2020.' FROM 'movie.+'); -- LIKE 'will%'

--one or more word characters from teh start

SELECT SUBSTRING('The movie will start at 8 p.m on Dec 10, 2020.' FROM '\w+' ); -- [A-Za-z0-9_]


--one or more word characters followed by any characters from the end

SELECT SUBSTRING('The movie will start at 8 p.m on Dec 10, 2020.' FROM '\w+.$');



SELECT SUBSTRING('The movie will start at 8 p.m on Dec 10, 2020.' FROM '\d{4}');


--creating a own regular expression to extract the 8p.m

SELECT SUBSTRING('The movie will start at 8 p.m on Dec 10, 2020.' FROM '\d (?:a.m|p.m)');

--get the year from the string

SELECT SUBSTRING('The movie will start at 8 p.m on Dec 10, 2020.' FROM '\d{4}')

--get either word 'Nov' or 'Dec'

SELECT SUBSTRING('The movie will start at 8 p.m on Dec 10, 2020.' FROM 'Nov|Dec');

--lets prepare the pattern to match our data , Dec 10, 2020.

SELECT SUBSTRING('The movie will start at 8 p.m on Dec 10, 2020.' FROM 'Dec \d{2}, \d{4}' )


--REGEXP_MATCHES function ####################

/*
	-REGEXP_MATCHES() function matches a regular expression against a string and returns matches substrings.

		REGEXP_MATCHES(source_string,pattern[,flags])

		flags
		-----

		g 	Glaobal search
		i 	matches case -insensitively

*/

SELECT REGEXP_MATCHES('Amazing#postgres#SQL','#([A-Za-z0-9]+)','g');

--extract Xand yz FROm xyz

SELECT REGEXP_MATCHES('XYZ','^(X)(..)');

-- capture the right values in the 1111 22222-A 333333-B 44444-C

--first extrcat the letters

SELECT REGEXP_MATCHES('1111 22222-A 333333-B 44444-C','-?[A-Z]','g');


--REGEXP_REPLACE() ###########################################################################################

/*
	- REGEXP_REPLACE() function to replace strings that match a regular expression
		REGEXP_REPLACE(source,pattern,replacement_string,[,flags])

	-This function returns a new string with the substring, which match a regular expression pattern, replaced by 
	a new substring
*/

--lets replace a string names sai sri to sri sai

SELECT REGEXP_REPLACE('sai sri','(.*) (.*)','\2 \1'); --reversing the string using the\2,\1 is we have thre then it would 
														-- probaly be \3,\2,\1

--having a string ABCD123xyz
-- in that string we have to remove the numbers from thgat string a get the output as the ABCDxyz

SELECT REGEXP_REPLACE('ABCD123xyz','[[:digit:]]','','g'); --that empty space is the replacement string we want to use 

-- now th wstring must only contain the numbers

SELECT REGEXP_REPLACE('ABCD123xyz','[[:alpha:]]','','g'); 

--Change the data replacing the text

SELECT REGEXP_REPLACE ('2019-10-10','\d{4}','2020')



--REGEXP_SPLIT_TO_TABLE function ############################################################################
-- splits delimited text into rows.

SELECT REGEXP_SPLIT_TO_TABLE('1,2,3,4,5,6,8,45,65',','); --','a kind of a delimiter it will give the string into rows



--REGEXP_SPLIT_TO_ARRAY ###################################################################################
--splits delimited text into arrays

SELECT REGEXP_SPLIT_TO_ARRAY('james,carter,cammeron,bond,lanister',','); --here we are using the ', as a seperator'

SELECT ARRAY_LENGTH(REGEXP_SPLIT_TO_ARRAY('james,carter,cammeron,bond,lanister',','),1); 

SELECT ARRAY_LENGTH(REGEXP_SPLIT_TO_ARRAY('james carter cammeron bond',' '),1); --here we are using spaces 