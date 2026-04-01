-- Subquery Practice - 3/31/26
-- Prompt 1:
-- Return all patients whose BMI is higher than the average BMI across all patients
-- Show their patient ID, age, BMI, and insurance type
-- Inner query will be average BMI across all patients
-- Outer query will be all patients with a BMI higher than the average

SELECT patient_id AS PatientID,
	   age AS Age,
       bmi As BMI,
       insurance_type AS Insurance_Type
FROM patients 
WHERE bmi > (
  SELECT AVG(bmi) 
  FROM patients 
);

-- Prompt 2: 
-- For each insurance type, show the average number of medications per patient
-- Use a subquery to first calculate each patients medication count
-- Then, aggregate those counts by insurance type in the outer query 
-- Write an inline subquery in the FROM clause rather than naming it as a CTE first 

SELECT p.insurance_type AS InsuranceType,
	   ROUND(AVG(MedicationCount), 2) AS AvgMedicationCount
FROM patients p 
	JOIN (
      SELECT patient_id,
             COUNT(*) AS MedicationCount
	  FROM medications
	  GROUP BY patient_id
    ) AS c 
    	ON c.patient_id = p.patient_id
GROUP BY InsuranceType;

-- Prompt 3: 
-- For each patient in the outcomes table, show their patient ID, total charges, 
-- and the difference between their charges and the average total charges across 
-- all outcome records. Label that difference clearly.

SELECT patient_id AS PatientID,
       total_charges_us AS TotalChargesUSD,
       ROUND(total_charges_us - (
         SELECT ROUND(AVG(total_charges_us), 2)
         FROM outcomes
       ), 2) AS Difference
FROM outcomes;
