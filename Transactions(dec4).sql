---Transactions and Cursors Assignments---

----------TASK 1------------

--1. Basic Transaction — Commit / Rollback 

--Create a table BankAccount with sample records.
Create table BankAccount(
Account_id int identity(1000,1),
Account_name varchar(20),
abalance int
)
select * from BankAccount;
insert into BankAccount values ('ajay',100),('ravi',100);

/**Write a transaction that transfers money from one account to another. 
If the source account balance becomes negative, roll back the transaction; otherwise 
commit.**/
begin transaction
	update BankAccount
	set abalance = abalance-500 where Account_name='ajay';
	update BankAccount
	set abalance = abalance+500 where Account_name='ravi';
	if exists (Select 1 from BankAccount where abalance<=0)
	Begin
		print('low balance')
		rollback transaction
	end
	else
	Begin
		print('TRANSACTION DONE')
		commit
	end

--------task 2----------

--2. Using SAVEPOINT ---
/**Insert three new records into a table Orders. 
Create a SAVEPOINT after each insert. 
Rollback only the second insert using the SAVEPOINT, then commit the remaining inserts. **/

begin transaction
	insert into orders values (6,getdate(),'mobile',2000,50,3);
	save transaction savepoint1;
	insert into orders values (5,getdate(),'mobile',2000,30,3);
	save transaction savepoint2;
	rollback transaction savepoint1;
	insert into orders values (4,getdate(),'mobile',2000,40,3);
	save transaction savepoint3;
commit transaction;
Select * from orders;

------task 3------
--3. Handling Errors with TRY…CATCH --
/** Write a transaction that updates prices in a Products table. 
Introduce a division-by-zero error inside the transaction. 
Use TRY…CATCH to rollback the transaction and log the error message in a separate 
ErrorLog table **/
create table newErrorLog (
	eId int primary key identity(100,10),
	eMessage varchar(MAX)
);
Begin transaction
	update products 
	set price =price+30
	Begin try
		declare @a int,@b int;
		set @a =10;
		set @b =0;
		set @a= @a/@b;
		Commit tran;
	End try
	Begin Catch
		RollBack tran
		insert into newErrorLog values (error_Message());
	End catch
		
select * from newErrorLog;
select * from products;

------task 4----------
--4. Nested Transactions --
/**Create nested transactions: 
• Outer transaction inserts a customer 
• Inner transaction inserts an order for the customer 
• Force an error in the inner transaction 
Practice observing whether the outer transaction is committed or rolled back**/
begin tran outertrans
insert into customer(cust_name)
values('priya');
Declare @CustId int=SCOPE_IDENTITY();
Begin TRY
	begin tran innertrans
	insert into orders (cust_id,price)
	values(@CustId,5000);
	declare @y int = 1/0
 
  commit transaction
commit transaction
end try
 
begin catch
rollback transaction
print 'Rollbacks due to inner error: ' + ERROR_MESSAGE();
end catch
select * from customer;
select *from orders;

-----task 5----
--5.Isolation Level – Dirty Read 
/**Use two sessions: 
• Session 1: Open a transaction, update a row, but don’t commit 
• Session 2: Use SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED and read 
the same row 
Check whether dirty reads are allowed. **/

--session 1
Begin transaction
update Products
Set price =99999
where ProductID =1;

--session 2
set Transaction isolation level Read Uncommitted;
Select * from products;

--6. Isolation Level – Non-repeatable Read --
/**Using two sessions: 
• Session 1 reads a row twice inside a transaction 
• Session 2 updates and commits the same row in between 
Observe changes and understand non-repeatable reads.**/


--session 1
set Transaction isolation level Read committed;

Begin transaction
Select * from products
Waitfor delay '00:00:10'
Select * from products
commit;
--session 2

Begin transaction
update Products
Set price =100
where ProductID =1;
commit;

--7. Isolation Level – Phantom Read 
/**Create a table Sales. 
Using two sessions: 
• Session 1 selects rows between a range inside a transaction 
• Session 2 inserts a new row within the range and commits 
See if the first session sees new rows depending on isolation level. **/

create table sales1(
    saleid int identity(1,1) primary key,
    amount int
);

insert into sales1(amount) values (100), (200), (300);

--session 1 — run this first
set transaction isolation level read committed;   

begin tran;

select * 
from sales1
where amount between 100 and 300;
Waitfor delay '00:00:10'
select * 
from sales1
where amount between 100 and 300;

commit;



--session 2 — run this while session 1 in other window
begin tran;
insert into sales1(amount) values (250);
commit;

/*8.Savepoint with Partial Rollback 
Inside a transaction: 
• Update 5 employee salaries 
• Create a savepoint after each update 
• Rollback to savepoint 3 
• Commit the rest 
Check which rows were updated finally. */
begin tran;

update employees set salary = salary + 1000 where empid = 1;
save tran sp1;

update employees set salary = salary + 1000 where empid = 2;
save tran sp2;

update employees set salary = salary + 1000 where empid = 3;
save tran sp3;

update employees set salary = salary + 1000 where empid = 4;
save tran sp4;

update employees set salary = salary + 1000 where empid = 5;
save tran sp5;

rollback tran sp3;  
commit;             

/*9.Insert multiple product records using a single transaction. 
Force an error in one insert (duplicate key or null value). 
Ensure that no records are inserted into the table.*/ 
begin tran;

begin try
    insert into products(productid, productname, price)
    values (1,'laptop',50000);

    insert into products(productid, productname, price)
    values (2,'mouse',1500);

    insert into products(productid, productname, price)
    values (1,'keyboard',1200);

    commit; 
end try
begin catch
    rollback; 
    print 'transaction failed: ' + error_message();
end catch;

 
/*10.Savepoint in TRY…CATCH 
Inside a long transaction: 
• Insert 3 orders 
• Savepoint after each 
• Force an error before the third insert 
Use savepoint rollback to keep first 2 inserts.*/

begin tran;

begin try

    insert into orders(cust_id, product, qty)
    values (1,'pen',5);
    save tran sp1;

    insert into orders(cust_id, product, qty)
    values (2,'book',2);
    save tran sp2;

    insert into orders(cust_id, product, qty)
    values (null,'bag',3);   
    save tran sp3;

    commit;
end try

begin catch
    print 'error occurred: ' + error_message();

    rollback tran sp2;   
    commit;            
end catch;
