# Healthcare Dataset Analysis 

A collection of queries written for a healthcare dataset, downloaded from kaggle.com: 
  •	https://www.kaggle.com/datasets/sergionefedov/patient-records-100k-patients-15-conditions

The dataset contains multiple tables with over 100K records, allowing for complex queries, joins, subqueries, and CTEs to be written. Within this dataset, I executed queries to extract result sets such as a patient’s BMI ranking amongst all BMI values, a patient’s total cost compared to the average of all costs combined, and the average medication count by patient in each insurance group. After seeing these results, as a final query, I pulled all patients who are considered High Risk (accumulated total diagnoses over 3) and High Cost (total charges greater than the global average), demonstrating the combination of multiple analytical concepts into one complex real-world question. 

# Files in this Folder
	•	SQL_Practice_WindowFunctions.sql - The first of three query documents for this healthcare data set. This file focuses on window functions and partitioning while also highlighting CTEs and aggregates
	•	SQL_Practice_Subqueries.sql - Contains three subqueries, one in the SELECT statement, one in the FROM clause, and one in the WHERE clause. This file demonstrates the flexibility of using subqueries to achieve the same results without using a CTE and the knowledge of syntax and functional differences of subquery placement. 
	•	SQL_Practice_challengeQuery.sql - Contains one final query asking the most complex, in-depth and realistic question about this data set. Utilizes chained CTEs, aggregates, and proper ordering all within one SQL statement. 
	•	outcomes.csv - The outcomes table from the healthcare dataset
	•	patients.csv - The patients table from the healthcare dataset

*NOTE: The medications.csv file was too large to include in this repository. Please visit the link above for the full csv files.*

# SQL Concepts Demonstrated
	•	Window Functions - RANK(), DENSE_RANK(), PARTITION BY, OVER()
	•	Aggregates - AVG(), SUM(), COUNT()
	•	JOINs 
	•	CTEs and Chained CTEs
	•	Subqueries - In the SELECT statement, FROM clause, and WHERE clause
	•	Subqueries within a CTE
	•	Formatting Results - ROUND(), Column Header Aliases

# Tools Used
	•	Kaggle Dataset - Link provided above
	•	sqliteonline.com - Online IDE for executing SQL queries
	•	PGLite - Online IDE available through sqliteonline.com for window function support

Note: All content and projects presented on this site are original work unless otherwise noted.
