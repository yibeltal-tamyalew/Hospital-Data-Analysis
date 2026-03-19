create DATABASE HospitalData

 --Create Relationships (FOREIGN KEYS)

--Now we connect tables like a real system.
-- Patient → Admissions
USE HospitalData
GO
ALTER TABLE admissions
ADD CONSTRAINT FK_Admissions_Patient
FOREIGN KEY (PatientID) REFERENCES patients(PatientID);

-- Doctor → Admissions
ALTER TABLE admissions
ADD CONSTRAINT FK_Admissions_Doctor
FOREIGN KEY (DoctorID) REFERENCES doctors(DoctorID);

-- Department → Admissions
ALTER TABLE admissions
ADD CONSTRAINT FK_Admissions_Department
FOREIGN KEY (DepartmentID) REFERENCES departments(DepartmentID);

SELECT *
FROM admissions;


-- REAL ANALYST QUERY 
--👉 Combine everything:
--So instead of separate tables, you get one clean report:
SELECT 
    p.FirstName,
    p.LastName,
    d.Name AS DoctorName,
    dep.DepartmentName,
    a.Cost
FROM admissions a
JOIN patients p ON a.PatientID = p.PatientID
JOIN doctors d ON a.DoctorID = d.DoctorID
JOIN departments dep ON a.DepartmentID = dep.DepartmentID;
--🧠 What this means

--You are:
--Connecting 4 tables
--Building real report

--This = Data Analyst work

--Total revenue
SELECT SUM(Cost) AS TotalRevenue
FROM admissions;

--Top 5 expensive admissions
SELECT TOP 5 *
FROM admissions
ORDER BY Cost DESC;

--Revenue per department
SELECT dep.DepartmentName, SUM(a.Cost) AS TotalRevenue
FROM admissions a
JOIN departments dep ON a.DepartmentID = dep.DepartmentID
GROUP BY dep.DepartmentName;

--i just did:
--✔ Database design
--✔ Import data
--✔ Create relationships
--✔ Write real queries

-- DATA CLEANING (VERY IMPORTANT)
-- Find NULL values
SELECT *
FROM admissions
WHERE Cost IS NULL;

--2. Fix NULL values
UPDATE admissions
SET Cost = 0
WHERE Cost IS NULL;

--3. Find duplicates
SELECT PatientID, DoctorID, COUNT(*) AS count_duplicate
FROM admissions
GROUP BY PatientID, DoctorID
HAVING COUNT(*) > 1;

--4. Remove duplicates (advanced)
--This creates a temporary table (CTE)
WITH CTE AS (
    SELECT *,
    ROW_NUMBER() OVER (PARTITION BY PatientID, DoctorID ORDER BY AdmissionID) AS rn
    FROM admissions
)
DELETE FROM CTE WHERE rn > 1;
-- ADVANCED ANALYSIS
--Top 5 Doctors by Revenue
SELECT TOP 5 
    d.Name,
    SUM(a.Cost) AS TotalRevenue
FROM admissions a
JOIN doctors d ON a.DoctorID = d.DoctorID
GROUP BY d.Name
ORDER BY TotalRevenue DESC;

--Patient Visit Count
SELECT 
    p.FirstName,
    p.LastName,
    COUNT(a.AdmissionID) AS TotalVisits
FROM admissions a
JOIN patients p ON a.PatientID = p.PatientID
GROUP BY p.FirstName, p.LastName
ORDER BY TotalVisits DESC;

--Department Workload
SELECT 
    dep.DepartmentName,
    COUNT(a.AdmissionID) AS TotalAdmissions
FROM admissions a
JOIN departments dep ON a.DepartmentID = dep.DepartmentID
GROUP BY dep.DepartmentName;

--CREATE VIEW (for reports)
CREATE VIEW vw_HospitalReport AS
SELECT 
    p.FirstName,
    p.LastName,
    d.Name AS DoctorName,
    dep.DepartmentName,
    a.Cost
FROM admissions a
JOIN patients p ON a.PatientID = p.PatientID
JOIN doctors d ON a.DoctorID = d.DoctorID
JOIN departments dep ON a.DepartmentID = dep.DepartmentID;


ALTER VIEW vw_HospitalReport AS
SELECT 
    a.AdmissionID,
    p.FirstName,
    p.LastName,
    d.Name AS DoctorName,
    dep.DepartmentName,
    a.Cost
FROM admissions a
JOIN patients p ON a.PatientID = p.PatientID
JOIN doctors d ON a.DoctorID = d.DoctorID
JOIN departments dep ON a.DepartmentID = dep.DepartmentID;


--Use it:
SELECT * FROM vw_HospitalReport;


-- STORED PROCEDURE
--Example: Get patient history
CREATE PROCEDURE sp_GetPatientHistory
@PatientID INT
AS
BEGIN
    SELECT *
    FROM admissions
    WHERE PatientID = @PatientID;
END;

EXEC sp_GetPatientHistory 1;