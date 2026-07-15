/*
LAB3
Name: Billy Conard 
Date: 04/26/2026
5.	Who earns less than or equal to $2,500? 
	File to create: q5.sql
	Columns to display: SALESPERSONS.ename, SALESPERSONS.salary 
	Instructions: Display the name and salary of all salespersons whose salary is 
  less than or equal to $2,500. Sort projection on salary high to low.
*/

SELECT S.ename, 
       S.salary
FROM   SALESPERSONS S
WHERE  S.salary <= 2500
ORDER BY S.salary DESC;

/*
6.	Which parts cost between one and fifteen dollars (inclusive)? 
	File to create: q6.sql 
	Columns to display: INVENTORY.partid, INVENTORY.description, INVENTORY.price 
	Instructions: Display the part id, description, and price of all parts where 
  the price is between $1.00 and $15.00. Show the output in descending order of 
  price. Use the BETWEEN clause.
*/

-- Examine all prices first
--SELECT * 
--FROM INVENTORY;

-- BETWEEN is inclusive on both ends in Oracle
SELECT I.partid, 
       I.description,
       I.price
FROM INVENTORY I
WHERE I.price BETWEEN 1 AND 15
ORDER BY I.price DESC;

/* 
7.	Which part descriptions begin with the letter tee? 
	File to create: q7.sql 
	Columns to display: INVENTORY.partid, INVENTORY.description 
	Instructions: Display the part id and description of all parts where the 
  description begins with the capital letter T or the lower case letter t.  
  Show the output in ascending order of price.
*/

-- Inspect all descriptions first
--SELECT * 
--FROM INVENTORY;

-- Ensure LOWER method used for consistency
SELECT I.partid,
       I.description
FROM   INVENTORY I
WHERE  LOWER(I.description) LIKE 't%'
ORDER BY I.price;

/*
8.	What are the highest and lowest priced parts? One query please.
	File to create: q8.sql 
	Columns to display: INVENTORY.partid, INVENTORY.description, INVENTORY.price 
	Instructions: Display the part id, description, and price for the highest and 
  lowest priced parts in our inventory.
*/
-- Inspect all price values in descending order
--SELECT *
--FROM INVENTORY
--ORDER BY INVENTORY.price DESC;

SELECT I.partid,
       I.description,
       I.price
FROM   INVENTORY I
WHERE I.price = (
    SELECT MAX(INVENTORY.price)
    FROM INVENTORY
    ) 
   OR I.price = (
    SELECT MIN(INVENTORY.price)
    FROM INVENTORY
   )
ORDER BY I.price DESC;

---- Alternative Approach
--SELECT I.partid,
--       I.description,
--       I.price
--FROM INVENTORY I
--WHERE I.price IN (
--    (SELECT MAX(price) FROM INVENTORY),
--    (SELECT MIN(price) FROM INVENTORY)
--)
--ORDER BY I.price DESC;

/*
9.	Which sales people have NOT sold anything? Use a correlated subquery.
	File to create: q9.sql 
	Columns to display: SALESPERSONS.ename 
	Instructions: Display all employees that are not involved with an order, i.e. 
  where the empid of the sales person does not appear in the ORDERS table.  
  Display the names in alphabetical order.  Do not use joins at all - use 
  sub-queries only. 
*/

-- Correlated subquery needs to reference empid column from SALESPERSONS
SELECT S.ename AS EmployeeName
FROM   SALESPERSONS S
WHERE NOT EXISTS (
    SELECT *
    FROM ORDERS O
    WHERE S.empid = O.empid -- Don't forget the correlation!
)
ORDER BY S.ename;


/*
10.	Which sales people have NOT sold anything? Use an implicit join.
	File to create: q10.sql 
	Columns to display: SALESPERSONS.ename 
	Instructions: Display the employees that are not involved with an order, i.e. 
  where the empid of the sales person does not appear in the ORDERS table. 
  Display the names in alphabetical order. Do not use sub-queries at all  - use 
  joins only. 
*/

-- JOIN will need to return NULL values
-- USE OUTER JOIN syntax with an IS NULL check
SELECT S.ename AS EmployeeName
FROM   SALESPERSONS S,
       ORDERS O
WHERE S.empid = O.empid (+)
    AND O.empid IS NULL
ORDER BY S.ename;
