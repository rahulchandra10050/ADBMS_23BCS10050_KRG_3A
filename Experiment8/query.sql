SELECT *FROM STUDENT;

--TRANSACTION: SET OF STATMENTS RUNNING - CREATE, UPDATE, DELETE ETC

--STATEMENT
--TRANSACTION: IMPLICIT TRANSACTION
UPDATE STUDENT 
SET NAME = 'XYZ'
WHERE ID = 1;


--EXPLICIT TRANSACTION: USER HAS THE CONTROL
BEGIN TRANSACTION

	UPDATE STUDENT 
	SET NAME = 'AMAN'
	WHERE ID = 1;

COMMIT
--IF A TRANSACTION HAS BEEN INITIATED -> MUST BE EITHER COMMITED (PERMANENT SAVE), ROLLBACKED (UNDO)


---------------------------TRANSACTION IN SQL--------------------------- 
/* 

- Whenever we perform any operation (CRUD) inside the database, these operations are treated as TRANSACTIONS. - Also known as T-SQL. 

*/ 
-- 1. T-SQL - transaction is a single unit of work. 
-- 2. TCL - TCL commands COMMIT and ROLLBACK and SAVEPOINTS 
-- 3. Discuss ACID Properties 
-- 4. Transactions are merged at Connection(Query File is known as connection) Level. 

/*
Quick conceptual recap (ACID)

Atomicity — a transaction is “all or nothing”.

Consistency — DB moves between consistent states.

Isolation — concurrent transactions don’t interfere (controlled by isolation level).

Durability — once committed, changes persist.

PostgreSQL defaults to autocommit on — each SQL statement is a transaction unless you start an explicit one with BEGIN.
*/

CREATE TABLE Students 
( 
Id INT PRIMARY KEY, 
Name VARCHAR(50) UNIQUE, 
Age INT, Class INT 
); 


INSERT INTO Students (ID, Name, Age, Class) VALUES 
(1,'Aarav', 17, 8), 
(2,'Vikram', 16, 4), 
(3,'Priya', 15, 6), 
(4,'Rohan', 16, 7), 
(5,'Sita', 17, 8), 
(6,'Kiran', 15, 6);

DROP TABLE STUDENTS;


SELECT *FROM STUDENTS;

--IMPLICIT TRANSACTION:
UPDATE STUDENTS 
SET NAME = 'XYZ'
WHERE ID = 6;
--IF THIS UPDATE: CAN YOU ROLLBACK THE CHANGES

--EXPLICIT TRANSACTION
BEGIN TRANSACTION;
UPDATE STUDENTS 
SET NAME = 'XYZ'
WHERE ID = 6;


ROLLBACK;
COMMIT;

SELECT *FROM STUDENTS;



---------------SAVEPOINTS IN TRANSACTION (T-SQL)-------------------
100 LINE OF CODE


BEGIN TRANSACTION;

-- SQL STATEMENTS   0 - 70
SAVEPOINT SV_NAME_01; 

---- SQL STATEMENTS  80 -90 - ERROR
SAVEPOINT SV_NAME_02; 



---- SQL STATEMENTS 
SAVEPOINT SV_NAME_03; 90- 100

COMMIT
ROLLBACK TO SAVEPOINT SV_NAME_01;


RELEASE SAVEPOINT SV_NAME_01; --DELETEING SAVEPOINT









RELEASE SAVEPOINT SV_NAME;




ROLLBACK TO SV_NAME;











--Implicit Transaction
-- each statement commits automatically (default nature)
INSERT INTO student(name, age, class) VALUES ('Aman', 19, '11th');  -- committed immediately


--Explicit Transaction
BEGIN TRANSACTION;  -- start transaction
INSERT INTO student(name, age, class) VALUES ('Riya', 18, '10th');
INSERT INTO student(name, age, class) VALUES ('Rohit', 17, '10th');
COMMIT; -- make all changes permanent


--COMMIT
BEGIN TRANSACTION;
INSERT INTO student(name, age, class) VALUES ('Pooja', 16, '9th');
COMMIT;

--ROLLBACK
BEGIN;
INSERT INTO student(name, age, class) VALUES ('Temp', 999, 'X');
ROLLBACK;  -- undoes the insert


--What happens when a statement fails inside a transaction?

BEGIN TRANSACTION;
INSERT INTO student(name, age, class) VALUES ('Alice', 18, '10th');
-- this will fail because name must be unique ('Alice' already exists)
INSERT INTO student(name, age, class) VALUES ('Alice', 19, '11th');
-- After the second INSERT error, the transaction is aborted.
SELECT * FROM student;  -- ERROR: current transaction is aborted ...
ROLLBACK;               -- required to reset the session transaction state



--SAVE POINTS IN TRANSACTIONS

/*
A SAVEPOINT creates a named rollback point inside an open transaction so you can undo part 
of the work (with ROLLBACK TO SAVEPOINT) without aborting the whole transaction.


----------------------Why savepoints?-------------------------

- Transactions are atomic: either everything in the transaction succeeds (commit) 
or everything fails (rollback).

- But sometimes you want: do steps A, B, C; if B fails, undo only B and continue with C and 
then commit everything that’s still valid.

- Savepoints let you implement that: they provide partial rollback inside a transaction.

*/


--SYNTAX:
BEGIN TRANSACTION;                       -- start transaction
SAVEPOINT sp_name;                       -- create a savepoint
-- SQL QUERIES
ROLLBACK TO SAVEPOINT sp_name;           -- undo all changes after sp_name
RELEASE SAVEPOINT sp_name;               -- remove the savepoint (optional)
COMMIT;                                  -- commit the transaction


/*
RELEASE SAVEPOINT deletes the savepoint; it does not commit anything.

All savepoints are cleared when the outer transaction ends (commit or rollback).
*/

DROP TABLE Students_01;

CREATE TABLE Students_01 
( 
Id INT PRIMARY KEY, 
Name VARCHAR(50) UNIQUE, 
Age INT, 
Class INT 
); 


INSERT INTO Students_01 (ID, Name, Age, Class) VALUES 
(1,'Aarav', 17, 8), 
(2,'Vikram', 16, 4), 
(3,'Priya', 15, 6), 
(4,'Rohan', 16, 7), 
(5,'Sita', 17, 8), 
(6,'Kiran', 15, 6);


SELECT *FROM STUDENTS;

BEGIN TRANSACTION;

INSERT INTO STUDENTS(ID, name, age, class) VALUES (7, 'Alice', 18, 10);  -- keep
SAVEPOINT sp1;

INSERT INTO STUDENTS(ID, name, age, class) VALUES (8, 'Bob', 17, 11);    -- maybe keep
SAVEPOINT sp2;

INSERT INTO STUDENTS(ID, name, age, class) VALUES (9, 'Charlie', 16, 9); -- maybe remove

SELECT *FROM STUDENTS;



-- decide to undo last insertion only:
ROLLBACK TO SAVEPOINT sp2;  -- removes Charlie; Bob and Alice remain

-- continue
INSERT INTO student(name, age, class) VALUES ('Dina', 15, '8th');

-- decide to undo everything after sp1 (remove Bob and Dina)
RELEASE SAVEPOINT sp1;

ROLLBACK TO SAVEPOINT sp1;  -- now only Alice remains



COMMIT;


------------------------------Experiment 08-------------------------------
---------------------Hard Level Problem-----------------------------
/*
Design a robust PostgreSQL transaction system for the students table where multiple student 
records are inserted in a single transaction. 

If any insert fails due to invalid data, only that insert should be rolled back while preserving the 
previous successful inserts using savepoints. 

The system should provide clear messages for both successful and failed insertions, ensuring data integrity 
and controlled error handling.

HINT: YOU HAVE TO USE SAVEPOINTS
*/





DROP TABLE IF EXISTS students;

CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE,
    age INT,
    class INT
);

-- EXCEPTION HANDLING


DO $$
BEGIN TRANSACTION 
    -- Start a transaction
    BEGIN 
        -- Insert multiple students
        INSERT INTO students(name, age, class) VALUES ('Anisha',16,8);
        INSERT INTO students(name, age, class) VALUES ('Neha',17,8);
        INSERT INTO students(name, age, class) VALUES ('Mayank',19,9);

        -- If all succeed
        RAISE NOTICE ' Transaction Successfully Done';

    EXCEPTION WHEN OTHERS THEN
            -- If any insert fails
            RAISE NOTICE 'Transaction Failed..! Rolling back changes.';
            RAISE;  -- this will rollback the entire transaction
    END;
END;
$$;


SELECT * FROM students;



--VIOLATED SCENARIO
DO $$
BEGIN TRANSACTION 
    -- Start a transaction
    BEGIN 
        -- Insert multiple students
        INSERT INTO students(name, age, class) VALUES ('Anisha',16,8);
		INSERT INTO students(name, age, class) VALUES ('Mayank',19,9);
        INSERT INTO students(name, age, class) VALUES ('Anisha',17,8); --ERROR
        INSERT INTO students(name, age, class) VALUES ('Mayank',19,9);

        -- If all succeed
        RAISE NOTICE ' Transaction Successfully Done';

    EXCEPTION WHEN OTHERS THEN
            -- If any insert fails
            RAISE NOTICE 'Transaction Failed..! Rolling back changes.';
            RAISE;  -- this will rollback the entire transaction
    END;
END;
$$;

