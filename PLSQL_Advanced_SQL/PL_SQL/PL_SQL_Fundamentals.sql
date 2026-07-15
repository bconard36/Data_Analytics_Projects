/*
CIS276  Lab 5 Q1:
NAME:  Billy Conard
DATE:  05/07/2026

Write a PL/SQL program that will declare two variables, vPartid and vDescription, 
and assign each values of 5001 and 'Gonzo' respectively.  Format your output line as 
"Part Number <vPartid> has a description of <vDescription>". No exception processing 
needed. Note: this does not require a SQL statement. Produce an output line that 
looks like the following line: 

Part Number 5001 has a description of Gonzo
*/

-- RESET SALESDB BEFORE STARTING 
SET SERVEROUTPUT ON FORMAT WRAPPED

DECLARE

    vPartID      INVENTORY.PartID%TYPE      := 5001;  
    vDescription INVENTORY.Description%TYPE := 'Gonzo';

BEGIN

    DBMS_OUTPUT.PUT_LINE('Part Number ' || vPartID 
            || ' has a description of ' || TRIM(vDescription));

END;
/
  
  
/*
CIS276  Lab 5 Q2

Write a PL/SQL program that will include an SQL statement that finds the description 
and price for partid 1001.  Declare variables vDescription and vPrice to hold the 
values you find; use another variable vPartid to store the partid above.  Embed an 
SQL statement that will select the description and price values from the inventory 
table INTO the variables vDescription and vPrice.  The WHERE clause should not check 
for the constant 1001, but rather check for the value in the variable vPartid. Use 
the OTHERS EXCEPTION to display the SQLERRM. Format your output line as 
"Part Number <vPartid> has a description of <vDescription> and costs <vPrice>". 
Your output line should look like: 

Part Number 1001 has a description of doodad and costs $10.00
*/

SET SERVEROUTPUT ON FORMAT WRAPPED

DECLARE
    
    vPartID      INVENTORY.PartID%TYPE := 1001;
    vDescription INVENTORY.Description %TYPE;
    vPrice       INVENTORY.Price%TYPE; 

BEGIN

    SELECT INVENTORY.Description, -- Extra white space in output
           INVENTORY.Price -- Conversion won't work here (number to char conversion err)
    INTO   vDescription, vPrice
    FROM   INVENTORY
    WHERE  INVENTORY.PartID = vPartID;
    
    DBMS_OUTPUT.PUT_LINE('Part Number ' || vPartid || ' has a description of ' || 
    TRIM(vDescription) || ' and costs' || TO_CHAR(vPrice, '$99.99')); -- Format/convert output here 

EXCEPTION

    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Lab5 q2 OTHERS EXCEPTION');
        DBMS_OUTPUT.PUT_LINE(SQLERRM);

END;
/

  
/*
CIS276  Lab 5 Q3:

Write a PL/SQL program that includes an SQL statement that finds the partid, 
description, and price of the highest priced item in our inventory. Format your output 
line as "Part Number <vPartid> described as <vDescription> is the highest priced item 
in inventory at <vPrice>". Do not handle the case of there being two parts with the 
same, highest price - save that for the next question. Use the OTHERS EXCEPTION to 
display the SQLERRM. Your output line should look like the following: 

Part Number 9999 described as XXXXXX is the highest priced item in inventory at $9999.999 
*/

SET SERVEROUTPUT ON FORMAT WRAPPED

DECLARE

    vPartID        INVENTORY.PartID%TYPE;
    vDescription   INVENTORY.Description%TYPE;
    vPrice         INVENTORY.Price%TYPE;

BEGIN
    /* 
        Similar data type and white space issues here.
        Format TO_CHAR() and TRIM() in DBMS_OUTPUT statement 
    */
    SELECT INVENTORY.PartID, 
           INVENTORY.Description,
           INVENTORY.Price
    INTO   vPartID,
           vDescription,
           vPrice
    FROM   INVENTORY
    WHERE  INVENTORY.Price = (
                SELECT MAX(INVENTORY.Price)
                FROM   INVENTORY
                );
    
    DBMS_OUTPUT.PUT_LINE('Part Number ' || vpartID || ' described as ' || TRIM(vDescription) || 
                        ' is the highest priced item in inventory at' || TO_CHAR(vPrice, '$99.99'));

EXCEPTION

    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Lab5 q3 OTHERS EXCEPTION');
        DBMS_OUTPUT.PUT_LINE(SQLERRM);

END;
/

  
/*
CIS276  Lab 5 Q4:

What would happen if there were two or more items that have that same highest price?  
(Let's say that the highest price is $80 and there are two or more items that have 
that price.)  Write the PL/SQL program that would handle this situation.  This 
requires using a CURSOR and a LOOP with a FETCH.  Use the OTHERS EXCEPTION to display 
the SQLERRM. Test your code for more than one item with the highest price.  Update 
your table in order to test this condition (you can change a price in one of the 
already existing partid's to match the maximum price, or INSERT a new row).
*/
SET SERVEROUTPUT ON FORMAT WRAPPED

/* 
TEST DUPLICATE VALUES 
UPDATE an existing price to return multiple values
*/
-- Inspect all price values 
--SELECT *
--FROM   INVENTORY;

-- Update one value to the max price
UPDATE INVENTORY
SET    price = (
    SELECT MAX(INVENTORY.Price)
    FROM   INVENTORY
)
WHERE  INVENTORY.PartID = 1009;

-- Confirm Update
--SELECT *
--FROM   INVENTORY
--WHERE  INVENTORY.PartID = 1009;

COMMIT;

-- Re-Run Program to ensure 2 lines output
DECLARE

    CURSOR max_price_cursor IS 
        SELECT INVENTORY.PartID,
               INVENTORY.Description,
               INVENTORY.Price
        FROM   INVENTORY
        WHERE  INVENTORY.Price = (
            SELECT MAX(INVENTORY.Price)
            FROM   INVENTORY
        );
    
    vMaxPrice      max_price_cursor%ROWTYPE;

BEGIN

    OPEN max_price_cursor;
    
    FETCH max_price_cursor INTO vMaxPrice;
    
    WHILE (max_price_cursor%FOUND) LOOP
    
        DBMS_OUTPUT.PUT_LINE('Part Number ' || vMaxPrice.PartID || ' described as ' || TRIM(vMaxPrice.Description) || 
                    ' is the highest priced item in inventory at' || TO_CHAR(vMaxPrice.Price, '$99.99'));
                    
        FETCH max_price_cursor INTO vMaxPrice;
        
    END LOOP;
    
    CLOSE max_price_cursor;

EXCEPTION

    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Lab5 q4 OTHERS EXCEPTION');
        DBMS_OUTPUT.PUT_LINE(SQLERRM);

END;
/

-- Set the price back to 70 after testing
UPDATE INVENTORY
SET  price = 70
WHERE INVENTORY.PartID = 1009;

COMMIT;


/*
CIS276  Lab 5 Q5:

Write a PL/SQL program that displays the name, employee number, and salary of all 
salespersons in descending order of salary.  This requires using a CURSOR and a 
LOOP with a FETCH. Use the OTHERS EXCEPTION to display the SQLERRM. Format your 
output line as �<ename> - <empid> <salary>�, i.e. your output should look something 
like the following:

109 - Kevin Kody        $3,100.00
108 - Harvey Harrison   $3,000.00
107 - Gloria Garcia     $2,500.00
106 - Faulkner Forest   $2,500.00
105 - Edward Everling   $2,200.00
104 - Dale Dahlman      $2,000.00
103 - Charles Cox       $2,000.00
110 - Larry Little      $1,500.00
102 - Burbank Burkett   $1,000.00
101 - Andrew Allen      $1,000.00
*/

SET SERVEROUTPUT ON FORMAT WRAPPED

DECLARE

    CURSOR  Sales_Specs IS 
        SELECT SALESPERSONS.empID,
               SALESPERSONS.ename,
               SALESPERSONS.salary
        FROM   SALESPERSONS
        ORDER BY SALESPERSONS.salary DESC;
        
    vSales_List  Sales_Specs%ROWTYPE;

BEGIN

    DBMS_OUTPUT.PUT_LINE('EmpID  Name                 Salary');
    DBMS_OUTPUT.PUT_LINE('---------------------------------------');

    OPEN Sales_Specs;
    
    FETCH Sales_Specs INTO vSales_List;
    
    WHILE (Sales_Specs%FOUND) LOOP
    
        DBMS_OUTPUT.PUT_LINE(vSales_List.empid || '     ' || vSales_List.ename || 
        '     ' || TO_CHAR(vSales_List.salary, '$9,999.99'));
        
        FETCH Sales_Specs INTO vSales_List;
        
    END LOOP;
    
    CLOSE Sales_Specs;

EXCEPTION

    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Lab5 q5 OTHERS EXCEPTION');
        DBMS_OUTPUT.PUT_LINE(SQLERRM);

END;
/

  
/*
CIS276  Lab 5 Q6:

Write a PL/SQL program that accepts (&empid) an empid from the keyboard using 
variable substitution, and displays the name, employee number, and salary of the 
salesperson with the empid.  Use the OTHERS EXCEPTION to display the SQLERRM. 
Format your output line as �<ename> (employee <empid>) earns <salary>�, i.e. 
your output should look something like: 

Enter value for myempid: 109
Kevin Kody      (employee  109) earns   $3,410.00

PL/SQL procedure successfully completed.
*/

SET SERVEROUTPUT ON FORMAT WRAPPED
SET VERIFY OFF

DECLARE

    vEmpID   SALESPERSONS.EmpID%TYPE;
    vName    SALESPERSONS.Ename%TYPE;
    vSalary  SALESPERSONS.Salary%TYPE;

BEGIN

    vEmpID := &EmployeeID;
    
    SELECT  SALESPERSONS.Ename,
            SALESPERSONS.Salary
    INTO    vName,
            vSalary
    FROM    SALESPERSONS
    WHERE   EmpID = vEmpID;
    
    DBMS_OUTPUT.PUT_LINE(TRIM(vName) || ' (Employee ' || vEmpID || 
                            ') earns' || TO_CHAR(vSalary, '$9,999.99'));

EXCEPTION

    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Lab5 q6 OTHERS EXCEPTION');
        DBMS_OUTPUT.PUT_LINE(SQLERRM);

END;
/


/*
CIS276  Lab 5 Q7:

Write a PL/SQL program with no CURSOR to input a custid and then display the 
customer's name and the total amount of all the customer's orders. The output for 
each test should be two values:  the customer's name and the total amount the 
customer has ordered.  Test your program with a good customer id, a customer id 
that does not exist in the database, and a customer id that exists in the database 
but has no orders.  Be sure to distinguish between a nonexistent customer and a 
customer that exists but has no orders (i.e. display different output for each 
situation).  Use the NO_DATA_FOUND and OTHERS EXCEPTION handlers.
*/

-- Single dollar total for all orders
-- Different output for each exception/case
-- RELEVANT MESSAGES BASED ON EACH CASE

/* Find valid cust ids and total spent to verify script output
SELECT     C.Custid,
           C.cname,
           NVL(SUM(OI.qty * I.price), 0) AS TotalValue
FROM   CUSTOMERS C
    LEFT JOIN ORDERS O 
        ON O.custid = C.custid
    LEFT JOIN ORDERITEMS OI
        ON OI.orderid = O.orderid
    LEFT JOIN INVENTORY I
        ON I.partid = OI.partid
GROUP BY C.cname, C.Custid
ORDER BY TotalValue DESC;
*/

SET SERVEROUTPUT ON FORMAT WRAPPED
SET VERIFY OFF

/*
- SELECT INTO with aggregates like SUM will always return a value
- So, NO_DATA_FOUND will never be raised. How do I aggregate AND return no data?
- Check to see if the CustID exists FIRST, then calcuate the total amount ordered
- Handle existing customers BEFORE the EXCEPTION
    - If the amount ordered is greater than 0, success
    - If the amount equals 0 (use NVL()), print customer has placed no orders
- If custID does not exist, first SELECT INTO returns no value (no aggregate), so
the NO_DATA_FOUND error is raised in the EXCEPTION 
- Use OTHERS as a fail safe
*/

DECLARE

    vCustID      CUSTOMERS.CustID%TYPE  := &EnterCustID;
    vCustName    CUSTOMERS.CName%TYPE;
    vAmtOrdered  INVENTORY.Price%TYPE;  

BEGIN

    DBMS_OUTPUT.PUT_LINE('CustName                   AmtOrdered($)');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------');
    
    -- Ensure Customer exists 
    SELECT C.Cname
    INTO   vCustName
    FROM   CUSTOMERS C
    WHERE  C.CustID = vCustID;
    
    -- Total order values 
    SELECT  NVL(SUM(OI.Qty * I.price), 0)
    INTO    vAmtOrdered
    FROM    ORDERS O
        LEFT JOIN ORDERITEMS OI
            ON OI.OrderID = O.OrderID
        LEFT JOIN INVENTORY I
            ON I.PartID = OI.PartID
    WHERE O.CustID = vCustID;
            
    IF vAmtOrdered > 0
    
        THEN
            DBMS_OUTPUT.PUT_LINE(TRIM(vCustName) || '        ' || TO_CHAR(vAmtOrdered, '$9,999.99'));
        ELSE 
            DBMS_OUTPUT.PUT_LINE(TRIM(vCustName) || ' has not placed any orders');
            
    END IF;
    
EXCEPTION

    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Invalid Customer ID: ' || vCustID);
    WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Lab5 q7 OTHERS EXCEPTION');
            DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

  
/*
CIS276  Lab 5 Q8:

Write a PL/SQL program using a CURSOR for the same problem as #7 above. Do all the 
same tests as #7 and hopefully get the same results!  Use the NO_DATA_FOUND and 
OTHERS exception handlers.  The customer that has no orders can be checked using 
%ROWCOUNT in a condition. 
*/

-- RELEVANT MESSAGES BASED ON EACH CASE


SET SERVEROUTPUT ON FORMAT WRAPPED
SET VERIFY OFF

DECLARE

    vCustID     CUSTOMERS.CustID%TYPE := &EnterCustID;
    vCustName   CUSTOMERS.Cname%TYPE;         

    CURSOR AmountOrdered IS
        -- Query to find total spent by each customer
        SELECT  C.CustID,
                C.Cname,
                NVL(SUM(OI.Qty * I.Price), 0) AS TotalSpent
        FROM    CUSTOMERS C
            LEFT JOIN ORDERS O
                ON O.CustId = C.CustID
            LEFT JOIN ORDERITEMS OI
                ON OI.OrderID = O.OrderID
            LEFT JOIN INVENTORY I
                ON I.PartID = OI.PartID
        WHERE   C.CustID = vCustID
        GROUP BY C.CName, C.CustID
        ORDER BY TotalSpent DESC;
        
    vCustomers   AmountOrdered%ROWTYPE;

BEGIN
    
    DBMS_OUTPUT.PUT_LINE('CustName                   AmtOrdered($)');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------');
    
    -- Check if Customer Exists first to handle no data found
    SELECT C.Cname
    INTO   vCustName
    FROM   CUSTOMERS C
    WHERE  C.CustID = vCustID;
    
    OPEN AmountOrdered;
    
    FETCH AmountOrdered INTO vCustomers;
    
    WHILE (AmountOrdered%FOUND) LOOP
    
        IF vCustomers.TotalSpent = 0 
        
            THEN 
                DBMS_OUTPUT.PUT_LINE(TRIM(vCustomers.Cname) || ' has not placed any orders');
                
            ELSE
                DBMS_OUTPUT.PUT_LINE(TRIM(vCustomers.Cname) || '      ' || 
                TO_CHAR(vCustomers.TotalSpent, '$9,999.99'));
        END IF;
        
        FETCH AmountOrdered INTO vCustomers;
        
    END LOOP;
    
    CLOSE AmountOrdered;
    
EXCEPTION

     WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Invalid Customer ID: ' || vCustID);
        
    WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Lab5 q8 OTHERS EXCEPTION');
            DBMS_OUTPUT.PUT_LINE(SQLERRM);

END;
/

-- Query to see total spent by each customer

-- SELECT  C.CustID,
--         C.Cname,
--         NVL(SUM(OI.Qty * I.Price), 0) AS TotalSpent
--FROM    CUSTOMERS C
--    LEFT JOIN ORDERS O
--        ON O.CustId = C.CustID
--    LEFT JOIN ORDERITEMS OI
--        ON OI.OrderID = O.OrderID
--    LEFT JOIN INVENTORY I
--        ON I.PartID = OI.PartID
--GROUP BY C.CName, C.CustID
--ORDER BY TotalSpent DESC;

  
/*
CIS276  Lab 5 Q9:

Write a PL/SQL program to input a custid (&Custid).  Display the customer�s name, 
and the orderid, salesdate, and total value of each order for that customer.  
Produce the output in descending order by total value of each order.  This output 
will produce one or more lines for the customer, depending on how many orders that 
customer has made.  Test your program with a good custid, a custid that is not in 
the CUSTOMERS table, and one that is in the CUSTOMERS table but has no orders.  
Be sure to distinguish between the customer that does not exist and a customer 
that exists but has no orders (as above: display different output for each 
situation).  Use the NO_DATA_FOUND and OTHERS exception handlers.
*/

-- Total each order for customer using a CURSOR
-- Sales date AND dollar total for each order 
-- GROUP BY custID, OrderID
-- RELEVANT MESSAGES BASED ON EACH CASE
SET SERVEROUTPUT ON FORMAT WRAPPED
SET VERIFY OFF 

DECLARE

    vCustID         CUSTOMERS.CustID%TYPE   := &CustomerID;

    CURSOR OrderData IS 
        SELECT C.CustID,
               C.Cname,
               O.OrderID,
               NVL(SUM(OI.Qty * I.Price), 0) AS OrderTotal,
               O.SalesDate
        FROM   CUSTOMERS C
            LEFT JOIN ORDERS O
                ON O.CustID = C.CustID
            LEFT JOIN ORDERITEMS OI
                ON OI.OrderID = O.OrderID
            LEFT JOIN INVENTORY I
                ON I.PartID = OI.PartID
        WHERE  C.CustID = vCustID
        GROUP BY C.CustID, O.OrderID, O.SalesDate, C.CName
        ORDER BY OrderTotal DESC;
        
    vOrderTotals    OrderData%ROWTYPE;

BEGIN

    DBMS_OUTPUT.PUT_LINE('CustName            OrderID         AmtOrdered($)          DateOrdered');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------');
    
    -- Ensure CustID input exists before opening cursor
    SELECT C.CustID
    INTO   vCustID
    FROM   CUSTOMERS C
    WHERE  C.CustID = vCustID;
    
    OPEN OrderData;
    
    FETCH OrderData INTO vOrderTotals;
    
    WHILE (OrderData%FOUND) LOOP
    
        IF vOrderTotals.OrderTotal = 0 
            
            THEN 
                 DBMS_OUTPUT.PUT_LINE(TRIM(vOrderTotals.Cname) || ' has not placed any orders');
                 
            ELSE 
                DBMS_OUTPUT.PUT_LINE(TRIM(vOrderTotals.Cname) || '    ' || 
                vOrderTotals.OrderID || '          ' || 
                TO_CHAR(vOrderTotals.OrderTotal, '$9,999.99') || '            ' || 
                TO_CHAR(vOrderTotals.SalesDate, 'MM/DD/YYYY'));
                
        END IF;
        
        FETCH OrderData INTO vOrderTotals;
        
    END LOOP;
    
    CLOSE OrderData;

EXCEPTION

    WHEN NO_DATA_FOUND THEN 
         DBMS_OUTPUT.PUT_LINE('Invalid Customer ID: ' || vCustID);
         
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Lab5 q9 OTHERS EXCEPTION');
        DBMS_OUTPUT.PUT_LINE(SQLERRM);

END;
/

-- Query to find each order total and date for every customer 
--SELECT C.CustID,
--       C.Cname,
--       O.OrderID,
--       NVL(SUM(OI.Qty * I.Price), 0) AS OrderTotal,
--       O.SalesDate
--FROM   CUSTOMERS C
--    LEFT JOIN ORDERS O
--        ON O.CustID = C.CustID
--    LEFT JOIN ORDERITEMS OI
--        ON OI.OrderID = O.OrderID
--    LEFT JOIN INVENTORY I
--        ON I.PartID = OI.PartID
--GROUP BY C.CustID, O.OrderID, O.SalesDate, C.CName;

  
/*
CIS276  Lab 5 Q10:

Write a PL/SQL program to input a partid (&partid).  Show the customers who have 
ordered this part by displaying the customer name, quantity ordered, and salesdate 
of order.  Display the information in descending order of salesdate.  Test your 
program with a good partid, one that does not exist in the INVENTORY table, and 
one that no customer has ordered. Be sure to distinguish between a partid that 
does not exist and a partid that exists but has not been ordered.  Use the 
NO_DATA_FOUND and OTHERS exception handlers. You can modify your INVENTORY table 
for the third test (I will be doing so when grading).
*/


SET SERVEROUTPUT ON FORMAT WRAPPED
SET VERIFY OFF

DECLARE

    vPartID     INVENTORY.PartID%TYPE     := &PartID;

    CURSOR PartOrders IS 
        SELECT C.Cname,
               I.PartID,
               NVL(SUM(OI.qty), 0) AS QtyOrdered,
               O.SalesDate
        FROM   CUSTOMERS C
            LEFT JOIN ORDERS O
                ON O.CustID = C.CustID
            LEFT JOIN ORDERITEMS OI
                ON OI.OrderID = O.OrderID
            LEFT JOIN INVENTORY I
                ON I.PartID = OI.PartID
        WHERE I.PartID = vPartID
        GROUP BY C.Cname, O.SalesDate, I.PartID
        ORDER BY SalesDate DESC;
        
        vParts  PartOrders%ROWTYPE;

BEGIN

    DBMS_OUTPUT.PUT_LINE('CustName          QtyOrdered          DateOrdered');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
    
    -- Ensure Part ID Exists First 
    SELECT I.PartID
    INTO   vPartID
    FROM   INVENTORY I
    WHERE  I.PartID = vPartID;
    
    OPEN PartOrders;
    
    FETCH PartOrders INTO vParts;
    
    WHILE (PartOrders%FOUND) LOOP
        
        DBMS_OUTPUT.PUT_LINE(RTRIM(vParts.Cname) || '       ' || 
                            TRIM(vParts.QtyOrdered) || '        ' ||
                            TO_CHAR(vParts.SalesDate, 'MM/DD/YYYY'));         
        
        FETCH PartOrders INTO vParts;
        
    END LOOP;
    
    IF (PartOrders%ROWCOUNT = 0) 
            
            THEN 
         
                DBMS_OUTPUT.PUT_LINE('Part No. ' || TRIM(vPartID) || ' has not been ordered yet.');
            
    END IF;
    
    CLOSE PartOrders;    

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Invalid Part ID: ' || vPartID);

    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Lab5 q10 OTHERS EXCEPTION');
        DBMS_OUTPUT.PUT_LINE(SQLERRM);

END;
/

-- INSERT new row for testing a part that has not been ordered yet 
--INSERT INTO INVENTORY (PartID, Description, StockQty, ReorderPnt, Price)
--    VALUES (1020, 'this', 20, 5, 10.5);
--    
--COMMIT;
    
    
-- Inspect all parts 
--SELECT *
--FROM INVENTORY;

-- 1001-1010 are valid part numbers 

-- Query to find all orders per part 
--SELECT I.PartID,
--       NVL(SUM(OI.qty), 0) AS OrderQuantity,
--       O.SalesDate
--FROM   CUSTOMERS C
--    LEFT JOIN ORDERS O
--        ON O.CustID = C.CustID
--    LEFT JOIN ORDERITEMS OI
--        ON OI.OrderID = O.OrderID
--    LEFT JOIN INVENTORY I
--        ON I.PartID = OI.PartID
--WHERE I.PartID = 1020
--GROUP BY O.SalesDate, I.PartID
--ORDER BY I.PartID;
