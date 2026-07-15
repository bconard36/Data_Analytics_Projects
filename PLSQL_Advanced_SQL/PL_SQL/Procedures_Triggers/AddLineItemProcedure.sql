/* Lab 6 - CIS 276 

    Name: Billy Conard 
    Date: 05/21/2026

Add a new lineItem (INSERT) to an already existing order 
The scenario could be that a customer has previously placed an order and now wishes to add another 
item to the order. This could happen by a phone call or a web connection. The input data for this 
transaction will be the CustID, the Orderid, the Partid and Quantity for the new lineitem 
(in that order). After the new lineitem has been inserted, the INVENTORY table must be updated to 
reflect the change in the Stockqty for the partid on the new lineitem. After that UPDATE, check the 
value of the stockqty. If it is a negative number there is not enough stock to sell so the 
transaction needs to be rolled back. We can leave a zero balance in stock although that puts the 
quantity under the reorder point.
*/

SET SERVEROUTPUT ON FORMAT WRAPPED
SET VERIFY OFF

DECLARE
-- 1. Accept Data when Lab 6 is run. 
-- Input Order: CustID (1), OrderID (2), PartID (3), Quantity (4)
    vCustID        ORDERS.CustID%TYPE      :=&1;
    vOrderID       ORDERITEMS.OrderID%TYPE :=&2;
    vPartID        INVENTORY.PartID%TYPE   :=&3;
    vQty           INVENTORY.StockQty%TYPE :=&4;
    
    vDetail        ORDERITEMS.Detail%TYPE;  -- inventory detail variable 
    vStockQty      INVENTORY.StockQty%TYPE; -- inventory stock quantity variable
    vCounter       NUMBER(4);               -- generic counter (use for validations)
    
    -- Provide user-defined exceptions that display messages based on certain conditions and errors
    exInvalidCustID  EXCEPTION; 
    exInvalidOrderID EXCEPTION;
    exInvalidMatch   EXCEPTION;
    exInvalidPartID  EXCEPTION;
    exInvalidQty     EXCEPTION;
    exNotEnoughStock EXCEPTION; -- For NOT ENOUGH STOCK, place ROLLBACK in user defined exception
                                -- Same concept for success, place COMMIT in success message 
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
    -- 7-10. Once all validations are passed, modify data
    -- SELECT New Detail Number 
    -- Dynamically generate the Detail column in case part entered is 1st of order
    SELECT NVL(MAX(detail), 0) + 1 AS NewDetailNumber
    INTO   vDetail
    FROM   ORDERITEMS OI
    WHERE  OI.OrderID = vOrderID;
    
    -- INSERT Statement
    INSERT INTO ORDERITEMS (OrderID, Detail, PartID, Qty)
    VALUES (vOrderID, vDetail, vPartID, vQty);
        
    -- After INSERT, UPDATE StockQty in INVENTORY
    UPDATE INVENTORY
    SET    StockQty = StockQty - vQty
    WHERE  INVENTORY.PartID = vPartID;
    
    -- Inspect updated value 
    SELECT I.StockQty
    INTO   vStockQty
    FROM   INVENTORY I 
    WHERE  I.PartID = vPartID;
    
    -- Validate Stock Qty is greater than or equal to 0 after update 
    IF vStockQty < 0 THEN
        RAISE exNotEnoughStock;
    ELSE 
        DBMS_OUTPUT.PUT_LINE('Customer ID ' || vCustID || ' on Order ID ' || vOrderID || ' Detail ' 
        || vDetail || ' Part ID ' || vPartID || ' quantity ' || vQty || 
        ' passes all tests so we can COMMIT the changes.');
        COMMIT; -- COMMIT once all validations pass
    END IF;
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
       DBMS_OUTPUT.PUT_LINE('Not enough stock for part # ' || vPartID 
       || ' - cannot complete order.');
       ROLLBACK; -- Undo changes to avoid negative stock quantity   
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('SYSTEM ERROR: ' || SQLCODE || ' - ' || SQLERRM);
END;
/
