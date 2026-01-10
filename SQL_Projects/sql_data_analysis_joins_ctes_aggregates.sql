/*
*******************************************************************************************
CIS275 at PCC
CIS275 Lab Week 6: using SQL SERVER and various databases
*******************************************************************************************

                                   CERTIFICATION:

   By typing my name below I certify that the enclosed is original coding written by myself
without unauthorized assistance, such as seeing answers to versions of specific 
questions. If I use AI for any questions, I will list the tool used (ChatGPT, Gemini, etc)
and the prompt(s) I gave for each. I agree to abide by class restrictions and understand 
that if I have violated them, I may receive reduced credit (or none) for this assignment.

                CONSENT:   Billy Conard
                DATE:      August 1st, 2025

*******************************************************************************************
*/

GO
PRINT '|---' + REPLICATE('+----',15) + '|'
PRINT 'Read the questions below and insert your queries where prompted. 
For the entire term, your results should match the samples shown, though DO NOT force it by 
  using the sample data in your queries since your queries must work when new data is added or changed.  
For example, if the sample shows results only for CustID 100, do not use WHERE CustID = 100.
  
When you are finished, you should be able to run the file as a script to execute all answers
  sequentially (without errors!).' + CHAR(10)
PRINT 'Queries should be well-formatted. SQL is not case-sensitive, but it is good form to
  capitalize keywords and to capitalize table names as they appear in the database; you should
  also put each projected column on its own line and use indentation for neatness. Example:

   SELECT Name,
          CustomerID AS "Customer ID"  -- Always use double quotes for aliases
   FROM   CUSTOMER
   WHERE  CustomerID < 106;            -- All SQL statements should end with a semicolon

Whatever format you choose for your queries, make sure that it is readable and consistent.

Place the name of the database on the top of each query. 
Format all queries with the column names in the sample.

There are several ways to solve many problems. 
  Unless specified to use a particular one, pick one that works for you.

Be sure to remove the double-dash comment indicator when you insert your code!';
PRINT '|---' + REPLICATE('+----',15) + '|' + CHAR(10) + CHAR(10)
GO



PRINT 'CIS275, Lab Week 6, Question 1  [3 pts possible]:
Display the list of orders that only have one item. 
Use the ProductOrders database. 
Format your columns accordingly. 
There should be 29 records. 

OrderID     Item ID     Quantity
----------- ----------- --------
19          5           1
32          7           3
70          1           1
89          4           1
...
703         4           1
773         10          2
827         6           1
' + CHAR(10)
-- Find the orders that only have one item. Quantity can be more than one, but item id count needs to be 1. Had a
-- similar query in a previous lab.

USE ProductOrders;

SELECT OrderID AS "OrderID",
       ItemID AS "Item ID",
       Quantity AS "Quantity"
FROM OrderDetails
WHERE OrderID IN (SELECT OrderID
                  FROM OrderDetails
                  GROUP BY OrderID
                  HAVING COUNT(ItemID) = 1)
ORDER BY OrderID;

--

GO
PRINT 'CIS275, Lab Week 6, Question 2  [3 pts possible]:
Write a common table expression to identify Vendors who have some Total Credit. 
Also display the total number of all their invoices. 
The AP database will be used for this problem. 

Vendor ID   Vendor Name                    Total Credit    NBR_Invoices
----------- ------------------------------ --------------- ------------
110         Malloy Lithographing Inc       $3,495.95       5
121         Zylka Design                   $200.00         8 
'+ CHAR(10)

GO
-- Find vendors who have some total credit. Invoices table in AP has Credit Total, Invoices, and Vendor ID.
-- Vendors table has vendor name data.

USE AP;

WITH Vendor AS
    (
        SELECT VendorID,
               VendorName
        FROM Vendors
    ),
    Totals AS
    (
        SELECT VendorID,
               SUM(CreditTotal) AS "Total Credit",
               COUNT(InvoiceNumber) AS "NBR_Invoices"
        FROM Invoices
        GROUP BY VendorID
        HAVING SUM(CreditTotal) > 0
    )
SELECT CONVERT(varchar(5), V.VendorID) AS "Vendor ID",
       CONVERT(varchar(25), V.VendorName) AS "Vendor Name",
       '$' + CONVERT(varchar(10), "Total Credit", 1) AS "Total Credit",
       CONVERT(varchar(2), "NBR_Invoices") AS "NBR_Invoices"
FROM Vendor V
    JOIN Totals T
        ON V.VendorID = T.VendorID
ORDER BY V.VendorID;
--


GO
PRINT 'CIS275, Lab Week 6, Question 3  [3 pts possible]:
Your manager wants you to provide the number of orders which were placed between 
  Dec 1, 2015 and April 1, 2016 each day any orders were placed. 
Show the complete names of each customer in date order.
Use the ProductOrders database.
Hint: Use the DATENAME Function (Ch 9 Murach) to format the dates.

Date                           Customer Name             # Orders
------------------------------ ------------------------- -----------
Monday, December 21, 2015      Dakota Baylee             1
Friday, December 25, 2015      Erick Kaleigh             1
Friday, December 25, 2015      Kaitlin Hostlery          1
Sunday, January 3, 2016        Samuel Jacobsen           3
Monday, January 4, 2016        Yash Randall              1
...
Saturday, March 19, 2016       Samuel Jacobsen           1
Monday, March 21, 2016         Kyle Marissa              1
Monday, March 21, 2016         Yash Randall              1
Friday, April 1, 2016          Korah Blanca              1
'+ CHAR(10)
-- Find the number of orders placed per day during a range of dates.

USE ProductOrders;

SELECT DATENAME(weekday, OrderDate) + ', ' + DATENAME(month, OrderDate) + ' ' +
        DATENAME(day, OrderDate) + ', ' + DATENAME(year, OrderDate) AS "Date",
       CustFirstName + ' ' + CustLastName AS "Customer Name",
       CONVERT(varchar(2), COUNT(OrderID)) AS "# Orders"
FROM Customers c
    JOIN Orders o
        ON c.CustID = o.CustID
GROUP BY OrderDate, CustFirstName, CustLastName
HAVING OrderDate BETWEEN '2015-12-1' AND '2016-04-1'
ORDER BY OrderDate;
--
GO


GO
PRINT 'CIS275, Lab Week 6, Question 4  [3 pts possible]:
Find all customers who placed orders in 2014 but did not place any in 2016.
There are several good ways to solve this. Choose one.
Use the ProductOrders database.

CustID      Customer First Name Customer Last Name City
----------- ------------------- ------------------ ---------------
3           Johnathon           Millerton          New York
8           Deborah             Damien             Fresno
10          Kurt                Nickalus           Valencia
11          Kelsey              Eulalia            Sacramento
14          Gonzalo             Keeton             Fairfield
22          Rashad              Holbrooke          Fresno
24          Julian              Carson             San Francisco
.' + CHAR(10)
-- Customers who placed orders in 2014 but not in 2016.

USE ProductOrders;

SELECT CustID AS "CustID",
       CONVERT(varchar(20), CustFirstName) AS "Customer First Name",
       CONVERT(varchar(30), CustLastName) AS "Customer Last Name",
       CONVERT(varchar(30), CustCity) AS "City"
FROM Customers
WHERE CustID IN (SELECT CustID
                 FROM Orders
                 WHERE YEAR(OrderDate) = 2014
                 )
AND CustID NOT IN (SELECT CustID
                 FROM Orders
                 WHERE YEAR(OrderDate) = 2016
                 )
ORDER BY CustID;
--
GO
PRINT 'CIS275, Lab Week 6, Question 5  [3 pts possible]:
Do the previous questions again using a different technique. It might be
   solved using joins, subqueries, CTEs, EXCEPT, a combination of these, 
   or some other way.
Whichever you used in Q4, do not use that same way here.
   If Q4 had a subquery, no subquery here.
   If Q4 had a join, no join here.
   Etc.
Note that your results here should match your results in Q4.
' + CHAR(10)
-- First query used subqueries. Second query uses joins. Join customers and orders tables to find customers who placed
-- orders in 2014. Then, use a left outer join to include all rows from the first result set and join back to orders
-- table to find the orders dated in 2016 but where the CustID from the first result set is null. That will narrow
-- down the results to customers who only placed orders in 2014.

USE ProductOrders;

SELECT C.CustID AS "CustID",
       CONVERT(varchar(20), CustFirstName) AS "Customer First Name",
       CONVERT(varchar(30), CustLastName) AS "Customer Last Name",
       CONVERT(varchar(30), CustCity) AS "City"
FROM Customers C
    JOIN Orders O1
        ON O1.CustID = C.CustID
        AND YEAR(O1.OrderDate) = 2014
    LEFT JOIN Orders O2
        ON O2.CustID = C.CustID
        AND YEAR(O2.OrderDate) = 2016
WHERE O2.CustID IS NULL
ORDER BY CustID;
--

GO

GO

PRINT 'CIS275, Lab Week 6, Question 6  [3 pts possible]:
In which quarters have customers placed orders in 2015?
Show the number of orders and the total quantity placed then.
Use the ProductOrders database and show them in customer and quarter order.
Hint: Use DATEPART Function (Ch 9 Murach).

Customer Name             Year        Quarter     # Orders    Total Quantity
------------------------- ----------- ----------- ----------- --------------
Ania Irvin                2015        1           1           1
Dakota Baylee             2015        4           2           3
Derek Chaddick            2015        3           1           1
Erick Kaleigh             2015        4           1           2
...
Trisha Anum               2015        1           1           2
Yash Randall              2015        2           1           1
Yash Randall              2015        4           1           1
'+ CHAR(10)
-- For the year 2015, which quarters have customers placed orders, how many orders were placed and what's the quantity?
-- Display the distinct number (count) of orders each customer placed and the total quantity (sum) placed then. Order
-- by Customer Name, Year and Quarter. Group by needs to be used because of aggregate functions, make sure to group by
-- the DATEPART result of the year and quarter.

USE ProductOrders;

SELECT CONVERT(varchar(40), CustFirstName + ' ' + CustLastName) AS "Customer Name",
       CONVERT(varchar(4), DATEPART(year, OrderDate)) AS "Year",
       CONVERT(varchar(1), DATEPART(quarter, OrderDate)) AS "Quarter",
       CONVERT(varchar(1), COUNT(DISTINCT O.OrderID)) AS "# Orders",
       CONVERT(varchar(1), SUM(Quantity)) AS "Total Quantity"
FROM Customers C
    JOIN Orders O
        ON C.CustID = O.CustID
    JOIN OrderDetails OD
        ON OD.OrderID = O.OrderID
WHERE DATEPART(Year, OrderDate) = 2015
GROUP BY CustFirstName, CustLastName, DATEPART(year, OrderDate), DATEPART(quarter, OrderDate)
ORDER BY "Customer Name", "Quarter";
--
GO


GO
PRINT 'CIS275, Lab Week 6, Question 7  [3 pts possible]:
Write a query to find the products whose list price is greater than or equal to the 
  average list price of the products that are in category 3. 
Sort by the list price.
Use database MyGuitarShop.

ProductID   Product Name                             List Price CategoryID
----------- ---------------------------------------- ---------- -----------
7           Fender Precision                         799.99     2
10          Tama 5-Piece Drum Set with Cymbals       799.99     3
2           Gibson Les Paul                          1199.00    1
3           Gibson SG                                2517.00    1
'+ CHAR(10)
-- Similar query from a previous assignment. Use that as reference. Instead of finding the average list price of all
-- items, find the average list price of products with a categoryID of 3. Then filter for products whose price is
-- greater than or equal to that. Order by list price.

USE MyGuitarShop;

SELECT CONVERT(varchar(2), ProductID) AS "ProductID",
       CONVERT(varchar(40), ProductName) AS "Product Name",
       CAST(ListPrice AS DECIMAL(12, 2)) AS "List Price",
       CONVERT(varchar(2), CategoryID) AS "CategoryID"
FROM Products
WHERE ListPrice >= (SELECT AVG(ListPrice)
                    FROM Products
                    WHERE CategoryID = 3
                    )
ORDER BY ListPrice;
--
GO


GO
PRINT 'CIS275, Lab Week 6, Question 8  [3 pts possible]:
Display the difference between when the order was placed and when the order was shipped.
If it was never shipped, display 9999.
You need to use DATEDIFF and CASE (Ch 9 in Murach). 
Display the TOP 10 days late only.
Use ProductOrders for this problem.
Display the results as follows.

OrderID     CustID      Date Ordered Date Shipped Days Late
----------- ----------- ------------ ------------ -----------
824         1           04-01-2016                9999
827         18          04-02-2016                9999
829         9           04-02-2016                9999
180         24          12-25-2014   01-30-2015   36
...
548         2           11-22-2015   12-18-2015   26
158         9           12-04-2014   12-20-2014   16
'+ CHAR(10)
-- Find difference between Order Date and Shipped Date (Order Date (Days) - Shipped Date (Days)). Use DATEDIFF, which
-- will use the earlier date (date ordered) as the second arg, and the later date (date shipped) as the third arg.
-- First arg will be the unit we want the difference of (month, day, year); in this case - day. Make a case, or
-- condition, that if the ShippedDate IS NOT NULL, display the specified DATEDIFF value. If ShippedDate IS NULL, or
-- was never shipped, then display '9999'. Only display the top 10, order by "Days Late" in DESC order. Use this for
-- date formatting in output: CONVERT(CHAR(12), GETDATE(), 110).

USE ProductOrders;

SELECT TOP 10 CONVERT(varchar(4), OrderID) AS "OrderID",
              CONVERT(varchar(4), CustID) AS "CustID",
              CONVERT(CHAR(12), OrderDate, 110) AS "Date Ordered",
              CONVERT(CHAR(12), ShippedDate, 110) AS "Date Shipped",
    CASE
        WHEN ShippedDate IS NOT NULL
            THEN (DATEDIFF(day, OrderDate, ShippedDate))
        ELSE '9999'
    END AS "Days Late"
FROM Orders
ORDER BY "Days Late" DESC;
--
GO


GO
PRINT 'CIS275, Lab Week 6, Question 9  [3 pts possible]:
What orders were placed by each customer on their last order date? 
For example, Customer ID 1 has placed one orders on�6/23/15, 9/30/15 and 4/01/16.
We want the order number for the one that was placed on 4/01/16.
Use subquery to produce the output. 
Display the first 6 customers.
The ProductOrders database will be used for this problem.

CustID      OrderID     Date Ordered
----------- ----------- ------------
1           824         04/01/16    
2           802         03/21/16    
3           523         11/07/15    
4           494         10/10/15    
5           442         08/28/15    
6           606         12/25/15    
' + CHAR(10)
-- Customers placed multiple orders on different dates. Find the orders that were placed by each customer on their
-- last, or most recent order date (MAX). Only display the top 6 results. Use a subquery. Use this for Date Formatting:
-- CONVERT(CHAR(12), GETDATE(), 001)

USE ProductOrders;

SELECT TOP 6 CustID AS "CustID",
             CONVERT(varchar(5), OrderID) AS "OrderID",
             CONVERT(CHAR(12), OrderDate, 001) AS "Date Ordered"
FROM Orders O
WHERE OrderDate = (SELECT MAX(OrderDate)
                   FROM Orders O2
                   WHERE O.CustID = O2.CustID)
ORDER BY CustID;
--
GO



GO
PRINT 'CIS275, Lab Week 6, Question 10  [3 pts possible]:
Calculate the percent of total sales of each sales rep in 2014. 
The calculation will show the percentage of the total sales for each 
  rep compared to the company overall total sales for all years.
For example, if the overall sales for all years was $10,000 and
  rep''s total sales for 2014 was $1000, the percentage would be 10%.
Use both a subquery and JOIN. 
Use the Examples database.
Sort the results by the highest sales.

Rep ID Last Name  2014 Totals   % of Company Sales
------ ---------- ------------- ------------------
1      Thomas     $1,274,856.38 14.32%
3      Markasian  $1,032,875.48 11.60%
2      Martinez   $978,465.99   10.99%
' + CHAR(10)
-- Find the percentage of sales each sales rep accounted for in 2014 compared to the total sales of every sales rep
-- combined across all years. Use BOTH a subquery and a join. Rep Last Name will be in SalesReps Table. Join that to
-- SalesTotal Table. Use a subquery in the SELECT statement for calculations. Similar query from past lab, use that
-- for reference. Take the SalesTotal value from the ST table, multiply that by 100, then divide that amount by the
-- value returned from the subquery, where the SUM of ALL sales can be calculated. Concatenate a percentage sign to the
-- end of that result set. Order by Total Sales in descending order.

USE Examples;

SELECT CONVERT(varchar(2), SR.RepID) AS "Rep ID",
       CONVERT(varchar(20), SR.RepLastName) AS "Last Name",
       '$' + CONVERT(varchar(20), ST.SalesTotal, 1) AS "2014 Totals",
       CONCAT(CAST(ROUND((ST.SalesTotal * 100) /
           (SELECT SUM(SalesTotal)
            FROM SalesTotals), 2) AS varchar(10)), '%') AS "% of Company Sales"
FROM SalesReps SR
    JOIN SalesTotals ST
        ON ST.RepID = SR.RepID
WHERE ST.SalesYear = 2014
ORDER BY SalesTotal DESC;
--
GO



GO
-------------------------------------------------------------------------------------
-- This is an anonymous program block. DO NOT CHANGE OR DELETE.
-------------------------------------------------------------------------------------
BEGIN
    PRINT '|---' + REPLICATE('+----',15) + '|';
    PRINT ' End of CIS275 Lab Week 6' + REPLICATE(' ',50) + CONVERT(CHAR(12),GETDATE(),101);
    PRINT '|---' + REPLICATE('+----',15) + '|';
END;


