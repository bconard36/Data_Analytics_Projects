CREATE OR REPLACE PACKAGE SALESDB_CODE AS

   -- Function calculates and returns SUM(Price*Qty) for a given OrderID
   FUNCTION GET_ORDERTOTAL (argOrderID NUMBER) RETURN NUMBER;

   -- Function calculates and returns SUM(Price*Qty) for a given EmpID, 
   --  subtracting Salary
   FUNCTION GET_PROFITABILITY (argEmpID NUMBER) RETURN NUMBER;

   -- Function determines what the new Detail value should be for a given OrderID
   FUNCTION GET_NEWDETAIL (argOrderID NUMBER) RETURN NUMBER;
   
   -- Procedure adds a new line item and reduces the corresponding Stockqty
   --  for the specified PartID.  If it results in negative, fail and ROLLBACK;
   --  otherwise COMMIT transaction.
   --  Note: no validation steps needed; assume inputs are good.
   PROCEDURE ADDLINEITEM (argOrderID NUMBER, argPartID NUMBER, argQty NUMBER);

END SALESDB_CODE;
