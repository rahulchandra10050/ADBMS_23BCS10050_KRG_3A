--easy problem
CREATE TABLE TBL_EMPLOYEE(
    EMP_ID INT
);
INSERT INTO TBL_EMPLOYEE VALUES (2),(4),(4),(6),(6),(7),(8),(8);

SELECT MAX(EMP_ID) as [Greatest Unique ID] FROM TBL_EMPLOYEE WHERE EMP_ID IN
(SELECT EMP_ID FROM TBL_EMPLOYEE GROUP BY EMP_ID HAVING COUNT(EMP_ID)=1);




-- medium problem
CREATE TABLE department (
    id INT PRIMARY KEY,
    dept_name VARCHAR(50)
);

-- Create Employee Table
CREATE TABLE employee (
    id INT,
    name VARCHAR(50),
    salary INT,
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES department(id)
);

-- Insert into Department Table
INSERT INTO department (id, dept_name) VALUES
(1, 'IT'),
(2, 'SALES');

-- Insert into Employee Table
INSERT INTO employee (id, name, salary, department_id) VALUES
(1, 'JOE', 70000, 1),
(2, 'JIM', 90000, 1),
(3, 'HENRY', 80000, 2),
(4, 'SAM', 60000, 2),
(5, 'MAX', 90000, 1);

select d.dept_name, e.name, e.salary, d.id
from 
employee as e 
inner join 
department as D 
on e.department_id=d.id 
where e.salary in (Select max(salary) from employee group by department_id);



-- hard problem
create table tbl_A (
	empid int PRIMARY key,
	empname varchar(20),
	salary int
)
insert into tbl_A values (1,'AA',1000), (2, 'BB',300);
create table tbl_B (
	empid int PRIMARY key,
	empname varchar(20),
	salary int
)
insert into tbl_B values (2, 'BB',400), (3,'CC',100);

select empid, min(empname) as empname, min(salary) as min_salary from
(select * FROM
tbl_A
UNION
select * from
tbl_b) as UNI 
group by empid;

