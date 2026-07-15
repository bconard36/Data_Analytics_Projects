/*
*******************************************************************************************
CIS276 at PCC
LAB 2 using SQL SERVER 2012 and the SalesDB tables
*******************************************************************************************

                                   CERTIFICATION:

   By typing my name below I certify that the enclosed is original coding written by myself
without unauthorized assistance.  I agree to abide by class restrictions and understand that
if I have violated them, I may receive reduced credit (or none) for this assignment.

                CONSENT:   Billy Conard
                DATE:      April 20th, 2026

*******************************************************************************************
*/
PRINT '================================================================================' + CHAR(10)
    + 'CIS276 Lab2'                                   + CHAR(10)
    + '================================================================================' + CHAR(10)

USE SalesDB
GO


PRINT '1. 1.	What is the dollar total for each of the salespeople?' + CHAR(10) 
PRINT 'Calculate totals for all salespeople (even if they have no sales).' + CHAR(10)
/*
Columns to display: SALESPERSONS.EmpID, SALESPERSONS.Ename, SUM(ORDERITEMS.Qty*INVENTORY.Price) 
Display the total dollar value that each and every sales person has sold.
List in dollar value descending.
NOTE: You need to include all salespeople, not just those salespeople with orders;
so you cannot do a simple inner JOIN. The outer JOIN picks up all salespeople.  
The warning statement is because of the NULL and can be disregarded. -- OUTER JOIN 
*/

SELECT S.EmpID,
       S.Ename AS EmployeeName,
       ISNULL (SUM(OI.Qty * I.Price), 0) AS TotalDollarsSold -- Replace NULL values (salespeople with no sales) with 0
FROM SALESPERSONS S
    LEFT JOIN ORDERS O
        ON S.EmpID = O.EmpID
    LEFT JOIN ORDERITEMS OI
        ON O.OrderID = OI.OrderID
    LEFT JOIN INVENTORY I -- All LEFT JOINS to prevent NULL data loss 
        ON OI.PartID = I.PartID
GROUP BY S.EmpID, S.Ename
ORDER BY TotalDollarsSold DESC;

GO


PRINT '================================================================================' + CHAR(10)
PRINT '2. What is the $$ value of each of the orders?' + CHAR(10) 
/*
Columns to display: ORDERS.OrderID, SUM(ORDERITEM.Qty*INVENTORY.Price) 
List in dollar value descending. 
OUTER JOIN to include all orders 
*/
-- Do any orders have no parts? 
            --SELECT *
            --FROM ORDERS
            --    LEFT JOIN ORDERITEMS
            --        ON ORDERITEMS.OrderID = ORDERS.OrderID
            --    LEFT JOIN INVENTORY
            --        ON INVENTORY.PartID = ORDERITEMS.PartID;
-- YES - Above query produces rows with NULL values 

SELECT O.OrderID,
       ISNULL (SUM(OI.Qty * I.Price), 0) AS OrderTotalDollars
FROM   ORDERS O
    LEFT JOIN ORDERITEMS OI 
        ON OI.OrderID = O.OrderID
    LEFT JOIN INVENTORY I
        ON I.PartID = OI.PartID
GROUP BY O.OrderID
ORDER BY OrderTotalDollars DESC;

GO


PRINT '================================================================================' + CHAR(10)
PRINT '3. Which orders contain widgets?' + CHAR(10)
/*
Columns to display: ORDERS.OrderID, ORDERS.SalesDate 
The word 'widget' may not be the only word in the part's description (use a wildcard).
Display the orders where a 'widget' part appears in at least one ORDERITEMS rows for the order.
List in sales date sequence with the newest first. 
Do not use the EXISTS comparison. (14 individual OrderIDs)
*/
-- Look at all descriptions
        --SELECT INVENTORY.Description,
        --       O.OrderID
        --FROM   INVENTORY
        --    LEFT JOIN ORDERITEMS OI 
        --        ON OI.PartID = INVENTORY.PartID
        --    LEFT JOIN ORDERS O
        --        ON O.OrderID = OI.OrderID
        --WHERE LOWER(INVENTORY.Description) LIKE '%widget%';
-- widget and WIDGETU found
-- WIDGETU has NULL for OrderID

-- Front and back end wildcard needed, but results should just show widget since OrderID is NULL for WIDGETU
SELECT ORDERS.OrderID, 
       CONVERT(CHAR(12), ORDERS.SalesDate, 110)
FROM   ORDERS 
    LEFT JOIN ORDERITEMS 
        ON ORDERITEMS.OrderID = ORDERS.OrderID
    LEFT JOIN INVENTORY 
        ON INVENTORY.PartID = ORDERITEMS.PartID
WHERE LOWER(INVENTORY.Description) LIKE '%widget%'
ORDER BY ORDERS.SalesDate DESC;

GO


PRINT '================================================================================' + CHAR(10)
PRINT '4. Which orders contain widgets?' + CHAR(10)
/*
Columns to display: ORDERS.OrderID, ORDERS.SalesDate 
The word 'widget' might not be the only word in the part's description (use a wildcard).
Display the orders where a 'widget' part appears in at least one ORDERITEMS rows for the order.
List in sales date sequence with the most recent first. 
Use the EXISTS comparison. (14 individual OrderIDs)
*/

-- DON'T FORGET THE CORRELATION!
SELECT ORDERS.OrderID,
       CONVERT(CHAR(12), ORDERS.SalesDate, 110)
FROM   ORDERS
WHERE EXISTS (
    SELECT *
    FROM ORDERITEMS
        JOIN INVENTORY 
            ON INVENTORY.PartID = ORDERITEMS.PartID
    WHERE LOWER(INVENTORY.Description) LIKE '%widget%'
    AND ORDERITEMS.OrderID = ORDERS.OrderID
)
ORDER BY ORDERS.SalesDate DESC;


GO


PRINT '================================================================================' + CHAR(10)
PRINT '5. What are the gadget and gizmo only orders? i.e. which orders contain at least one gadget and at least one gizmo, but no other parts?' + CHAR(10)
/*
Columns to display:  OrderID 
The words 'gadget' and 'gizmo' may not be the only word in the part's description. Code accordingly.
List in ascending order of OrderID.
3 conditions for this query (must contain at least one gadget, must contain at least one gizmo, cannot contain other parts)
Multiple where clause conditions (Subqueries) (1 record in solution)

*/

-- Could use ORDERITEMS and INVENTORY without ORDERS, because OrderID is in ORDERITEMS. 
SELECT OI.OrderID
FROM   ORDERITEMS OI
WHERE (EXISTS ( -- Add extra parentheses to force OR operation first
    SELECT INVENTORY.Description
    FROM   INVENTORY
    WHERE LOWER(INVENTORY.Description) LIKE '%gadget%'
    AND   INVENTORY.PartID = OI.PartID
) OR EXISTS (
    SELECT INVENTORY.Description
    FROM   INVENTORY
    WHERE LOWER(INVENTORY.Description) LIKE '%gizmo%'
    AND   INVENTORY.PartID = OI.PartID
)) AND NOT EXISTS (
    SELECT *
    FROM     ORDERITEMS
        JOIN INVENTORY  
            ON INVENTORY.PartID = ORDERITEMS.PartID
    WHERE   ORDERITEMS.OrderID = OI.OrderID
        AND LOWER(INVENTORY.Description) NOT LIKE '%gadget%'
        AND LOWER(INVENTORY.Description) NOT LIKE '%gizmo%'
)
GROUP BY OI.OrderID
ORDER BY OI.OrderID;

GO


PRINT '================================================================================' + CHAR(10)
PRINT '6. Who are our profit-less customers?' + CHAR(10)
/*
Columns to display: CUSTOMERS.CustID, CUSTOMERS.Cname 
Display the customers that have not placed orders.
Show in customer name order (either ascending or descending). 
Use the EXISTS comparison. 
REFER to "What did we do wrong" in Query Practice with exists and correlations 
*/

SELECT CUSTOMERS.CustID,
       CUSTOMERS.Cname AS CustomerName
FROM   CUSTOMERS 
WHERE NOT EXISTS (
    SELECT *
    FROM   ORDERS -- Query to view all orders 
    WHERE  CUSTOMERS.CustID = ORDERS.CustID
)
ORDER BY CustomerName;

--SELECT ORDERS.CustID
--FROM   ORDERS; -- Run with query above to cross reference CustID values

GO


PRINT '================================================================================' + CHAR(10)
PRINT '7. What is the average $$ value of an order?' + CHAR(10)
/*
To get the answer, you need to add up all the order values (see #2, above) and divide this by the number of orders. 
There are two possible averages on this question, because not all of the order numbers in the ORDERS table are in the ORDERITEMS table...
You will calculate and display both averages.
Columns to display are determined by whether your output is horizontal (two columns: "Orders Average" and "OrderItems Average") 
  or vertical (one column, holding both averages in separate lines).
Write one query that produces both averages. 
21 distinct order IDs in orderitems, 23 orderIds in orders. There are 2 orders that have not been completed yet
*/
-- SELECT COUNT(DISTINCT OrderID)
-- FROM ORDERS; -- Returns 23 - Lower Average $$ Value

-- SELECT COUNT(DISTINCT OrderID)
-- FROM ORDERITEMS; -- Returns 21 - Higher Average $$ Value 

SELECT ROUND(SUM(ORDERITEMS.Qty * INVENTORY.Price) / COUNT(DISTINCT ORDERS.OrderID), 2) AS OrdersAverage,
       ROUND(SUM(ORDERITEMS.Qty * INVENTORY.Price) / COUNT(DISTINCT ORDERITEMS.OrderID), 2) AS OrderItemsAverage
FROM   ORDERS  
    LEFT JOIN ORDERITEMS
        ON ORDERITEMS.OrderID = ORDERS.OrderID
    LEFT JOIN INVENTORY
        ON INVENTORY.PartID = ORDERITEMS.PartID;


GO


PRINT '================================================================================' + CHAR(10)
PRINT '8. Who is our most profitable salesperson?' + CHAR(10)
/*
Columns to display: SALESPERSONS.EmpID, SALESPERSONS.Ename, (SUM(ORDERITEMS.Qty*INVENTORY.Price) - SALESPERSONS.Salary) 
A salesperson's profit (or loss) is the difference between what the person sold and what the person earns 
((SUM(ORDERITEMS.Qty*INVENTORY.Price) - SALESPERSONS.Salary)).  If the value is positive then there is a profit, otherwise 
there is a loss.  The most profitable salesperson, therefore, is the person with the greatest profit or smallest loss.
Display the most profitable salesperson (there can be more than one). THERE IS ONE SALESPERSON WHO HAS NOT SOLD ANYTHING. 
Wrap (SUM(ORDERITEMS.Qty*INVENTORY.Price) in an IS NULL clause
JOINING 4 TABLES - ALL BUT CUSTOMERS
*/
-- Write a query to see profitability values
--SELECT S.EmpID,
--       S.Ename AS EmployeeName,
--       (SUM(OI.Qty * I.Price) - S.Salary) AS Profitability
--FROM   SALESPERSONS S
--    LEFT JOIN ORDERS O
--        ON O.EmpID = S.EmpID
--    LEFT JOIN ORDERITEMS OI
--        ON OI.OrderID = O.OrderID
--    LEFT JOIN INVENTORY I
--        ON I.PartID = OI.PartID
--GROUP BY S.EmpID,
--         S.Ename,
--         S.Salary;

-- Use above query as a derived table 
-- Apply DENSE_RANK to categorize profitability values
-- Return Rank 1 
SELECT *
FROM   (
    SELECT S.EmpID,
           S.Ename AS EmployeeName,
           ROUND((SUM(OI.Qty * I.Price) - S.Salary), 2) AS ProfitabilityDollars,
           DENSE_RANK () OVER (ORDER BY ISNULL((SUM(OI.Qty * I.Price) - S.Salary), 0) DESC) AS ProfitabilityRank 
    FROM   SALESPERSONS S
        LEFT JOIN ORDERS O
            ON O.EmpID = S.EmpID
        LEFT JOIN ORDERITEMS OI
            ON OI.OrderID = O.OrderID
        LEFT JOIN INVENTORY I
            ON I.PartID = OI.PartID
    GROUP BY S.EmpID,
             S.Ename,
             S.Salary
       ) AS RankTable
WHERE ProfitabilityRank = 1;

GO


PRINT '================================================================================' + CHAR(10)
PRINT '9. Who is our second-most profitable salesperson?' + CHAR(10)
    + 'The key is to take the best two, reverse, and take the best one'
/*
Columns to display: SALESPERSONS.EmpID, SALESPERSONS.Ename, (SUM(ORDERITEMS.Qty*INVENTORY.Price) - SALESPERSONS.Salary)
A salesperson's profit (or loss) is the difference between what the person sold and what the person earns 
((SUM(ORDERITEMS.Qty*INVENTORY.Price) - SALESPERSONS.Salary)).  If the value is positive then there is a profit, otherwise 
there is a loss.  The most profitable salesperson, therefore, is the person with the greatest profit or smallest loss.  
The second-most profitable salesperson is the person with the next greatest profit or next smallest loss.  
Display the second-most profitable salesperson (there can be more than one).  
Do not hard-code the results of #2 into this query - that simply creates a data-dependent query.
See if you can do this without using the SQL Server keyword TOP or TOP WITH TIES. 
*/
SELECT *
FROM   (
    SELECT S.EmpID,
           S.Ename AS EmployeeName,
           ROUND(ISNULL(SUM(OI.Qty * I.Price), 0) - S.Salary, 2) AS ProfitabilityDollars,
           DENSE_RANK () OVER (ORDER BY ISNULL(SUM(OI.Qty * I.Price), 0) - S.Salary DESC) AS ProfitabilityRank 
    FROM   SALESPERSONS S
        LEFT JOIN ORDERS O
            ON O.EmpID = S.EmpID
        LEFT JOIN ORDERITEMS OI
            ON OI.OrderID = O.OrderID
        LEFT JOIN INVENTORY I
            ON I.PartID = OI.PartID
    GROUP BY S.EmpID,
             S.Ename,
             S.Salary
             ) AS RankTable
WHERE ProfitabilityRank = 2;

GO


PRINT '================================================================================' + CHAR(10)
PRINT'10.	What would be the discounts for each line item on orders of five or more units?' + CHAR(10)
/* Columns to display: Orderid, Partid, Description, Qty, UnitPrice, OriginalCost, QuantityDeduction, and FinalCost
 We have decided to give quantity discounts to encourage more sales.  If an order contains five or more units of a given 
 product we will give a 5% discount for that line item.  If an order contains ten or more units we will give a 10% discount 
 on that line item.   Produce an output that prints the OrderID, partid, description, Qty ordered, unit list Price, the total
 original Price(Qty ordered * list Price),  the total discount value (shown as money or percent), and the total final Price 
 of the product after the discount.   Display only those line items subject to the discount in ascending order by the OrderID 
 and partid.  Use the CASE statement.
 */ 
 -- JOIN ORDERITEMS AND INVENTORY
 -- Check for 10 or more units first, and then check for 5 or more units
 -- 2 CASE statements needed 

 -- CALCULATIONS
 -- Total Original Price = Qty * Price 
 -- Total Discount Value = (OriginalPrice * Discount) 
 -- Final Price = OriginalPrice - DiscountValue

SELECT DISCOUNTS.OrderID,
       DISCOUNTS.PartID,
       DISCOUNTS.Description,
       DISCOUNTS.Qty,
       DISCOUNTS.UnitPrice,
       ROUND(CAST((DISCOUNTS.Qty * DISCOUNTS.UnitPrice) AS DECIMAL(10,2)), 2) AS TotalOriginalPrice,
       ROUND(CAST((DISCOUNTS.Qty * DISCOUNTS.UnitPrice) * DiscountPercentage AS DECIMAL(10,2)), 2) AS QuantityDeduction,
       ROUND(CAST((DISCOUNTS.Qty * DISCOUNTS.UnitPrice) 
                - ((DISCOUNTS.Qty * DISCOUNTS.UnitPrice) 
                * DiscountPercentage) AS DECIMAL(10,2)), 2) AS FinalPrice
FROM (
    SELECT  ORDERITEMS.OrderID,
            ORDERITEMS.PartID,
            INVENTORY.Description,
            ORDERITEMS.Qty,
            INVENTORY.Price AS UnitPrice,
    CASE 
        WHEN ORDERITEMS.Qty >= 10 THEN  0.1
        WHEN ORDERITEMS.Qty >= 5 
            AND ORDERITEMS.Qty < 10 THEN 0.05
        ELSE 0
        END AS DiscountPercentage
    FROM ORDERITEMS
        JOIN INVENTORY
            ON INVENTORY.PartID = ORDERITEMS.PartID
     ) AS DISCOUNTS
WHERE DISCOUNTS.Qty >= 5 
ORDER BY OrderID, PartID;


GO


--------------------------------------------------------------------------------
-- Program block
--------------------------------------------------------------------------------
DECLARE @v_now DATETIME;
BEGIN
    SET @v_now = GETDATE();
    PRINT '================================================================================'
    PRINT 'End of CIS276 Lab2 [202502]';
    PRINT @v_now;
    PRINT '================================================================================';
END;


