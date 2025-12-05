select * from customer;
select * from products;
select * from orders;
select * from sales;
---Answer---
------------Sub query------------
/** 1. display all the records from customers who made a purchase of books  **/
select * from customers
	where cust_id in(select custid from sales 
		where productid in (select productid from products where ProductName='Books'));

/**2. display all the records from customer who made a purchase of books , toys, cd**/
select * from customers
	where cust_id in(select custid from sales 
		where productid in (select productid from products where ProductName in('Books','toy','cd')));

/**3. display the list of customers who never made any purchase**/
select * from customers
	where cust_id not in (select custid from sales);

/**4. display the second highest age from customers (do not use top keyword)**/
select Max(age) As second_highest_age
From customers where age <(select Max(age) from customer);

/**5. display the list from orders  where customers stays in bangalore**/
select * from orders 
	where cust_id in(Select cust_id from customers where address ='bangalore');

/** 6. display list of customer who made lowest purchase (in terms of quantity) **/
select * from customers
	where cust_id in(select cust_id from orders where qty = (select min(qty) from orders));

/**7. display the list of customer who's age is greater then  ajay's age ( but we 
dont know ajay's age) **/
Select * from customers where age >(select age from customers where cust_name='ajay');

/**8. update customer table where 
custid =100's age  = custid=200's age**/
update customers 
set age =(Select age from customers where cust_id =200) where cust_id=100;

/**9. Display those details who made orders in December of any year**/
Select * from customers where cust_id in (Select cust_id from orders where month(orderdate)=12);

/**10. Show all  orders made before first half of the month (before the 16th of the 
month who does not reside in bangalore). **/
select *
from orders
where extract(day from orderdate) < 16
and customerid in (
    select customerid
    from customers
    where city <> 'bangalore'
);


/**11. Display list of customers  from delhi and Bangalore who made purchase of 
less than 3 product  **/
select *
from customers
where city in ('delhi','bangalore')
and customerid in (
    select customerid
    from orders
    where orderid in (
        select orderid
        from orderdetails
        group by orderid
        having count(productid) < 3
    )
);

/**12. Display list of orders where price is greater than average price**/
select *
from orders
where price > (select avg(price) from orders);

/**13. update orders table increasing  price by 10%  for customers residing in 
Bangalore and who have purchased books. **/
update orders
set price = price * 1.10
where customerid in (
    select customerid
    from customers
    where city = 'bangalore'
)
and orderid in (
    select orderid
    from orderdetails
    where product = 'books'
);


/**14.Display orderdetails in following format 
OrderID-Date Total(price*qty) 
100-1/1/2000 500**/
select 
    orderid || '-' || to_char(orderdate,'dd/mm/yyyy') as order_info,
    (select sum(price * qty)
     from orderdetails od
     where od.orderid = orders.orderid) as total
from orders;
