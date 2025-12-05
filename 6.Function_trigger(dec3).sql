/**1. create a function to find the greatest of three numbers**/
create function fn_greatest
	(@x int,@y int,@z int)
RETURNS int
as
begin
	Declare @maxvalue int;
	set @maxvalue =
	case 
		when @x>=@y AND @x>=@z then @x
		when @y>=@z And @y>=@z then @y
		else @z
	end;
	return @maxValue;
End;

Select dbo.fn_greatest(1,2,3);

/**2. create a function to calculate to discount of 10% on price on all 
the products**/
select * from orders;
create function applyDiscount
(
	@price int
)
Returns decimal(10,2)
as
begin
	Return @price*0.10;
End;

select price,dbo.applyDiscount(price) As discount from orders;

/**3. create a function to calculate the discount on price as following 
if productname = 'books' then 10% 
if productname = toys then 15% 
else 
no discount**/
Select * from products
create function getproductdiscount
	(@name varchar(20),
	@price decimal(10,2)
	)
RETURNS decimal(10,2)
as
Begin
	Declare @discount Decimal(10,2);
	Set @discount =
	case
		when lower(@name)='books' then @price*0.1
		when lower(@name)='toys' then @price*0.15
		else 0
	end;
	Return @discount;
End

select productname,price,dbo.getproductdiscount(productname,price) as discount
From products;

/**4. create inline function which accepts number and prints last n 
years of orders made from  now. 
(pass n as a parameter)**/
Select * from orders;
create function getlastnYearsorders
(
	@n int
)
Returns table 
AS
Return
(
	Select * From orders
	Where orderdate >= DATEADD(Year,-@N,GETDATE())
);

SELECT * 
FROM dbo.getlastnYearsorders(3);


--Trigger
/**1. Create a trigger for table customer, which does not allow 
the user to delete the record who stays in Bangalore, 
Chennai, delhi**/
select * from Customer
create trigger trg_PreventDeleteCity
On customer
After Delete
as
if exists(Select 1 from deleted 
where address in ('chennai','delhi','bangalore'))
Begin
	print('Cannot delete this row because of prevented cities')
	Rollback transaction
End

delete from customer 
where address ='chennai';

/**2. Create a triggers for orders which allows the user to insert 
only books, cd, mobile **/
Select * from orders
create trigger trg_insertOrders
On orders
for insert
as
if exists (Select 1 from inserted where product not in ('books','cd','mobile'))
Begin
	print('inserted row is invalid')
	RollBack transaction
end
--no trigger
insert into orders values(2,'','mobile',2000,500,3);
--trigger
insert into orders values(2,'','laptop',2000,500,1);

/**3. Create a trigger for customer table whenever an item is 
delete from this table. The corresponding item should be 
added in customerhistory table.**/
Select * from customer;
create table customer_history (cust_id int,cust_name varchar(100),age int,address varchar(100));
create trigger trg_deleteToInsert
on customer
for delete
as
begin
INSERT INTO customer_history (cust_id, cust_name, age, address)
    SELECT cust_id, cust_name, age, address
    FROM deleted;
end

delete from customer
where cust_id =14;
select * from customer_history;
/**4. Create update trigger for stock. Display old values and new 
values**/
Select * from customer;
Create trigger trg_Update
on customer
for update
as
begin
select * from inserted
select * from deleted
end

Update customer 
 set age =21 where cust_name='John';

/**5. Create Instead Of Insert Trigger for Joined View (the user 
should able to insert record for 2 table using single insert 
command) Use following table**/
 
create table a 
( 
custid int, 
custname varchar(12) 
) 
create table b 
( 
custid int, 
product varchar(12) 
) 
 
create view testview 
as 
select a.* , b.product from a inner join b on a.custid = 
b.custid 
 
select * from testview

create trigger trg_testview_insert
on testview
instead of insert
as
begin
    insert into a (custid, custname)
    select custid, custname
    from inserted;

    insert into b (custid, product)
    select custid, product
    from inserted;
end;