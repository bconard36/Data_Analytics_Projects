# Healthcare Dataset Analysis

A collection of SQL queries written against a healthcare dataset downloaded from Kaggle:
https://www.kaggle.com/datasets/sergionefedov/patient-records-100k-patients-15-conditions

The dataset contains multiple related tables with over 100K records, allowing for complex queries, joins, subqueries, and CTEs. Within this dataset, I wrote queries to extract result sets such as a patient's BMI ranking among all patients, a patient's total cost compared to the combined average of all costs, and the average medication count per patient within each insurance group. As a final query, I combined multiple analytical concepts into one real-world question: identifying all patients who are both **High Risk** (more than 3 accumulated diagnoses) and **High Cost** (total charges above the global average).

## Files in This Folder

- **SQL_Practice_WindowFunctions.sql** — The first of three query files. Focuses on window functions and partitioning, while also demonstrating CTEs and aggregates.
- **SQL_Practice_Subqueries.sql** — Contains three subqueries: one in the SELECT clause, one in the FROM clause, and one in the WHERE clause. Demonstrates how the same result can be reached without a CTE, and how syntax and behavior differ depending on where a subquery is placed.
- **SQL_Practice_ChallengeQuery.sql** — One final, most complex query, asking the most in-depth and realistic question about this dataset. Uses chained CTEs, aggregates, and careful ordering all within a single statement.
- **outcomes.csv** — The outcomes table from the healthcare dataset.
- **patients.csv** — The patients table from the healthcare dataset.

> **Note:** medications.csv was too large to include in this repository. Visit the Kaggle link above for the full set of CSV files.

## SQL Concepts Demonstrated

- Window Functions — RANK(), DENSE_RANK(), PARTITION BY, OVER()
- Aggregates — AVG(), SUM(), COUNT()
- Joins
- CTEs and chained CTEs
- Subqueries — in the SELECT clause, FROM clause, and WHERE clause
- Subqueries nested within a CTE
- Result formatting — ROUND(), column header aliases

## Tools Used

- Kaggle dataset (link above)
- SQLiteOnline.com — online IDE for executing SQL queries
- PGLite — online IDE available through SQLiteOnline.com, used for window function support

---
*Part of the [Data Analytics Projects](../) portfolio repository. All content and projects presented here are original work unless otherwise noted.*
