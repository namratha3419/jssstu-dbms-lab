/*2. Write ER diagram and schema diagram. The primary keys are underlined and the
data types are specified.
Create tables for the following schema listed below by properly specifying the
primary keys and foreign keys.
Enter at least five tuples for each relation.
Insurance database
PERSON (driver id#: string, name: string, address: string)
CAR (regno: string, model: string, year: int)
ACCIDENT (report_ number: int, acc_date: date, location: string)
OWNS (driver id#: string, regno: string)
PARTICIPATED(driver id#:string, regno:string, report_ number:
int,damage_amount: int)*/
-------------------
create database insurance;
use insurance;
---------------
create tables
create table person
(driver_id int,
dname varchar(25),
daddress varchar(25),
primary key (driver_id)
);
create table car
(regno varchar(25),
model text,
year int,
primary key (regno)
);
create table accident
(report_number int,
acc_date date,
location varchar(25),
primary key (report_number)
);
create table owns
(driver_id int,
regno varchar(25),
foreign key(driver_id) references person(driver_id),
foreign key(regno) references car(regno)
);
create table participated
(driver_id int,
regno varchar(25),
report_number int,
damage_amount int,
foreign key(driver_id) references person(driver_id),
foreign key(regno) references car(regno),
foreign key(report_number) references accident(report_number)
);
------------------------------------------
--insert values
insert into person values
(111,'Driver_1','kuvempunager,Mysuru'),
(222,'Driver_2','saraswathipuram, Mysuru'),
(333,'Driver_3','jp nagar,Mysuru'),
(444,'Smith','jss layout'),
(555,'Driver_5','sharadhadevi nager,Mysuru');
insert into car values
('KA-09-AB-1234','alto',2019),
('KA-09-CD-6789','swift',2014),
('KA-09-MA-1234','Mazda',2017),
('KA-09-BC-0903','benze',2020),
('KA-09-AD-4314','kea',2021);
insert into accident values
('2345','2023-08-05','chamaraja nagar'),
('5674','2022-12-23','vishweshwara nagar'),
('3476','2019-03-15','kuvempunagar nagar'),
('8469','2021-05-26','shree nagar'),
('5647','2021-07-21','devaraja nager');
insert into owns values
(111,'KA-09-AB-1234'),
(222,'KA-09-CD-6789'),
(333,'KA-09-MA-1234'),
(444,'KA-09-BC-0903'),
(555,'KA-09-AD-4314');
insert into participated values
(111,'KA-09-MA-1234',5674,3000),
(222,'KA-09-CD-6789',8469,25000),
(333,'KA-09-MA-1234',8469,25000),
(444,'KA-09-BC-0903',2345,6700),
(555,'KA-09-AD-4314',5647,7800);
select * from person;
select * from car;
select * from accident;
select * from owns;
select * from participated;
----------------------------------
--Queries
1. Find the total number of people who owned cars that were involved in accidents
in 2021.
select COUNT(driver_id)
from participated p, accident a
where p.report_number = a.report_number and a.acc_date like "2021%";
--OR
SELECT COUNT(DISTINCT P.driver_id) AS total_people
FROM PERSON P
JOIN OWNS O ON P.driver_id = O.driver_id
JOIN PARTICIPATED PA ON O.regno = PA.regno
JOIN ACCIDENT A ON PA.report_number = A.report_number
WHERE A.acc_date like '2021%';
/*o/p
+------------------+
| COUNT(driver_id) |
+------------------+
| 3                |
+------------------+
+--------------+
| total_people |
+--------------+
| 3            |
+--------------+
-------------------------------------------*/
2. Find the number of accident in which cars belonging to smith were involved
select count(*) as accidents_involving_smith
from person p
join owns o on p.driver_id = o.driver_id
join participated pa on o.regno = pa.regno
where p.dname = 'smith';
/*
+---------------------------+
| accidents_involving_smith |
+---------------------------+
| 1                         |
+---------------------------+*/
insert into participated values(444,'KA-09-BC-0903',3476,7000);
Query OK, 1 row affected (0.00 sec)
  /*
+---------------------------+
| accidents_involving_smith |
+---------------------------+
| 2                         |
+---------------------------+*/
select count(*) as num_of_acc_smith
from accident a
join participated pa on pa.report_no=a.report_no
join person p on p.driver_id=pa.driver_id
where p.driver_name='smith';
-------------------------------------------------
--3.Add a new accident to the database,assume any values for required attributes.
insert into accident values
('9845','2022-08-30','shanthi sagar');
insert into participated values
(444,'KA-09-BC-0903',9845,7000);
select * from accident;
/*
+---------------+------------+--------------------+
| report_number | acc_date | location |
+---------------+------------+--------------------+
| 2345 | 2023-08-05 | chamaraja nagar |
| 3476 | 2019-03-15 | kuvempunagar nagar |
| 5647 | 2021-07-21 | devaraja nager |
| 5674 | 2022-12-23 | vishweshwara nagar |
| 8469 | 2021-05-26 | shree nagar |
| 9845 | 2022-08-30 | shanthi sagar |
+---------------+------------+--------------------+
6 rows in set (0.00 sec)
mysql> select * from participated;
+-----------+---------------+---------------+---------------+
| driver_id | regno | report_number | damage_amount |
+-----------+---------------+---------------+---------------+
| 111 | KA-09-MA-1234 | 5674 | 3000 |
| 222 | KA-09-CD-6789 | 8469 | 25000 |
| 333 | KA-09-MA-1234 | 8469 | 25000 |
| 444 | KA-09-BC-0903 | 2345 | 6700 |
| 555 | KA-09-AD-4314 | 5647 | 7800 |
| 444 | KA-09-BC-0903 | 9845 | 7000 |
+-----------+---------------+---------------+---------------+
6 rows in set (0.00 sec)*/
-----------------------------------------------------------------
--4.Delete the Mazda belonging to “Smith”.(used insurance_manual database)
delete from car where model='Mazda' and reg_no in (select reg_no from owns o
join person p on p.driver_id = o.driver_id and p.driver_name='smith');
--OR
DELETE FROM CAR
WHERE reg_no IN (SELECT reg_no FROM OWNS WHERE driver_id = (SELECT driver_id FROM
PERSON WHERE driver_name = 'Smith') AND model = 'Mazda');
insert into owns values
(333,'KA-09-MA-1234'),
(444,'KA-09-MA-1234');
select * from car;
/*
+---------------+-------+--------+
| reg_no | model | c_year |
+---------------+-------+--------+
| KA-09-AB-1234 | alto | 2019 |
| KA-09-AD-4314 | kea | 2021 |
| KA-09-BC-0903 | benze | 2020 |
| KA-09-CD-6789 | swift | 2014 |
+---------------+-------+--------+
4 rows in set (0.00 sec)
mysql> select * from owns;
+-----------+---------------+
| driver_id | reg_no |
+-----------+---------------+
| 111 | KA-09-AB-1234 |
| 222 | KA-09-CD-6789 |
| 444 | KA-09-BC-0903 |
| 555 | KA-09-AD-4314 |
+-----------+---------------+*/
-----------------------------------------------------------------------------------

--5.Update the damage amount for the car with license number “KA09MA1234” in the
accident with report.
update participated
set damage_amount=3000
where reg_no='KA-09-MA-1234' and report_no=8469;
Query OK, 1 row affected (0.00 sec)
Rows matched: 1 Changed: 1 Warnings: 0
mysql> select * from participated;
/*
+-----------+---------------+-----------+---------------+
| driver_id | reg_no | report_no | damage_amount |
+-----------+---------------+-----------+---------------+
| 222 | KA-09-CD-6789 | 8469 | 25000 |
| 444 | KA-09-BC-0903 | 2345 | 6700 |
| 555 | KA-09-AD-4314 | 5647 | 7800 |
| 444 | KA-09-BC-0903 | 9845 | 7000 |
| 333 | KA-09-MA-1234 | 8469 | 3000 |
+-----------+---------------+-----------+---------------+
5 rows in set (0.00 sec)*/
-----------------------------------------------------------------------------------

--6.A view that shows models and year of cars that are involved in accident.
create view CarsInvolvedInAcc as
select model,c_year from car
where reg_no in (select reg_no from participated);
select * from CarsInvolvedInAcc;
/*
+-------+--------+
| model | c_year |
+-------+--------+
| kea | 2021 |
| benze | 2020 |
| swift | 2014 |
| Mazda | 2017 |
+-------+--------+*/
-----------------------------------------------------------------------------------

--7.A trigger that prevents a driver from participating in more than 3 accidents in a
given year.
DELIMITER //
create trigger PreventParticipation
before insert on participated
for each row
BEGIN
IF 2<=(select count(*) from participated where driver_id=new.driver_id) THEN
signal sqlstate '45000' set message_text='Driver has already participated in 2
accidents';
END IF;
END;//
DELIMITER ;
insert into participated values
(444,' KA-09-MA-1234', 5647,4500);

--o/p
--ERROR 1644 (45000): Driver has already participated in 2 accidents
