# DataCleaning

This folder contains an intentionally dirty dataset (sourced from Kaggle), used for practicing data cleaning, validation, and exploratory analysis in SQL. Values were profiled, standardized, and corrected based on conditional logic and column-specific rules. A single source-of-truth flag separates valid transactions from invalid ones for downstream querying, and the cleaned data was carried into a set of analysis queries and an interactive Tableau dashboard.

## Original Dataset Specifications

- **transaction_id** — unique identifier for each row; 10,000 rows total, all unique
- **item** — name of the item purchased; invalid values included empty strings, UNKNOWN, and ERROR
- **quantity** — quantity of the item purchased; invalid values included empty strings, UNKNOWN, and ERROR
- **price_per_unit** — price of a single unit of the item; invalid values included empty strings, UNKNOWN, and ERROR
- **total_spent** — total amount spent on the transaction; invalid values included empty strings, UNKNOWN, and ERROR
- **payment_method** — invalid values included empty strings, UNKNOWN, and ERROR
- **location** — invalid values included empty strings, UNKNOWN , and ERROR
- **transaction_date** — invalid values included empty strings,  UNKNOWN, and ERROR

## File List

- **SQL_Practice_Data_Cleaning.sql** 
  A SQL script that cleans and restructures the dirty cafe sales dataset in stages:
  - **Item & price standardization** — invalid item names were categorized (Item Missing, Item Unknown, Item Error) and price_per_unit was corrected against a reference table of known item prices; invalid items were set to NULL pricing.
  - **Location & payment method standardization** — invalid values in each column were categorized consistently (e.g., Location Missing, Pmt Error).
  - **Quantity cleanup** — invalid quantity values were converted to NULL so they wouldn't silently corrupt downstream arithmetic.
  - **Total spent recalculation** — total_spent was recalculated from price_per_unit × quantity, but only for transactions with a valid, known payment_method; without a valid payment method or quantity, total_spent is NULL rather than a placeholder string, since an invalid transaction shouldn't be reported as if it had a real value.
  - **Transaction date standardization** — invalid date values were normalized to a consistent placeholder.
  - **Validity flagging** — rather than maintaining two separate "valid" and "invalid" query definitions (which drifted out of sync during earlier iterations), a single BadRecords CTE defines what counts as invalid *once*, and is joined back against the full dataset to produce one is_bad flag column. This keeps the definition of "clean" in exactly one place instead of duplicated logic that can silently disagree with itself.
  - **clean_sales view** — a view built on top of the cleaned table, filtering out invalid items and missing revenue, so every downstream analysis query reads from one consistent, pre-filtered source instead of repeating filter conditions.
- **dirty_cafe_sales.csv** — the original, unmodified dataset as downloaded from Kaggle; 10,000 rows.
- **clean_cafe_sales.csv** — the output of the clean_sales view: 5,879 rows with a valid item name and a non-null total_spent. The remaining 4,121 rows (41.2% of the original dataset) were excluded because of invalid item names, unknown payment methods, or missing quantity/price data that made revenue impossible to calculate reliably. This is disclosed here rather than left implicit, since a nearly-two-in-five exclusion rate is a meaningful data quality finding in its own right, not just a cleanup detail.

## Analysis

Using the cleaned data, exploratory SQL queries were written to examine:
- Revenue and volume by item, including which items over- or under-perform on revenue relative to volume
- Revenue share (% of total) contributed by each item
- Revenue and volume broken down by location (In-store vs. Takeaway)
- Revenue and volume trends by month

Each analysis query explicitly filters out invalid records and reports what percentage of the dataset was excluded, so results are transparent about data quality rather than presenting clean-looking numbers without disclosing what was dropped.

## Visualization

Findings were built into an interactive Tableau dashboard covering item performance, location comparison, and monthly trends.

- **Live dashboard:** https://public.tableau.com/app/profile/billy.conard/viz/CafeSalesAnalysis_17852674405110/VolumeRevenueByMonth#1
- **Tableau Public profile:** https://public.tableau.com/app/profile/billy.conard/vizzes

## Tools Used

- **SQLiteOnline.com** — writing and running the cleaning and analysis SQL
- **Kaggle** — dataset source
- **VS Code** — final file formatting and syntax review
- **Tableau Public** — dashboard building and publishing

---
*This repository is actively maintained and continuously updated as new projects and coursework are completed.*
