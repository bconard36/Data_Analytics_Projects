/*
CIS276 Lab 7
Billy Conard

InsertOrderitemsTRG
  Trigger runs before an insert on the ORDERITEMS table.  Dynamically calculates 
  the new Detail value for the specified OrderID and assigns it to :NEW.Detail
  (overriding any invalid or NULL values).  Update the INVENTORY table to reduce
  StockQty by the :NEW.Qty value for this row.  Determines whether a custom 
  exception resulted from that operation; if so, it raises a custom exception.
*/

-- INCLUDE Custom exception handler here, raise it back to Stored Procedure 
-- Pass an Oracle Error number between the triggers and stored procedure

CREATE OR REPLACE TRIGGER InsertOrderItemsTRG 
    BEFORE INSERT ON ORDERITEMS
    FOR EACH ROW
    DECLARE

    exNotEnoughStock EXCEPTION;
    PRAGMA EXCEPTION_INIT(exNotEnoughStock, -20010);

BEGIN 
    
    SELECT NVL(MAX(detail), 0) + 1 AS NewDetailNumber
    INTO   :NEW.Detail
    FROM   ORDERITEMS OI
    WHERE  OI.OrderID = :NEW.OrderID; 
    
    UPDATE INVENTORY
    SET    StockQty = StockQty - :NEW.Qty  -- Use :NEW to access variables from Lab7.sql
    WHERE  INVENTORY.PartID = :NEW.PartID; -- Use :NEW to access variables from Lab7.sql
    
EXCEPTION 

    WHEN exNotEnoughStock THEN
        DBMS_OUTPUT.PUT_LINE('InsertOrderItemsTRG Not Enough Stock USER EXCEPTION');
        DBMS_OUTPUT.PUT_LINE(SQLCODE || ': Invalid Quantity: ' || :NEW.Qty || ' - Not Enough Stock.');
        RAISE;
        
    WHEN OTHERS THEN 
        DBMS_OUTPUT.PUT_LINE(SQLCODE || ': '  || SQLERRM);
        RAISE;
    
    
END;
/  
    
