-- There are 6 types of triggers 
-- 1.before insert
-- 2.after insert
-- 3.before update
-- 4.after update
-- 5.before delete
-- 6.after delete   
create database triggers;

use triggers;

-- First, create one table that we will use for all six triggers.

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    salary int,
    department VARCHAR(30)
);

INSERT INTO employees
VALUES
(1, 'Rahul', 30000, 'IT'),
(2, 'Priya', 40000, 'HR'),
(3, 'Amit', 35000, 'Finance');

select * from employees;

-- 1. BEFORE INSERT Trigger :-  Executes before a new record is inserted into the table.
-- Suppose you want to ensure that an employee's salary is never less than ₹15,000.

delimiter //
create trigger before_employee_insert
before insert on employees
for each row
begin
	if new.salary < 15000 then 
    signal sqlstate '45000'
    set message_text = "salary must be atleast 15000";
    end if;
end //
delimiter ;

-- Try inserting an employee with a salary below ₹15,000:

insert into employees values
(4,"sumit",10000,"HR");

-- Now try:

insert into employees values
(4,"sumit",20000,"HR");



-- 2. AFTER INSERT Trigger :- Executes after a new record has been inserted.
-- Whenever a new employee joins, automatically save their details in an employee log table

CREATE TABLE employee_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT,
    emp_name VARCHAR(50),
    action_type VARCHAR(20)
);

delimiter //
create trigger after_employye_insert
after insert on employees
for each row
begin 
	insert into employee_log
    (emp_id,emp_name,action_type)
    values
    (New.emp_id,new.emp_name,"insert");
end//
delimiter ;

-- Test the trigger

insert into employees values
(5,"kruti",25000,"Sales");

-- check the trigger

select * from employee_log;

-- 3. BEFORE UPDATE Trigger: Executes before an existing record is updated.
-- Suppose an employee's salary should never be reduced below ₹15,000.

delimiter //
create trigger before_employee_update
before update on employees 
for each row
begin
	if new.salary < 15000 then
		signal sqlstate '45000'
		set message_text = "updated salary must be atleast 15000";
	end if;
end //
delimiter ;
-- test the trigger:

update employees 
set salary = 10000
where emp_id = 1;

update employees 
set salary = 35000
where emp_id = 1;



-- 4. AFTER UPDATE Trigger: Executes after an existing record has been updated.
-- Whenever an employee's salary changes, record the old and new salaries.

CREATE TABLE salary_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT,
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2)
);


delimiter //
create trigger after_employee_update
after update on employees
for each row
begin
	if old.salary <> new.salary then 
		insert into salary_history
		(emp_id,old_salary,new_salary)
		values
		(old.emp_id,old.salary,new.salary);
    end if ;
end //

delimiter ;

-- Test the trigger

update employees
set salary = 30000
where emp_id = 1;

-- check trigger
 
select * from employees;
select * from salary_history;

-- 5. BEFORE DELETE Trigger: Executes before an existing record is deleted.
-- Suppose you want to prevent the deletion of employees from the IT department.

delimiter //
create trigger before_employee_delete
before delete on employees
for each row
begin
	if old.department = "IT" then
		signal sqlstate  '45000'
		set message_text = "IT department employees can not be deleted";
	end if;
end //
delimiter ; 

select * from employees;

-- Try deleting Rahul if his department is IT: 

delete from employees
where emp_id = 1;
 
--  Now try deleting Priya:

DELETE FROM employees
WHERE emp_id = 2;

-- 6. AFTER DELETE Trigger: Executes after an existing record has been deleted.
-- Suppose you want to record the details of every deleted employee. 

CREATE TABLE deleted_employees (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT,
    emp_name VARCHAR(50),
    salary DECIMAL(10,2)
);

delimiter //
create trigger deleted_employees
after delete on employees
for each row
begin
	insert into deleted_employees 
    (emp_id,emp_name,salary)
    value(old.emp_id,old.emp_name,old.salary);
end //
delimiter ;

-- Test the trigger

-- Delete Amit, whose department is Finance:

delete from employees
where emp_id = 2;

select * from deleted_employees;
    


