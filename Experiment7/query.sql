-- Triggers in PostgreSQL------------
/*
A trigger is a special function that is automatically executed (fired) by PostgreSQL when 
a specific event occurs on a table or view.


in terms of postgres: trigger -> developed by functions()

1. I WILL DEVELOP SOME FUNCTIONS: AUTOMATED TASK

2. WITH THE HELP OF TRIGGERS I WILL APPLY THIS FUNCTION TO RESPECTIVE TABLE


Events could be:

INSERT

UPDATE

DELETE

TRUNCATE


----Important Pointer-----------
In PostgreSQL, triggers call a trigger function written in PL/pgSQL 


----------TYPES OF TRIGGERS IN POSTGRES------------
(A) BASED ON TIMING
	1. AFTER TRIGGER: Fires after the operation has occurred.
		Useful for logging, auditing, or performing cascading actions.
		
	2. BEFORE TRIGGER: Fires before the operation is executed.
		Useful for validation, modifying values before they go into the table, 
		or stopping the operation with an exception.

(B) BASED ON EVENT: INSERT, UPDATE, DELETE, TRUNCATE ETC.

(C) ROW LEVEL & STATEMENT LEVEL


*/

------------------SYNTAX FOR CREATING TRIGGERS---------------------------------
--1. CREATE TRIGGER FUNCTION
CREATE OR REPLACE FUNCTION function_name()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS 
$$
BEGIN
    -- logic here
    RETURN NEW; -- default
END;
$$;

--2. CREATE TRIGGER
-- CREATE TRIGGER trigger_name
-- { BEFORE | AFTER } { INSERT | UPDATE | DELETE | TRUNCATE }
-- ON 
-- table_name
-- [ FOR EACH ROW | FOR EACH STATEMENT ]
-- EXECUTE FUNCTION function_name();


--------------SAMPLE TABLE FOR DEMONSTRATION------------------
DROP TABLE IF EXISTS student CASCADE;
CREATE TABLE student (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    age INT,
    class VARCHAR(20)
);

-- Note: using lowercase table name 'student' consistently
SELECT * FROM student;

-----------------------------------AFTER TRIGGERS---------------------------------------

--P.S: CREATE A TRIGGER, IN WHICH IF ANYONE INSERTS ANY DATA IN STUDENT TABLE,
--     YOU WILL GET A MESSAGE 'INSERTION HAS BEEN DONE..!'


-- Step 1: Function
CREATE OR REPLACE FUNCTION fn_student_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
AS 
$$
BEGIN
    RAISE NOTICE 'Insertion has been done in your table';
    RETURN NEW;
END;
$$;



-- Step 2: Trigger
DROP TRIGGER IF EXISTS trg_student_insert ON student;
CREATE TRIGGER trg_student_insert
AFTER INSERT 
ON student
FOR EACH ROW
EXECUTE FUNCTION fn_student_insert();

--TRIGGER EXECUTION
--INSERT INTO student(name, age, class) VALUES ('Aman', 19, '11th');





-------NOW IF I WANT TO CREATE ALL THESE FUNCTIONALITY INTO ONE TRIGGER----------

CREATE OR REPLACE FUNCTION fn_student_audit_allops()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS 
$$
BEGIN
    IF TG_OP = 'INSERT' THEN
        RAISE NOTICE 'Insertion has been done in your table';
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        RAISE NOTICE 'Deletion has been done in your table';
        RETURN OLD;

    ELSIF TG_OP = 'UPDATE' THEN
        RAISE NOTICE 'Updation has been done in your table';
        RETURN NEW;
    END IF;

    RETURN NULL;
END;
$$;

-- Attach it for demonstration (after triggers):
DROP TRIGGER IF EXISTS trg_student_audit_allops ON student;
CREATE TRIGGER trg_student_audit_allops
AFTER INSERT OR UPDATE OR DELETE
ON student
FOR EACH ROW
EXECUTE FUNCTION fn_student_audit_allops();


--WHAT IS NEW AND OLD???
/*
These are record variables that PostgreSQL automatically provides inside trigger functions, 
and they represent the row states before and after the triggering operation.

---------------OLD MAGIC TABLE--------------------

- Refers to the row before the triggering event.

Available in:

- DELETE triggers → because a row is being deleted, so only OLD exists.

- UPDATE triggers → contains the row values before the update.

Not available in:

- INSERT triggers (since there’s no existing row before insertion).

-------------Example-----------------------------------
If a student row with id=1, name='Aman', age=20 is deleted:

- OLD.id = 1

- OLD.name = 'Aman'

- OLD.age = 20


--------------------------NEW MAGIC TABLE-------------------------

- Refers to the row after the triggering event.

Available in:

- INSERT triggers → contains the newly inserted row.

- UPDATE triggers → contains the modified row values after the update.

Not available in:

- DELETE triggers (because after deletion, no row exists).

------------------Example--------------
If you insert ('Rohit', 19, '10th') into the student table:

- NEW.name = 'Rohit'

- NEW.age = 19

- NEW.class = '10th'
*/


--SIMILARLY WE CAN CREATE AFTER TRIGGER FOR UPDATE, DELETE AND OTHER OPERATIONS.



-----------------------------------BEFORE TRIGGERS---------------------------------------
--P.S: CREATE A TRIGGER WHICH RESRICTS THE USER TO PERFROM THE INSERT OPERATION INSIDE A TABLE.

--CREATING TRIGGER FUNCTION
CREATE OR REPLACE FUNCTION fn_student_before_insert()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'You are not allowed to INSERT in this table!';
    RETURN NULL;  -- Prevents insertion
END;
$$;


--CREATING TRIGGER
DROP TRIGGER IF EXISTS trg_student_before_insert ON student;
CREATE TRIGGER trg_student_before_insert
BEFORE INSERT 
ON student
FOR EACH ROW
EXECUTE FUNCTION fn_student_before_insert();


--TESTING THE TRIGGER
-- The following INSERT will be prevented by the BEFORE INSERT trigger
-- INSERT INTO student(name, age, class) VALUES ('Aman', 19, '11th');

--INSERT 0 0 -> NO RECORD WILL BE INSERTED
--SIMILARLY WE CAN CREATE A BEFORE TRIGGER FOR OTHER OPERATIONS AS WELL..!

SELECT * FROM student;
