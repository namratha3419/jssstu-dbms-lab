/*company database
Write ER diagram and schema diagram. The primary keys are underlined and the data
types are specified.
Create tables for the following schema listed below by properly specifying the
primary keys and foreign keys.
Enter at least five tuples for each relation.
Company Database:
EMPLOYEE (SSN, Name, Address, Sex, Salary, SuperSSN, DNo)
DEPARTMENT (DNo, DName, MgrSSN, MgrStartDate)
DLOCATION (DNo,DLoc)
PROJECT (PNo, PName, PLocation, DNo)
WORKS_ON (SSN, PNo, Hours)
1.Make a list of all project numbers for projects that involve an employee whose
last name is ‘Scott’, either as a worker or as a manager of the department that
controls the project.
2.Show the resulting salaries if every employee working on the ‘IoT’ project is
given a 10 percent raise.
3.Find the sum of the salaries of all employees of the ‘Accounts’ department, as
well as the maximum salary, the minimum salary, and the average salary in this
department
4.Retrieve the name of each employee who works on all the projects controlled by
department number 5 (use NOT EXISTS operator).
5.For each department that has more than five employees, retrieve the department
number and the number of its employees who are making more than Rs. 6,00,000.
6.Create a view that shows name, dept name and location of all employees.
7.Create a trigger that prevents a project from being deleted if it is currently
being worked by any employee.*/
---------------------------------------------------------
create database company;
use company;
---------------------------------------------------------
--create tables
create table if not exists Employee(
ssn varchar(35) primary key,
name varchar(35) not null,
address varchar(255) not null,
sex varchar(7) not null,
salary int not null,
super_ssn varchar(35),
d_no int,
foreign key (super_ssn) references Employee(ssn) on delete set null
);
create table if not exists Department(
d_no int primary key,
dname varchar(100) not null,
mgr_ssn varchar(35),
mgr_start_date date,
foreign key (mgr_ssn) references Employee(ssn) on delete cascade
);
create table if not exists DLocation(
d_no int not null,
d_loc varchar(100) not null,
foreign key (d_no) references Department(d_no) on delete cascade
);
create table if not exists Project(
p_no int primary key,
p_name varchar(25) not null,
p_loc varchar(25) not null,
d_no int not null,
foreign key (d_no) references Department(d_no) on delete cascade
);
create table if not exists WorksOn(
ssn varchar(35) not null,
p_no int not null,
hours int not null default 0,
foreign key (ssn) references Employee(ssn) on delete cascade,
foreign key (p_no) references Project(p_no) on delete cascade
);
--------------------------------------------------------------------
--insert values
INSERT INTO Employee VALUES
("01NB235", "Chandan_Krishna","Siddartha Nagar, Mysuru", "Male", 1500000,
"01NB235", 5),
("01NB354", "Employee_2", "Lakshmipuram, Mysuru", "Female", 1200000,"01NB235", 2),
("02NB254", "Employee_3", "Pune, Maharashtra", "Male", 1000000,"01NB235", 4),
("03NB653", "Employee_4", "Hyderabad, Telangana", "Male", 2500000, "01NB354", 5),
("04NB234", "Employee_5", "JP Nagar, Bengaluru", "Female", 1700000, "01NB354", 1);
INSERT INTO Department VALUES
(001, "Human Resources", "01NB235", "2020-10-21"),
(002, "Quality Assesment", "03NB653", "2020-10-19"),
(003,"System assesment","04NB234","2020-10-27"),
(005,"Production","02NB254","2020-08-16"),
(004,"Accounts","01NB354","2020-09-4");
INSERT INTO DLocation VALUES
(001, "Jaynagar, Bengaluru"),
(002, "Vijaynagar, Mysuru"),
(003, "Chennai, Tamil Nadu"),
(004, "Mumbai, Maharashtra"),
(005, "Kuvempunagar, Mysuru");
INSERT INTO Project VALUES
(241563, "System Testing", "Mumbai, Maharashtra", 004),
(532678, "IOT", "JP Nagar, Bengaluru", 001),
(453723, "Product Optimization", "Hyderabad, Telangana", 005),
(278345, "Yeild Increase", "Kuvempunagar, Mysuru", 005),
(426784, "Product Refinement", "Saraswatipuram, Mysuru", 002);
INSERT INTO WorksOn VALUES
("01NB235", 278345, 5),
("01NB354", 426784, 6),
("04NB234", 532678, 3),
("02NB254", 241563, 3),
("03NB653", 453723, 6);
alter table Employee add constraint foreign key (d_no) references Department(d_no)
on delete cascade;
SELECT * FROM Department;
SELECT * FROM Employee;
SELECT * FROM DLocation;
SELECT * FROM Project;
SELECT * FROM WorksOn;
----------------------------------------------------------------
--1.Make a list of all project numbers for projects that involve an employee whose last name is ‘Scott’, either as a worker or as a manager of the department that controls the project.
SELECT p.p_no,p.p_name,e.name
FROM project p
JOIN employee e ON p.d_no = e.d_no
JOIN department d ON d.d_no = e.d_no
WHERE EXISTS (
SELECT *
FROM workson w
WHERE w.ssn = e.ssn AND e.name LIKE '%krishna'
)
UNION
SELECT p.p_no,p.p_name,e.name
FROM project p
JOIN employee e ON p.d_no = e.d_no
JOIN department d ON d.d_no = e.d_no
WHERE EXISTS (
SELECT *
FROM department d
WHERE d.mgr_ssn = e.super_ssn AND e.name LIKE '%krishna'
)
GROUP BY p.p_no;
--or
select p_no,p_name,name from Project p, Employee e
where p.d_no=e.d_no and e.name like "%Krishna";
/*o/p
+--------+----------------------+-----------------+
| p_no | p_name | name |
+--------+----------------------+-----------------+
| 278345 | Yeild Increase | Chandan_Krishna |
| 453723 | Product Optimization | Chandan_Krishna |
+--------+----------------------+-----------------+*/
---------------------------------------------------------------
--2.Show the resulting salaries if every employee working on the ‘IoT’ project is given a 10 percent raise.
select e.ssn,e.name,e.salary as old_salary,e.salary*1.1 as new_salary
from employee e
join workson w on w.ssn=e.ssn
join project p on p.p_no=w.p_no
where p.p_name='IOT';
/*o/p
+---------+------------+------------+------------+
| ssn | name | old_salary | new_salary |
+---------+------------+------------+------------+
| 04NB234 | Employee_5 | 1700000 | 1870000.0 |
+---------+------------+------------+------------+*/
----------------------------------------------------------------------------------------------
--3.Find the sum of the salaries of all employees of the ‘Accounts’ department, as well as the maximum salary, the minimum salary, and the average salary in this department
select sum(salary) as total_salary,
max(salary) as max_salary,
min(salary) as min_salary,
avg(salary) as avg_salary
from employee e
join department d on d.d_no=e.d_no
where d.dname='Accounts';
/*o/p
+--------------+------------+------------+--------------+
| total_salary | max_salary | min_salary | avg_salary |
+--------------+------------+------------+--------------+
| 1000000 | 1000000 | 1000000 | 1000000.0000 |
+--------------+------------+------------+--------------+*/
-----------------------------------------------------------------
--4.Retrieve the name of each employee who works on all the projects controlled by department number 5 (use NOT EXISTS operator).
select Employee.ssn,name,d_no from Employee where not exists
(select p_no from Project p where p.d_no=5 and p_no not in
(select p_no from WorksOn w where w.ssn=Employee.ssn));
--or
SELECT name
FROM EMPLOYEE E
WHERE NOT EXISTS (
SELECT P_No
FROM PROJECT P
WHERE D_No = 5
AND NOT EXISTS (
SELECT *
FROM WORKSON W
WHERE W.SSN = E.SSN AND W.P_No = P.P_No
)
);
/*o/p
+---------+-----------------+------+
| ssn | name | d_no |
+---------+-----------------+------+
| 01NB235 | Chandan_Krishna | 5 |
+---------+-----------------+------+*/
---------------------------------------------------------------------------------------
--5.For each department that has more than one employees, retrieve the department number and the number of its employees who are making more than Rs. 6,00,000.
select d.d_no, count(*)
from Department d
join Employee e on e.d_no=d.d_no
where salary>600000
group by d.d_no
having count(*)>1;
--OR
select d.d_no, count(e.d_no)
from Department d, employee e
where e.d_no=d.d_no
and salary>600000
group by d.d_no
having count(*)>1;
/*o/p
+------+----------+
| d_no | count(*) |
+------+----------+
| 5 | 2 |
+------+----------+*/
-----------------------------------------------------------------------
--6.Create a view that shows name, dept name and location of all employees.
create view empdetails as
select e.name, d.dname,l.d_loc
from employee e,department d, dlocation l
where e.d_no=d.d_no and d.d_no=l.d_no;
select * from empdetails;
/*o/p
+-----------------+-------------------+----------------------+
| name | dname | d_loc |
+-----------------+-------------------+----------------------+
| Employee_5 | Human Resources | Jaynagar, Bengaluru |
| Employee_2 | Quality Assesment | Vijaynagar, Mysuru |
| Employee_3 | Accounts | Mumbai, Maharashtra |
| Chandan_Krishna | Production | Kuvempunagar, Mysuru |
| Employee_4 | Production | Kuvempunagar, Mysuru |
+-----------------+-------------------+----------------------+*/
------------------------------------------------------------------------
--7.Create a trigger that prevents a project from being deleted if it is currently being worked by any employee.
delimiter //
create trigger preventdelete
before delete on project
for each row
begin
if exists(select p_no from project where p_no in(select p_no from workson where
p_no=old.p_no)) then
signal sqlstate '45000' set message_text='project in in progress and cannot be
deleted';
end if;
end;//
delimiter;
--delete from project
delete from project where p_no=532678;
/*o/p
ERROR 1644 (45000): project in in progress and cannot be deleted*/
