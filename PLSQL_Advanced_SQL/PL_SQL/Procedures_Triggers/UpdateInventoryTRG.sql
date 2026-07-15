/*
CIS276 Lab 7
Billy Conard

UpdateInventoryTRG
  Trigger runs before an update on the INVENTORY table.  Determines whether the 
  resulting StockQty value is less than zero; if so, it raises a custom exception.
*/

CREATE OR REPLACE TRIGGER UpdateInventoryTRG 
    BEFORE UPDATE ON INVENTORY
    FOR EACH ROW 
    
DECLARE

    exNotEnoughStock EXCEPTION;
    PRAGMA EXCEPTION_INIT(exNotEnoughStock, -20010);
        
BEGIN 

    -- Ensure new stock qty not negative (0 ok for now)
    IF :NEW.StockQty < 0 THEN
        RAISE exNotEnoughStock;
    END IF;
    
EXCEPTION 

    WHEN exNotEnoughStock THEN 
        DBMS_OUTPUT.PUT_LINE('UpdateInventoryTRG Not Enough Stock USER EXCEPTION');
        DBMS_OUTPUT.PUT_LINE(':old.stockqty ' || :OLD.StockQty 
                                || ', :new.stockqty = ' || :NEW.StockQty);
        RAISE;

    WHEN OTHERS THEN 
        DBMS_OUTPUT.PUT_LINE(SQLCODE || ': '  || SQLERRM);
        RAISE;
END;
/
