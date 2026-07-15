/*
Lab4
1.	Who are the profit-less customers? 
o	Columns to display: CUSTOMERS.custid, CUSTOMERS.cname 
o	Instructions: Display the customers that have not placed orders.   
o	Show in customer name order.
o	Use the EXISTS (or NOT EXISTS) comparison. 
*/

-- View all customers
-- SELECT *
-- FROM CUSTOMERS; 

SELECT C.custid AS CustomerID,
       C.cname AS CustomerName
FROM   CUSTOMERS C
WHERE  NOT EXISTS (
    SELECT *
    FROM ORDERS O
    WHERE O.custid = c.custid
)
ORDER BY CustomerName;


/* 
2. Delete the profit-less customers 
o	Columns to display: none 
o	Instructions: Write a DELETE query to delete from the CUSTOMERS table all customers who have not placed orders. 
*/
-- Use q1 query as subquery condition here
-- Remove cname from inner SELECT 
DELETE 
FROM   CUSTOMERS 
WHERE  custid IN (
    SELECT C.custid AS CustomerID
    FROM   CUSTOMERS C
    WHERE  NOT EXISTS (
        SELECT *
        FROM ORDERS O
        WHERE O.custid = c.custid
    )
);

-- Re-run Q1 to ensure no results returned
--SELECT C.custid AS CustomerID,
--       C.cname AS CustomerName
--FROM   CUSTOMERS C
--WHERE  NOT EXISTS (
--    SELECT *
--    FROM ORDERS O
--    WHERE O.custid = c.custid
--)
--ORDER BY CustomerName;

-- Save Changes if valid 
COMMIT;

-- Fail safe if not 
-- ROLLBACK;


/*
3.	How are the salespersons doing? 
o	Columns to display: SALESPERSONS.empid, SALESPERSONS.ename, SUM(ORDERITEMS.qty*INVENTORY.price) 
o	Instructions: Display the total dollar value that each and every sales person has sold. 
o	If you want to show zero use NVL. 
o	List in descending order of  total amount sold. 
*/

-- 4 table join (OUTER JOIN to collect each and every)
-- SALESPERSONS -> ORDERS -> ORDERITEMS -> INVENTORY
-- Use NVL to convert NULL values (i.e. Larry Little)
SELECT S.empid,
       S.ename AS EmployeeName,
       NVL(SUM(OI.qty * I.price), 0) AS TotalDollarsSold
FROM   SALESPERSONS S
    LEFT JOIN ORDERS O
        ON O.empid = S.empid
    LEFT JOIN ORDERITEMS OI
        ON OI.orderid = O.orderid
    LEFT JOIN INVENTORY I
        ON I.partid = OI.partid
GROUP BY S.empid, S.ename
ORDER BY TotalDollarsSold DESC;


/* 
4.	What is the value of all orders? 
o	Columns to display: ORDERS.orderid, SUM(ORDERITEM.qty*INVENTORY.price) 
o	Instructions: Display the total value of each and every order.
o	If you want to show zero use NVL.
*/

-- SUM of all orders
-- Each and every implies orders inclusion of NULL values
-- Find all orders
--SELECT COUNT(*)
--FROM ORDERS;

-- 23 total orders 

-- Are there orders with no parts?
--SELECT COUNT(*)
--FROM   ORDERS 
--    LEFT JOIN ORDERITEMS 
--        ON ORDERITEMS.OrderID = ORDERS.OrderID
--WHERE PARTID IS NULL;

-- 2 orders with no items, NULL values expected
-- Use NVL and expect 2 rows with 0 for TotalValue

SELECT O.orderid,
       NVL(SUM(OI.qty * I.price), 0) AS TotalValue
FROM   ORDERS O
    LEFT JOIN ORDERITEMS OI
        ON OI.orderid = O.orderid
    LEFT JOIN INVENTORY I
        ON I.partid = OI.partid
GROUP BY O.orderid
ORDER BY TotalValue DESC; -- Sort for readability


/*
5.	Who is our most profitable salesperson? 
o	Columns to display: SALESPERSONS.empid, SALESPERSONS.ename, (SUM(ORDERITEMS.qty*INVENTORY.price) - SALESPERSONS.salary) 
o	Instructions: A salesperson's profit (or loss) is the difference between what the person sold and what the person earns ((SUM(ORDERITEMS.qty*INVENTORY.price) - SALESPERSONS.salary)).
o	If the value is positive then there is a profit, otherwise there is a loss.  
o	The most profitable salesperson, therefore, is the person with the greatest profit or smallest loss. 
o	Display the most profitable salesperson. 
*/

-- Convert sales total (ProfitVal) to NVL() BEFORE subtracting salary
SELECT RankTable.empID,
       RankTable.ename AS EmployeeName,
       TO_CHAR(ProfitVal, '$999,999.99') AS Profitability
FROM (
    SELECT S.empID, -- Inner query returns all employees with their profitability rank
           S.ename,
           NVL(SUM(OI.qty * I.price), 0) - S.salary AS ProfitVal,
           DENSE_RANK () OVER (ORDER BY NVL(SUM(OI.qty * I.price), 0) - S.salary DESC) AS ProfitabilityRank
    FROM   SALESPERSONS S
        LEFT JOIN ORDERS O
            ON O.empid = S.empid
        LEFT JOIN  ORDERITEMS OI
            ON OI.orderid = O.orderid
        LEFT JOIN INVENTORY I
            ON I.partid = OI.partid
    GROUP BY S.empid, 
             S.ename, 
             S.salary
    ) RankTable
WHERE  ProfitabilityRank = 1; -- Return highest ranked salesperson


/*
6. Who is our second-most profitable salesperson?
	Columns to display: SALESPERSONS.empid, SALESPERSONS.ename, (SUM(ORDERITEMS.qty*INVENTORY.price) - SALESPERSONS.salary) 
	Instructions: A salesperson's profit (or loss) is the difference between what the person sold and what the person earns ((SUM(ORDERITEMS.qty*INVENTORY.price) - SALESPERSONS.salary)).
	If the value is positive then there is a profit, otherwise there is a loss. 
	The most profitable salesperson, therefore, is the person with the greatest profit or smallest loss. 
	The second-most profitable salesperson is the person with the next greatest profit or next smallest loss. 
	Display the second-most profitable salesperson. 
	Do not hard-code the results of #5 into this query - that simply creates a data-dependent query. 
*/

-- Convert sales total to NVL() BEFORE subtracting salary
SELECT RankTable.empID,
       RankTable.ename AS EmployeeName,
       TO_CHAR(ProfitVal, '$999,999.99') AS Profitability
FROM (
    SELECT S.empID,
           S.ename,
           NVL(SUM(OI.qty * I.price), 0) - S.salary AS ProfitVal,
           DENSE_RANK () OVER (ORDER BY NVL(SUM(OI.qty * I.price), 0) - S.salary DESC) AS ProfitabilityRank
    FROM   SALESPERSONS S
        LEFT JOIN ORDERS O
            ON O.empid = S.empid
        LEFT JOIN  ORDERITEMS OI
            ON OI.orderid = O.orderid
        LEFT JOIN INVENTORY I
            ON I.partid = OI.partid
    GROUP BY S.Empid, 
             S.Ename, 
             S.salary
    ) RankTable
WHERE  ProfitabilityRank = 2; -- Same concept as before, just change the rank to 2
-- It will NOT be Larry Little (ensure accurate NVL placement)


/*
7. Add a new salesperson  
	Columns to display: none 
	Instructions: Write an INSERT query to insert a new salesperson into the database with the following attribute values.
	empid should be one greater than the largest existing empid (no hard-coding, use SELECT)
	ename should be your name (hard-code your name here) 
	rank should be whichever rank is associated with the lowest-paid salesperson (use SELECT).
	salary is to be 9% more than the lowest-paid salesperson (another SELECT clause). (X 1.09)        
*/

-- Start with a check of all SALESPERSONS
--SELECT *
--FROM SALESPERSONS;

-- INSERT Value Order:
-- Value for empid: SELECT NVL(MAX(SALESPERSONS.empid), 0) + 1 AS empid
-- Value for ename: Billy Conard
-- Value for rank: SELECT SALESPERSONS.rank WHERE SALESPERSONS.salary = MIN(SALESPERSONS.salary)
-- Value for salary: SELECT SALESPERSONS.salary * 1.09 WHERE SALESPERSONS.salary = MIN(SALESPERSONS.salary)

INSERT INTO SALESPERSONS (empid, ename, rank, salary)
    VALUES ((SELECT NVL(MAX(SALESPERSONS.empid), 0) + 1 FROM SALESPERSONS), -- dynamic query for empid
            'Billy Conard', -- ename
            (SELECT DISTINCT SALESPERSONS.rank -- DISTINCT to return one value
             FROM   SALESPERSONS 
             WHERE  SALESPERSONS.salary = (
                SELECT MIN(SALESPERSONS.salary)
                FROM   SALESPERSONS
             ) -- dynamic query for rank value
            ),
            (SELECT DISTINCT (SALESPERSONS.salary * 1.09) -- DISTINCT to return one value
             FROM   SALESPERSONS
             WHERE  SALESPERSONS.salary = (
                SELECT MIN(SALESPERSONS.salary)
                FROM   SALESPERSONS
             ) -- dynamic query for salary value
            )
    );


-- Confirm insertion    
--SELECT *
--FROM SALESPERSONS;

-- Save changes if valid
COMMIT;

-- Fail Safe if not 
--ROLLBACK;


/*
8.  Give a raise to our best salesperson(s). 
	Columns to display: none 
	Instructions: Write an UPDATE query to increase the value of 
	the SALESPERSONS.salary column by 9% for the most profitable salesperson(s).
*/

-- Handle ties for first place via DENSE_RANK 
-- Write a query to find the most profitable salespersons
-- Retrieve only empIDs and use as subquery

-- Find the most profitable salesperson(s) and salary values using Q5 query
--SELECT     S.empID,
--           S.ename,
--           S.salary,
--           DENSE_RANK () OVER (ORDER BY NVL(SUM(OI.qty * I.price), 0) - S.salary DESC) AS ProfitabilityRank
--FROM   SALESPERSONS S
--    LEFT JOIN ORDERS O
--        ON O.empid = S.empid
--    LEFT JOIN  ORDERITEMS OI
--        ON OI.orderid = O.orderid
--    LEFT JOIN INVENTORY I
--        ON I.partid = OI.partid
--GROUP BY S.Empid, 
--         S.Ename, 
--         S.salary
--ORDER BY ProfitabilityRank;
         
-- Nest that query in an UPDATE WHERE clause to target the most profitable
UPDATE SALESPERSONS
SET    SALESPERSONS.salary = (SALESPERSONS.salary * 1.09)
WHERE  SALESPERSONS.empid IN (
    SELECT RankTable.empid
    FROM (
        SELECT S.empid,
               DENSE_RANK () OVER (ORDER BY NVL(SUM(OI.qty * I.price), 0) - S.salary DESC) AS ProfitabilityRank
        FROM   SALESPERSONS S
            LEFT JOIN ORDERS O
                ON O.empid = S.empid
            LEFT JOIN  ORDERITEMS OI
                ON OI.orderid = O.orderid
            LEFT JOIN INVENTORY I
                ON I.partid = OI.partid
        GROUP BY S.empid, S.salary
        ) RankTable
    WHERE ProfitabilityRank = 1
    );

---- Confirm salary increase for Dale Dahlman    
--SELECT     S.empID,
--           S.ename,
--           S.salary,
--           DENSE_RANK () OVER (ORDER BY NVL(SUM(OI.qty * I.price), 0) - S.salary DESC) AS ProfitabilityRank
--FROM   SALESPERSONS S
--    LEFT JOIN ORDERS O
--        ON O.empid = S.empid
--    LEFT JOIN  ORDERITEMS OI
--        ON OI.orderid = O.orderid
--    LEFT JOIN INVENTORY I
--        ON I.partid = OI.partid
--GROUP BY S.Empid, 
--         S.Ename, 
--         S.salary;
--         
-- COMMIT CHANGES
COMMIT;

-- Fail safe
--ROLLBACK;


/*
9.	Clean up the orders 
	Columns to display: none 
	Instructions: Write a DELETE query to delete rows from the ORDERS table that are not associated 
	with any rows in ORDERITEMS (i.e. remove the orders with no line items). 
*/

-- Find orders with no line items 
--SELECT *
--FROM ORDERS 
--WHERE NOT EXISTS (
--    SELECT *
--    FROM   ORDERITEMS 
--    WHERE  ORDERS.orderid = ORDERITEMS.orderid
--);

-- DELETE those rows
DELETE 
FROM ORDERS
WHERE NOT EXISTS (
    SELECT *
    FROM ORDERITEMS
    WHERE ORDERS.orderid = ORDERITEMS.orderid
);

-- Confirm query returns no results 
--SELECT *
--FROM ORDERS 
--WHERE NOT EXISTS (
--    SELECT *
--    FROM   ORDERITEMS 
--    WHERE  ORDERS.orderid = ORDERITEMS.orderid
--);

-- COMMIT if valid
COMMIT;

-- ROLLBACK if not 
--ROLLBACK;
