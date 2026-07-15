/*
*******************************************************************************************
CIS276 at PCC
LAB 1 using SQL SERVER 2012 and the SalesDB tables
*******************************************************************************************

                                   CERTIFICATION:

   By typing my name below I certify that the enclosed is original coding written by myself
without unauthorized assistance.  I agree to abide by class restrictions and understand that
if I have violated them, I may receive reduced credit (or none) for this assignment.

                CONSENT:   Billy Conard
                DATE:      April 13th, 2026

*******************************************************************************************
*/
PRINT '================================================================================' + CHAR(10)
    + 'CIS276 Lab1' + CHAR(10)
    + '================================================================================' + CHAR(10)
GO


USE SalesDB
GO


PRINT '1. Who earns less than or equal to $2,500?' + CHAR(10)
/*
Projection: SALESPERSONS.Ename, SALESPERSONS.Salary 
Instructions: Display the name and salary of all salespersons 
whose salary is less than or equal to $2,500. 
Sort projection on salary high to low.
*/
SELECT SALESPERSONS.Ename AS EmployeeName, 
       SALESPERSONS.Salary
FROM   SALESPERSONS
WHERE  SALESPERSONS.Salary <= 2500
ORDER BY SALESPERSONS.Salary DESC;

GO


PRINT '================================================================================' + CHAR(10)
PRINT '2. Which parts cost between one and fifteen dollars (inclusive)?' + CHAR(10)
/*
Projection: INVENTORY.PartID, INVENTORY.Description, INVENTORY.Price 
Instructions: Display the part id, Description, and Price of all parts 
where the Price is between the numbers given (inclusive). 
Show the output in descending order of Price.
Use the BETWEEN comparison.
*/

-- Prompt says inclusive - No price appears that is inclusive to either 1 or 15
-- High Price of this Query is 12.5, Low price is 2.5. 
-- Check all inventory price values to ensure accuracy of inclusivity

--SELECT *
--FROM INVENTORY
--ORDER BY INVENTORY.Price DESC;

SELECT INVENTORY.PartID,
       INVENTORY.Description,
       INVENTORY.Price
FROM   INVENTORY
WHERE  INVENTORY.Price BETWEEN 1 AND 15
ORDER BY INVENTORY.Price DESC;

GO


PRINT '================================================================================' + CHAR(10)
PRINT '3. What is the highest Priced part? What is the lowest Priced part?' + CHAR(10)
/*
Projection: INVENTORY.PartID, INVENTORY.Description, INVENTORY.Price 
Instructions: Display the part id, Description, and Price for the 
highest and lowest Priced parts in our INVENTORY.  Show only these two parts and no others � using a single query.
*/

-- Perhaps a subquery in the WHERE clause? Start with SELECT * FROM INVENTORY to see the prices
-- One subquery for MIN, one for MAX. Errors received with 2 aggregates in the same subquery
SELECT INVENTORY.PartID, 
       INVENTORY.Description,
       INVENTORY.Price
FROM   INVENTORY
WHERE  INVENTORY.Price = (
        SELECT MAX(INVENTORY.Price)
        FROM INVENTORY
        ) 
       OR INVENTORY.Price = (
        SELECT MIN(INVENTORY.Price)
        FROM INVENTORY
);



GO


PRINT '================================================================================' + CHAR(10)
PRINT '4. Which part Descriptions begin with the letter T?' + CHAR(10)
/*
Projection: INVENTORY.PartID, INVENTORY.Description 
Instructions: Display the part id and Description of all parts where the 
Description begins with the letter 'T' (that's a capital 'T' or a lower case 't'). 
Show the output in descending order of Price.
*/

-- Case insensitive, so a LOWER method will need to be used 
-- Don't forget to sort DESC by price, even though it is not required in Projection
SELECT INVENTORY.PartID,
       INVENTORY.Description
FROM INVENTORY
WHERE LOWER(INVENTORY.Description) LIKE 't%'
ORDER BY INVENTORY.Price DESC; 

GO


PRINT '================================================================================' + CHAR(10)
PRINT '5. Which parts need to be ordered from our supplier?' + CHAR(10)
/*
Projection: INVENTORY.PartID, INVENTORY.Description, and (INVENTORY.ReorderPnt - INVENTORY.StockQty) 
Instructions: Display the part id and Description of all parts where the stock quantity is less than the reorder point. 
For each part where this is true also display the amount that the stock quantity is below the reorder point. 
Display the parts in descending order of the computed difference.
*/

-- WHERE stock quantity less than reorder point (Computed difference is in the projection)
-- Prompt says 'less than', so 0 values in AmtBelowReorderPnt column are excluded
-- Looking for positive values in AmtBelowReorderPnt column
SELECT INVENTORY.PartID, 
       INVENTORY.Description,
       -- INVENTORY.StockQty, Used for reference in calculations
       (INVENTORY.ReorderPnt - INVENTORY.StockQty) AS AmtBelowReorderPnt
FROM INVENTORY
WHERE INVENTORY.StockQty < INVENTORY.ReorderPnt
ORDER BY AmtBelowReorderPnt DESC;

GO


PRINT '================================================================================' + CHAR(10)
PRINT '6. Which sales people have NOT sold anything? Subquery version.' + CHAR(10)
/*
Projection: SALESPERSONS.Ename 
Instructions: Display all employees that are not involved with an order, 
i.e. where the EmpID of the salesperson does not appear in the ORDERS table. 
Display the names in alphabetical order. Do not use JOINs - use sub-queries only. 
OPTION: There are two ways to write the subquery version (correlated and non-correlated). 
If you supply both queries and they are both correct you may offset a points deduction elsewhere.
*/

-- Subquery in the WHERE clause
-- Inner query selects all NON NULL EmpID's from ORDERS
-- Outer Query filters to find EmpID's not returned from inner query
SELECT SALESPERSONS.Ename AS EmployeeName
FROM   SALESPERSONS
WHERE  SALESPERSONS.EmpID NOT IN (
    SELECT ORDERS.EmpID 
    FROM ORDERS
    WHERE ORDERS.EmpID IS NOT NULL
)
ORDER BY EmployeeName;

GO


PRINT '================================================================================' + CHAR(10)
PRINT '7. Which sales people have NOT sold anything? JOIN version (explicit or named JOIN).' + CHAR(10)
/*
Projection: SALESPERSONS.Ename 
Instructions: Display all employees that are not involved with an order, 
i.e. where the EmpID of the sales person does not appear in the ORDERS table. 
Display the names in alphabetical order. Do not use sub-queries - use only JOINs.
*/ 

-- LEFT JOIN with an extra WHERE clause condition 
-- OUTER JOIN explicit syntax from practice - that one dealt with orders, this one deals with salespersons
-- Start with SALESPERSONS table as that EmpID will (most likely) not be null
-- LEFT JOIN ORDERS, then check where the EmpID is null in ORDERS table
SELECT SALESPERSONS.Ename AS EmployeeName
FROM   SALESPERSONS
    LEFT JOIN ORDERS 
        ON ORDERS.EmpID = SALESPERSONS.EmpID
WHERE ORDERS.EmpID IS NULL
ORDER BY EmployeeName;

GO


PRINT '================================================================================' + CHAR(10)
PRINT '8. Who placed the most orders?' + CHAR(10)
/*
Projection: CUSTOMERS.CustID, CUSTOMERS.Cname, COUNT(DISTINCT ORDERS.OrderID) 
Instructions: Display the customer id, customer name, and number of orders 
for the customer who has placed the most orders; i.e. the customer who appears the most
times in the ORDERS table.  Display only this record!
*/

-- Use TOP 1 to ensure subquery in SELECT statement is scalar (returns one row)
-- Place in descending order to display the customer with the most orders
SELECT TOP 1 CUSTOMERS.CustID,
             CUSTOMERS.Cname AS CustName,
             (SELECT COUNT(DISTINCT ORDERS.OrderID) 
               FROM ORDERS
               WHERE ORDERS.CustID = CUSTOMERS.CustID) AS TotalOrders
FROM   CUSTOMERS
ORDER BY TotalOrders DESC;

GO


PRINT '================================================================================' + CHAR(10)
PRINT '9. Who ordered the most quantity?' + CHAR(10)
/* 
Projection: CUSTOMERS.CustID, CUSTOMERS.Cname, SUM(ORDERITEMS.Qty)
Instructions: Display the customer id, customer name, and total quantity of parts ordered 
by the customer who has ordered the greatest quantity. 
For this query you will sum the quantity for all order items of all orders 
associated with each customer to determine which customer has ordered the most quantity.
*/

-- GROUP BY non aggregates
-- Aggregation is done on ORDERITEMS table
-- CUSTOMERS AND ORDERITEMS do not have a direct relationship - need to join CUSTOMERS to ORDERS to ORDERITEMS
-- ORDER BY Desc, then filter with TOP 1 
SELECT TOP 1 c.CustID,
             c.Cname AS CustName,
             SUM(oi.Qty) AS TotalQtyOrdered
FROM CUSTOMERS c
    JOIN ORDERS o 
        ON c.CustID = o.CustID
    JOIN ORDERITEMS oi
        ON oi.OrderID = o.OrderID
GROUP BY c.CustID, c.Cname
ORDER BY TotalQtyOrdered DESC;

GO


PRINT '================================================================================' + CHAR(10)
PRINT '10. Who ordered the highest total value?' + CHAR(10)
/*
Projection: CUSTOMERS.CustID, CUSTOMERS.Cname, SUM(INVENTORY.Price * ORDERITEMS.Qty) 
Instructions: Display the customer id, customer name, and total value of all orders 
for the customer whose orders total the highest value. 
To find the total value for a customer you need to sum the (Price times Qty) 
for each line item of each order associated with the customer.
*/
-- Sort by DESC and retrieve only top row (revisit lecture if needed)
-- 4 tables in the join for this query! Refer to ERD!
SELECT TOP 1 c.CustID,
             c.Cname AS CustName,
             SUM(i.Price * oi.Qty) AS TotalValue
FROM CUSTOMERS c
    JOIN ORDERS o 
        ON o.CustID = c.CustID
    JOIN ORDERITEMS oi
        ON oi.OrderID = o.OrderID
    JOIN INVENTORY i 
        ON i.PartID = oi.PartID
GROUP BY c.CustID, c.Cname
ORDER BY TotalValue DESC;


GO


--------------------------------------------------------------------------------
-- Program block
--------------------------------------------------------------------------------
DECLARE @v_now DATETIME;
BEGIN
    SET @v_now = GETDATE();
    PRINT '================================================================================'
    PRINT 'End of CIS276 Lab1 [202502]';
    PRINT @v_now;
    PRINT '================================================================================';
END;
