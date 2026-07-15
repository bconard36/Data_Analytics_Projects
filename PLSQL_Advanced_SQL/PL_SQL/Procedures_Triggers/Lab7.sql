/*
CIS276 Lab 7
Billy Conard

Lab7
  Script accepts four input parameters via numeric-ampersand substitution and
  performs a series of validations (identical to Lab6).  But instead of modifying
  data it will simply execute the AddLineItemSP procedure, passing values for 
  input parameters: (OrderID, PartID, Qty).
*/

SET SERVEROUTPUT ON FORMAT WRAPPED
SET VERIFY OFF

DECLARE 

    vCustID        ORDERS.CustID%TYPE      :=&1;
    vOrderID       ORDERITEMS.OrderID%TYPE :=&2;
    vPartID        INVENTORY.PartID%TYPE   :=&3;
    vQty           INVENTORY.StockQty%TYPE :=&4;
    
    vCounter       NUMBER(4);               -- generic counter (use for validations)
    
    exInvalidCustID  EXCEPTION; 
    exInvalidOrderID EXCEPTION;
    exInvalidMatch   EXCEPTION;
    exInvalidPartID  EXCEPTION;
    exInvalidQty     EXCEPTION;
    exNotEnoughStock EXCEPTION;
    PRAGMA EXCEPTION_INIT(exNotEnoughStock, -20010);
    
----------------------------------------------------------------------------------------------------    
BEGIN 

    -- Validate User Inputs 
    -- 2. Verify that the customer exists. 
    BEGIN 
    
        SELECT COUNT(*)
        INTO   vCounter
        FROM   CUSTOMERS
        WHERE  CUSTOMERS.CustID = vCustID;
        
        IF vCounter = 0 THEN
            RAISE exInvalidCustID;
        END IF;

    END;
----------------------------------------------------------------------------------------------------
    -- 3. Verify that the orderid exists. 
    BEGIN
    
        SELECT COUNT(*)
        INTO   vCounter
        FROM   ORDERS
        WHERE  ORDERS.OrderID = vOrderID;
        
        IF vCounter = 0 THEN
            RAISE exInvalidOrderID;
        END IF;
        
    END;
----------------------------------------------------------------------------------------------------           
    -- 4. Verify the order belongs to the specified customer
    -- vCustID and vOrderID already validated at this point 
    -- Simply need to return all rows with matching values of those inputs
    BEGIN
         
        SELECT COUNT(*)
        INTO   vCounter
        FROM   ORDERS O
        WHERE  O.CustID = vCustID
            AND O.OrderID = vOrderID;
            
        IF vCounter = 0 THEN
            RAISE exInvalidMatch;
        END IF;
                
    END;
----------------------------------------------------------------------------------------------------   
     -- 5. Verify that the partid exists. 
     BEGIN  
        
        SELECT COUNT(*)
        INTO   vCounter
        FROM   INVENTORY
        WHERE  INVENTORY.PartID = vPartID;

        IF vCounter = 0 THEN
            RAISE exInvalidPartID;     
        END IF;
        
    END;
----------------------------------------------------------------------------------------------------               
    -- 6. Verify quantity is greater than 0 
    BEGIN 
    
        IF vQty < 1 THEN 
            RAISE exInvalidQty;
        END IF;
        
    END;
----------------------------------------------------------------------------------------------------

-- Once validations are complete, execute / call AddLineItemsSP
-- Pass values for input parameters (OrderID, PartID, Qty)
    AddLineItemSP(vOrderID, vPartID, vQty);

----------------------------------------------------------------------------------------------------
-- Main Exception Block with User Defined Exceptions
EXCEPTION

    WHEN exInvalidCustID THEN
        DBMS_OUTPUT.PUT_LINE('INPUT ERROR');
        DBMS_OUTPUT.PUT_LINE('Invalid Customer ID: ' || vCustID);
    WHEN exInvalidOrderID THEN
        DBMS_OUTPUT.PUT_LINE('INPUT ERROR');
        DBMS_OUTPUT.PUT_LINE('Invalid Order ID: ' || vOrderID);
    WHEN exInvalidMatch THEN
        DBMS_OUTPUT.PUT_LINE('INPUT ERROR');
        DBMS_OUTPUT.PUT_LINE('Order No. ' || vOrderID || ' does not belong to customer no. ' || vCustID);
    WHEN exInvalidPartID THEN
        DBMS_OUTPUT.PUT_LINE('INPUT ERROR');
        DBMS_OUTPUT.PUT_LINE('No such part ID: ' || vPartID);
    WHEN exInvalidQty THEN 
        DBMS_OUTPUT.PUT_LINE('INPUT ERROR');
        DBMS_OUTPUT.PUT_LINE('Invalid Quantity: ' || vQty);
    WHEN exNotEnoughStock THEN
        DBMS_OUTPUT.PUT_LINE('TRANSACTION ERROR');
        DBMS_OUTPUT.PUT_LINE(SQLCODE || ': Not enough stock for part ' || vPartID 
                            || '. Please try a smaller quantity.'); 
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('SYSTEM ERROR: ' || SQLCODE || ' - ' || SQLERRM);
   
END;
/
