-- Json basics 

SELECT *
FROM employee_docs

-- 1. Create tables with JSON and JSONB columns
DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name TEXT,
    attributes JSON,  -- Storing raw JSON
    settings JSONB    -- Storing parsed binary JSONB
);

-- 2. Insert sample data
INSERT INTO employees (name, attributes, settings)
VALUES
('Alice', '{"age": 30, "department": "HR", "skills": ["communication", "recruitment"]}', '{"theme": "dark", "notifications": true}'),
('Bob', '{"age": 25, "department": "IT", "skills": ["python", "postgresql"]}', '{"theme": "light", "notifications": false}');

-- 3. View data
SELECT * FROM employees;

-- 4. Using ROW_TO_JSON to convert a full table row into a JSON object
SELECT ROW_TO_JSON(e) AS employee_json
FROM employees e;

-- 5. Using JSON_AGG to aggregate multiple rows into a JSON array
SELECT JSON_AGG(ROW_TO_JSON(e)) AS employees_array
FROM employees e;

-- 6. Accessing JSON fields
SELECT
    name,
    attributes ->> 'department' AS department,
    settings ->> 'theme' AS preferred_theme
FROM employees;

-- 7. Filtering rows based on JSONB data
SELECT *
FROM employees
WHERE settings ->> 'theme' = 'dark';

-- 8. Updating JSONB data
UPDATE employees
SET settings = jsonb_set(settings, '{notifications}', 'false')
WHERE name = 'Alice';

-- 9. Building JSON manually using JSON_BUILD_OBJECT
SELECT
    JSON_BUILD_OBJECT(
        'employee_name', name,
        'age', attributes ->> 'age',
        'theme', settings ->> 'theme'
    ) AS employee_profile
FROM employees;

-- 10. Building a JSON array using JSON_BUILD_ARRAY
SELECT
    JSON_BUILD_ARRAY(
        name,
        attributes ->> 'department',
        settings ->> 'theme'
    ) AS employee_summary
FROM employees;

-- 11. Creating a complete JSON document from scratch (not from a table)
SELECT
    JSON_BUILD_OBJECT(
        'company', 'TechCorp',
        'departments', JSON_BUILD_ARRAY('HR', 'IT', 'Finance'),
        'founded', 1998,
        'active', true
    ) AS company_info;


--Searching through json data ##########################################################

-- 1. Drop and recreate the table
DROP TABLE IF EXISTS products;

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    product_name TEXT,
    product_data JSONB  -- Using JSONB for better search performance
);

-- 2. Insert sample products
INSERT INTO products (product_name, product_data) VALUES
('Phone', '{"brand": "Apple", "model": "iPhone 14", "specs": {"ram": "6GB", "storage": "128GB"}}'),
('Laptop', '{"brand": "Dell", "model": "XPS 15", "specs": {"ram": "16GB", "storage": "512GB"}}'),
('Tablet', '{"brand": "Samsung", "model": "Galaxy Tab", "specs": {"ram": "8GB", "storage": "256GB"}}');

-- 3. View the data
SELECT * FROM products;

-- 4. Search for products where brand = 'Apple'
SELECT *
FROM products
WHERE product_data ->> 'brand' = 'Apple';

-- 5. Search for products where the model contains 'XPS'
SELECT *
FROM products
WHERE product_data ->> 'model' LIKE '%XPS%';

-- 6. Search inside nested JSON (e.g., specs -> ram = '8GB')
SELECT *
FROM products
WHERE product_data -> 'specs' ->> 'ram' = '8GB';

-- 7. Check if a key exists (e.g., does 'specs' key exist?)
SELECT *
FROM products
WHERE product_data ? 'specs';  -- '?' operator = key existence

-- 8. Check if multiple keys exist (both 'brand' and 'model')
SELECT *
FROM products
WHERE product_data ?& ARRAY['brand', 'model'];  -- '?&' operator = all keys must exist

-- 9. Check if ANY key exists (either 'color' or 'storage')
SELECT *
FROM products
WHERE product_data ?| ARRAY['color', 'storage'];  -- '?|' operator = any key exists

-- 10. Search where product_data matches a whole JSON structure (partial match)
SELECT *
FROM products
WHERE product_data @> '{"brand": "Dell"}';  -- '@>' operator = contains

-- 11. Create a GIN index on product_data for fast searching (Recommended for large tables)
CREATE INDEX idx_products_product_data ON products USING GIN (product_data);

-- Now your JSONB searches will be **super fast**!

---updating the json data 

-- 1. Drop and recreate a sample table
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name TEXT,
    profile JSONB
);

-- 2. Insert sample users
INSERT INTO users (name, profile) VALUES
('Alice', '{"age": 30, "city": "New York", "skills": ["SQL", "Python"]}'),
('Bob', '{"age": 25, "city": "Los Angeles", "skills": ["Java", "Node.js"]}');

-- 3. View the table
SELECT * FROM users;

-- 4. Update a single top-level key (change city for Alice)
UPDATE users
SET profile = jsonb_set(profile, '{city}', '"Chicago"')
WHERE name = 'Alice';

-- 5. Add a new key (e.g., 'experience': 5 years)
UPDATE users
SET profile = jsonb_set(profile, '{experience}', '5', true)
WHERE name = 'Bob';

-- 6. Update a nested key inside an array (trickier — arrays can't be updated directly easily)

-- Example: Replace entire "skills" array for Bob
UPDATE users
SET profile = jsonb_set(profile, '{skills}', '["Golang", "Rust"]')
WHERE name = 'Bob';

-- 7. Delete a key from JSONB (e.g., remove "city" key)
UPDATE users
SET profile = profile - 'city'
WHERE name = 'Alice';

-- 8. Update multiple keys manually (more complex way)
-- You can chain updates if needed using nested jsonb_set()

UPDATE users
SET profile = jsonb_set(
                jsonb_set(profile, '{city}', '"Boston"'),
                '{age}', '32'
            )
WHERE name = 'Alice';

-- 9. View the updated table
SELECT * FROM users;


--deleting the json data ###################################################

-- Drop and recreate the users table again
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name TEXT,
    profile JSONB
);

-- Insert sample users
INSERT INTO users (name, profile) VALUES
('Alice', '{"age": 30, "city": "New York", "skills": ["SQL", "Python"]}'),
('Bob', '{"age": 25, "city": "Los Angeles", "skills": ["Java", "Node.js"], "projects": {"open_source": true, "count": 5}}');

-- View table
SELECT * FROM users;

-- 1. Delete a top-level key (remove "city" for Alice)
UPDATE users
SET profile = profile - 'city'
WHERE name = 'Alice';

-- 2. Delete multiple keys at once (remove "skills" and "projects" for Bob)
UPDATE users
SET profile = profile - ARRAY['skills', 'projects']  -- remove both keys
WHERE name = 'Bob';

-- 3. Delete a nested key (remove "count" inside "projects" for Bob)
UPDATE users
SET profile = jsonb_set(profile, '{projects}', (profile->'projects') - 'count')
WHERE name = 'Bob';

-- 4. Delete an array element (remove "SQL" from Alice's skills array)
UPDATE users
SET profile = jsonb_set(profile, '{skills}', (profile->'skills') - 0)  -- remove index 0 (first element)
WHERE name = 'Alice';

-- View the final state
SELECT * FROM users;

--deleting the json data 

-- 1. Drop and recreate the table
DROP TABLE IF EXISTS products;

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name TEXT,
    product_info JSONB   -- using JSONB (you can also create a JSON type separately if you want)
);

-- 2. Insert some sample data
INSERT INTO products (name, product_info) VALUES
('Laptop', '{"brand": "Dell", "model": "XPS", "specs": {"ram": "16GB", "storage": "512GB"}}'),
('Phone', '{"brand": "Apple", "model": "iPhone", "specs": {"ram": "6GB", "storage": "128GB"}}'),
('Tablet', '{"brand": "Samsung", "model": "Galaxy Tab", "specs": {"ram": "8GB", "storage": "256GB"}}');

-- 3. View the table
SELECT * FROM products;

------------------------------------------------
-- 🔥 A) DELETE a Key from JSONB (Single Key)
------------------------------------------------
-- Remove the "model" key from product_info
UPDATE products
SET product_info = product_info - 'model'
WHERE name = 'Laptop';

------------------------------------------------
-- 🔥 B) DELETE Multiple Keys from JSONB
------------------------------------------------
-- Remove both "brand" and "model" keys
UPDATE products
SET product_info = product_info - ARRAY['brand', 'model']
WHERE name = 'Tablet';

------------------------------------------------
-- 🔥 C) DELETE Nested Key inside JSONB
------------------------------------------------
-- Remove "storage" inside "specs"
UPDATE products
SET product_info = jsonb_set(
    product_info,
    '{specs}',    -- Path to nested object
    (product_info->'specs') - 'storage'  -- Remove 'storage' key inside 'specs'
)
WHERE name = 'Phone';

------------------------------------------------
-- 🔥 D) DELETE a Whole Row (from Table)
------------------------------------------------
-- Example: Delete product where name = 'Tablet'
DELETE FROM products
WHERE name = 'Tablet';

------------------------------------------------
-- 🔥 E) SELECT after Deletions
------------------------------------------------
SELECT * FROM products;


--INSERTING JSON data into the table

INSERT INTO employees_docs(docs)
SELECT ROW_TO_JSON(a)::JSONB FROM
(
	SELECT 
		department_id,
		name,
			(SELECT JSON_AGG(x) AS all_roles FROM
			(
				SELECT 
					role_name
				FROM 
					employees
				WHERE department_id = department.department_id
			) AS x
		)
		FROM department
) AS a

-- Handiling the null values 


INSERT INTO employee_docs(docs)
SELECT ROW_TO_JSON(a)::JSONB FROM
(
	SELECT 
		department_id,
		name,
		(
			SELECT 
				CASE COUNT(x)
					WHEN 0 THEN '[]' -- we are not leaving the empty data in the json doc insted we are making it as a empty array
				ELSE JSON_AGG(x) END AS all_roles
				FROM
			(
				SELECT 
					role_name
				FROM 
					employees
				WHERE department_id = department.department_id
			) AS x
		)
		FROM department
) AS a


SELECT *
FROM employee_docs;

--Nulls are very important while takling care of the json data 
-- when there is a null values we may not able to query from that data 

-- USING THE JSONB_ARRAY_ELEMENTS()

SELECT JSONB_ARRAY_ELEMENTS(body -> 'all_movies') 
FROM directors_docs;

--Excluding field where there are null values
--using the JSONB_STRIP_NULLS function

SELECT jsonb_strip_nulls(jsonb_build_object('id', id, 'name', name)) FROM users;


--GETTING THE INFORMATION from  the json Dcouments

--getting the count of all the employess in a department using the JSONB_ARRAY_LENGTH

SELECT 
	*
FROM 
	employee_docs;

SELECT 
	*,
	JSONB_ARRAY_LENGTH(docs->'all_roles') AS all_roles
FROM
	employee_docs
ORDER BY all_roles DESC;

-- listing all the object keys within each json row UISN GTHE JSONB_OBJECT_KEYS
--it will show all the key names in a row not for the entire document 

SELECT * FROM employee_docs;

SELECT DISTINCT -- we can use the distinct to get the distinct values 
	JSONB_OBJECT_KEYS(docs)
FROM employee_docs;

SELECT 
	JSONB_OBJECT_KEYS(docs)
FROM employee_docs;

-- querying th edat fopr the key value style

SELECT 
	j.KEY,
	j.VALUE
FROM employee_docs,JSONB_EACH(employee_docs.docs) AS j

--turning the json data into a table format

SELECT 
	j.*
FROM employee_docs,JSONB_TO_RECORD(employee_docs.docs) AS j (
	department_id INT,
	name VARCHAR(100),
	all_roles VARCHAR(500)
)

--existence operator on json data ?
--exisitng operator expects only text on both sides id donot prefers any other datatypes

SELECT *
FROM employee_docs
WHERE docs->'name' ? 'Sales Department';

--containment operator in the json data @> #############################

SELECT *
FROM employee_docs
WHERE docs @> '{"name":"IT Department"}'

-- finding records using the department_id

SELECT *
FROM employee_docs
WHERE docs @> '{"department_id" : 6}'

-- MIX and match json search 
--#######################################################################

SELECT *
FROM employee_docs
WHERE docs ->> 'name' LIKE '%C%';

--finding the recors greater than 2

SELECT *
FROM employee_docs
WHERE (docs ->> 'department_id'):: INTEGER > 2;

--finding all records with the department_id = 1,2,3,4,5,6,7,9

SELECT *
FROM employee_docs
WHERE (docs ->> 'department_id'):: INTEGER IN (1,2,3,4,5,6,7,9);


--INDEXING ON JSONB ########################################################################################################################################################

SELECT *
FROM contacts_docs;

-- Fetching all the records where first_name is 'john'

SELECT *
FROM contacts_docs
WHERE body @> '{"first_name" : "John"}';


-- analyzing th equery

EXPLAIN ANALYZE
SELECT *
FROM contacts_docs
WHERE body @> '{"first_name" : "John"}';


/*
	Speeding up the query using the GIN index 
	GIN stands for the GENERALISED INVERTED INDEX
	when performing searching based on specific keys or elements in a text or a document,GIN index is the way
	to go Gin index stores "key" (or an element or a value ) and the " position list " pairs. The position 
	list is the rowID of the key .If the "key" occurs at multiple places in the document, gin index stores the key only once aloing with its position of 
	occurence whioch is not only keeps the gin index compact in size and also helps speed up the search in a
	great way
*/

-- creating the gin index for the contacts table

CREATE INDEX idx_gin_contacts_docs_body ON contacts_docs USING GIN(body);


SELECT *
FROM contacts_docs
WHERE body @> '{"first_name" : "Carmine"}';


--checking the size of the index

SELECT pg_size_pretty(pg_relation_size('idx_gin_contacts_docs_body'::regclass)) AS index_size;


-- making the index better 

CREATE INDEX idx_gin_contacts_docs_body_cool ON contacts_docs USING GIN(body JSONB_PATH_OPS);

--CHECKING the bettered index

SELECT pg_size_pretty(pg_relation_size('idx_gin_contacts_docs_body_cool'::regclass)) AS index_size;

--creating index on a specific json keyt

CREATE INDEX idx_gin_contacts_docs_body_fname ON contacts_docs USING GIN((body -> 'first_name') JSONB_PATH_OPS);

--checking the specific json key

SELECT pg_size_pretty(pg_relation_size('idx_gin_contacts_docs_body_fname'::regclass)) AS index_size;