--	SQL Server Queries DAY 1	--

--Display the list of customers who resides in Bangalore 
-- task 1
select * from customer where address ='bangalore';

/**Display the list of customers who does not resides in Bangalore or 
chennai 
task 2 **/
select * from customer where address not in('bangalore','chennai');

/** Display the list of customers who’s age is greater then 50 and does not 
resides in Bangalore
task 3 **/
select * from customer where address <> 'bangalore' and age>50;

/** Display the list of customers who’s name starts with A
tesk 4 **/
select * from customer where cust_name like 'a%';

/** Display the list of customers who’s name contains a word Br 
task 5 **/
select * from customer where cust_name like '%br%';

/**  Display the list of customer who’s name start between a to k  
task 6 **/
select *from customer where cust_name like '[A-K]%'
order by cust_name;

/**  Display the list of customers who’s name is 5 character long
task 7**/
select * from customer where len(cust_name)=5;

/** Display the list of customer who’s name  
* a. Start with s 
* b. Third character is c 
* c. Ends with e
task 8**/
--insert into customer values ('Sace',21,'hyderabad');
select * from customer where cust_name like 's_c%e';

/**  Display unique customer names from customers table
task 9 **/
select distinct cust_name  from customer;

/**10. List orders details where qty falling in the range 100-200  and 700-1200 **/
select * from orders 
where 
	(qty between 100 And 200) or 
	(qty between 700 and 1200)

/** 11.  List customer details where custname beginning with AL and ending 
with N  **/
select * from customer where cust_name like 'al%n';

/** 12. Display what each  price would be if a 20% price increase were to take 
place. Show the custid , old price and new price ,using meaningful 
headings(use orders table)  **/
select 
	cust_id,
	price as [old price],
	price*1.20 as [new price]
from orders ;

/** 13. Display top 3 highest qty from orders table **/
select top 3 qty from orders
order by qty Desc;

/**14. Display how many times customers have purchased a product (display 
count and customerid from orders table) **/
select count(orderid) as OrderCount,
	cust_id 
from orders
group by cust_id
order by OrderCount desc;

/** 15. Display the list of orders who’s orders made earlier then 5 years from now **/
select * from orders where year(orderdate) =(year(getdate())-5)

/**16.  Select * from customers where custname is null**/
select * from customer where cust_name is null;

/**17.  Display orderdetails in following format 
OrderID-Date Total(price*qty) 
* 100-1/1/2000 500 **/
Select 
	concat(orderid,'-',FORMAT(orderdate, 'd/M/yyyy')) as [OrderID-Date]
	,price*qty as total
from orders;

/** 18.  Update orders table by decreasing price by 20% for qty > 50 **/
update orders 
set price = price*0.80 
where qty > 50;

/**19. You want to retrieve data for all the orders who made order  '1-12-90' 
having price 4000 – 6000 and sort the column in descending order on 
price **/
select * from orders 
where orderdate ='1990-12-01'
And price between 4000 and 6000;

/** 20. Display order details in following format 
Custid Price (sum of price) Count (count of qty) 
* 1 5000 3 
* 2 4000 9 
* 3 6700 6 **/

select cust_id,sum(price)as sprice,count(qty) as qcount
from orders
group by cust_id
order by cust_id;

--21. Display above details only for price > 4000 
select * from orders where price >4000;

/**22. Write a query to create duplicate table of customer , and name it as 
custhistory 
a. Delete all the records of custhistory 
b. Copy records of customers to custhistory where age > 30 **/
Select * from customer
Select * from custhistory
--a. Delete all the records of custhistory 
truncate table custhistory
--b. Copy records of customers to custhistory where age > 30 
insert into custhistory select * From customer where age>30;
