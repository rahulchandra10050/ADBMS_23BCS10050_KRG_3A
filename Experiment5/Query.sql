-------------------------------------------EXPERIMENT 05 (MEDIUM LEVEL)------------------------------

CREATE TABLE transaction_data (
    id INT,
    value INT
);
-- For id = 1
INSERT INTO transaction_data (id, value)
SELECT 1, random() * 1000  -- simulate transaction amounts 0-1000
FROM generate_series(1, 1000000);
-- For id = 2
INSERT INTO transaction_data (id, value)
SELECT 2, random() * 1000
FROM generate_series(1, 1000000);

SELECT *FROM transaction_data

--WITH NORMAL VIEW
CREATE OR REPLACE VIEW sales_summary_view AS
SELECT
    id,
    COUNT(*) AS total_orders,
    SUM(value) AS total_sales,
    AVG(value) AS avg_transaction
FROM transaction_data
GROUP BY id;


EXPLAIN ANALYZE
SELECT * FROM sales_summary_view;



--WITH MATERIALIZED VIEW
CREATE MATERIALIZED VIEW sales_summary_mv AS
SELECT
    id,
    COUNT(*) AS total_orders,
    SUM(value) AS total_sales,
    AVG(value) AS avg_transaction
FROM transaction_data
GROUP BY id;



EXPLAIN ANALYZE
SELECT * FROM sales_summary_mv;

create table random_tabl (id int, val decimal)

insert into random_tabl 
select 1, random() from generate_series(1,1000000);


insert into random_tabl 
select 2, random() from generate_series(1,1000000);

--normal execution
select id, avg(val), count(*)
from random_tabl
group by id;


--execution by materialized view
create materialized view mv_random_tabl
as
select id, avg(val), count(*)
from random_tabl
group by id;

select *from mv_random_tabl


--if you update anything in table, the mv doesn't gets updated
---for that we have to refresh it

------------------------------------------- (HARD LEVEL)------------------------------
CREATE VIEW vW_ORDER_SUMMARY
AS
SELECT 
    O.order_id,
    O.order_date,
    P.product_name,
    C.full_name,
    (P.unit_price * O.quantity) - ((P.unit_price * O.quantity) * O.discount_percent / 100) AS final_cost
FROM customer_master AS C
JOIN sales_orders AS O 
    ON O.customer_id = C.customer_id
JOIN product_catalog AS P
    ON P.product_id = O.product_id;


	--ACCESSING THE VIEW
SELECT * FROM vW_ORDER_SUMMARY;
-- STILL WE THE CLIENT CAN ACCESS THE CONTENTS OF THE TABLE BY ACCESSING THE SCRIPT FROM LEFT SIDE OBJECT EXPLORER
-- IN THAT CASE, WE WILL USE ACCESS RIGHTS - CREATE USER FOR CLIENT - AND WILL GIVE PERMISSION TO THE CLIENT

--APPLYING THE ACCESS RIGHTS TO THE VIEW FOR THE CLIENT

--1. CREATE USER
CREATE ROLE ALOK
LOGIN
PASSWORD 'alok';
--now instead of sharing the credentials of my database to the client, i'll share with the specific user 'ALOK' in this case
/*
	open new query window -> connect to new user / sign in as new user
	and in that query window try to access the newly created view

	this will give error

	now we will giev access to the client
*/

GRANT SELECT ON vW_ORDER_SUMMARY TO ALOK;
--client will only be able to do the select, no alteration, and he can not see the sql
REVOKE SELECT ON vW_ORDER_SUMMARY FROM ALOK;



CREATE TABLE EMPLOYEE (
  empId INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  dept TEXT NOT NULL
);

-- insert
INSERT INTO EMPLOYEE VALUES (0001, 'Clark', 'Sales');
INSERT INTO EMPLOYEE VALUES (0002, 'Dave', 'Accounting');
INSERT INTO EMPLOYEE VALUES (0003, 'Ava', 'Sales');

select *from employee;

CREATE VIEW vW_STORE_SALES_DATA
AS
	SELECT EMPID, NAME, DEPT 
	FROM EMPLOYEE
	WHERE DEPT = 'Sales'
	WITH CHECK OPTION;

SELECT *FROM vW_STORE_SALES_DATA;

INSERT INTO vW_STORE_SALES_DATA(EMPID, NAME, DEPT) VALUES (5, 'Aman', 'Admin'); --VIOLATION CONDITION

refresh materialized view mv_random_tabl;
