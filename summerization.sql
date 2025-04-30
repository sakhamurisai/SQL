--computing subtotals
--intriduction to summerization #####################################################

/*

	When we are aggreagting the data, we generally remove the datil data that lies below the summarised totals

	The whole point of aggregation is to replace detail data with summarization. THis is where the subtotals comesin 

	grou by is used to group the dat together.however when summarization you might need grouping setd

	A grouping set is a set of columns by which you group 

	The postgreSQL rollup is a subclause of the group by clause that offers a shorthand for defining 'multiple grouping set'

*/

--creating a course table

CREATE TABLE Courses(
	course_id SERIAL PRIMARY KEY ,
	course_name VARCHAR(100) NOT NULL,
	course_level VARCHAR(100) NOT NULL,
	sold_units INT NOT NULL
);

-- lets browse the data

SELECT *
FROM courses;

--lets insert some data

INSERT INTO courses (course_name,course_level,sold_units) 
VALUES 
	('Machine Learning With python','Premium',100),
	('Data Science Bootcamp','Premium',50),
	('Introduction to python','Basic',200),
	('Understanding MongoDB','Premium',100),
	('Algorithum Design in Python','Premium',200);

SELECT *
FROM courses;

-- arranging the data

SELECT 
	course_level,
	course_name,
	sold_units
FROm courses;

SELECT 
	course_level,
	sum(sold_units)
FROM courses
GROUP BY course_level;


SELECT 
	course_level,
	course_name,
	SUM(sold_units) AS "total_sold"
FROM courses
GROUP BY ROLLUP(
	course_level,
	course_name)
ORDER BY 
	course_level,
	course_name

SELECT 
	course_level,
	sum(sold_units),
	GROUPING(course_level)
FROM courses
GROUP BY course_level;

--one of the example for the grouping function

SELECT 
  region,
  product,
  SUM(revenue) AS total_revenue,
  GROUPING(region) AS grp_region,
  GROUPING(product) AS grp_product
FROM sales
GROUP BY ROLLUP(region, product);

/*
Returns 0 if the column was grouped normally.

Returns 1 if the column is null because of subtotal/grand total.*/

 