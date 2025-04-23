create table employees(
						emp_id int primary key,
						first_name text not null,
						last_name text not null,
						job_position text not null,
						salary numeric(8,2),
						start_date date not null,
						birth_date date not null,
						store_id int,
						department_id int,
						manager_id int
);

create table departments(
						department_id int primary key,
						department text not null,
						division text not null
);

select 
	*
from 
	employees;

select 
	*
from 
	departments;

alter table employees
alter column department_id set not null,
alter column start_date set default current_date,
add column end_date date ,
add constraint birth_check check(birth_date <= current_date);

alter table employees
rename column job_position  to position_titile;

alter table employees
rename column position_titile to position_title;

insert into employees(emp_id,first_name,last_name,position_title,salary,
	start_date,birth_date,store_id,department_id,manager_id,end_date)
	values 
	(1,'Morrie','Conaboy','CTO',21268.94,'2005-04-30','1983-07-10',1,1,NULL,NULL),
(2,'Miller','McQuarter','Head of BI',14614.00,'2019-07-23','1978-11-09',1,1,1,NULL),
(3,'Christalle','McKenny','Head of Sales',12587.00,'1999-02-05','1973-01-09',2,3,1,NULL),
(4,'Sumner','Seares','SQL Analyst',9515.00,'2006-05-31','1976-08-03',2,1,6,NULL),
(5,'Romain','Hacard','BI Consultant',7107.00,'2012-09-24','1984-07-14',1,1,6,NULL),
(6,'Ely','Luscombe','Team Lead Analytics',12564.00,'2002-06-12','1974-08-01',1,1,2,NULL),
(7,'Clywd','Filyashin','Senior SQL Analyst',10510.00,'2010-04-05','1989-07-23',2,1,2,NULL),
(8,'Christopher','Blague','SQL Analyst',9428.00,'2007-09-30','1990-12-07',2,2,6,NULL),
(9,'Roddie','Izen','Software Engineer',4937.00,'2019-03-22','2008-08-30',1,4,6,NULL),
(10,'Ammamaria','Izhak','Customer Support',2355.00,'2005-03-17','1974-07-27',2,5,3,'2013-04-14'),
(11,'Carlyn','Stripp','Customer Support',3060.00,'2013-09-06','1981-09-05',1,5,3,NULL),
(12,'Reuben','McRorie','Software Engineer',7119.00,'1995-12-31','1958-08-15',1,5,6,NULL),
(13,'Gates','Raison','Marketing Specialist',3910.00,'2013-07-18','1986-06-24',1,3,3,NULL),
(14,'Jordanna','Raitt','Marketing Specialist',5844.00,'2011-10-23','1993-03-16',2,3,3,NULL),
(15,'Guendolen','Motton','BI Consultant',8330.00,'2011-01-10','1980-10-22',2,3,6,NULL),
(16,'Doria','Turbat','Senior SQL Analyst',9278.00,'2010-08-15','1983-01-11',1,1,6,NULL),
(17,'Cort','Bewlie','Project Manager',5463.00,'2013-05-26','1986-10-05',1,5,3,NULL),
(18,'Margarita','Eaden','SQL Analyst',5977.00,'2014-09-24','1978-10-08',2,1,6,'2020-03-16'),
(19,'Hetty','Kingaby','SQL Analyst',7541.00,'2009-08-17','1999-04-25',1,2,6,null),
(20,'Lief','Robardley','SQL Analyst',8981.00,'2002-10-23','1971-01-25',2,3,6,'2016-07-01'),
(21,'Zaneta','Carlozzi','Working Student',1525.00,'2006-08-29','1995-04-16',1,3,6,'2012-02-19'),
(22,'Giana','Matz','Working Student',1036.00,'2016-03-18','1987-09-25',1,3,6,NULL),
(23,'Hamil','Evershed','Web Developper',3088.00,'2022-02-03','2012-03-30',1,4,2,NULL),
(24,'Lowe','Diamant','Web Developper',6418.00,'2018-12-31','2002-09-07',1,4,2,NULL),
(25,'Jack','Franklin','SQL Analyst',6771.00,'2013-05-18','2005-10-04',1,2,2,NULL),
(26,'Jessica','Brown','SQL Analyst',8566.00,'2003-10-23','1965-01-29',1,1,2,NULL)
;


insert into departments
values
	(1,'Analytics','IT'),
	(2,'Finance','Administration'),
	(3,'Sales','Sales'),
	(4,'Website','IT'),
	(5,'Back Office','Administration');

update employees
set position_title = 'Senior SQL Analyst',
	salary = 7200
where first_name='Jack' and last_name = 'Franklin';

update employees
set position_title = 'Customer Specialist'
where position_title = 'Customer Support';

update employees
set salary = salary+(salary*0.06)
where position_title = 'SQL Analyst' or position_title = 'Senior SQL Analyst';


select position_title,round(avg(salary),2),count(*)
from employees
group by position_title
having position_title = 'SQL Analyst';

create view v_employees_info as 
select first_name || last_name as manager,
		case 
			when end_date is not null then 'false'
			else 'true'
		end as is_active
from employees;

select position_title,round(avg(salary),2)
from employees
group by position_title
;

select position_title,round(avg(salary),2)
from employees
group by position_title
having position_title = 'Software Engineer';

select d.department_id,
		e.position_title,
		d.division,
		round(avg(e.salary) over(partition by d.division),2) as average
from departments as d
left join employees as e on d.department_id = e.department_id
where d.division = 'Sales';

select emp_id,
		first_name,
		last_name,
		position_title,
		salary,
		round(avg(salary) over(partition by position_title order by emp_id),2)
from employees
order by emp_id;

select count(*)
from employees as e
join (
		select avg(salary) as average,position_title as grouped_title
		from employees
		group by position_title
) as a
on e.position_title = a.grouped_title
where salary < a.average;


select emp_id,position_title,salary,sum(salary) over(order by start_date),start_date
from employees;

SELECT 
start_date,
SUM(salary) OVER(ORDER BY start_date)
FROM (
SELECT 
emp_id,
salary,
start_date
FROM employees
UNION 
SELECT 
emp_id,
-salary,
end_date
FROM v_employees_info
WHERE is_active ='false'
ORDER BY start_date) a ;

select sub.first_name,sub.position_title,sub.salary
from
(select first_name,position_title,salary,rank() over(partition by position_title order by salary desc) as rank
from employees) as sub
where sub.rank = 1;


select sub.first_name,sub.average,sub.position_title
from (select first_name,position_title,salary,round(avg(salary) over(partition by position_title),2) as average
from employees) as sub
where salary = sub.average;

select d.division,d.department,e.position_title,count(emp_id),sum(salary),round(avg(salary),2)
from employees as e
left join departments as d on e.department_id = d.department_id
group by 
rollup
(d.division,d.department,e.position_title)
order by 1,2,3;

select emp_id,position_title,department,salary,rank() over(partition by department order by salary desc)
from employees
natural join departments;

select sub.emp_id,sub.position_title,sub.department,sub.salary,sub.rank
from (select emp_id,position_title,department,salary,rank() over(partition by department order by salary desc) as rank
from employees
natural join departments) as sub
where rank = 1;