/*
*******************************************************************************************
CIS275 at PCC
CIS275 Lab Week 5: using SQL SERVER and various databases
The name of the database must be placed on the top of ALL queries. 
*******************************************************************************************

                                   CERTIFICATION:

   By typing my name below I certify that the enclosed is original coding written by myself
without unauthorized assistance, such as seeing answers to versions of specific 
questions. If I use AI for any questions, I will list the tool used (ChatGPT, Gemini, etc)
and the prompt(s) I gave for each. I agree to abide by class restrictions and understand 
that if I have violated them, I may receive reduced credit (or none) for this assignment.

                CONSENT:   Billy Conard
                DATE:      July 23rd, 2025

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

PRINT 'CIS 275, Lab Week 5, Question 1  [3 pts possible]:
Matching States
-------------
This week we focus on subqueries. 
To start, write a subquery to find vendors'' names, and other info 
    whose state matches the state of a vendor named ''Newbrige Book Clubs''.
Format the name and address to 23 characters each.
Use the AP database.

Vendor ID   State Vendor Name             Address
----------- ----- ----------------------- -----------------------
5           NJ    Newbrige Book Clubs     3000 Cindel Drive
27          NJ    Rich Advertising        12 Daniel Road
32          NJ    RR Bowker               PO Box 31
76          NJ    Simon Direct Inc        4 Cornwall Dr Ste 102
' + CHAR(10)

GO

--
USE AP;

SELECT CONVERT(varchar(2), VendorID) AS "Vendor ID",
       CONVERT(varchar(2), VendorState) AS "State",
       CONVERT(varchar(23), VendorName) AS "Vendor Name",
       CONVERT(varchar(23), VendorAddress1) AS "Address"
FROM Vendors
WHERE VendorState IN (SELECT VendorState
                     FROM Vendors
                     WHERE VendorName = 'Newbrige Book Clubs')
ORDER BY VendorID;
--

GO


PRINT 'CIS 275, Lab Week 5, Question 2  [3 pts possible]:
Run Time Minutes
---------
Write a SQL subquery to find the primary titles of the records whose 
    runtime minutes are more than the average runtime minutes. 
Return Primary Title and Runtime Minutes.
Use only subqueries and no joins. Do not hard-code any strings from the results.
You will be using IMDB database.
There will be 537,945 rows if you eliminate duplicate titles.
    Note that there is more than one way to eliminate duplicates.
	See the sample code in lesson 4 for two techniques.
Format the output with proper names. Truncate Primary Title to 90 characters.
The correct answer will be sorted and look like this:

Primary Title                                                                              Run Time Minutes
------------------------------------------------------------------------------------------ ----------------
----                                                                                       80
'' AV muri'' Fukada Nana 107 cmK kappu gingakei saikyo oppai muchakucha damashi momi         120
'' Horse Trials ''                                                                           120
!Women Art Revolution                                                                      83
"All in the Family" Retrospective                                                          90
"Are They All Yours?" Live Q & A                                                           72
"Bort g� de, stumma skrida de..."                                                          49
...
ZZ Top: Live at Montreux 2013                                                              81
ZZ Top: Live from Texas                                                                    122
Zzim                                                                                       101
ZZonk!! Splatt!!- the World of Children''s Comics                                           50
ZZZZZ                                                                                      51
' + CHAR(10)

--
USE IMDB;

SELECT CONVERT(varchar(90), primaryTitle) AS "Primary Title",
       CONVERT(varchar(4), runtimeMinutes) AS "Run Time Minutes"
FROM title_basics
WHERE runtimeMinutes > (SELECT AVG(runtimeMinutes)
                        FROM title_basics)
GROUP BY primaryTitle, runtimeMinutes
ORDER BY "Primary Title";
--

GO

PRINT 'CIS 275, Lab Week 5, Question 3  [3 pts possible]:
MIN Price
---------- 
Use a subquery and no joins to find for each order which products 
   had the lowest quantity.  
Use the MyGuitarShop database.
Format the columns with proper columns names.
Correct answers will have 45 rows and will look like this:

Order#      Product ID  Quantity
----------- ----------- -----------
1           2           1
2           8           1
3           1           1
3           9           1
4           2           2
...
40          6           1
41          6           1
41          8           1
' + CHAR(10)

GO
-- For each order placed, find the products that had the lowest quantity among all products in that order.
-- Select OrderID, ProductID, and Quantity from the OrderItems table, then use a subquery to return the minimum
-- quantity value for each specific order.
--
USE MyGuitarShop;

SELECT CONVERT(varchar(3), OrderID) AS "Order#",
       CONVERT(varchar(3), ProductID) AS "Product ID",
       CONVERT(varchar(2), Quantity) AS "Quantity"
FROM OrderItems O
WHERE Quantity = (SELECT MIN(OI.Quantity)
                  FROM OrderItems OI
                  WHERE OI.OrderID = O.OrderID)
GROUP BY OrderID, ProductID, Quantity;
--
 
GO

PRINT 'CIS 275, Lab Week 5, Question 4  [3 pts possible]:
Customers
----------
Write a SQL subquery to find those customers whose ID is not in orders 310-700.
Write a SQL subquery and no joins to find those customers whose ID is not in orders 310-700.
The database is ProductOrders.
Format columns with appropriate names.
There will be 11 rows. Return the fields that are in the output below.

Customer ID Last Name       First Name      City
----------- --------------- --------------- --------------------
8           Damien          Deborah         Fresno
10          Nickalus        Kurt            Valencia
11          Eulalia         Kelsey          Sacramento
...
24          Carson          Julian          San Francisco
25          Story           Kirsten         Washington
' + CHAR(10)

GO

--
USE ProductOrders;

SELECT CONVERT(varchar(2), CustID) AS "Customer ID",
       CONVERT(varchar(20), CustLastName) AS "Last Name",
       CONVERT(varchar(15), CustFirstName) AS "First Name",
       CONVERT(varchar(25), CustCity) AS "City"
FROM Customers C
WHERE CustID NOT IN (SELECT CustID
                    FROM Orders O
                    WHERE OrderID BETWEEN 310 AND 700)
ORDER BY CustID;
--

GO




GO
PRINT'CIS 275, Lab 5, Question 5 [3 pts possible]
High Prices
-----------
Your manager who is Italian wants you to find all products whose 
   list price is more than half the average list price. That is, 
   if the average was $1000, show all those with prices over $500.
Use MyGuitarShop. 
Write a subquery to produce the following output, using Italian date format.
There should be 8 rows.
Hint: Remember Dates_CONVERT from module 2.

Product Name                             List Price      Category ID Date Added
---------------------------------------- --------------- ----------- ------------
Fender Stratocaster                      $699.00         1           30-10-2015  
Gibson Les Paul                          $1,199.00       1           05-12-2015  
Gibson SG                                $2,517.00       1           04-02-2016  
...
Tama 5-Piece Drum Set with Cymbals       $799.99         3           30-07-2016  
' + CHAR(10)

-- Find the average list price. Divide that by 2. Then find all products whose list price is greater than that amount.
-- CONVERT(CHAR(12), GETDATE(), 105) - Italian Date Format to use. Use the CONVERT(varchar, MONEY, 1) method for price
-- formatting.
USE MyGuitarShop;

SELECT CONVERT(varchar(50), ProductName) AS "Product Name",
       '$' + CONVERT(varchar(10), ListPrice, 1) AS "List Price",
       CONVERT(varchar(2), CategoryID) AS "Category ID",
       CONVERT(CHAR(12), DateAdded, 105) AS "Date Added"
FROM Products
WHERE ListPrice > (SELECT (AVG(ListPrice) / 2)
                   FROM Products)
ORDER BY CategoryID;
--


GO

PRINT 'CIS 275, Lab Week 5, Question 6 [3 pts possible]:
Young Writers
-------------
Review the following subquery:'
USE IMDB 
SELECT	TOP 10	CAST(primaryName AS CHAR(20)) AS primaryName,
			birthYear AS DOB,
			(SELECT		COUNT(*) AS "Nbr Written"
			FROM		title_writers AS TD
			WHERE		nconst = NB.nconst
			) AS WRITTEN
FROM		name_basics AS NB
WHERE		birthYear > 2000
ORDER BY	WRITTEN DESC;
PRINT '
1- In a paragraph, explain the purpose of the above query. What does it do?
2- Revise the query to produce the following result. 
Do not use any joins.
Note that this shows it in the order of the highest number directed.

NAME                 DOB         AGE         WRITTEN     DIRECTED
-------------------- ----------- ----------- ----------- -----------
Chase Ramos          2001        23          118         128
Eric Martinez        2001        23          74          92
...
Miranda Laird        2004        20          8           14
Kacey Fifield        2005        19          0           11
' + CHAR(10)

-- EXPLAIN THE PURPOSE OF THE ABOVE QUERY. WHAT DOES IT DO?
-- This query returns the top 10 writers, born after the year 2000, who have written the most projects/titles. The query
-- selects each person's name and birth year, and the number of titles they have written, which is calculated in the
-- subquery. The subquery counts how many times a person's nconst appears in the title_writers table by correlating it
-- with the nconst from the name_basics table. The results are then sorted in descending order by the number of titles
-- written.

-- To revise the query, use the same method as finding the writer titles but use title_directors instead. Change table
-- aliases if needed. Sort by most directed titles in descending order. When CONVERT or CAST is used on WRITTEN and
-- DIRECTED (the two subqueries in the SELECT statement), the order of the results and the values in each row
-- are incorrect. Keep current data types for those specific subqueries and do not convert for now.
-- Lab instructions in D2L state:
-- "Note that the sample results for Q6 were true in 2024. Everyone is now is older, so all ages are different."
-- Use current year for results, not 2024.
--
USE IMDB;

SELECT	TOP 10	CAST(primaryName AS CHAR(20)) AS "NAME",
			CONVERT(varchar(4), birthYear) AS "DOB",
			CONVERT(varchar(2), (2025 - birthYear)) AS "AGE",
                (SELECT	COUNT(*) AS "Nbr Written"
                FROM	title_writers AS TW
                WHERE	TW.nconst = NB.nconst
                ) AS "WRITTEN",
                (SELECT COUNT(*) AS "Nbr Directed"
                 FROM title_directors AS TD
                 WHERE TD.nconst = NB.nconst
                ) AS "DIRECTED"
FROM		name_basics AS NB
WHERE		birthYear > 2000
ORDER BY	"DIRECTED" DESC;
--

GO

PRINT 'CIS 275, Lab Week 5, Question 7  [3 pts possible]:
Only One Item
-------------
Display the orders that only have one product.
	This does not mean a quantity of 1.
The database name is MyGuitarShop.
Use subqueries, not joins to find the result.
Format your output by proper column names.

Order ID    Item ID     Product ID  Quantity
----------- ----------- ----------- -----------
1           1           2           1
2           2           8           1
4           5           2           2
...
37          42          1           1
38          43          2           2
39          44          6           1
40          45          6           1
' + CHAR(10)

GO

--
USE MyGuitarShop;

SELECT CONVERT(varchar(3), OrderID) AS "Order ID",
       CONVERT(varchar(3), ItemID) AS "Item ID",
       CONVERT(varchar(3), ProductID) AS "Product ID",
       CONVERT(varchar(1), Quantity) AS "Quantity"
FROM OrderItems
WHERE OrderID IN (SELECT OrderID
                 FROM OrderItems
                 GROUP BY OrderID
                 HAVING COUNT(*) = 1
                )
ORDER BY OrderID;
--

GO


PRINT 'CIS 275, Lab Week 5, Question 8  [3 pts possible]:
Write a subquery to display the sales reps whose total sales exceeded 800,000 
    in the years after 2014 in highest Total Sales order.
The database name is Examples.

Rep ID      Total Sales     Sales Year
----------- --------------- ----------
3           $1,132,744.56   2015
2           $974,853.81     2015
1           $923,746.85     2015
2           $887,695.75     2016
' + CHAR(10)

GO
-- The query below yields the correct output, but the subquery doesn't really help. Without the extra AND statements
-- outside the subquery, the result is not correct and prints a RepID who's total sales is less than 800000 and in
-- 2014. So, I can move the subquery from the WHERE clause to the FROM clause, and use the FROM clause to return a
-- derived table with RepID's who have total sales greater than $800,000 after the year 2014.

-- USE Examples;
--
-- SELECT CONVERT(varchar(2), RepID) AS "Rep ID",
--        '$' + CONVERT(varchar(15), SalesTotal, 1) AS "Total Sales",
--        CONVERT(varchar(4), SalesYear) AS "Sales Year"
-- FROM SalesTotals
-- WHERE RepID IN (SELECT RepID
--                   FROM SalesTotals
--                   WHERE SalesYear > 2014
--                   GROUP BY RepID
--                   HAVING SUM(SalesTotal) > 800000
--                   )
--   AND SalesTotal > 800000
--   AND SalesYear > 2014
-- ORDER BY SalesTotal DESC;

USE Examples;

SELECT CONVERT(varchar(2), RepID) AS "Rep ID",
       '$' + CONVERT(varchar(15), TotalSales, 1) AS "Total Sales",
       CONVERT(varchar(4), SalesYear) AS "Sales Year"
FROM (SELECT RepID,
             SalesYear,
             SUM(SalesTotal) AS TotalSales
      FROM SalesTotals
      WHERE SalesYear > 2014
      GROUP BY RepID, SalesYear
      HAVING SUM(SalesTotal) > 800000
                  ) AS Results --Table alias needs to be used for subqueries in the FROM clause.
ORDER BY TotalSales DESC;
--

GO

PRINT 'CIS 275, Lab Week 5, Question 9  [3 pts possible]:
Discussion posts
--------------------
Alan Turing has posted a few messages about the Discussions. 
Show only the first 55 characters of these messages.
Use only subqueries, no joins.
Do not hard code Alan''s user ID.
You will be using the Discussions database. 
I did some editing because of several apostrophes which were part of the results:

Title                     Alan''s Content
------------------------- -------------------------------------------------------
Lesson 6 Discussion       <p>Yes Lee, what''s REALLY exensive is human labor. That
Discussion                <p>"Some people are just better than others at certain 
Lesson#4 Discussion       <p>I don''t necessarily disagree with you, but that rais
Lesson#4 Discussion       <p>Your Uncle has probably not picked up a book on Algo
Lession 9 Discussion      <p>I think it''s a great example of Selection, Melissa :
' + CHAR(10)

GO

--
USE Discussions;

SELECT CONVERT(varchar(30), Title) AS "Title",
       CONVERT(varchar(55), Content) AS "Alan's Content"
FROM Posts
WHERE FK_UserID = (
    SELECT UserID
    FROM Profiles
    WHERE FirstName = 'Alan'
      AND LastName = 'Turing'
    )
  AND Title LIKE '%Discussion%';
--

GO

PRINT 'CIS 275, Lab Week 5, Question 10  [3 pts possible]:
Sales Reps
---------------------
Use subqueries to show the top 4 sales reps who had the highest total sales.
Do not use join or hard code sales reps ID or names.
You will be using the Examples database.
The correct results will look like this:

Rep ID      Rep Last Name   Total Sales
----------- --------------- ---------------------
2           Martinez        2841015.55
1           Thomas          2697771.96
3           Markasian       2165620.04
4           Winters         728230.29
                              
' + CHAR(10)

GO

--
USE Examples;

SELECT TOP 4 CONVERT(varchar(2), RepID) AS "Rep ID",
             CONVERT(varchar(15), RepLastName) AS "Rep Last Name",
             (SELECT CAST(ROUND(SUM(SalesTotal), 2) AS DECIMAL(12, 2))
              FROM SalesTotals ST
              WHERE ST.RepID = SR.RepID) AS "Total Sales"
FROM SalesReps SR
ORDER BY "Total Sales" DESC;
--


GO
-------------------------------------------------------------------------------------
-- This is an anonymous program block. DO NOT CHANGE OR DELETE.
-------------------------------------------------------------------------------------
BEGIN
    PRINT '|---' + REPLICATE('+----',15) + '|';
    PRINT ' End of CIS275 Lab Week 5' + REPLICATE(' ',50) + CONVERT(CHAR(12),GETDATE(),101);
    PRINT '|---' + REPLICATE('+----',15) + '|';
END;


