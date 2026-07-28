/* 
================================================================
DATA CLEANING PRACTICE - dirty_cafe_sales dataset

GOAL: 
- Identify missing / invalid values across all columns 
- Standardize categorical inconsistencies
- Correct known structured values 
- Validate cleaning steps after transformation 

NOTE:
- This dataset being queried was intentionally "dirty" for practice purposes. 
================================================================
*/

/* ==========================================
STEP 1 - EXPLORATORY ANALYSIS (DATA PROFILING)
=========================================== */ 
-- Inspect DataSet to examine values 
SELECT *
FROM dirty_cafe_sales;

-- Check how many rows have invalid or placeholder values exist in price_per_unit column
SELECT COUNT(*)
FROM   dirty_cafe_sales
WHERE price_per_unit = ''
	OR price_per_unit = 'ERROR'
    OR price_per_unit = 'UNKNOWN';
    
-- Check how many invalid values exist across ALL major columns
SELECT COUNT(*)
FROM   dirty_cafe_sales
WHERE (TRIM(item) = '' OR TRIM(item) = 'ERROR' OR TRIM(item) = 'UNKNOWN')
  OR (quantity = '' OR quantity = 'ERROR' OR quantity = 'UNKNOWN')
  OR (price_per_unit = '' OR price_per_unit = 'ERROR' OR price_per_unit = 'UNKNOWN')
  OR (total_spent = '' OR total_spent = 'ERROR' OR total_spent = 'UNKNOWN')
  OR (payment_method = '' OR payment_method = 'ERROR' OR payment_method = 'UNKNOWN')
  OR (location = '' OR location = 'ERROR' OR location = 'UNKNOWN')
  OR (transaction_date = '' OR transaction_date = 'ERROR' OR transaction_date = 'UNKNOWN');

-- Check for naming inconsistencies in item column using partial string match 
SELECT item
FROM dirty_cafe_sales
WHERE LOWER(item) LIKE 'c%';

SELECt item
FROM dirty_cafe_sales
WHERE LOWER(item) LIKE 's%';
  
-- Column-level data quality summary (binary count of bad vs good values)
SELECT SUM(CASE 
           WHEN item = '' OR item = 'ERROR' OR item = 'UNKNOWN' THEN 1 ELSE 0
           END) AS BadItemNameCount,
        SUM(CASE
            WHEN quantity = '' OR quantity = 'ERROR' OR quantity = 'UNKNOWN' THEN 1 ELSE 0
            END) AS BadQuantityCount,
        SUM(CASE
            WHEN price_per_unit = '' OR price_per_unit = 'ERROR' OR price_per_unit = 'UNKNOWN' THEN 1 ELSE 0
            END) AS BadPriceValueCount,
        SUM(CASE
            WHEN total_spent = '' OR total_spent = 'ERROR' OR total_spent = 'UNKNOWN' THEN 1 ELSE 0
            END) AS BadTotalSpentValueCount,
        SUM(CASE
            WHEN payment_method = '' OR payment_method = 'ERROR' OR payment_method = 'UNKNOWN' THEN 1 ELSE 0
            END) AS BadPaymentMethodCount,
        SUM(CASE 
            WHEN location = '' OR location = 'ERROR' OR location = 'UNKNOWN' THEN 1 ELSE 0
            END) AS BadLocationValue,
        SUM(CASE
            WHEN transaction_date = '' OR transaction_date = 'ERROR' OR transaction_date = 'UNKNOWN' THEN 1
           ELSE 0
      END) AS BadTransactionDateCount
FROM dirty_cafe_sales;

/* ==========================================
STEP 2 - DATA CLEANING - PRICE PER UNIT
=========================================== */
-- Build a reference check for item prices 
SELECT item,
	   price_per_unit
FROM dirty_cafe_sales
GROUP BY item;

-- Invalid values found for both item name and price_per_unit  
-- Standardize item values 
-- For missing/empty string values, update to MISSING 
-- For UNKNOWN values, keep as ITEM_UNKNOWN
-- For ERROR values, update to ITEM_ERROR
BEGIN TRANSACTION; 
  UPDATE dirty_cafe_sales
  SET    item = CASE
            WHEN item = '' THEN 'Item Missing'
            WHEN LOWER(item) = 'unknown' then 'Item Unknown'
            WHEN LOWER(item) = 'error' THEN 'Item Error'
            ELSE item
            END,
    -- Use original item values for price_per_unit updates
    -- Item values only updated after entire statement runs 
    -- All invalid price values will be NULL
           price_per_unit = CASE
            WHEN item = 'Cake' THEN '3.0'
            WHEN item = 'Coffee' THEN '2.0'
            WHEN item = 'Cookie' THEN '1.0'
            WHEN item = 'Juice' THEN '3.0'
            WHEN item = 'Salad' THEN '5.0'
            WHEN item = 'Sandwich' THEN '4.0'
            WHEN item = 'Smoothie' then '4.0'
            WHEN item = 'Tea' THEN '1.5'
            WHEN item = '' THEN NULL
            WHEN item = 'UNKNOWN' Then NULL
            WHEN item = 'ERROR' THEN NULL
        END 
    WHERE item IN ('Cake', 'Coffee', 'Cookie', 'Juice', 'Salad', 'Sandwich', 'Smoothie', 'Tea')
        OR item = '' 
        OR LOWER(item) = 'error' 
        OR LOWER(item) = 'unknown';
COMMIT;

    
-- VALIDATION: Ensure no remmaining bad values exist 
-- EXPECTED RESULT: 0
SELECT COUNT(*)
FROM   dirty_cafe_sales
WHERE price_per_unit = '' 
	OR LOWER(price_per_unit) = 'unknown'
    OR LOWER(price_per_unit) = 'error';

/* ==========================================
STEP 3 - DATA CLEANING - LOCATION 
=========================================== */
-- Inspect unique location values 
SELECT location
FROM   dirty_cafe_sales
GROUP BY location;

-- Analyze which bad value appears most frequently to prioritize cleaning efforts
SELECT location,
	   COUNT(*)
FROM dirty_cafe_sales
WHERE location = '' -- 3265 missing values 
	OR location = 'ERROR' -- 358 ERROR values 
    OR location = 'UNKNOWN' -- 338 UNKNOWN values 
GROUP BY location;
    
-- Check for NULL values to ensure missing/bad value accuracy 
SELECT COUNT(*)
FROM dirty_cafe_sales
WHERE location IS NULL; -- 0

-- Standardize Location Values
-- For missing/empty string values, update to Missing Location 
-- For ERROR values, update to Location Error 
-- For UNKNOWN values, keep as Unknown Location
BEGIN TRANSACTION; 

  UPDATE dirty_cafe_sales
  SET location = CASE 
          WHEN location = '' THEN 'Location Missing'
          WHEN LOWER(location) = 'error' THEN 'Location Error'
          WHEN LOWER(location) = 'unknown' THEN 'Location Unknown'
      END
  WHERE location = '' 
      OR LOWER(location) = 'error' 
      OR LOWER(location) = 'unknown';
      
COMMIT;
    
-- Post-cleaning validation: Ensure no remaining bad values exist
SELECT location, 
	   COUNT(*)
FROM dirty_cafe_sales
WHERE location = '' -- Expected - 0 missing values now
	OR LOWER(location) = 'error' -- Expected - 0 ERROR values 
    OR LOWER(location) = 'unknown' -- Expected - 0 UNKNOWN values 
GROUP BY location;

/* ==========================================
STEP 4 - DATA CLEANING - PAYMENT METHOD
=========================================== */
-- Inspect unique payment method values 
SELECT payment_method
FROM dirty_cafe_sales
GROUP BY payment_method;

-- Analyze which bad value appears most frequently to prioritize cleaning efforts
SELECT payment_method,
	   COUNT(*)
FROM dirty_cafe_sales
WHERE payment_method = '' -- 2579
	OR LOWER(payment_method) = 'error' -- 306
    OR LOWER(payment_method) = 'unknown' -- 293
GROUP BY payment_method;

-- Standardize Payment Method Values
-- For missing/empty string values, update to MISSING 
-- For ERROR values, update to PMT_ERROR 
-- For UNKNOWN values, keep as UNKNOWN
BEGIN TRANSACTION;

  UPDATE dirty_cafe_sales
  SET payment_method = CASE 
          WHEN payment_method = '' THEN 'Pmt Missing'
          WHEN LOWER(payment_method) = 'error' THEN 'Pmt Error'
          WHEN LOWER(payment_method) = 'unknown' THEN 'Pmt Unknown'
      END
  WHERE payment_method = '' 
      OR LOWER(payment_method) = 'error' 
      OR LOWER(payment_method) = 'unknown';
      
COMMIT;
    
-- Post-cleaning validation: Ensure no remaining bad values exist
-- Counts with value of UNKNOWN will remain unchanged because the name is the same!
SELECT payment_method,
	   COUNT(*)
FROM dirty_cafe_sales
WHERE payment_method = '' -- Expected - 0 missing values now
	OR LOWER(payment_method) = 'error' -- Expected - 0 ERROR values 
    OR LOWER(payment_method) = 'unknown' -- Expected - 293 UNKNOWN values 
GROUP BY payment_method;

/* ==========================================
STEP 5 - DATA CLEANING - QUANTITY 
=========================================== */
-- Total of 479 invalid quantity values discovered after updating total_spent
-- Same values as other columns: '', 'UNKNOWN', 'ERROR'.
SELECT COUNT(*)
FROM   dirty_cafe_sales
WHERE  quantity = ''
	OR LOWER(quantity) = 'unknown'
    OR LOWER(quantity) = 'error';
    
-- Invalid values are empty strings, ERROR, or UNKNOWN 

-- Inspect new quantity and total spent values after update above
SELECT quantity,
	   price_per_unit,
	   total_spent
FROM dirty_cafe_sales;

BEGIN TRANSACTION; 
    
  UPDATE dirty_cafe_sales
  SET quantity = CASE
      WHEN quantity = '' 
          OR LOWER(quantity) = 'error'
          OR LOWER(quantity) = 'unknown'
      THEN NULL
      ELSE quantity
      END;
      
COMMIT;
    
-- Run the same validation query to confirm changes 
SELECT quantity,
	   price_per_unit,
	   total_spent
FROM dirty_cafe_sales
WHERE quantity = ''
	   OR LOWER(quantity) = 'error'
       OR LOWER(quantity) = 'unknown';

-- Inspect All Columns 
SELECT *
FROM dirty_cafe_sales;

/* ==========================================
STEP 6 - DATA CLEANING - TOTAL SPENT 
=========================================== */
-- UPDATE all total_spent values for VALID payment methods only 
-- Invalid payment methods cannot be charged, meaning total_spent is invalid.
-- CAST price_per_unit and quantity as DECIMAL for currency 
BEGIN TRANSACTION;

  UPDATE dirty_cafe_sales
  SET total_spent = CASE
          WHEN LOWER(payment_method) = 'cash'
              OR LOWER(payment_method) = 'credit card'
              OR LOWER(payment_method) = 'digital wallet'
              THEN (CAST(price_per_unit AS DECIMAL(10, 2)) * CAST(quantity AS INT)) 
          END;
          
COMMIT;

-- Validate Updates based on logic above 
SELECT payment_method,
	   quantity,
	   price_per_unit,
       total_spent
FROM dirty_cafe_sales;

/* ======================================
STEP 7 - DATA CLEANING - TRANSACTION DATE
========================================= */
-- Inspect transaction date against payment method and total spent 
-- Looking for correlations in invalid values
SELECT transaction_date,
	   payment_method,
       total_spent
FROM dirty_cafe_sales;

-- Are there invalid transaction IDs with dates?
-- There should be no nulls or invalid values in transaction id
SELECT transaction_id
FROM   dirty_cafe_sales
WHERE  transaction_date = ''
	OR LOWER(transaction_date) = 'error'
    OR LOWER(transaction_date) = 'unknown';
    
-- As expected, no nulls - dates could be backtracked by transaction ID
-- Same invalid values found (ERROR, UNKNOWN, '')
-- UPDATE invalid values
BEGIN TRANSACTION; 

  UPDATE dirty_cafe_sales
  SET transaction_date = CASE 
      WHEN transaction_date = ''
      OR LOWER(transaction_date) = 'error'
      OR LOWER(transaction_date) = 'unknown'
      THEN 'N/A'
      ELSE transaction_date
      END;
      
COMMIT;
    
-- Validation Check - Should Return 0
SELECT COUNT(*)
FROM   dirty_cafe_sales
WHERE  transaction_date = ''
    OR LOWER(transaction_date) = 'error'
    OR LOWER(transaction_date) = 'unknown';

/* ======================================
STEP 8 - DATA CLEANING - CTEs for Querying 
========================================= */
-- Inspect All Values 
SELECT *
FROM   dirty_cafe_sales;

-- Updated, cleaner CTE Structure for Invalid Values 
-- Start by spot-checking transactionIDs for uniqueness
SELECT transaction_id, 
	   COUNT(*) 
FROM   dirty_cafe_sales
GROUP BY transaction_id
HAVING COUNT(*) > 1;

-- Define the bad value list ONCE and reference it in both valid and invalid values 
WITH BadRecords AS (
 	SELECT transaction_id
  	FROm   dirty_cafe_sales
  	WHERE LOWER(item) IN ('item missing', 'item unknown', 'item error')
  		OR quantity IS NULL
  		OR price_per_unit IS NULL
  		OR total_spent IS NULL
  		OR LOWER(payment_method) IN ('pmt error', 'pmt unknown', 'pmt missing')
  	    OR LOWER(location) IN ('location error', 'location unknown', 'location missing')
        OR transaction_date = 'N/A'
 )
 
 -- Transaction IDs are unique — LEFT JOIN with dirty_cafe_sales to find bad values 
 SELECT d.*, 
 	    (b.transaction_id IS NOT NULL) AS is_bad
 FROM   dirty_cafe_sales d
 LEFT JOIN BadRecords b 
 	ON d.transaction_id = b.transaction_id;

/* ======================================
STEP 9 - DATA QUERYING 
========================================= */
-- 1. Which items generate the most total revenue, and which the least? 
SELECT item,
	   COUNT(*) as TransactionCount,
       SUM(CAST(quantity AS INTEGER)) AS UnitsSold,
	   SUM(total_spent) AS TotalRevenue,
       ROUND(AVG(total_spent), 2) AS AvgTransactionValue
FROM   dirty_cafe_sales
WHERE  item NOT IN ('Item Missing', 'Item Unknown', 'Item Error')
	AND total_spent IS NOT NULL
GROUP BY item
ORDER BY TotalRevenue DESC;

-- 2. Which items sell the highest volume (units), and does that ranking match the revenue ranking from above?
WITH item_summary AS (
  SELECT item,
  	     SUM(CAST(quantity AS INTEGER)) AS UnitsSold,
  	     SUM(total_spent) AS TotalRevenue
  FROM   dirty_cafe_sales
  WHERE item NOT IN ('Item Missing', 'Item Unknown', 'Item Error')
  	AND total_spent IS NOT NULL
  GROUP BY item
)
SELECT item,
	   UnitsSold,
       TotalRevenue,
       RANK() OVER (ORDER BY TotalRevenue DESC) AS RevenueRank,
       RANK() OVER (ORDER BY UnitsSold DESC) AS VolumeRank
FROM item_summary
ORDER BY RevenueRank;

-- 3. What percentage of total revenue does each item contribute?
SELECT item,
       SUM(total_spent) AS ItemRevenue,
       ROUND(100.0 * SUM(total_spent) / SUM(SUM(total_spent)) OVER (), 2) AS PercentageOfTotal
FROM   dirty_cafe_sales
WHERE item NOT IN ('Item Missing', 'Item Unknown', 'Item Error')
  	AND total_spent IS NOT NULL
GROUP BY item
ORDER BY ItemRevenue DESC;
       
-- 4. What is the average transaction value per item 
SELECT item,
	   ROUND(AVG(total_spent), 2) AS AverageTransactionValue
FROm   dirty_cafe_sales
WHERE item NOT In ('Item Missing', 'Item Unknown', 'Item Error')
  	AND total_spent IS NOT NULL
GROUP BY item
ORDER BY AverageTransactionValue DESC;

-- 5. Because of bad item names and invalid total spent values,
-- how many rows (and what % of the dataset) had to be excluded from this analysis?
SELECT COUNT(*) 
FROM dirty_cafe_sales;

SELECT SUM(
  	CASE WHEN item IN ('Item Missing', 'Item Unknown', 'Item Error') 
  		OR total_spent IS NULL THEN 1 ELSE 0 END) AS ExcludedRows,
    COUNT(*) AS TotalRows,
    ROUND(100.0 * SUM(CASE WHEN item IN ('Item Missing', 'Item Unknown', 'Item Error') 
  		OR total_spent IS NULL THEN 1 ELSE 0 END) / COUNT(*), 1) AS PercentExcluded
FROM   dirty_cafe_sales;

-- 6. Do the top-selling items differ between In-store and Takeaway locations? 
SELECT item,
  	   location,
	   COUNT(*) as TransactionCount,
       SUM(CAST(quantity AS INTEGER)) AS UnitsSold,
	   SUM(total_spent) AS TotalRevenue,
       ROUND(AVG(total_spent), 2) AS AvgTransactionValue,
       RANK() OVER (PARTITION BY location ORDER BY SUM(total_spent) DESC) AS LocationRank
FROM   dirty_cafe_sales
WHERE  item NOT IN ('Item Missing', 'Item Unknown', 'Item Error')
  	AND location IN ('In-store', 'Takeaway')
GROUP BY item, location
ORDER BY location, TotalRevenue DESC;

-- GO  -- Will throw an error in SQLite. Keep for SQL Server Porting 
-- Final step: expose a clean, query-ready view for all downstream analysis
CREATE VIEW clean_sales AS
SELECT *
FROM dirty_cafe_sales
WHERE item NOT IN ('Item Missing', 'Item Unknown', 'Item Error')
  AND total_spent IS NOT NULL;
  
SELECT *
FROM clean_sales;
