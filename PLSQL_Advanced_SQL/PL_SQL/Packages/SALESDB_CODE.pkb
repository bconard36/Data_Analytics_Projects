/* 
    * CIS 276 Lab 8 *
    Name: Billy Conard 
    Date: 05/28/2026
*/

CREATE OR REPLACE PACKAGE BODY SALESDB_CODE AS

/* 
    * FUNCTION GET_ORDERTOTAL *
    Calculate the SUM(Price*Qty) for a specified OrderID value.
    Function accepts specified OrderID as parameter.
    Remember that some valid orders may have no ORDERITEMS!  
    If the result is NULL, substitute a zero.  
    If the OrderID is invalid, use an exception handler to return -1 (indicating an error).  
    Note that all return values must be numeric!
*/

    FUNCTION GET_ORDERTOTAL (argOrderID NUMBER) RETURN NUMBER IS 
    
        vReturnValue     NUMBER;
        vCounter         NUMBER;
        exInvalidOrderID EXCEPTION;
        
    
    BEGIN
        -- Validate OrderID first
        -- Orders may have no items, so check ORDERS table, not ORDERITEMS
        SELECT COUNT(*)
        INTO   vCounter
        FROM   ORDERS O
        WHERE  O.OrderID = argOrderID;
        
        IF vCounter = 0 THEN 
            RAISE exInvalidOrderID;
        END IF;
    
        SELECT NVL(SUM(OI.Qty * I.Price), 0) AS OrderTotal
        INTO   vReturnValue
        FROM   ORDERITEMS OI
            LEFT JOIN INVENTORY I
                ON I.PartID = OI.PartID
        WHERE OI.OrderID = argOrderID;
        
        RETURN vReturnValue;
        
    EXCEPTION
    
        WHEN exInvalidOrderID THEN
                DBMS_OUTPUT.PUT_LINE('ORDER ID ERROR');
                DBMS_OUTPUT.PUT_LINE('Invalid Order ID: ' || argOrderID);
                RETURN -1;
    
        WHEN OTHERS THEN 
            DBMS_OUTPUT.PUT_LINE('Unexpected error in FUNCTION GET_ORDERTOTAL: ' || SQLERRM);
            RETURN -1;
        
    
    END GET_ORDERTOTAL;
    
/* 
    * FUNCTION GET_PROFITABILITY *
    Calculate the �profitability� of a specified employee.  
    This is the SUM of their sales minus their Salary value.  
    Be sure to substitute zero for NULL sales before subtracting Salary!  
    If the employee ID is invalid, use an exception handler to return -1 (indicating an error). 
*/

    FUNCTION GET_PROFITABILITY (argEmpID NUMBER) RETURN NUMBER IS 
    
        vReturnValue   NUMBER;
        vCounter       NUMBER;
        exInvalidEmp   EXCEPTION;
        
    BEGIN
        -- Validate EmpID first
        SELECT COUNT(*)
        INTO vCounter 
        FROM SALESPERSONS S
        WHERE S.EmpID = argEmpID;
        
        IF vCounter = 0 THEN 
            RAISE exInvalidEmp;
        END IF;
    
        SELECT NVL(SUM(OI.qty * I.price), 0) - S.salary AS ProfitVal
        INTO   vReturnValue
        FROM   SALESPERSONS S
            LEFT JOIN ORDERS O
                ON O.EmpID = S.EmpID
            LEFT JOIN ORDERITEMS OI
                ON OI.OrderID = O.OrderID
            LEFT JOIN INVENTORY I
                ON I.PartID = OI.PartID
        WHERE S.EmpID = argEmpID
        GROUP BY S.Salary;
        
        RETURN vReturnValue;
        
    EXCEPTION 
    
        WHEN exInvalidEmp THEN
            DBMS_OUTPUT.PUT_LINE('EMP ID ERROR');
            DBMS_OUTPUT.PUT_LINE('Invalid Employee ID: ' || argEmpID);
            RETURN -1;
    
        WHEN OTHERS THEN 
            DBMS_OUTPUT.PUT_LINE('Unexpected error in FUNCTION GET_PROFITABILITY: ' || SQLERRM);
            RETURN -1;
            
    END GET_PROFITABILITY;
    
/* 
    * FUNCTION GET_NEWDETAIL *
    For a specified OrderID value, determine what the next Detail value should be.
    This should be one higher than the largest Detail value in the ORDERITEMS table for that OrderID.  
    If no rows exist in ORDERITEMS for the OrderID value, return a value of 1.  
    If any unexpected errors result, use an exception handler to return -1.
*/

    FUNCTION GET_NEWDETAIL (argOrderID NUMBER) RETURN NUMBER IS 
    
        vReturnValue      NUMBER;
        vCounter          NUMBER; 
        
    BEGIN
        -- Validate OrderID First 
        SELECT COUNT(*)
        INTO   vCounter
        FROM   ORDERITEMS OI
        WHERE  OI.OrderID = argOrderID;
        
        IF vCounter = 0 THEN
            RETURN 1;
        END IF;
    
        SELECT NVL(MAX(OI.Detail + 1), 1) AS NewDetailNum -- Use 1 as the sub value here, not 0 (see instructions)
        INTO   vReturnValue
        FROM   ORDERITEMS OI
        WHERE  OI.OrderID = argOrderID;
        
        RETURN vReturnValue;
        
    EXCEPTION 
    
        WHEN OTHERS THEN 
            DBMS_OUTPUT.PUT_LINE('Unexpected error in FUNCTION GET_NEWDETAIL: ' || SQLERRM);
            RETURN -1; 
            
    END GET_NEWDETAIL;
            
/* 
    * PROCEDURE ADDLINEITEM *
    Procedure adds a new line item and reduces the corresponding Stockqty
    for the specified PartID.  If it results in negative, fail and ROLLBACK.
    Otherwise - COMMIT transaction.
    Note: no validation steps needed; assume inputs are good.
*/

    PROCEDURE ADDLINEITEM (argOrderID NUMBER, argPartID NUMBER, argQty NUMBER) IS
    
        vDetail   ORDERITEMS.Detail%TYPE; 
        vStockQty INVENTORY.StockQty%TYPE;
    
        exNotEnoughStock EXCEPTION;
        
    BEGIN
        -- Use GET_NEWDETAIL() from above to store detail value
        vDetail := GET_NEWDETAIL(argOrderID);
        
        INSERT INTO ORDERITEMS (OrderID, PartID, Qty, Detail)
        VALUES (argOrderID, argPartID, argQty, vDetail);
        
        UPDATE INVENTORY
        SET    StockQty = StockQty - argQty
        WHERE  INVENTORY.PartID = argPartID;
        
        -- Inspect updated value 
        SELECT I.StockQty
        INTO   vStockQty
        FROM   INVENTORY I 
        WHERE  I.PartID = argPartID;
        
        -- Validate Stock Qty is greater than or equal to 0 after update 
        IF vStockQty < 0 THEN
            ROLLBACK;
            RAISE exNotEnoughStock;
        ELSE 
            DBMS_OUTPUT.PUT_LINE('Order ID ' || argOrderID || ' Detail ' 
            || vDetail || ' Part ID ' || argPartID || ' quantity ' || argQty || 
            ' passes all tests so we can COMMIT the changes.');
            COMMIT; 
        END IF;
        
        EXCEPTION 
            WHEN exNotEnoughStock THEN 
                DBMS_OUTPUT.PUT_LINE('Invalid Qty: ' || argQty || '. Not enough stock to process transaction.');
                
            WHEN OTHERS THEN 
                DBMS_OUTPUT.PUT_LINE('Unexpected error in AddLineItem PROCEDURE: ' || SQLERRM);
                ROLLBACK;
    
    END ADDLINEITEM; 

END SALESDB_CODE;
/
