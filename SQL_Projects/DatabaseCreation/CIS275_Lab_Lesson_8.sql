/*
*******************************************************************************************
CIS275 at PCC
CIS275 Lab Week 8: using SQL SERVER and CIS275Sandboxx
*******************************************************************************************

                                   CERTIFICATION:

   By typing my name below I certify that the enclosed is original coding written by myself
without unauthorized assistance, such as seeing answers to versions of specific 
questions. If I use AI for any questions, I will list the tool used (ChatGPT, Gemini, etc)
and the prompt(s) I gave for each. I agree to abide by class restrictions and understand 
that if I have violated them, I may receive reduced credit (or none) for this assignment.

                CONSENT:   Billy Conard
                DATE:      August 18th, 2025

*******************************************************************************************
*/

GO
PRINT '|---' + REPLICATE('+----',15) + '|'
PRINT 'Read the questions below and insert your code where prompted. When you are finished,
you should be able to run the file as a script to execute all answers sequentially (without errors!).

This week, there are seven questions worth 30 points total. The point totals for each 
question depend on the difficulty of the question. 
Please be sure to answer each part of each question for full credit.

All SQL should be properly formatted as in previous weeks.';
PRINT '|---' + REPLICATE('+----',15) + '|' + CHAR(10) + CHAR(10)
GO

PRINT 'CIS 275, Lab Week 8, Question 1  [5 pts possible]:
Create tables
-------------
Review your assignment 7. If you never finished it, email your instructor.
 
Pick three related tables you identified for your system. 
Create those tables within the CIS275Sandboxx database. Here are things you need to follow:
1- All table names must start with your initials, such as GSF_Nurses. If they exist (another 
   student has the same initials), add a number to the end of your initials to make it unique.
2- Add all your columns. The columns must be identical to the columns you proposed 
   in your lab 7, with any corrections based on the feedback.
3- All your primary and foreign keys must be identified.

You have the permissions required to create tables in the CIS275Sandboxx database.
You cannot create Databases.
' + CHAR(10)

GO
-- 3 Parent Tables created first - Patients, Nurses, Doctors. Linking tables after to allow for relationships.
-- Put initials (BC) at start of each table. Add all columns, must be identical to Lab 7 (extra columns added to
-- Patients table per the instructor's feedback).
-- Identify all PKs and FKs

USE CIS275Sandboxx;

CREATE TABLE BC_Patients (
    PatientID                 NUMERIC(6, 0) PRIMARY KEY IDENTITY,
    PatientFirstName          NVARCHAR(50) NOT NULL,
    PatientLastName           NVARCHAR(50) NOT NULL,
    DateOfBirth               DATE NOT NULL,
    PatientGender             VARCHAR(10) NOT NULL,
    PatientInsurance          NVARCHAR(100) NULL,
    PatientCondition          NVARCHAR(100) NOT NULL,
    PatientAddress            NVARCHAR(100) NULL,
    PatientCity               NVARCHAR(100) NULL,
    PatientState              VARCHAR(2) NULL,
    PatientZip                VARCHAR(10) NULL,
    PatientPhone              VARCHAR(20) NOT NULL,
    PatientEmail              VARCHAR(256) NOT NULL UNIQUE
);

CREATE TABLE BC_Nurses (
    NurseID         INT PRIMARY KEY IDENTITY,
    NurseFirstName  NVARCHAR(50) NOT NULL,
    NurseLastName   NVARCHAR(50),
    NurseEmail      NVARCHAR(256) NOT NULL UNIQUE,
    NursePhone      VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE BC_Doctors (
    DoctorID         INT PRIMARY KEY IDENTITY,
    DoctorFirstName  NVARCHAR(50) NOT NULL,
    DoctorLastName   NVARCHAR(50) NOT NULL,
    DoctorEmail      NVARCHAR(256) NOT NULL UNIQUE,
    DoctorPhone      VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE BC_PatientNurseAssignment (
     FK_PatientID NUMERIC(6, 0) NOT NULL FOREIGN KEY REFERENCES BC_Patients (PatientID),
     FK_NurseID   INT NOT NULL FOREIGN KEY REFERENCES BC_Nurses (NurseID),
     PRIMARY KEY (FK_PatientID, FK_NurseID)
);

CREATE TABLE BC_TreatmentAssignment (
     FK_DoctorID  INT NOT NULL FOREIGN KEY REFERENCES BC_Doctors (DoctorID),
     FK_PatientID NUMERIC(6, 0) NOT NULL FOREIGN KEY REFERENCES BC_Patients (PatientID),
     PRIMARY KEY (FK_DoctorID, FK_PatientID)
);

CREATE TABLE BC_DoctorNurseAssignment (
     FK_DoctorID INT NOT NULL FOREIGN KEY REFERENCES BC_Doctors (DoctorID),
     FK_NurseID  INT NOT NULL FOREIGN KEY REFERENCES BC_Nurses (NurseID),
     PRIMARY KEY (FK_DoctorID, FK_NurseID)
);

--

GO
PRINT 'CIS 275, Lab Week 8, Question 2  [3 pts possible]:
Adding columns
-----------
Add two more columns to each of two of the tables you created.

' + CHAR(10)

GO
--
-- Add two more columns to each of the tables created above.

ALTER TABLE BC_Patients
ADD EmergencyContactName  NVARCHAR(100),
    EmergencyContactPhone VARCHAR(20);

ALTER TABLE BC_Nurses
ADD NurseHireDate DATE,
    NurseShift    VARCHAR(20);

ALTER TABLE BC_Doctors
ADD Specialty       NVARCHAR(100),
    DoctorHireDate  Date;

ALTER TABLE BC_PatientNurseAssignment
ADD NPAssignmentDate DATE,
    NPANotes         VARCHAR(255);

ALTER TABLE BC_TreatmentAssignment
ADD DPAssignmentDate DATE,
    DPANotes         VARCHAR(255);

ALTER TABLE BC_DoctorNurseAssignment
ADD DNAssignmentDate DATE,
    DNANotes         VARCHAR(255);

GO
PRINT 'CIS 275, Lab Week 8, Question 3  [3 pts possible]:
Adding data
-----------
Use INSERT INTO to add four records to each of the tables you created in Question 1.
You need meaningful data (not things like MMMMM!).

' + CHAR(10)

GO
--
-- Add 4 (four) records to each of the tables created in Question 1.
-- Make them meaningful. Valid, detailed records

INSERT INTO BC_Patients
     (PatientFirstName, PatientLastName, DateOfBirth, PatientGender, PatientInsurance,
      PatientCondition, PatientAddress, PatientCity, PatientState, PatientZip, PatientPhone,
      PatientEmail, EmergencyContactName, EmergencyContactPhone)
VALUES ('Jason', 'Jones', '1975-03-02', 'Male', 'Kaiser', 'Broken Leg',
            '674 SE Main St', 'Portland', 'OR', '97236', '555-555-0987',
            'jasonjonesconsulting@hotmail.com', 'Sherry Jones', '555-555-1234'),
       ('Joel', 'Rivers', '1999-12-03', 'Male', 'Cigna', 'Stomach Pain',
            '9032 W Canyon Club Dr', 'Gresham', 'OR', '97030', '555-555-3333',
            'riverratjoel@gmail.com', 'Mary Rivers', '555-555-6565'),
       ('Shannon', 'McCale', '1987-02-24', 'Female', 'Providence', 'Sliced Finger',
            '5436 N 33rd Ave', 'Salem', 'OR', '97310', '555-555-0000',
            'mccaleshannon42@yahoo.com', 'Mike McCale', '555-555-0909'),
       ('Stacey', 'Childress', '1992-06-19', 'Non-Binary', 'Kaiser', 'Cast Removal',
            '9351 E Highgate Pl', 'Portland', 'OR', '97202', '555-555-7777',
            'princessstacey@outlook.com', 'Amy Morris', '555-555-3212');

INSERT INTO BC_Nurses
     (NurseFirstName, NurseLastName, NurseEmail, NursePhone, NurseHireDate, NurseShift)
VALUES ('Jennifer', 'Daniels', 'jdaniels@acahospital.org', '555-555-5555 x 1234', '2019-03-17', 'Day 12-Hour'),
       ('Steven', 'Goodman', 'sgoodman@acahospital.org', '555-555-5555 x 0876', '2021-09-13', 'Evening 10-Hour'),
       ('Kyle', 'Paulson', 'spaulson@acahospital.org', '555-555-5555 x 4321', '2020-04-02', 'On-Call'),
       ('Anna', 'West', 'awest@acahospital.org', '555-555-5555 x 6754', '2018-05-06', 'Day 10-Hour');

INSERT INTO BC_Doctors
     (DoctorFirstName, DoctorLastName, DoctorEmail, DoctorPhone, Specialty, DoctorHireDate)
VALUES ('Kevin', 'Anderson', 'kanderson@acahospital.org', '555-555-5555 x 124', 'Orthopedics', '2023-12-01'),
       ('Amanda', 'Pritchard', 'apritchard@acahospital.org', '555-555-5555 x 430', 'Pediatrics', '2021-01-04'),
       ('Amy', 'Rohrbach', 'arohrbach@acahospital.org', '555-555-5555 x 942', 'General Surgery', '2019-06-04'),
       ('Samuel', 'Bernstein', 'sbernstein@acahospital.org', '555-555-5555 x 409', 'Gastroenterology', '2018-07-20');

INSERT INTO BC_PatientNurseAssignment
     (FK_PatientID, FK_NurseID, NPAssignmentDate, NPANotes)
VALUES (1, 2, '2024-12-30', 'Patient 1 assigned Nurse 2'),
       (2, 3, '2025-01-22', 'Patient 2 assigned Nurse 3'),
       (3, 1, '2025-08-01', 'Patient 3 assigned Nurse 1'),
       (4, 4, '2025-08-03', 'Patient 4 assigned Nurse 4');

INSERT INTO BC_TreatmentAssignment
     (FK_DoctorID, FK_PatientID, DPAssignmentDate, DPANotes)
VALUES (2, 1, '2024-12-30', 'Doctor 2 assigned Patient 1'),
       (3, 2, '2025-01-22', 'Doctor 3 assigned Patient 2'),
       (3, 3, '2025-08-01', 'Doctor 3 assigned Patient 3'),
       (1, 4, '2025-08-03', 'Doctor 1 assigned Patient 4');

INSERT INTO BC_DoctorNurseAssignment
     (FK_DoctorID, FK_NurseID, DNAssignmentDate, DNANotes)
VALUES (2, 2, '2025-07-29', 'Doctor 2 assigned Nurse 2'),
       (3, 3, '2025-08-01', 'Doctor 3 assigned Nurse 3'),
       (3, 1, '2025-08-01', 'Doctor 3 assigned Nurse 1'),
       (1, 4, '2025-08-03', 'Doctor 1 assigned Nurse 4');


--

GO
PRINT 'CIS 275, Lab Week 8, Question 4  [3 pts possible]:
Drop a column
---------------------
Drop one column from one of the tables.
' + CHAR(10)

GO

--
ALTER TABLE BC_Nurses
DROP COLUMN NurseShift;

--

GO
PRINT 'CIS 275, Lab Week 8, Question 5  [4 pts possible]:
Add a new table
-------------
Pick another table from your last assignment and add it to the database with all its columns. 
Once again, all tables must start with your initials. 
Add three records to this table.
' + CHAR(10)

GO

--
USE CIS275Sandboxx;

CREATE TABLE BC_Invoices (
    InvoiceID       NUMERIC(6, 0) PRIMARY KEY IDENTITY,
    FK_PatientID    NUMERIC(6, 0) NOT NULL FOREIGN KEY REFERENCES BC_Patients (PatientID),
    ApptDate        DATE NOT NULL,
    InvoiceDate     DATE NOT NULL,
    InvoiceTotal    MONEY NULL,
    InvoiceDueDate  DATE NOT NULL,
    PaymentTotal    MONEY NULL,
    PaymentDate     DATE NULL,
    DaysPastDue     INT NULL
);

-- Add 3 records to BC_Invoices
INSERT INTO BC_Invoices
     (FK_PatientID, ApptDate, InvoiceDate, InvoiceTotal, InvoiceDueDate, PaymentTotal,
      PaymentDate, DaysPastDue)
VALUES (1, '2024-12-30', '2025-01-04', 250.75, '2025-02-01', 250.75, '2025-01-22', NULL),
       (2, '2025-01-22', '2025-02-01', 1220.00, '2025-03-01', NULL, NULL, 167),
       (3, '2025-08-01', '2025-08-15', 450.91, '2025-09-01', NULL, NULL, NULL);
--

GO
PRINT 'CIS 275, Lab Week 8, Question 6  [3 pts possible]:
Changing values
---------------
Use UPDATE commands to change the values of three columns of each table
' + CHAR(10)

GO
--
-- Update 3 columns (Address, City, State) in the BC_Patients table

UPDATE BC_Patients
SET PatientAddress = '4982 SW Phoenix Lane',
    PatientCity = 'Beaverton',
    PatientZip = '97007'
WHERE PatientID = 2;
--
-- Update 3 columns (PaymentTotal, PaymentDate, DaysPastDue) in the BC_Invoices Table

UPDATE BC_Invoices
SET PaymentTotal = 450.91,
    PaymentDate = '2025-08-15',
    DaysPastDue = 0
WHERE FK_PatientID = 3;
--
-- Update One Column (Phone) in the BC_Nurses Table

UPDATE BC_Nurses
SET NursePhone = '555-555-5555 x 4409'
WHERE NurseID = 4;
--
-- Update 2 more columns (Email, Phone) in the BC_Nurses Table

UPDATE BC_Nurses
SET NurseEmail = 'spgoodman@acahospital.org',
    NursePhone = '555-555-5555 x 5501'
WHERE NurseID = 2;
--
-- Update 2 columns (HireDate, Specialty) in the BC_Doctors Table

UPDATE BC_Doctors
SET DoctorHireDate = '2019-04-06',
    Specialty = 'Internal Medicine'
WHERE DoctorID = 3;
--
-- Update 1 more column (Specialty) in the BC_Doctors Table

UPDATE BC_Doctors
SET Specialty = 'Emergency Medicine'
WHERE DoctorID = 1;
--
-- Update 3 columns in the BC_PatientNurseAssignment Table

UPDATE BC_PatientNurseAssignment
SET FK_NurseID = 3,
    NPAssignmentDate = '2025-08-15',
    NPANotes = 'Patient 1 assigned Nurse 3'
WHERE FK_PatientID = 1;
--
-- Update 3 columns in the BC_TreatmentAssignment Table

UPDATE BC_TreatmentAssignment
SET FK_DoctorID = 4,
    DPAssignmentDate = '2025-08-15',
    DPANotes = 'Doctor 4 assigned Patient 3'
WHERE FK_PatientID = 3;
--
-- Update 3 columns in the BC_DoctorNurseAssignment Table

UPDATE BC_DoctorNurseAssignment
SET FK_DoctorID = 4,
    DNAssignmentDate = '2025-08-16',
    DNANotes = 'Doctor 4 assigned Nurse 3'
WHERE FK_NurseID = 3;

--

GO
PRINT 'CIS 275, Lab Week 8, Question 7  [9 pts possible]:
Creating views
--------------
Create a VIEW that uses a JOIN query to display the content of your three related tables. 
Include all the columns and rows from all three tables in your query. 
Do not forget to add your initials at the beginning of the name. 

Display all rows and columns from your view.
' + CHAR(10)

GO
--
-- Some columns are named the same in different tables. Aliases are needed for the view, so cannot use SELECT *
-- Start with Patients, then link to Nurses who are treating the patient. Link patient to doctors next, and finally
-- show the doctor-nurse pairings (if applicable). Use LEFT JOINS to include all patients and respective staff details

USE CIS275Sandboxx;

GO

CREATE VIEW BC_StaffPatientAssignments
AS
SELECT BCP.PatientID,
       BCP.PatientFirstName,
       BCP.PatientLastName,
       BCP.DateOfBirth,
       BCP.PatientGender,
       BCP.PatientInsurance,
       BCP.PatientCondition,
       BCP.PatientAddress,
       BCP.PatientCity,
       BCP.PatientState,
       BCP.PatientZip,
       BCP.PatientPhone,
       BCP.PatientEmail,
       BCP.EmergencyContactName,
       BCP.EmergencyContactPhone,
       BCPN.FK_PatientID AS BCPN_PatientID,
       BCPN.FK_NurseID AS BCPN_NurseID,
       BCPN.NPAssignmentDate,
       BCPN.NPANotes,
       BCN.NurseID AS NurseID,
       BCN.NurseFirstName AS NurseFirstName,
       BCN.NurseLastName AS NurseLastName,
       BCN.NurseEmail AS NurseEmail,
       BCN.NursePhone AS NursePhone,
       BCN.NurseHireDate AS NurseHireDate,
       BCDN.FK_DoctorID AS BCDN_DoctorID,
       BCDN.FK_NurseID AS BCDN_NurseID,
       BCDN.DNAssignmentDate,
       BCDN.DNANotes,
       BCD.DoctorID AS DoctorID,
       BCD.DoctorFirstName AS DoctorFirstName,
       BCD.DoctorLastName AS DoctorLastName,
       BCD.DoctorEmail AS DoctorEmail,
       BCD.DoctorPhone AS DoctorPhone,
       BCD.Specialty AS DoctorSpecialty,
       BCD.DoctorHireDate AS DoctorHireDate,
       BCTA.FK_DoctorID AS BCTA_DoctorID,
       BCTA.FK_PatientID AS BCTA_PatientID,
       BCTA.DPAssignmentDate,
       BCTA.DPANotes
FROM BC_Patients BCP
LEFT JOIN BC_PatientNurseAssignment BCPN
    ON BCP.PatientID = BCPN.FK_PatientID
LEFT JOIN BC_Nurses BCN
    ON BCPN.FK_NurseID = BCN.NurseID
LEFT JOIN BC_TreatmentAssignment BCTA
    ON BCP.PatientID = BCTA.FK_PatientID
LEFT JOIN BC_Doctors BCD
    ON BCTA.FK_DoctorID = BCD.DoctorID
LEFT JOIN BC_DoctorNurseAssignment BCDN
    ON BCD.DoctorID = BCDN.FK_DoctorID;


GO
--

GO
-------------------------------------------------------------------------------------
-- This is an anonymous program block. DO NOT CHANGE OR DELETE.
-------------------------------------------------------------------------------------
BEGIN
    PRINT '|---' + REPLICATE('+----',15) + '|';
    PRINT ' End of CIS275 Lab Week 8' + REPLICATE(' ',50) + CONVERT(CHAR(12),GETDATE(),101);
    PRINT '|---' + REPLICATE('+----',15) + '|';
END;

