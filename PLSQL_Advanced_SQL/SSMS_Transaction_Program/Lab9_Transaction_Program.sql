/*
********************************************************************************
CIS276 @PCC using SQL Server 2022
Lab 9
Billy Conard 
06/08/2026 

Testing blocks are commented out per instructors request.
********************************************************************************
*/
USE s276_BillyC;  

/*
--------------------------------------------------------------------------------
CUSTOMERS.CustID validation
--------------------------------------------------------------------------------
*/

IF EXISTS (SELECT name FROM sys.objects WHERE name = 'ValidateCustID')
    BEGIN 
        DROP PROCEDURE ValidateCustID; 
    END;    -- must use block for more than one statement
-- END IF;  SQL Server does not use END IF 
GO

-- Notice my found variable contains the customer name
-- YOU can/should do something else to indicate a row exists to validate CustID

CREATE PROCEDURE ValidateCustID 

    @vCustID SMALLINT,
    @vFound  CHAR(25) OUTPUT 

AS 
BEGIN 

    SET @vFound = 'blank';  -- initializes my found variable
    SELECT @vFound = Cname 
    FROM   CUSTOMERS
    WHERE  CUSTOMERS.CustID = @vCustID;

END;
GO

-- testing block for ValidateCustID
--BEGIN
    
--    DECLARE @vCname CHAR(25);  -- holds value returned from procedure

--    EXECUTE ValidateCustID 1, @vCname OUTPUT;
--    PRINT 'ValidateCustID test with valid CustID 1 returns ' + @vCname;
--	-- When @vCname contains a customer name the custid is validated

--    EXECUTE ValidateCustID 5, @vCname OUTPUT;
--    PRINT 'ValidateCustID test w/invalid CustID 5 returns ' + @vCname;
--	-- When @vCname contains 'blank' the custid is not in the CUSTOMERS table

--END;
GO

/*
--------------------------------------------------------------------------------
ORDERS.OrderID validation:
--------------------------------------------------------------------------------
*/

IF EXISTS (SELECT name FROM sys.objects WHERE name = 'ValidateOrderID')
    BEGIN 
        DROP PROCEDURE ValidateOrderID; 
    END;
GO

CREATE PROCEDURE ValidateOrderID -- with custid and orderid input
    
    @vCustID  SMALLINT,
    @vOrderID SMALLINT,
    @vFound   CHAR(16) OUTPUT

AS 

BEGIN
    -- Initialize @vFound to 'Not Found'.
    SET @vFound = 'Not Found';

    -- Set to 'Found' if matching OrderID is found
    SELECT @vFound = 'Found'
    FROM   ORDERS
    WHERE  ORDERS.OrderID = @vOrderID;

    -- Set to 'Invalid' when CustID/OrderID pairing is invalid.
    -- Otherwise, CustID/OrderID matching allows further processing 
    SELECT @vFound = 'Invalid'
    FROM   ORDERS
    WHERE  ORDERS.OrderID = @vOrderID
    AND    ORDERS.CustID <> @vCustID;

END;

GO

-- testing block for ValidateOrderID
--BEGIN    
    --DECLARE @vResult CHAR(16);

    ---- OrderID Not Found 
    --EXECUTE ValidateOrderID 1, -344, @vResult OUTPUT;
    --PRINT 'Customer 1 with an Order No. of -344: ' + @vResult;

    ---- Invalid Customer and Order Pairing 
    --EXECUTE ValidateOrderID 5, 6157, @vResult OUTPUT;
    --PRINT 'Customer 5 with an Order No. of 6157: ' + @vResult;

    ---- Valid Customer and Order Pairing 
    --EXECUTE ValidateOrderID 22, 6217, @vResult OUTPUT;
    --PRINT 'Customer 22 with an Order No. of 6217: ' + @vResult;
--END;

GO


/*
--------------------------------------------------------------------------------
INVENTORY.PartID validation:
--------------------------------------------------------------------------------
*/
IF EXISTS (SELECT name FROM sys.objects WHERE name = 'ValidatePartID')
    BEGIN DROP PROCEDURE ValidatePartID; END;
GO

CREATE PROCEDURE ValidatePartID 

    @vPartID INT,
    @vFound  CHAR(16) OUTPUT

AS 
BEGIN 
    -- Determine whether specified PartID exists in the table
    SET    @vFound = 'False';
    SELECT @vFound = 'True'
    FROM   INVENTORY
    WHERE  INVENTORY.PartID = @vPartID;
END;
GO

-- testing block for ValidatePartID
--BEGIN    

--    DECLARE @vResult CHAR(16);

--    -- Invalid PartID
--    EXECUTE ValidatePartID 5555, @vResult OUTPUT;
--    PRINT 'A part exists with an ID of 5555: ' + @vResult;

--    -- Valid PartID
--    EXECUTE ValidatePartID 1010, @vResult OUTPUT;
--    PRINT 'A part exists with an ID of 1010: ' + @vResult; 

--END;
GO

/*
--------------------------------------------------------------------------------
Input quantity validation:
--------------------------------------------------------------------------------
*/
IF EXISTS (SELECT name FROM sys.objects WHERE name = 'ValidateQty')
    BEGIN DROP PROCEDURE ValidateQty; END;
GO

CREATE PROCEDURE ValidateQty 

    @vQty   INT,
    @vValid CHAR(16) OUTPUT

AS 
BEGIN 

-- No query required; test for positive value
    IF @vQty <= 0 
        SET @vValid = 'Invalid' 
    ELSE 
        SET @vValid = 'Valid';

END;
GO

--BEGIN    

--    DECLARE @vResult CHAR(16);

--    -- Invalid Qty
--    EXECUTE ValidateQty -1, @vResult OUTPUT;
--    PRINT 'A quantity of -1 is ' + @vResult;

--    -- Valid Qty 
--    EXECUTE ValidateQty 5, @vResult OUTPUT;
--    PRINT 'A quantity of 5 is ' + @vResult;

--END;
GO

/*
--------------------------------------------------------------------------------
ORDERITEMS.Detail determines new value:
You can handle NULL within the projection but it can be done in two steps
(SELECT and then test).  It is important to deal with the possibility of NULL
because the detail is part of the primary key and therefore cannot contain NULL.
--------------------------------------------------------------------------------
*/
IF EXISTS (SELECT name FROM sys.objects WHERE name = 'GetNewDetail')
    BEGIN DROP PROCEDURE GetNewDetail; END;
GO

CREATE PROCEDURE GetNewDetail 

    @vOrderID   INT,
    @vNewDetail SMALLINT OUTPUT

AS 
BEGIN 

    -- Validate OrderID exists first - use ORDERS table to catch ORDERS with no ORDER ITEMS
    SELECT @vOrderID = OrderID
    FROM   ORDERS
    WHERE  ORDERS.OrderID = @vOrderID;

    IF (@@ROWCOUNT = 0)
        BEGIN
            PRINT 'Invalid OrderID: ' + TRIM(CONVERT(CHAR(10), @vOrderID));
        END;
    ELSE 
        BEGIN
            -- Use @vOrderid (input) to get @vNewDetail (output) via a query;
            SELECT @vNewDetail = ISNULL(MAX(ORDERITEMS.Detail), 0) + 1
            FROM   ORDERITEMS
            WHERE  ORDERITEMS.OrderID = @vOrderID;
        END;
END;
GO

-- testing block for GetNewDetail
--BEGIN  

--    DECLARE @vDetail INT;

    -- Order with no OrderItems (Detail No. should be 1)
    --EXECUTE GetNewDetail 6107, @vDetail OUTPUT;
    --PRINT 'New detail for order no. 6107: ' + TRIM(CONVERT(CHAR(10), @vDetail));

    -- Order with 5 OrderItems (New Detail should be 6)
    --EXECUTE GetNewDetail 6099, @vDetail OUTPUT;
    --PRINT 'New detail for order no. 6099: ' + TRIM(CONVERT(CHAR(10), @vDetail));

--END;
GO

/*
--------------------------------------------------------------------------------
INVENTORY trigger for an UPDATE:
--------------------------------------------------------------------------------
*/
IF EXISTS (SELECT name FROM sys.objects WHERE name = 'InventoryUpdateTRG')
    BEGIN DROP TRIGGER InventoryUpdateTRG; END;
GO

CREATE TRIGGER InventoryUpdateTRG
ON INVENTORY FOR UPDATE
AS

    DECLARE @vNewStockQty INT;
    DECLARE @errMsg       CHAR(128);
    
BEGIN

    -- compare (SELECT Stockqty FROM INSERTED) to zero
    SELECT @vNewStockQty = StockQty
    FROM   INSERTED;

    -- your error handling
    IF @vNewStockQty < 0 
        BEGIN
            SET @errMsg = 'UPDATE Failed - unable to set StockQty to ' + LTRIM(STR(@vNewStockQty));
            RAISERROR(@errMsg, 11, 1) WITH SETERROR;
        END;
END;

GO

-- testing blocks for InventoryUpdateTRG
-- Test should pass 
--BEGIN TRANSACTION
--UPDATE INVENTORY
--SET    StockQty = 1
--WHERE  PartID = 1010;

--IF @@ERROR <> 0 
--    BEGIN 
--        PRINT 'UPDATE Failed.';
--        ROLLBACK TRANSACTION
--    END;
--ELSE
--    BEGIN
--        PRINT 'UPDATE Succeeded!';
--        COMMIT TRANSACTION
--    END;
--GO

-- Test should fail - inventory cannot be less than 0
--BEGIN TRANSACTION
--UPDATE INVENTORY
--SET    StockQty = -1
--WHERE  PartID = 1003;

--IF @@ERROR <> 0 
--    BEGIN
--        PRINT 'UPDATE Failed - Stock Qty Cannot be Negative';
--        ROLLBACK TRANSACTION
--    END;
--ELSE
--    BEGIN
--        PRINT 'UPDATE Succeeded!';
--        COMMIT TRANSACTION
--    END;
--GO

/*
--------------------------------------------------------------------------------
ORDERITEMS trigger for an INSERT:
--------------------------------------------------------------------------------
*/

IF EXISTS (SELECT name FROM sys.objects WHERE name = 'OrderitemsInsertTRG')
    BEGIN DROP TRIGGER OrderitemsInsertTRG; END;
GO

CREATE TRIGGER OrderitemsInsertTRG
ON ORDERITEMS FOR INSERT
AS

    DECLARE @vPartID   INT;
    DECLARE @vQty      INT;
    DECLARE @vStockQty INT;
    DECLARE @errMsg    CHAR(128);

BEGIN 
    -- get new values for qty and partid from the INSERTED table
    SELECT  @vPartID = PartID, 
            @vQty = Qty     
    FROM INSERTED;
    -- get current (changed) StockQty for this PartID
    SELECT @vStockQty = StockQty
    FROM   INVENTORY
    WHERE  INVENTORY.PartID = @vPartID;

    -- UPDATE with current (changed) StockQty 
    UPDATE INVENTORY
    SET StockQty = StockQty - @vQty
    WHERE INVENTORY.PartID = @vPartID;

    -- your error handling
    IF @@ERROR <> 0 
        BEGIN
            SET @errMsg = 'INSERT Failed - unable to set StockQty to ' + LTRIM(STR(@vQty));
            RAISERROR(@errMsg, 11, 1) WITH SETERROR;
        END;

END;
GO

-- testing blocks for OrderItemsInsertTrg
-- Failed Test - Qty too High 
--BEGIN TRANSACTION
 
--    DECLARE @errMsg CHAR(128);


--    INSERT INTO ORDERITEMS (OrderID, Detail, PartID, Qty)
--    VALUES (6099, 6, 1002, 500);

--    IF @@ERROR <> 0 
--        BEGIN
--            SET @errMsg = 'INSERT Failed - unable to set StockQty to a negative value.';
--            RAISERROR(@errMsg, 11, 1) WITH SETERROR;
--            ROLLBACK TRANSACTION;
--        END;
--    ELSE
--        BEGIN
--            PRINT 'INSERT Succeeded!';
--            COMMIT TRANSACTION
--END;

-- Passed Test - Successful Insert
--BEGIN TRANSACTION

--    INSERT INTO ORDERITEMS (OrderID, Detail, PartID, Qty)
--    VALUES (6109, 5, 1001, 5);

--    IF @@ERROR <> 0 
--         BEGIN
--            SET @errMsg = 'INSERT Failed - unable to set StockQty to a negative value.';
--            RAISERROR(@errMsg, 11, 1) WITH SETERROR;
--            ROLLBACK TRANSACTION;
--        END;
--    ELSE
--        BEGIN
--            PRINT 'INSERT Succeeded!';
--            COMMIT TRANSACTION

--END;
GO

/* 
--------------------------------------------------------------------------------
The TRANSACTION, this procedure calls GetNewDetail and performs an INSERT
to the ORDERITEMS table which in turn performs an UPDATE to the INVENTORY table.
Error handling determines COMMIT/ROLLBACK.
--------------------------------------------------------------------------------
*/

IF EXISTS (SELECT name FROM sys.objects WHERE name = 'AddLineItem')
    BEGIN DROP PROCEDURE AddLineItem; END;
GO

CREATE PROCEDURE AddLineItem 

    @vOrderID INT,
    @vPartID  INT,
    @vQty     INT,
    @vDetail  INT OUTPUT,
    @errMsg   CHAR(25) OUTPUT

AS
BEGIN
BEGIN TRANSACTION    -- this is the only BEGIN TRANSACTION for the lab assignment
    EXECUTE GetNewDetail @vOrderID, @vDetail OUTPUT;

    INSERT INTO ORDERITEMS (OrderID, PartID, Qty, Detail)
    VALUES (@vOrderID, @vPartID, @vQty, @vDetail);

    -- your error handling
    IF @@ERROR <> 0 
        BEGIN
            PRINT 'Transaction Rolled Back';
            SET @errMsg = 'Unable to Add Line Item';
            RAISERROR(@errMsg, 11, 1) WITH SETERROR;
            ROLLBACK TRANSACTION;
        END;
    ELSE 
        BEGIN
            PRINT 'Transaction Committed';
            PRINT 'Line Item Added for OrderID ' + TRIM(CONVERT(CHAR(10), @vOrderID)) + ': Quantity of PartID ' 
                + TRIM(CONVERT(CHAR(10), @vPartID)) + ' has been increased by ' + TRIM(CONVERT(CHAR(10), @vQty))
                + ' and has a new detail number of ' + TRIM(CONVERT(CHAR(10), @vDetail));
            COMMIT TRANSACTION;
        END;

-- END TRANSACTION;
END;
GO

-- No AddLineItem tests, saved for main block testing

GO

/* 
--------------------------------------------------------------------------------
Puts all of the previous together to produce a solution for Lab9 done in
SQL Server. This stored procedure accepts the 4 pieces of input: 
Custid, Orderid, Partid, and Qty (in that order please). It validates all the 
data and does the transaction processing by calling the previously written and 
tested modules.
--------------------------------------------------------------------------------
*/
IF EXISTS (SELECT name FROM sys.objects WHERE name = 'Lab9proc')
    BEGIN DROP PROCEDURE Lab9proc; END;
GO

CREATE PROCEDURE Lab9proc 

    @vCustID  INT,
    @vOrderID INT,
    @vPartID  INT,
    @vQty     INT

AS

BEGIN

    DECLARE @vDetail  INT;
    DECLARE @vErrMsg  CHAR(125);
    -- Variables to capture result of tests 
    DECLARE @validCustID  CHAR(10);
    DECLARE @validOrderID CHAR(10);
    DECLARE @validPartID  CHAR(10);
    DECLARE @validQty     CHAR(10);

    PRINT 'Lab9Proc Begins';
    
    -- EXECUTE ValidateCustId
    EXECUTE ValidateCustID @vCustID, @validCustID OUTPUT;
	--   Note failure/success
    PRINT 'Customer with an ID of ' + TRIM(CONVERT(CHAR(10), @vCustID)) + ' is : ' + TRIM(@validCustID);

	-- EXECUTE ValidateOrderid
    EXECUTE ValidateOrderID @vCustID, @vOrderID, @validOrderID OUTPUT;
	--   Note failure/success
    PRINT 'The Order ID ' + TRIM(CONVERT(CHAR(10), @vOrderID)) + ' is: ' + TRIM(@validOrderID);
    PRINT 'The pairing of Customer ID ' + TRIM(CONVERT(CHAR(10), @vCustID)) + ' and OrderID ' 
            + TRIM(CONVERT(CHAR(10), @vOrderID)) + ' is: ' + TRIM(@validOrderID);

    -- EXECUTE ValidatePartId
    EXECUTE ValidatePartID @vPartID, @validPartID OUTPUT;
	--   Note failure/success
    PRINT 'Does a part exist with a partID of ' + TRIM(CONVERT(CHAR(10), @vPartID)) + '? ' + TRIM(@validPartID);

    -- EXECUTE ValidateQty
    EXECUTE ValidateQty @vQty, @validQty OUTPUT;
	--   Note failure/success
    PRINT 'A quantity value of ' + TRIM(CONVERT(CHAR(10), @vQty)) + ' is: ' + TRIM(@validQty);

	-- IF all validations pass, do the TRANSACTION:
    IF @validCustID <> 'blank' AND @validOrderID = 'Found' AND @validPartID = 'True' AND @validQty = 'Valid'
        BEGIN
            PRINT 'Validations Complete. Processing Transaction...';
            EXECUTE AddLineItem @vOrderID, @vPartID, @vQty, @vDetail, @vErrMsg;
        END;
    -- ELSE report error messages
    ELSE 
        BEGIN
            PRINT 'Transaction Rolled Back. Terminating Procedure...';
            SET @vErrMsg = 'Invalid Input(s). Please try again.';
            RAISERROR(@vErrMsg, 11, 1);
        END;
END;
GO 

/*
--------------------------------------------------------------------------------
-- Your testing blocks for Lab9proc goes last
--------------------------------------------------------------------------------
*/
--BEGIN 

    -- Invalid Cust ID
    --EXECUTE Lab9proc 35, 6109, 1002, 1; 
    --PRINT 'Invalid Customer ID';

    -- Invalid OrderID
    --EXECUTE Lab9proc 2, 7999, 1005, 2;
    --PRINT   'Invalid OrderID';

    -- Invalid Custid/Orderid Pairing 
    --EXECUTE Lab9proc 1, 6148, 1006, 3;
    --PRINT 'Order does not belong to specified customer.';

    -- Invalid PartID
    --EXECUTE Lab9proc 3, 6129, 9999, 2;
    --PRINT 'Invalid PartID.';

    -- Negative Qty 
    --EXECUTE Lab9proc 3, 6129, 1005, -200;
    --PRINT 'Invalid Quantity.';

    -- Zero Quantity
    --EXECUTE Lab9proc 3, 6129, 1005, 0;
    --PRINT 'Quantity must be greater than 0.';

    -- Insufficient Stock 
     --EXECUTE Lab9Proc 15, 6168, 1007, 1000;
     --PRINT 'Not enough stock';

    -- Successful Insert and Update on order with line items 
    --EXECUTE Lab9proc 3, 6129, 1004, 2;
    --PRINT 'Insert and Update operations are successful!';

    -- Successful Insert and Update on order with no line items 
     --EXECUTE Lab9Proc 21, 6124, 1004, 2;
     --PRINT 'Insert and Update operations are successful!';

--END;
