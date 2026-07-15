/* 

    Lab 6 CIS 276 - Test Script 
    
    Name: Billy Conard 
    Date: 05/21/2026

*/

-- Query to see test data for customer's orders
--SELECT O.CustID,
--       OI.OrderID,
--       I.PartID,
--       OI.Detail,
--       OI.Qty,
--       I.StockQty
--FROM   ORDERS O
--    LEFT JOIN ORDERITEMS OI
--        ON OI.OrderID = O.OrderID
--    LEFT JOIN INVENTORY I
--        ON I.PartID = OI.PartID
--ORDER BY O.CustID, OI.Detail;

-- Test 1: Bad CustID 
@AddLineItem 60 6099 1009 1

-- test 2: Ok CustID, Bad OrderID 
@AddLineItem 2 7894 1005 2 

-- Test 3: Good CustID and OrderID, but wrong combination of CustID and OrderID
@AddLineItem 2 6099 1001 5 

-- Test 4: Matching CustID and OrderID, bad PartID
@AddLineItem 15 6168 1069 3

-- Test 5: Bad Qty 
@AddLineItem 15 6168 1001 0

-- Test 6: Negative Quantity
@AddLineItem 15 6168 1001 -5

-- Test 7: Invalid StockQty AFTER Update 
@AddLineItem 1 6099 1005 75

-- Query BEFORE UPDATE/INSERT
SELECT O.CustID,
       OI.OrderID,
       I.PartID,
       OI.Detail,
       OI.Qty,
       I.StockQty
FROM   ORDERS O
    LEFT JOIN ORDERITEMS OI
        ON OI.OrderID = O.OrderID
    LEFT JOIN INVENTORY I
        ON I.PartID = OI.PartID
ORDER BY O.CustID, OI.Detail;

-- Test 8: Successful INSERT and UPDATE 1 (Order with Order Items)
@AddLineItem 26 6239 1008 5

-- Test 9: Successful INSERT and UPDATE 2 (Order Without Order Items)
@AddLineItem 15 6168 1001 2

-- Query AFTER UPDATE/INSERT
SELECT O.CustID,
       OI.OrderID,
       I.PartID,
       OI.Detail,
       OI.Qty,
       I.StockQty
FROM   ORDERS O
    LEFT JOIN ORDERITEMS OI
        ON OI.OrderID = O.OrderID
    LEFT JOIN INVENTORY I
        ON I.PartID = OI.PartID
ORDER BY O.CustID, OI.Detail;

-- Reset SalesDB After Successful Tests
@Sales_DB_Reset_Script
