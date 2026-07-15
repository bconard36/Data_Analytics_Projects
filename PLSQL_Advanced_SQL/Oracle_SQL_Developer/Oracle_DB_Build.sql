/*
LAB3 create-salesdb.sql

Name: Billy Conard 
Date: 04/26/2026

1.	Build the table create script in a file named create-salesdb.sql 
	Instructions: Create a .sql file that contains the CREATE TABLE statements to 
  build the SalesDB tables. Include the primary keys, foreign keys, and domain 
  constraints shown in the Database Design section (above) in your CREATE TABLE 
  statements. The order of statements is important.
*/

-- Inspect SalesDB Tables
DESCRIBE SALESDB.CUSTOMERS;
DESCRIBE SALESDB.SALESPERSONS;
DESCRIBE SALESDB.INVENTORY;
DESCRIBE SALESDB.ORDERITEMS;
DESCRIBE SALESDB.ORDERS;

-- ORDERS MUST BE CREATED BEFORE ORDERITEMS

-- Create CUSTOMERS Table 
-- Check that CREDIT IN A, B, or C
CREATE TABLE CUSTOMERS
(
    CUSTID   NUMBER(4)  NOT NULL,
    CNAME    CHAR(25)   NOT NULL,
    CREDIT   CHAR(1)    NOT NULL,
    CONSTRAINT CUSTOMERS_pk PRIMARY KEY (CUSTID),
    CONSTRAINT CUSTOMERS_credit_chk CHECK (CREDIT IN ('A', 'B', 'C'))
);

-- Create SALESPERSONS Table
-- Check that RANK IN 1, 2, or 3
-- Check that SALARY is greater than or equal to 1000
-- DEFAULT 1000
CREATE TABLE SALESPERSONS 
(
    EMPID    NUMBER(4)   NOT NULL,
    ENAME    CHAR(15)    NOT NULL,
    RANK     NUMBER(2)   NOT NULL,
    SALARY   NUMBER(8,2) DEFAULT 1000.00 NOT NULL,
    CONSTRAINT SALESPERSONS_pk PRIMARY KEY (EMPID),
    CONSTRAINT SALESPERSONS_rank_chk CHECK (RANK IN (1, 2, 3)),
    CONSTRAINT SALESPERSONS_salary_chk CHECK (SALARY >= 1000.00)
);

-- Create INVENTORY Table 
CREATE TABLE INVENTORY 
(
    PARTID      NUMBER(4)   NOT NULL,
    DESCRIPTION CHAR(12)    NOT NULL,
    STOCKQTY    NUMBER(4)   NOT NULL,
    REORDERPNT  NUMBER(4),
    PRICE       NUMBER(8,2) NOT NULL,
    CONSTRAINT INVENTORY_pk PRIMARY KEY (PARTID)
);

-- Create ORDERS Table
-- Set DEFAULT DATE to SYSDATE
CREATE TABLE ORDERS
(
    ORDERID     NUMBER(4)   NOT NULL,
    EMPID       NUMBER(4)   NOT NULL,
    CUSTID      NUMBER(4)   NOT NULL,
    SALESDATE   DATE        DEFAULT SYSDATE NOT NULL,
    CONSTRAINT ORDERS_pk PRIMARY KEY (ORDERID),
    CONSTRAINT ORDERS_empid_fk FOREIGN KEY (EMPID) REFERENCES SALESPERSONS,
    CONSTRAINT ORDERS_custid_fk FOREIGN KEY (CUSTID) REFERENCES CUSTOMERS
);

-- Create ORDERITEMS Table 
CREATE TABLE ORDERITEMS 
(
    ORDERID   NUMBER(4)  NOT NULL,
    DETAIL    NUMBER(2)  NOT NULL,
    PARTID    NUMBER(4)  NOT NULL, 
    QTY       NUMBER(6)  NOT NULL,
    CONSTRAINT ORDERITEMS_pk PRIMARY KEY (ORDERID, DETAIL),
    CONSTRAINT ORDERITEMS_orderid_fk FOREIGN KEY (ORDERID) REFERENCES ORDERS,
    CONSTRAINT ORDERITEMS_partid_fk FOREIGN KEY (PARTID) REFERENCES INVENTORY
);

-- DROP Order Here (FallBack)
--DROP TABLE ORDERITEMS;
--DROP TABLE ORDERS;
--DROP TABLE INVENTORY;
--DROP TABLE SALESPERSONS;
--DROP TABLE CUSTOMERS;

/*
2.	Build the table delete script in a file named drop-salesdb.sql 
	Instructions: Create a .sql file that  contains DROP TABLE statements to 
  delete the SalesDB tables.  The order of statements is important.
*/

-- Drop SALESDB Tables in REVERSE Creation Order
-- CREATE Order: CUSTOMERS -> SALESPERSONS -> INVENTORY -> ORDERS -> ORDERITEMS
-- DROP Order: ORDERITEMS -> ORDERS -> INVENTORY -> SALESPERSONS -> CUSTOMERS
DROP TABLE ORDERITEMS;
DROP TABLE ORDERS;
DROP TABLE INVENTORY;
DROP TABLE SALESPERSONS;
DROP TABLE CUSTOMERS;
/*

3.	Build the index create script in a file named index-salesdb.sql (not a UNIQUE index).
	Instructions: Create a .sql file that contains CREATE INDEX statements for the following columns: 
?	CUSTOMERS.cname 
?	SALESPERSONS.ename 
?	ORDERS.salesdate
?	ORDERITEMS.partid
?	INVENTORY.description 
*/

-- Dot notation like seen above threw an error
-- Use underscores like CONSTRAINTS to keep consistent naming conventions
CREATE INDEX CUSTOMERS_cname ON CUSTOMERS (CNAME);
CREATE INDEX SALESPERSONS_ename ON SALESPERSONS (ENAME);
CREATE INDEX ORDERS_salesdate ON ORDERS (SALESDATE);
CREATE INDEX ORDERITEMS_partid ON ORDERITEMS (PARTID);
CREATE INDEX INVENTORY_description ON INVENTORY (DESCRIPTION);

/*
4.	Build the table load script in a file named load-salesdb.sql 
	Instructions: Create a .sql file that contains INSERT statements to load the 
  SalesDB tables from the corresponding SALESDB user tables. 
*/

-- With INSERT, use COMMIT and ROLLBACK!

-- Bulk Insert into CUSTOMERS
INSERT INTO CUSTOMERS
    SELECT * FROM SALESDB.CUSTOMERS;

COMMIT;

-- Bulk Insert into SALESPERSONS
INSERT INTO SALESPERSONS
    SELECT * FROM SALESDB.SALESPERSONS;

COMMIT;

-- Bulk Insert into INVENTORY
INSERT INTO INVENTORY
    SELECT * FROM SALESDB.INVENTORY;

COMMIT;

-- Bulk Insert into ORDERS
INSERT INTO ORDERS
    SELECT * FROM SALESDB.ORDERS;

COMMIT; 

-- Bulk Insert into ORDERITEMS
INSERT INTO ORDERITEMS
    SELECT * FROM SALESDB.ORDERITEMS;

COMMIT; 
