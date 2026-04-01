SQL Practice - 3/30/26 

- Window Functions, CTEs, and Aggregates 

QUERY 1: BMI Ranking by Insurance Type 
-- Description: Ranks all patients by BMI within their insurance 
-- group using DENSE_RANK(). Rank 1 = highest BMI per group. 
-- Demonstrates: Window functions, PARTITION BY, ORDER BY DESC 
-- Tables used: patients

 SELECT patient_id AS PatientID,
 	   insurance_type As Insurance,
        bmi AS BMI,
        DENSE_RANK() OVER (
         PARTITION BY insurance_type -- Restart rank for each insurance group
         ORDER BY BMI DESC           -- Highest BMI = Rank 1
         ) AS BMI_Rank
 FROM patients
 ORDER BY BMI, insurance_type, patient_id; -- Display ordering only, independent of ranking logic

—————————————————————————————————— 

-- QUERY 2: Per-Patient Medication Count vs. Global Average 
-- Description: For each patient, displays their total medication 
-- count alongside the average medication count across all patients. 
-- Demonstrates: CTEs, COUNT aggregation, AVG() OVER() window function 
-- Tables used: medications

 WITH MedicationCount AS 
 	(
	-- CTE: Pre-aggregates medication count per patient
	-- Produces one row per patient with their total medication count
     	SELECT patient_id AS PatientID,
 	   		   COUNT(*) AS MedicationCount
       	FROM medications
       	GROUP BY patient_id
     )
-- Outer Query: Displays individual count alongside global average
-- AVG() OVER() either empty OVER clause calculates across all rows 
-- without collapsing them, repeating the global average on every row
 SELECT PatientID,
 	   MedicationCount,
 	   Avg(MedicationCount) OVER() AS AvgMedicationCount 
 FROM MedicationCount;

—————————————————————————————————— 

QUERY 3: Top 3 Highest Charges by Discharge Disposition 
-- Description: Identifies the 3 most expensive hospital stays
-- within each discharge disposition group using chained CTEs 
-- and DENSE_RANK(). Filters on rank after window function is calculated, which requires the two-CTE structure. 
-- Demonstrates: Chained CTEs, DENSE_RANK(), PARTITION BY, filtering on window function results via WHERE clause 
-- Tables used: outcomes

WITH records AS 
(
	-- CTE 1: Pulls relevant columns from outcomes table
	-- No aggregation needed - outcomes has one row per patient 
  SELECT patient_id AS PatientID,
	     discharge_dispos AS DischargeNote,
         total_charges_us AS TotalChargesUSD
  FROM outcomes
), 
results AS 
(
	-- CTE 2: Applies DENSE_RANK() within each discharge group 
	-- PARTITION BY restarts ranking for each disposition type 
	-- ORDER BY DESC ensures highest charges = Rank 1 
	-- Cannot filter on this rank in a WHERE clause at this level
  SELECT PatientID,
	   DischargeNote,
       TotalChargesUSD,
       DENSE_RANK() OVER(
       	PARTITION BY DischargeNote      -- Rank within each discharge group
        ORDER BY TotalChargesUSD DESC   -- Highest Charge = Rank 2
       ) AS Top_3_Charges
  FROM records
)

-- Outer Query: Now that rank is a regular column, WHERE can filter on it 
-- <= 3 captures ranks 1, 2, and 3 (top 3 per group)
-- DENSE_RANK chosen over RANK to avoid gaps if tied charge values exist
SELECT *
FROM results
WHERE Top_3_Charges <= 3;
