/*Student enrollment
Write ER diagram and schema diagram. The primary keys are underlined and the data
types are specified.
Create tables for the following schema listed below by properly specifying the
primary keys and foreign keys.
Enter at least five tuples for each relation.
Student enrollment in courses and books adopted for each course
STUDENT (regno: string, name: string, major: string, bdate: date)
COURSE (course#:int, cname: string, dept: string)
ENROLL(regno:string, course#: int,sem: int,marks: int)
BOOK-ADOPTION (course#:int, sem: int, book-ISBN: int)
TEXT (book-ISBN: int, book-title: string, publisher: string,author: string)
1.Demonstrate how you add a new text book to the database and make this book be
adopted by some department.
2.Produce a list of text books (include Course #, Book-ISBN, Book-title) in the
alphabetical order for courses offered by the ‘CS’ department that use more than
two books.
3.List any department that has all its adopted books published by a specific
publisher.
4.List the students who have scored maximum marks in ‘DBMS’ course.
5.Create a view to display all the courses opted by a student along with marks
obtained.
6.Create a trigger that prevents a student from enrolling in a course if the marks
prerequisite is less than 40.*/
----------------------------------------------------------------------
create database student_enrollment;
use student_enrollment;
---------------------------------------------------
--create tables
create table Student(
regno varchar(13) primary key,
name varchar(25) not null,
major varchar(25) not null,
bdate date not null
);
create table Course(
course int primary key,
cname varchar(30) not null,
dept varchar(100) not null
);
create table Enroll(
regno varchar(13),
course int,
sem int not null,
marks int not null,
foreign key(regno) references Student(regno) on delete cascade,
foreign key(course) references Course(course) on delete cascade
);
create table TextBook(
bookIsbn int not null,
book_title varchar(40) not null,
publisher varchar(25) not null,
author varchar(25) not null,
primary key(bookIsbn)
);
create table BookAdoption(
course int not null,
sem int not null,
bookIsbn int not null,
foreign key(bookIsbn) references TextBook(bookIsbn) on delete cascade,
foreign key(course) references Course(course) on delete cascade
);
------------------------------------------------------
--insert values
INSERT INTO Student VALUES
("01HF235", "Student_1", "CSE", "2001-05-15"),
("01HF354", "Student_2", "Literature", "2002-06-10"),
("01HF254", "Student_3", "Philosophy", "2000-04-04"),
("01HF653", "Student_4", "History", "2003-10-12"),
("01HF234", "Student_5", "Computer Economics", "2001-10-10");
INSERT INTO Course VALUES
(001, "DBMS", "CS"),
(002, "Literature", "English"),
(003, "Philosophy", "Philosphy"),
(004, "History", "Social Science"),
(005, "Computer Economics", "CS");
INSERT INTO Enroll VALUES
("01HF235", 001, 5, 85),
("01HF354", 002, 6, 87),
("01HF254", 003, 3, 95),
("01HF653", 004, 3, 80),
("01HF234", 005, 5, 75);
INSERT INTO TextBook VALUES
(241563, "Operating Systems", "Pearson", "Silberschatz"),
(532678, "Complete Works of Shakesphere", "Oxford", "Shakesphere"),
(453723, "Immanuel Kant", "Delphi Classics", "Immanuel Kant"),
(278345, "History of the world", "The Times", "Richard Overy"),
(426784, "Behavioural Economics", "Pearson", "David Orrel");
INSERT INTO BookAdoption VALUES
(001, 5, 241563),
(002, 6, 532678),
(003, 3, 453723),
(004, 3, 278345),
(001, 6, 426784);
select * from Student;
select * from Course;
select * from Enroll;
select * from BookAdoption;
select * from TextBook;
-------------------------------------------------------------
/*1.Demonstrate how you add a new text book to the database and make this book be
adopted by some department.*/
insert into adoption values
(002,1,123456);
insert into bookadoption values
(002,1,123456);
select * from BookAdoption;
/*o/p
+--------+-----+----------+
| course | sem | bookIsbn |
+--------+-----+----------+
| 1 | 5 | 241563 |
| 2 | 6 | 532678 |
| 3 | 3 | 453723 |
| 4 | 3 | 278345 |
| 1 | 6 | 426784 |
| 2 | 1 | 123456 |
+--------+-----+----------+*/
select * from TextBook;
/*o/p
+----------+-------------------------------+-----------------+---------------+
| bookIsbn | book_title | publisher | author |
+----------+-------------------------------+-----------------+---------------+
| 123456 | alice novel | kb publications | Robert alice |
| 241563 | Operating Systems | Pearson | Silberschatz |
| 278345 | History of the world | The Times | Richard Overy |
| 426784 | Behavioural Economics | Pearson | David Orrel |
| 453723 | Immanuel Kant | Delphi Classics | Immanuel Kant |
| 532678 | Complete Works of Shakesphere | Oxford | Shakesphere |
+----------+-------------------------------+-----------------+---------------+*/
--2.Produce a list of text books (include Course #, Book-ISBN, Book-title) in the alphabetical order for courses offered by the ‘CS’ department that use more than two books.
SELECT c.course, t.bookisbn, t.book_title
FROM course c
JOIN bookadoption ba ON c.course = ba.course
JOIN textbook t ON ba.bookisbn = t.bookisbn
WHERE c.dept = 'cs'
GROUP BY t.book_title
HAVING COUNT(ba.bookisbn) > 2;
/*o/p
+--------+----------+-------------------------------+
| course | bookisbn | book_title |
+--------+----------+-------------------------------+
| 5 | 532678 | Complete Works of Shakesphere |
+--------+----------+-------------------------------+*/
-----------------------------------------------------------------------
--3.List any department that has all its adopted books published by a specific publisher.
select distinct c.dept as depatment_name
from course c
join BookAdoption ba on c.course = ba.course
join TextBook t on t.bookisbn=ba.bookisbn
where t.publisher='pearson';
--OR
SELECT DISTINCT c.dept
FROM Course c
WHERE c.dept IN
( SELECT c.dept
FROM Course c,BookAdoption b,TextBook t
WHERE c.course=b.course
AND t.bookIsbn=b.bookIsbn
AND t.publisher='PEARSON');
/*o/p
+----------------+
| depatment_name |
+----------------+
| CS |
+----------------+*/
------------------------------------------------------------------------
--4.List the students who have scored maximum marks in ‘DBMS’ course.
select name, max(enroll.marks) as max_marks
from student
join enroll on enroll.regno=student.regno
join course c on c.course=enroll.course
where c.cname='DBMS';
--OR
select name from Student s, Enroll e, Course c
where s.regno=e.regno and e.course=c.course and c.cname="DBMS" and e.marks in
(select max(marks) from Enroll e1, Course c1 where c1.cname="DBMS" and
c1.course=e1.course);
/*o/p
+-----------+-----------+
| name | max_marks |
+-----------+-----------+
| Student_1 | 85 |
+-----------+-----------+*/
-----------------------------------------------------------------------------------
--5.Create a view to display all the courses opted by a student along with marks obtained.
create view courseopted2 as
select c.cname,e.marks
from course c, enroll e
where c.course=e.course and e.regno='01HF254'
group by marks;

/*o/p
+------------+-------+
| cname | marks |
+------------+-------+
| Philosophy | 95 |
+------------+-------+*/
-----------------------------------------------------------------------------------
--6.Create a trigger that prevents a student from enrolling in a course if the marks prerequisite is less than 40.
delimiter //
create trigger lessthan40
after insert into enroll
for each row
begin
if (new.marks < 40) then
signal sqlstate '45000' set message_text='marks is less than 40';
end if;
end;//
delimiter;

INSERT INTO Enroll VALUES ("01HF235", 002, 5, 5);
/*o/p
ERROR 1644 (45000): Marks is less than 40*/
