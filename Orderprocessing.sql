--Order processing database
/*Customer (Cust#:int, cname: string, city: string)
Order (order#:int, odate: date, cust#: int, order-amt: int)
Order-item (order#:int, Item#: int, qty: int)
Item (item#:int, unitprice: int)
Shipment (order#:int, warehouse#: int, ship-date: date)
Warehouse (warehouse#:int, city: string)
1. List the Order# and Ship_date for all orders shipped from Warehouse# "W2".
2. List the Warehouse information from which the Customer named "Kumar" was
supplied his orders. Produce a listing of Order#, Warehouse#.
3. Produce a listing: Cname, #ofOrders, Avg_Order_Amt, where the middle column is
the total number of orders by the customer and the last column is the average order
amount for that customer. (Use aggregate functions)
4. Delete all orders for customer named "Kumar".
5. Find the item with the maximum unit price.
6. A trigger that updates order_amout based on quantity and unitprice of order_item
7. Create a view to display orderID and shipment date of all orders shipped from a
warehouse 5.*/
-----------------------------------------
create database order_processing;
use order_processing;
-------------------------
create tables
create table if not exists Customers (
cust_id int primary key,
cname varchar(35) not null,
city varchar(35) not null
);
create table if not exists Orders (
order_id int primary key,
odate date not null,
cust_id int,
order_amt int not null,
foreign key (cust_id) references Customers(cust_id) on delete cascade
);
create table if not exists Items (
item_id int primary key,
unitprice int not null
);
create table if not exists OrderItems (
order_id int not null,
item_id int not null,
qty int not null,
foreign key (order_id) references Orders(order_id) on delete cascade,
foreign key (item_id) references Items(item_id) on delete cascade
);
create table if not exists Warehouses (
warehouse_id int primary key,
city varchar(35) not null
);
create table if not exists Shipments (
order_id int not null,
warehouse_id int not null,
ship_date date not null,
foreign key (order_id) references Orders(order_id) on delete cascade,
foreign key (warehouse_id) references Warehouses(warehouse_id) on delete cascade
);
----------------------------------------------
--insert values
INSERT INTO Customers VALUES
(0001, "Customer_1", "Mysuru"),
(0002, "Customer_2", "Bengaluru"),
(0003, "Kumar", "Mumbai"),
(0004, "Customer_4", "Dehli"),
(0005, "Customer_5", "Bengaluru");
INSERT INTO Orders VALUES
(001, "2020-01-14", 0001, 2000),
(002, "2021-04-13", 0002, 500),
(003, "2019-10-02", 0003, 2500),
(004, "2019-05-12", 0005, 1000),
(005, "2020-12-23", 0004, 1200);
INSERT INTO Items VALUES
(0001, 400),
(0002, 200),
(0003, 1000),
(0004, 100),
(0005, 500);
INSERT INTO Warehouses VALUES
(0001, "Mysuru"),
(0002, "Bengaluru"),
(0003, "Mumbai"),
(0004, "Dehli"),
(0005, "Chennai");
INSERT INTO OrderItems VALUES
(001, 0001, 5),
(002, 0005, 1),
(003, 0005, 5),
(004, 0003, 1),
(005, 0004, 12);
INSERT INTO Shipments VALUES
(001, 0002, "2020-01-16"),
(002, 0001, "2021-04-14"),
(003, 0004, "2019-10-07"),
(004, 0003, "2019-05-16"),
(005, 0005, "2020-12-23");
SELECT * FROM Customers;
SELECT * FROM Orders;
SELECT * FROM OrderItems;
SELECT * FROM Items;
SELECT * FROM Shipments;
SELECT * FROM Warehouses;
--------------------------------------------------------------
1.List the Order# and Ship_date for all orders shipped from Warehouse# "W2".
select order_id,ship_date
from shipments where warehouse_id=2;
/*o/p
+----------+------------+
| order_id | ship_date |
+----------+------------+
| 1 | 2020-01-16 |
+----------+------------+*/
--------------------------------------------------------------------
/*2. List the Warehouse information from which the Customer named "Kumar" was
supplied his orders. Produce a listing of Order#, Warehouse#*/
select order_id,warehouse_id from Warehouses
natural join Shipments where order_id in
(select order_id from Orders
where cust_id in (Select cust_id from Customers
where cname like "%Kumar%"));
--OR
select o.order_id,w.warehouse_id
from orders o
join shipments s on o.order_id=s.order_id
join warehouses w on w.warehouse_id=s.warehouse_id
where cust_id in(select cust_id from customers where cname like '%kumar');
/*o/p
+----------+--------------+
| order_id | warehouse_id |
+----------+--------------+
|        3 |            4 |
+----------+--------------+*/
------------------------------------------------------------------------
/*3.Produce a listing: Cname, #ofOrders, Avg_Order_Amt, where the middle column is
the total number of orders by the customer and the last column is the average order
amount for that customer. (Use aggregate functions)*/
select c.cname,count(o.order_id) as namberoforders,
avg(o.order_amt) as Avg_Order_Amt
from customers c,orders o
where c.cust_id=o.cust_id
group by c.cname;
/*o/p
+------------+----------------+---------------+
| cname       | namberoforders | Avg_Order_Amt |
+------------+----------------+---------------+
| Customer_1 |         1       |     2000.0000 |
| Customer_2 |         1       |     500.0000  |
| Customer_4 |         1       |     1200.0000 |
| Customer_5 |         1       |     1000.0000 |
| Kumar      |         1       |     2500.0000 |
+------------+----------------+---------------+*/
-------------------------------------------------------------------
--4. Delete all orders for customer named "Kumar".
delete from orders
where cust_id in(select cust_id from customers where cname like '%kumar%');
/*o/p
+----------+------------+---------+-----------+
| order_id | odate | cust_id | order_amt |
+----------+------------+---------+-----------+
| 1 | 2020-01-14 | 1 | 2000 |
| 2 | 2021-04-13 | 2 | 500 |
| 4 | 2019-05-12 | 5 | 1000 |
| 5 | 2020-12-23 | 4 | 1200 |
+----------+------------+---------+-----------+*/
----------------------------------------------------------------------
--5. Find the item with the maximum unit price.
select * from items
where unitprice in(select max(unitprice) from items);
/*o/p
+---------+-----------+
| item_id | unitprice |
+---------+-----------+
| 3 | 1000 |
+---------+-----------+*/
-------------------------------------------------------------------------
/*6. Create a view to display orderID and shipment date of all orders shipped from a
warehouse 5.*/
create view ShipmentDatesFromWarehouse2 as
select order_id, ship_date
from Shipments
where warehouse_id=2;
select * from ShipmentDatesFromWarehouse2;
/*o/p
+----------+------------+
| order_id | ship_date |
+----------+------------+
| 1 | 2020-01-16 |
+----------+------------+
---------------------------------------*/
/*7. A tigger that updates order_amount based on quantity and unit price of
order_item*/
DELIMITER $$
create trigger UpdateOrderAmt
after insert on OrderItems
for each row
BEGIN
update Orders set order_amt=(new.qty*(select distinct unitprice from Items NATURAL
JOIN OrderItems where item_id=new.item_id)) where Orders.order_id=new.order_id;
END; $$
DELIMITER ;
--insert into orders and orderitems
INSERT INTO Orders VALUES
(007, "2020-12-23", 0004, 1200);
INSERT INTO OrderItems VALUES
(007, 0001, 5);
/*o/p
+----------+------------+---------+-----------+
| order_id | odate | cust_id | order_amt |
+----------+------------+---------+-----------+
| 1 | 2020-01-14 | 1 | 2000 |
| 2 | 2021-04-13 | 2 | 500 |
| 4 | 2019-05-12 | 5 | 1000 |
| 5 | 2020-12-23 | 4 | 2000 |
| 6 | 2020-12-23 | 4 | 2000 |
| 7 | 2020-12-23 | 4 | 2000 |
+----------+------------+---------+-----------+*/
