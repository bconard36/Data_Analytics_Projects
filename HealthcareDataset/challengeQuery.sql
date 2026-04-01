-- Challenge Query - 4/1/26
-- Identify patients who are both high-risk and high-cost. 
-- A patient is considered high-risk if they have more than 3 diagnoses across all dx columns. 
-- A patient is considered high-cost if their total hospital charges exceed the 
-- average total charges across all outcome records. 
-- Return their patient ID, total diagnosis count, insurance type, and total charges, 
-- sorted by total charges descending.

-- CTE for high cost - if a patient's total charges exceed the avg

WITH HighCost AS (
	SELECT patient_id AS PatientID,
	       total_charges_us AS TotalChargesUSD
	FROM outcomes 
	WHERE total_charges_us > (

  		-- Subquery for average total charges across all outcome records 
		SELECT ROUND(AVG(total_charges_us), 2)
		FROM outcomes
	)
),

-- CTE for High Risk - if patients total diagnoses exceeds 3 

HighRisk AS (
	SELECT patient_id AS PatientID,
  		   dx_hypertension + dx_type2_diabete + dx_hyperlipidemi 
			+ dx_obesity + dx_coronary_arte
  			+ dx_heart_failure + dx_atrial_fibril + dx_chronic_kidne 
			+ dx_copd + dx_asthma + dx_depression
  			+ dx_anxiety + dx_hypothyroidis + dx_osteoarthriti + dx_type1_diabete 
		   AS DiagnosesCount
  	FROM patients
  	WHERE dx_hypertension + dx_type2_diabete + dx_hyperlipidemi + dx_obesity + dx_coronary_arte
  	      + dx_heart_failure + dx_atrial_fibril + dx_chronic_kidne + dx_copd + dx_asthma + dx_depression
  	      + dx_anxiety + dx_hypothyroidis + dx_osteoarthriti + dx_type1_diabete > 3
  	GROUP BY patient_id
)

-- Query to tie it all together, returning patientID, total diagnoses count, insurance type, and 
-- total charges for high risk and high cost patients
-- Sort by total charges descending 

SELECT p.patient_id AS PatientID,
       p.insurance_type AS InsuranceType,
       DiagnosesCount,
       TotalChargesUSD
FROM patients p 
	JOIN HighCost hc
    	ON hc.PatientID = p.patient_id
    JOIN HighRisk hr
    	ON hr.PatientID = hc.PatientID -- Joining through HighCost ensures only patients appearing in both CTEs are returned
 ORDER BY TotalChargesUSD DESC;
