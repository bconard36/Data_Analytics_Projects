/*
CIS276 Lab 7
Billy Conard

AddLineItemSP
  Script creates a stored procedure which will be executed by Lab7.sql to create
  a new row in the ORDERITEMS table.  Procedure will accept three input parameters
  (OrderID, PartID, Qty) which will be used to INSERT a row into ORDERITEMS - 
  deliberately omitting the Detail value (see InsertOrderitemsTRG; value will be
  calculated and set in that trigger).  Determines whether a custom 
  exception resulted from that operation; if so, it raises a custom exception and
  executes ROLLBACK.  If not, it displays a success message and executes COMMIT.
*/

-- THIS IS THE ONLY FILE WITH COMMIT / ROLLBACK COMMANDS

CREATE OR REPLACE PROCEDURE AddLineItemSP 
            (
                inOrderID IN ORDERITEMS.OrderID%TYPE,
                inPartID  IN ORDERITEMS.PartID%TYPE,
                inQty     IN ORDERITEMS.Qty%TYPE
            )
IS

    exNotEnoughStock EXCEPTION;
    PRAGMA EXCEPTION_INIT(exNotEnoughStock, -20010);
    
BEGIN

    INSERT INTO ORDERITEMS (OrderID, PartID, Qty)
    VALUES (inOrderID, inPartID, inQty);
    
    -- IF no errors are raised, then a successful insert was completed 
    -- COMMIT here
    DBMS_OUTPUT.PUT_LINE('Transaction completed successfully.');
    COMMIT;  
    
EXCEPTION

    WHEN exNotEnoughStock THEN
        DBMS_OUTPUT.PUT_LINE('AddLineItemSP Not Enough Stock USER EXCEPTION');
        DBMS_OUTPUT.PUT_LINE(SQLCODE || ': Invalid Quantity: ' || inQty 
                                || ' - not enough stock to process transaction.');
        ROLLBACK;
        RAISE;
        
    WHEN OTHERS THEN 
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE(SQLCODE || ': '  || SQLERRM);
        
END AddLineItemSP;
/

