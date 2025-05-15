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