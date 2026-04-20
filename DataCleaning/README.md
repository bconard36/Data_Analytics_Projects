# DataCleaning
This folder contains an intentionally dirty dataset, used for the purpose of cleaning and restructuring data for analysis. Values have been adjusted based on conditional logic and column-specific categorization, and valid values have been separated for further querying and analysis. 

## Original DataSet Specifications 
- _transaction_id_ - unique identifier for each row; 10000 unique values
- _item_: name of the item purchased - invalid values like empty strings, UNKNOWN, and ERROR
- _quantity_: quantity of the item purchased - invalid values like empty strings, UNKNOWN, and ERROR
- _price_per_unit_: price of a single unit of the item - invalid values like empty strings, UNKNOWN, and ERROR
- _total_spent_: total amount spent on the transaction - invalid values like empty strings, UNKNOWN, and ERROR
- _payment_method_ - invalid values like empty strings, UNKNOWN, and ERROR
- _location_ - invalid values like empty strings, UNKNOWN, and ERROR
- _transaction_date_ - invalid values like empty strings, UNKNOWN, and ERROR

# File List 
- SQL_Data_Cleaning_Practice.sql - A SQL file written to clean and restructure a dirty cafe sales data set. Item, pricing and location adjustments were handled first, where invalid values for price_per_unit, location and item were categorized based on column specification. Payment calculations were handled next, with extra care surrounding column values. Conditional logic was applied to only display total_spent values when payment_method and quantity values are known. Without a valid payment method or quantity, no reliable value for total_spent may be calculated. Lastly, transaction_date values were adjusted to display the same error message across all column values. Valid and error values were then separated into two separate CTEs for further analysis.
  
# Tools Used 
- sqliteonline.com 
- Kaggle
- VS Code for final file and code formatting

_This repository is actively maintained and continuously updated as new projects and coursework are completed._
