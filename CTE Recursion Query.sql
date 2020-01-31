
/*
Recursive query to apply a hierarchical rank to data set
*/

IF OBJECT_ID('tempdb..#TEST', 'U') IS NOT NULL
DROP TABLE #TEST
GO
CREATE TABLE #TEST
(
  EmployeeID int NOT NULL PRIMARY KEY,
  FirstName varchar(50) NOT NULL,
  LastName varchar(50) NOT NULL,
  ManagerID int NULL
)
GO
INSERT INTO #TEST VALUES (101, 'Ken', 'Sánchez', NULL)
INSERT INTO #TEST VALUES (102, 'Terri', 'Duffy', 101)
INSERT INTO #TEST VALUES (103, 'Roberto', 'Tamburello', 101)
INSERT INTO #TEST VALUES (104, 'Rob', 'Walters', 102)
INSERT INTO #TEST VALUES (105, 'Gail', 'Erickson', 102)
INSERT INTO #TEST VALUES (106, 'Jossef', 'Goldberg', 103)
INSERT INTO #TEST VALUES (107, 'Dylan', 'Miller', 103)
INSERT INTO #TEST VALUES (108, 'Diane', 'Margheim', 105)
INSERT INTO #TEST VALUES (109, 'Gigi', 'Matthew', 105)
INSERT INTO #TEST VALUES (110, 'Michael', 'Raheem', 106)

SELECT * FROM #TEST

;WITH
	cteReports (EmpID, FirstName, LastName, MgrID, EmpLevel) AS (
		SELECT EmployeeID, FirstName, LastName, ManagerID, 1
		FROM #TEST
		WHERE ManagerID IS NULL
		
		UNION ALL
		
		SELECT e.EmployeeID, e.FirstName, e.LastName, e.ManagerID, r.EmpLevel + 1
		FROM #TEST e
		INNER JOIN cteReports r ON e.ManagerID = r.EmpID
	  )
SELECT
  FirstName + ' ' + LastName AS FullName, 
  EmpLevel,
  (SELECT FirstName + ' ' + LastName FROM #TEST 
    WHERE EmployeeID = cteReports.MgrID) AS Manager
FROM cteReports 
ORDER BY EmpLevel, MgrID


/*
Recursive query to pivot wide format column into long format
*/


CREATE TABLE #WIDEFORMAT 
(
	ID int NOT NULL PRIMARY KEY,
	PARTNUMBERS varchar(100)
)
INSERT INTO #WIDEFORMAT (ID, PARTNUMBERS)
SELECT 1,'CF' UNION ALL
SELECT 2,'CF' UNION ALL
SELECT 3,'CF' UNION ALL
SELECT 4,'Z5' UNION ALL
SELECT 5,'2Q  ,3Z  ,D7  ,DK  ,EF  ,V2  ,V4  ,WL' UNION ALL
SELECT 6,'CF  ,DK' UNION ALL
SELECT 7,'CF  ,DK' UNION ALL
SELECT 8,'BM  ,CF  ,DK  ,EF' UNION ALL
SELECT 9,'BM  ,CF  ,DK  ,EF  ,WL' UNION ALL
SELECT 10,'BM  ,CF  ,DK  ,EF  ,WL' UNION ALL
SELECT 11,'CF  ,DK' 
SELECT 12,'' 


;WITH LONGFORMAT (ID, PARTNUMBER, PARTNUMBERS) as (
	SELECT ID, LEFT(PARTNUMBERS, CHARINDEX(',', PARTNUMBERS + ',') - 1), STUFF(PARTNUMBERS, 1, CHARINDEX(',', PARTNUMBERS + ','), '')
	FROM ( SELECT ID, REPLACE(PARTNUMBERS,' ','') PARTNUMBERS FROM #WIDEFORMAT A) A
	UNION ALL
	SELECT ID, LEFT(PARTNUMBERS, CHARINDEX(',', PARTNUMBERS + ',') - 1), STUFF(PARTNUMBERS, 1, CHARINDEX(',', PARTNUMBERS + ','), '')
	FROM LONGFORMAT
	WHERE PARTNUMBERS > ''
)
SELECT ID, CASE WHEN PARTNUMBER = '' THEN '*' ELSE PARTNUMBER END PARTNUMBER
FROM LONGFORMAT A 
ORDER BY 1


