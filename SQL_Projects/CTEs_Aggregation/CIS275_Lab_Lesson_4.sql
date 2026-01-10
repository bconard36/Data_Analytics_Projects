/*
*******************************************************************************************
CIS275 at PCC
CIS275 Lab Week 4: using SQL SERVER  and various databases
*******************************************************************************************

                                   CERTIFICATION:

   By typing my name below I certify that the enclosed is original coding written by myself
without unauthorized assistance, such as seeing answers to versions of specific 
questions. If I use AI for any questions, I will list the tool used (ChatGPT, Gemini, etc)
and the prompt(s) I gave for each. I agree to abide by class restrictions and understand 
that if I have violated them, I may receive reduced credit (or none) for this assignment.

                CONSENT:   Billy Conard
                DATE:      July 17th, 2025

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

PRINT 'CIS 275, Lab Week 4, Question 1  [3 pts possible]:
Customer in each state
-----------------------------------
For this query, count the customers in each state.
Use the Examples database.

Correct results will have 17 rows and look like this:

States          # of Customers
--------------- ---------------
AK				1
AR				1
CA				1
GA				1
...
NM				1
OR				3
RI				1
TX				1
WA				4
WY				1
' + CHAR(10)
GO

--
USE Examples;

SELECT  CONVERT(varchar(2), CustState) AS "States",
        CONVERT(varchar(3), COUNT(CustID)) AS "# of Customers"
FROM Customers
GROUP By CustState;
--

GO

PRINT 'CIS 275, Lab Week 4, Question 2  [3 pts possible]:
Discount
-------
Your manager wants you to extract/calculate the following data in the AP database:
Number of invoices submitted by a vendor.
Average invoice amount.
Total Invoice calculated for all invoices.
Calculating a 10% discount on Total Invoice.
The balance after applying discounts.
Format columns with names and formats as below.

The correct output should have 34 rows

Vendor ID   # Invoices  Avg Invoice Amnt Total Invoice 10% Discount Balance
----------- ----------- ---------------- ------------- ------------ ----------
34          2           $600.06          $1,200.12     $120.01      $1,080.11
37          3           $188.00          $564.00       $56.40       $507.60
48          1           $856.92          $856.92       $85.69       $771.23
72          2           $10,963.66       $21,927.31    $2,192.73    $19,734.58
...
122         9           $2,575.33        $23,177.96    $2,317.80    $20,860.16
123         47          $93.15           $4,378.02     $437.80      $3,940.22
' + CHAR(10)
GO
--

--
USE AP;

SELECT CAST(VendorID AS varchar(4)) AS "Vendor ID",
       CAST(COUNT(InvoiceID) AS varchar(3)) AS "# Invoices",
       '$' + CONVERT(varchar(10), AVG(InvoiceTotal), 1) AS "Avg Invoice Amnt",
       '$' + CONVERT(varchar(10), SUM(InvoiceTotal), 1) AS "Total Invoice",
       '$' + CONVERT(varchar(10), SUM(InvoiceTotal) / 10, 1) AS "10% Discount",
       '$' + CONVERT(varchar(10), SUM(InvoiceTotal - (InvoiceTotal / 10)), 1) AS "Balance"
FROM Invoices
GROUP BY VendorID
ORDER BY VendorID;

-- Originally had the following for the Balance Column, where the balance is calculated after applying the discounts:
--
-- '$' + CONVERT(varchar(10), ROUND(SUM(InvoiceTotal) - SUM(InvoiceTotal) / 10, 2), 1) AS "Balance"
--
-- But, after finishing Question 6, I thought I could condense this into one SUM instead of two. I was able to yield
-- the same results, with a somewhat less cluttered SELECT statement. Also, I found the ROUND function was not needed
-- because of the CONVERT method. I removed the ROUND function to further clean up the statement, and yielded the same
-- results.

GO

PRINT 'CIS 275, Lab Week 4, Question 3 [3 pts possible]:
Selecting Vendors
--------------
Your manager wants to know the number of invoices that vendors submitted. 
They want to see the vendors whose vendor ID is between 110 to 140 
   and whose total sales are greater than $1000.
Show the largest numbers first.
You need to use AP database.

Correct results will look like this:

Vendor ID   Number of Invoices
----------- ------------------
123         47
122         9
121         8
110         5
113         1
119         1
' + CHAR(10)
GO

--
USE AP;

SELECT CONVERT(varchar(3), VendorID) AS "Vendor ID",
       CONVERT(varchar(2), COUNT(InvoiceID)) AS "Number of Invoices"
FROM Invoices
WHERE VendorID >= 110 AND VendorID <= 140
GROUP BY VendorID
HAVING SUM(InvoiceTotal) > 1000
ORDER BY COUNT(InvoiceID) DESC;
--

GO

PRINT 'CIS 275, Lab Week 4, Question 4  [3 pts possible]:
MIN & MAX
---------
Use AP database for this query.
Calculate the number of invoices each vendor has submitted. 
Calculate the first 5 lowest and highest payment amounts by vendor.
Format the columns with proper names. Insert a dollar sign.

Vendor ID   # Invoices  Min Payment Max Payment
----------- ----------- ----------- -----------
34          2           $116.54     $1083.58
37          3           $0.00       $224.00
48          1           $856.92     $856.92
72          2           $0.00       $21842.00
80          2           $0.00       $175.00
' + CHAR(10)

GO

--
USE AP;

SELECT TOP 5
       CONVERT(varchar(3), VendorID) AS "Vendor ID",
       CONVERT(varchar(2), COUNT(InvoiceID)) AS "# Invoices",
       '$' + CONVERT(varchar(10), MIN(PaymentTotal)) AS "Min Payment",
       '$' + CONVERT(varchar(10), MAX(PaymentTotal)) AS "Max Payment"
FROM Invoices
GROUP BY VendorID
ORDER BY VendorID;
--

GO



PRINT 'CIS 275, Lab Week 4, Question 5 [3 pts possible]:
Sales Report
------------
Produce a report showing sales reps'' ID, their last names, and the amount of sales for 2015.
Display them in last name order.
You need to use JOIN for this problem.
Use Examples database for this query.
Correct results will look like this:

Rep ID      Rep Last Name Year Total Sales
----------- ------------- ---- ---------------
5           Kramer        2015 $422,847.86
3           Markasian     2015 $1,132,744.56
2           Martinez      2015 $974,853.81
1           Thomas        2015 $923,746.85
4           Winters       2015 $655,786.92
' + CHAR(10)

GO


--
USE Examples;

SELECT CONVERT(varchar(2), SR.RepID) AS "Rep ID",
       CONVERT(varchar(20), RepLastName) AS "Rep Last Name",
       CONVERT(varchar(4), SalesYear) AS "Year",
       '$' + CONVERT(varchar(15), SUM(ST.SalesTotal), 1) AS "Total Sales"
FROM SalesReps SR
    JOIN SalesTotals ST
        ON SR.RepID = ST.RepID
WHERE ST.SalesYear = '2015'
GROUP BY SR.RepID, RepLastName, SalesYear
ORDER BY RepLastName;
--

GO

PRINT 'CIS 275, Lab Week 4, Question 6  [3 pts possible]:
Price of items ordered
----------------------
Calculate the sum of the price of all items ordered for each product.
Use the OrderItems table in the MyGuitarShop database.
Make sure you subtract the price of the item by the discount amount, 
  and then multiply that by the quantity of the items. Make sure your 
  order of operations is correct in this calculation because it will matter!
Format your report as below.

Product ID  Item Price Total
----------- ----------------
1           $8,457.12      
2           $10,071.60     
3           $5,039.91      
4           $2,039.97      
5           $979.98        
6           $7,339.50      
7           $749.98        
8           $911.37        
9           $506.30        
10          $1,793.00   
' + CHAR(10)
GO


--
USE MyGuitarShop;

SELECT CONVERT(varchar(3), ProductID) AS "Product ID",
       '$' + CONVERT(varchar(10), SUM((ItemPrice - DiscountAmount) * Quantity), 1) AS "Item Price Total"
FROM OrderItems
GROUP BY ProductID;
--


GO

PRINT 'CIS 275, Lab Week 4, Question 7  [3 pts possible]:
Total Price Using Rollup
------------------------
Modify problem 6 to also show the total for all products combined.
Use the ROLLUP Operator (Murach page 172 (2019) or 149 (2022)) to do so.
Correct results will be like this:

Product ID  Item Price Total
----------- --------------------
1           $8,457.12
2           $10,071.60
3           $5,039.91
4           $2,039.97
5           $979.98
6           $7,339.50
7           $749.98
8           $911.37
9           $506.30
10          $1,793.00
NULL        $37,888.73
' + CHAR(10)
GO


--
USE MyGuitarShop;

SELECT CONVERT(varchar(3), ProductID) AS "Product ID",
       '$' + CONVERT(varchar(10), SUM((ItemPrice - DiscountAmount) * Quantity), 1) AS "Item Price Total"
FROM OrderItems
GROUP BY ProductID WITH ROLLUP;
--
GO


PRINT 'CIS 275, Lab Week 4, Question 8  [3 pts possible]:
Total Using ROLLUP
------------------------------
Calculate the complete total per date for vendor 123 using the ROLLUP 
  Operator (Page 172 or 149 Murach).
Use AP database for this query.
There will be 39 records.
Format your report as below. A label for the bottom total is optional.

Invoice Date Invoice Total
------------ --------------------
2015-12-10   $40.20              
2015-12-13   $138.75             
2015-12-16   $202.95     
. . .
2016-03-30   $22.57              
2016-04-02   $127.75 
TOTAL        $4,378.02  
' + CHAR(10)

GO

--
USE AP;

SELECT CONVERT(char(12), InvoiceDate, 023) AS "Invoice Date",
       '$' + CONVERT(varchar(10), SUM(InvoiceTotal), 1) AS "Invoice Total"
FROM Invoices
WHERE VendorID = '123'
GROUP BY ROLLUP(InvoiceDate);
--

GO

PRINT 'CIS 275, Lab Week 4, Question 9  [3 pts possible]:
Customer Orders
--------------------
Using JOIN find customers who have placed orders that have 2 or more different items in them.
Format your report with approriate spacing and column numbers. 
You will be using the MyGuitarShop database.
Correct results will have 5 rows that look like this:

CustomerID  Customer Last Name Order ID    Items in Order
----------- ------------------ ----------- --------------
1           Sherwood           3           2
6           Wilson             7           3
14          Morasca            16          2
27          Whobrey            31          2
35          Caudy              41          2

' + CHAR(10)



GO


--
USE MyGuitarShop;

SELECT CONVERT(varchar(2), c.CustomerID) AS "CustomerID",
       CONVERT(varchar(25), LastName) AS "Customer Last Name",
       CONVERT(varchar(3), o.OrderID) AS "Order ID",
       CONVERT(varchar(2), COUNT(ProductID)) AS "Items in Order"
FROM Customers c
    JOIN Orders o
        ON c.CustomerID = o.CustomerID
    JOIN OrderItems oi
        ON o.OrderID = oi.OrderID
GROUP BY c.CustomerID, LastName, o.OrderID
HAVING COUNT(ProductID) > 1;
-- Quantity was used first, but did not distinguish between different items. Only reflected the amount, or count. Try
-- using COUNT(ProductID) instead. This way, the "Items in Order" column will reflect the quantity of each unique
-- ProductID instead of the total quantity of items ordered. Specify the specific count condition in HAVING not WHERE
-- (because of the use of the aggregate function, can't have aggregate functions in WHERE clause).
--

GO

PRINT 'CIS 275, Lab Week 4, Question 10  [3 pts possible]:
Finally, an easy one:-)
---------------------
Calculate the total sales for the SalesTotal.
Use Examples database.

Total Sales
--------------------
$8,900,668.14     
' + CHAR(10)

GO

--
USE Examples;

SELECT '$' + CONVERT(varchar(15), SUM(SalesTotal), 1) AS "Total Sales"
FROM SalesTotals;
--

GO
-------------------------------------------------------------------------------------
-- This is an anonymous program block. DO NOT CHANGE OR DELETE.
-------------------------------------------------------------------------------------
BEGIN
    PRINT '|---' + REPLICATE('+----',15) + '|';
    PRINT ' End of CIS275 Lab Week 4' + REPLICATE(' ',50) + CONVERT(CHAR(12),GETDATE(),101);
    PRINT '|---' + REPLICATE('+----',15) + '|';
END;


