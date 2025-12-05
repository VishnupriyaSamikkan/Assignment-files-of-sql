---cursors

/*1.basic cursor – print all employee names */
insert into employee values (1,'vishnu',2000);
insert into employee values (2,'riya',2000);
insert into employee values (3,'priya',2000);

select * from employee;

declare @name varchar(20);
declare @sal int;

declare emp_cursor cursor for
    select ename, sal from employee;

open emp_cursor;

fetch next from emp_cursor into @name, @sal;

while @@fetch_status = 0
begin
    print 'employee: ' + @name + ' salary: ' + cast(@sal as varchar(20));
    fetch next from emp_cursor into @name, @sal;
end

close emp_cursor;
deallocate emp_cursor;


/*2.cursor to update salary by 10% */
declare @empid int;
declare @oldsalary decimal(10,2);
declare @newsalary decimal(10,2);

declare salarycursor cursor for
    select empid, salary from employees;

open salarycursor;

fetch next from salarycursor into @empid, @oldsalary;

while @@fetch_status = 0
begin
    set @newsalary = @oldsalary * 1.10;
    update employees
    set salary = @newsalary
    where empid = @empid;

    print 'updated salary for empid ' + cast(@empid as varchar(10));

    fetch next from salarycursor into @empid, @oldsalary;
end

close salarycursor;
deallocate salarycursor;

select * from employee;


/*3.cursor with conditional logic */
declare @orderid int;
declare @quantity int;
declare @price decimal(10,2);
declare @discountedprice decimal(10,2);

declare ordercursor cursor for
    select orderid, qty, price from orders;

open ordercursor;

fetch next from ordercursor into @orderid, @quantity, @price;

while @@fetch_status = 0
begin
    if @quantity > 10
    begin
        set @discountedprice = @price * 0.95;
        print 'order ' + cast(@orderid as varchar(10)) + ': applied 5% discount';
    end
    else
    begin
        set @discountedprice = @price * 0.98;
        print 'order ' + cast(@orderid as varchar(10)) + ': applied 2% discount';
    end

    update orders
    set price = @discountedprice
    where orderid = @orderid;

    fetch next from ordercursor into @orderid, @quantity, @price;
end

close ordercursor;
deallocate ordercursor;

select * from employee;


/*4.cursor to copy data from one table to another */
declare @pid int;
declare @pname varchar(50);
declare @pr decimal(10,2);

declare copycursor cursor for
    select productid, productname, price from oldproducts;

open copycursor;

fetch next from copycursor into @pid, @pname, @pr;

while @@fetch_status = 0
begin
    insert into newproducts(productid, productname, price)
    values(@pid, @pname, @pr);

    print 'copied product ' + cast(@pid as varchar(10));

    fetch next from copycursor into @pid, @pname, @pr;
end

close copycursor;
deallocate copycursor;


/*5.cursor to delete customers older than 2 years lastorderdate */
declare @cid int;
declare @lastdate date;

declare delcursor cursor for
    select customerid, lastorderdate from customers;

open delcursor;

fetch next from delcursor into @cid, @lastdate;

while @@fetch_status = 0
begin
    if @lastdate < dateadd(year, -2, getdate())
    begin
        delete from customers where customerid = @cid;
        print 'deleted customer ' + cast(@cid as varchar(10));
    end

    fetch next from delcursor into @cid, @lastdate;
end

close delcursor;
deallocate delcursor;
