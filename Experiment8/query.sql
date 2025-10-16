----------------EXPERIMENT 08----------------------------------

----------------------MEDIUM LEVEL PROBLEM---------------------
--REQUIREMENTS: DESIGN A TRIGGER WHICH:
--1. WHENEVER THERE IS A INSERTION ON STUDENT TABLE THEN, THE CURRENTLY INSERTED OR DELETED 
--ROW SHOULD BE PRINTED AS IT AS ON THE OUTPUT CONSOLE WINDOW.

--SOLUTION
CREATE OR REPLACE FUNCTION fn_student_audit_print()
RETURNS TRIGGER
LANGUAGE plpgsql
AS 
$$
BEGIN
    IF TG_OP = 'INSERT' THEN
        RAISE NOTICE 'Inserted Row -> ID: %, Name: %, Age: %, Class: %',
                     NEW.id, NEW.name, NEW.age, NEW.class;
        RETURN NEW;

    ELSIF 
		TG_OP = 'DELETE' THEN
        RAISE NOTICE 'Deleted Row -> ID: %, Name: %, Age: %, Class: %',
                     OLD.id, OLD.name, OLD.age, OLD.class;
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;

-- Attach trigger for demonstration
DROP TRIGGER IF EXISTS trg_student_audit_print ON student;
CREATE TRIGGER trg_student_audit_print
AFTER INSERT OR DELETE
ON student
FOR EACH ROW
EXECUTE FUNCTION fn_student_audit_print();


----------------------HARD LEVEL PROBLEM----------------------------

/*
Requirements: DESIGN A PORSTGRESQL TRIGGERS THAT: 

Whenever a new employee is inserted in tbl_employee, a record should be added to tbl_employee_audit like:
"Employee name <emp_name> has been added at <current_time>"

Whenever an employee is deleted from tbl_employee, a record should be added to tbl_employee_audit like:
"Employee name <emp_name> has been deleted at <current_time>"

The solution must use PostgreSQL triggers.
*/


--THERE IS INSERT IN EMPLOYEE TABLE AT 'TIME'

DROP TABLE IF EXISTS tbl_employee_audit CASCADE;
DROP TABLE IF EXISTS tbl_employee CASCADE;

CREATE TABLE tbl_employee (
    emp_id SERIAL PRIMARY KEY,
    emp_name VARCHAR(100) NOT NULL,
    emp_salary NUMERIC
);

CREATE TABLE tbl_employee_audit (
    sno SERIAL PRIMARY KEY,
    message TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);


CREATE OR REPLACE FUNCTION audit_employee_changes()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS 
$$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO tbl_employee_audit(message)
        VALUES ('Employee name ' || NEW.emp_name || ' has been added at ' || NOW());
        RETURN NEW;
        
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO tbl_employee_audit(message)
        VALUES ('Employee name ' || OLD.emp_name || ' has been deleted at ' || NOW());
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END;
$$;


DROP TRIGGER IF EXISTS trg_employee_audit ON tbl_employee;
CREATE TRIGGER trg_employee_audit
AFTER INSERT OR DELETE 
ON 
tbl_employee
FOR EACH ROW
EXECUTE FUNCTION audit_employee_changes();


--TESTING THE TRIGGER
-- Insert an employee
INSERT INTO tbl_employee(emp_name, emp_salary) VALUES ('Aman', 50000);

-- Delete an employee
DELETE FROM tbl_employee WHERE emp_name = 'Aman';

-- Check audit log
SELECT * FROM tbl_employee_audit;




--SELECT * FROM STUDENTS;  
SELECT * FROM student;

--UPDATE STATEMENT - EXPLICIT TRANSACTIONS
UPDATE student
SET name = 'Aman'
WHERE id = 6;


BEGIN;
	UPDATE student
	SET name = 'Neha'
	WHERE id = 6;

	UPDATE student
	SET name = 'Neha'
	WHERE id = 6;

	UPDATE student
	SET name = 'Neha'
	WHERE id = 6;

	-- If you want to abort the transaction use ROLLBACK; otherwise COMMIT;
	--ROLLBACK;
	COMMIT;

-- End of script
