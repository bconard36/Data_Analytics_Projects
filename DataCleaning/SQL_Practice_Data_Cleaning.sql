/* 
============================================
DATA CLEANING PRACTICE - dirty_cafe_sales dataset

GOAL: 
- Identify missing / invalid values across all columns 
- Standardize categorical inconsistencies
- Correct known structured values 
- Validate cleaning steps after transformation 

NOTE:
- This dataset is intentionally "dirty" for practice purposes. 
=============================================
*/

/* ==========================================
STEP 1 - EXPLORATORY ANALYSIS (DATA PROFILING)
=========================================== */ 
-- Check how many rows have invalid or placeholder values exist in price_per_unit column
SELECT COUNT(*)
FROM   dirty_cafe_sales
WHERE price_per_unit = ''
	OR price_per_unit = 'ERROR'
    OR price_per_unit = 'UNKNOWN';
    
-- Check how many invalid values exist across ALL major columns
SELECT COUNT(*)
FROM   dirty_cafe_sales
WHERE (item = '' OR item = 'ERROR' OR item = 'UNKNOWN')
  OR (quantity = '' OR quantity = 'ERROR' OR quantity = 'UNKNOWN')
  OR (price_per_unit = '' OR price_per_unit = 'ERROR' OR price_per_unit = 'UNKNOWN')
  OR (total_spent = '' OR total_spent = 'ERROR' OR total_spent = 'UNKNOWN')
  OR (payment_method = '' OR payment_method = 'ERROR' OR payment_method = 'UNKNOWN')
  OR (location = '' OR location = 'ERROR' OR location = 'UNKNOWN')
  OR (transaction_date = '' OR transaction_date = 'ERROR' OR transaction_date = 'UNKNOWN');

-- Check for naming inconsistencies in item column using partial string match 
SELECT *
FROM dirty_cafe_sales
WHERE LOWER(item) LIKE 'c%';
  
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
UPDATE dirty_cafe_sales
SET    item = CASE
		WHEN item = '' THEN 'MISSING'
		WHEN LOWER(item) = 'unknown' then 'ITEM_UNKNOWN'
    	WHEN LOWER(item) = 'error' THEN 'ITEM_ERROR'
        ELSE item
    	END,
-- Standardize price_per_unit values based on item reference
       price_per_unit = CASE
		WHEN item = 'Cake' THEN '3.0'
        WHEN item = 'Coffee' THEN '2.0'
        WHEN item = 'Cookie' THEN '1.0'
        WHEN item = 'Juice' THEN '3.0'
        WHEN item = 'Salad' THEN '5.0'
        WHEN item = 'Sandwich' THEN '4.0'
        WHEN item = 'Smoothie' then '4.0'
        WHEN item = 'Tea' THEN '1.5'
        WHEN LOWER(item) = 'missing' THEN 'N/A'
        WHEN LOWER(item) = 'item_unknown' Then 'N/A'
        WHEN LOWER(item) = 'item_error' THEN 'N/A'
	END 
WHERE item IN ('Cake', 'Coffee', 'Cookie', 'Juice', 'Salad', 'Sandwich', 'Smoothie', 'Tea')
    OR item = '' 
    OR LOWER(item) = 'error' 
    OR LOWER(item) = 'unknown';
    
-- VALIDATION: Ensure no remmaining bad values exist 
-- EXPECTED RESULT: 0
SELECT COUNT(*)
FROM   dirty_cafe_sales
WHERE price_per_unit = ''
	OR price_per_unit = 'ERROR'
    OR price_per_unit = 'UNKNOWN';

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
-- For missing/empty string values, update to MISSING 
-- For ERROR values, update to DATA_ERROR 
-- For UNKNOWN values, keep as UNKNOWN
UPDATE dirty_cafe_sales
SET location = CASE 
		WHEN location = '' THEN 'MISSING'
        WHEN LOWER(location) = 'error' THEN 'DATA_ERROR'
        WHEN LOWER(location) = 'unknown' THEN 'UNKNOWN'
    END
WHERE location = '' 
	OR LOWER(location) = 'error' 
    OR LOWER(location) = 'unknown';
    
-- Post-cleaning validation: Ensure no remaining bad values exist
-- Counts with value of UNKNOWN will remain unchanged because the name is the same!
SELECT location, 
	   COUNT(*)
FROM dirty_cafe_sales
WHERE location = '' -- Expected - 0 missing values now
	OR LOWER(location) = 'error' -- Expected - 0 ERROR values 
    OR LOWER(location) = 'unknown' -- Expected - 338 UNKNOWN values 
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
UPDATE dirty_cafe_sales
SET payment_method = CASE 
		WHEN payment_method = '' THEN 'MISSING'
        WHEN LOWER(payment_method) = 'error' THEN 'PMT_ERROR'
        WHEN LOWER(payment_method) = 'unknown' THEN 'UNKNOWN'
    END
WHERE payment_method = '' 
	OR LOWER(payment_method) = 'error' 
    OR LOWER(payment_method) = 'unknown';
    
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
STEP 5 - DATA CLEANING - TOTAL SPENT 
=========================================== */
-- UPDATE all total_spent values for VALID payment methods only 
-- Invalid payment methods cannot be charged, meaning total_spent is invalid.
-- CAST price_per_unit and quantity as DECIMAL for currency 
UPDATE dirty_cafe_sales
SET total_spent = CASE
		WHEN LOWER(payment_method) = 'cash'
        	OR LOWER(payment_method) = 'credit card'
            OR LOWER(payment_method) = 'digital wallet'
        	THEN (CAST(price_per_unit AS DECIMAL(10, 2)) * CAST(quantity AS INT)) 
		END;
-- Validate Updates based on logic above 
SELECT payment_method,
	   quantity,
	   price_per_unit,
       total_spent
FROM dirty_cafe_sales;

/* ==========================================
STEP 6 - DATA CLEANING - QUANTITY 
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

-- UPDATE total_spent first, then address quantity discrepancies 
UPDATE dirty_cafe_sales
SET total_spent = CASE
	WHEN quantity = '' 
    	OR LOWER(quantity) = 'error'
        OR LOWER(quantity) = 'unknown'
    THEN 'N/A'
    ELSE total_spent
    END;
    
UPDATE dirty_cafe_sales
SET quantity = CASE
	WHEN quantity = '' 
    	OR LOWER(quantity) = 'error'
        OR LOWER(quantity) = 'unknown'
    THEN 'N/A'
    ELSE quantity
    END;
    
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
UPDATE dirty_cafe_sales
SET transaction_date = CASE 
	WHEN transaction_date = ''
    OR LOWER(transaction_date) = 'error'
    OR LOWER(transaction_date) = 'unknown'
    THEN 'N/A'
    ELSE transaction_date
	END;
    
-- Validation Check - Should Return 0
SELECT COUNT(*)
FROM   dirty_cafe_sales
WHERE  transaction_date = ''
    OR LOWER(transaction_date) = 'error'
    OR LOWER(transaction_date) = 'unknown';

-- Inspect All Values 
SELECT *
FROM   dirty_cafe_sales;

-- Write CTE for Invalid Values 
WITH ErrorRecords AS (
	SELECT * 
  	FROM   dirty_cafe_sales
    WHERE  LOWER(item) IN ('missing', 'item_unknown', 'item_error')
  		OR quantity = 'N/A'
  		OR price_per_unit = 'N/A'
  		OR total_spent IS NULL
  		OR total_spent = 'N/A'
  		OR payment_method IN ('PMT_ERROR', 'UNKNOWN', 'MISSING')
  	    OR location IN ('DATA_ERROR', 'UNKNOWN', 'MISSING')
        OR transaction_date = 'N/A'
)
-- Inspect all ErrorRecords and ensure consistency across placeholders
SELECT *
FROM ErrorRecords;

-- Write CTE for Valid Values
WITH ValidRecords AS (
	SELECT *
  	FROM dirty_cafe_sales
  	WHERE LOWER(item) NOT IN ('missing', 'item_unknown', 'item_error')
  		AND quantity <> 'N/A'
  		AND price_per_unit <> 'N/A'
  		AND total_spent IS NOT NULL
  		AND payment_method NOT IN ('PMT_ERROR', 'UNKNOWN', 'MISSING')
  	    AND location NOT IN ('DATA_ERROR', 'UNKNOWN', 'MISSING')
  		AND transaction_date <> 'N/A'
)
-- Inspect all ValidRecords and ensure no placeholder values 
SELECT *
FROM ValidRecords;
