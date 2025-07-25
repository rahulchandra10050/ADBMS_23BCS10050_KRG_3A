--EXPERIMENT 1
Create Database Experiment1;
use Experiment1; 
-- organizational herarichy in office
CREATE TABLE EMPLOYEE (
  empId INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  dept TEXT NOT NULL,
  managerId INTEGER,
  FOREIGN KEY (managerId) REFERENCES EMPLOYEE(empId)
);


INSERT INTO EMPLOYEE VALUES (1, 'Clark', 'Sales', NULL);
INSERT INTO EMPLOYEE VALUES (2, 'Dave', 'Accounting', 1);
INSERT INTO EMPLOYEE VALUES (3, 'Bob', 'HR', 2);
INSERT INTO EMPLOYEE VALUES (4, 'Adam', 'IT', 2);  
INSERT INTO EMPLOYEE VALUES (6, 'Frank', 'Finance', 3); 
INSERT INTO EMPLOYEE VALUES (5, 'Eve', 'Sales', 4); 


SELECT 
  e1.name AS EMP_NAME,
  e1.dept AS EMPLOYEE_DEPARTMENT,
  e2.name AS MANAGER_NAME,
  e2.dept AS MANAGER_DEPARTMENT
FROM EMPLOYEE AS e1
INNER JOIN EMPLOYEE AS e2
ON e1.managerId = e2.empId;
