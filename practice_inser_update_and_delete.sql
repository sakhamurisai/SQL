CREATE TABLE IF NOT EXISTS employees_practice (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    department VARCHAR(50),
    salary NUMERIC(10, 2),
    hire_date DATE DEFAULT CURRENT_DATE
);

SELECT *
FROM employees_practice;


--simple questions

INSERT INTO employees_practice (first_name,last_name,email,department,salary,hire_date)
VALUES
	('Jhon','Wick','Jhonwick@gmail.com','Bounty Hunter',10,'2020-01-01');

INSERT INTO employees_practice (first_name,last_name,email,department,salary)
VALUES
	('Django','Walster','django@gmail.com','Freedom Fighter',0);

INSERT INTO employees_practice (first_name,last_name,email)
VALUES
	('Williams','Smith','smith@gmail.com');


--Intermediate questions

INSERT INTO employees_practice (first_name,last_name,email,department,salary,hire_date)
VALUES 
	('John', 'Doe', 'john.doe@example.com', 'Sales', 55000, '2022-03-15'),
('Jane', 'Smith', 'jane.smith@example.com', 'Engineering', 72000, '2021-07-01'),
('Alice', 'Brown', 'alice.brown@example.com', 'HR', 60000, '2023-01-10');


INSERT INTO employees_practice (first_name,last_name,email,department,salary,hire_date)
SELECT first_name,last_name,email,department,salary,hire_date
FROM new_hires;


INSERT INTO employees_practice (first_name,last_name,email,department,salary,hire_date)
VALUES
	('Michael', 'Johnson', 'michael.johnson@example.com', 'Marketing', 58000, '2022-11-05')
RETURNING id;


--advanced insert questions

INSERT INTO employees_practice (first_name,last_name,email,department,salary,hire_date)
VALUES 
	('Emily', 'Clark', 'django@gmail.com', 'Finance', 67000, '2023-06-20')
ON CONFLICT (email) DO NOTHING;

--excluded is a special table that holds the values proposed for insertion in case of conflict.

INSERT INTO employees_practice (first_name,last_name,email,department,salary,hire_date)
VALUES 
	('David', 'Lee', 'django@example.com', 'IT', 63000, '2021-09-12')
ON CONFLICT (email) DO UPDATE SET email = excluded.first_name || '@gmail.com' , hire_date = CURRENT_DATE;

INSERT INTO employees_practice (first_name,last_name,email,department,salary,hire_date)
VALUES 
	('Sophia', 'Martinez', 'django@gmail.com', 'Operations', 62000, '2022-08-18')
ON CONFLICT (email) DO UPDATE SET email = excluded.first_name || '@gmail.com' , salary = EXCLUDED.salary;


INSERT INTO employees_practice (first_name,last_name,email,department,salary,hire_date)
VALUES 
	('Liam', 'Anderson', 'liam.anderson@example.com', 'Finance', 67000, '2023-04-22')
ON CONFLICT (email) DO UPDATE SET email = excluded.first_name || '@gmail.com' , salary = EXCLUDED.salary;


SHOW SERVER_ENCODING;



/*UPDATE Statement Questions

Simple:

How would you change the salary of a single employee identified by their email address?
Describe how to update the department for all employees whose current department is 'Marketing'.
Explain how to update the email address for a specific employee identified by their id.
Intermediate:

How would you increase the salary of all employees in the 'Sales' department by 10%?
Describe how to change both the department and the salary for a specific employee in a single UPDATE statement.
How would you update the department for an employee based on information found in a different related table (e.g., using a join or subquery)?
Advanced:

How can you update the salary of employees differently based on their current salary level (e.g., a higher percentage raise for lower salaries)?
Describe how to update a column (department) based on the result of an aggregate function (like AVG or COUNT) calculated from the same table, potentially grouped in some way.
Explain how to update a record using values returned from a subquery that retrieves information from another table, ensuring the update applies to the correct record based on a join condition.
DELETE Statement Questions

Simple:

How would you remove a single employee record identified by their email address?
Describe how to delete all employee records where the department is 'Finance'.
Explain how to delete an employee record based on their unique id.
Intermediate:

How would you delete all employees who were hired before a specific date?
Describe how to delete employees whose salary is below a certain threshold and are in a specific department.
How would you delete employee records based on whether a corresponding record exists or does not exist in another related table?
Advanced:

Explain how to remove all rows from the employees table efficiently while keeping the table structure and resetting any sequence generators associated with columns like id.
Describe how to delete employees based on a condition that involves comparing their salary to the average salary of their own department (requiring a subquery or self-join).
How would you delete employee records while simultaneously returning the details of the rows that were just deleted?
*/