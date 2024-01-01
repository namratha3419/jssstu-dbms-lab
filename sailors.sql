/*1. Sailors database
SAILORS (sid, sname, rating, age)
BOAT(bid, bname, color)
RSERVERS (sid, bid, date)
Queries, View and Trigger
1. Find the colours of boats reserved by Albert
2. Find all sailor id’s of sailors who have a rating of at least 8 or
reserved boat 103
3. Find the names of sailors who have not reserved a boat whose name
contains the string “storm”. Order the names in ascending order.
4. Find the names of sailors who have reserved all boats.
5. Find the name and age of the oldest sailor.
6. For each boat which was reserved by at least 5 sailors with age >= 40,
find the boat id and the average age of such sailors.
7. Create a view that shows the names and colours of all the boats that
have been reserved by a sailor with a specific rating.
8. A trigger that prevents boats from being deleted If they have active
reservations.
-------------------------------------------------------------------------*/
-- Create tables
create table sailors (
sid varchar(20),
sname varchar(255),
rating float,
age int,
primary key (sid)
);
create table boat (
bid varchar(10),
bname varchar(255),
color varchar(255),
primary key (bid)
);
create table reserves (
sid varchar(20),
bid varchar(10),
date date,
foreign key (sid) references sailors(sid),
foreign key (bid) references boat(bid)
);
--------------------------
-- Insert sample values
insert into sailors values
(101, 'Albert', 8, 30),
(102, 'Bob', 7, 25),
(103, 'Charlie', 9, 35),
(104, 'john', 5, 50),
(105, 'meichel', 8.7, 40);
insert into boat values
(201, 'Boat1', 'Red'),
(202, 'Boat2', 'Blue'),
(203, 'Boat3', 'Green'),
(204, 'Boat4', 'Violet'),
(205, 'Boat5', 'Megenta');
insert into reserves values
(101, 201, '2023-01-01'),
(102, 202, '2023-02-01'),
(101, 203, '2023-03-01'),
(103, 201, '2023-04-01'),
(103, 202, '2023-05-01');
select * from sailors;
select * from boat;
select * from reserves;
------------------------------
-- Queries
-- 1. Find the colors of boats reserved by Albert
select distinct b.color
from sailors s
join reserves r on s.sid = r.sid
join boat b on r.bid = b.bid
where s.sname = 'Albert';
OR
select color
from Sailors s, Boat b, reserves r
where s.sid=r.sid and b.bid=r.bid and s.sname="Albert";
/*o/p:
+-------+
| color |
+-------+
| Red |
| Green |
+-------+
--------------------------------*/
-- 2. Find all sailor IDs of sailors who have a rating of at least 8 or reserved
boat 103
select sid
from sailors
where rating >= 8
or sid in (select sid from reserves where bid = 103);
OR
(select sid
from sailors
where rating >= 8)
union
(select sid
from reserves
where bid=103);
/*o/p:
+-----+
| sid |
+-----+
| 101 |
| 103 |
| 105 |
+-----+
-----------------------------------*/
-- 3. Find the names of sailors who have not reserved a boat whose name contains
the string “storm”. Order the names in ascending order.
select s.sname
from sailors s
where s.sid not in
(select s1.sid from sailors s1 join reserves r1 on r1.sid=s1.sid and s1.sname like
"%storm%")
and s.sname like "%storm%"
order by s.sname asc;
/*o/p
+----------------+
| sname |
+----------------+
| albert amstorm |
+----------------+*/
select s.sname from sailors s
where s.sid not in(select s1.sid from sailors s1 join reserves r on r.sid=s1.sid
and s1.sname like '%Albert%')
and s.sname like '%Albert%'
order by s.sname asc;
-------------------------------------
-- 4. Find the names of sailors who have reserved all boats.
select sname from sailors s where not exists
(select * from boat b where not exists
(select * from reserves r where r.sid=s.sid and b.bid=r.bid));
/*o/p
+-------+
| sname |
+-------+
| Bob |
+-------+*/
--------------------------------------
-- 5. Find the name and age of the oldest sailor.
select sname,age
from sailors
order by age desc
limit 1;
OR
select sname, age
from sailors
where age = (select max(age) from sailors);
/*o/p
+-------+------+
| sname | age |
+-------+------+
| john | 50 |
+-------+------+
---------------------------*/
-- 6. For each boat reserved by at least 5 sailors with age >= 40, find the boat ID
and the average age of such sailors.
select b.bid, avg(s.age) as average_age
from sailors s, boat b, reserves r
where r.sid=s.sid and r.bid=b.bid and s.age>=40
group by bid
having count(r.sid)>=5;

/*o/p
+-----+-------------+
| bid | average_age |
+-----+-------------+
| 202 | 45.0000 |
+-----+-------------+
-------------------------------------*/
-- 7. Create a view that shows the names and colors of all the boats that have been
reserved by a sailor with a specific rating.
create view ReservedBoat as
select s.sname,b.color
from sailors s
join reserves r on r.sid=s.sid join boat b on b.bid=r.bid
where rating=9;
select * from BoatReservations;

/*o/p
+---------+-------+
| sname   | color |
+---------+-------+
| Charlie | Red  |
| Charlie | Blue |
+---------+-------+
---------------------------------------*/
-- 8. Trigger to prevent deletion of boats with active reservations
delimiter //
create trigger CheckAndDelete
before delete on Boat
for each row
begin
if exists (select * from reserves where reserves.bid=old.bid)
then
signal sqlstate '45000' set message_text='Boat is reserved and hence cannot be
deleted';
end if;
end;//
delimiter ;
delete from boat where bid=203;
/*o/p
ERROR 1644 (45000): Boat is reserved and hence cannot be deleted*/
