CREATE DATABASE SQL_PROJECT;
USE SQL_PROJECT;

***WORLD_POPULATION_ANALYSIS***

CREATE TABLE IF NOT EXISTS CIA_World_Populations(
country	VARCHAR(50),
area VARCHAR(50) NOT NULL,
birth_rate	VARCHAR(50) NOT NULL,
death_rate	VARCHAR(50) NOT NULL,
infant_mortality_rate	VARCHAR(50) NOT NULL,
internet_users	VARCHAR(50) NOT NULL,
life_exp_at_birth	VARCHAR(50) NOT NULL,
maternal_mortality_rate	VARCHAR(50) NOT NULL,
net_migration_rate VARCHAR(50) NOT NULL,
population	VARCHAR(50) NOT NULL,
population_growth_rate VARCHAR(50) NOT NULL
)

SELECT * FROM CIA_World_Populations limit 10;

LOAD DATA INFILE
'C:\cia_factbook.csv'
INTO TABLE CIA_World_Populations
FIELDS TERMINATED  BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

###1. Which country has the highest population?
SELECT country FROM CIA_World_Populations 
WHERE population = (SELECT max(population) FROM CIA_World_Populations 
         WHERE population NOT IN ('NA'))
LIMIT 1;

###2. Which country has the least number of people?
SELECT country FROM CIA_World_Populations 
WHERE population = (SELECT min(population) FROM CIA_World_Populations 
         WHERE population NOT IN ('NA'))
LIMIT 1;

###3. Which country is witnessing the highest population growth?
SELECT country FROM CIA_World_Populations 
where population_growth_rate = (SELECT max(population_growth_rate) from CIA_World_Populations
								where population_growth_rate not in ('NA'))
ORDER BY population_growth_rate DESC
LIMIT 1;

###4. Which country has an extraordinary number for the population?
SELECT COUNTRY, AVG(POPULATION)
FROM CIA_World_Populations
GROUP BY COUNTRY
ORDER BY 2 DESC LIMIT 5;

###5. Which is the most densely populated country in the world?
SELECT COUNTRY, AVG(population) as Hightest_population
FROM CIA_World_Populations
GROUP BY COUNTRY
ORDER BY 2 DESC LIMIT 1; 

***UK_ROAD_SAFETY***

CREATE TABLE Accident(
Accident_Index VARCHAR(50),	
Accident_Severity int)

LOAD DATA INFILE 
'C:\Accidents_2015.csv'
INTO TABLE Accident
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@col1, @dummy, @dummy, @dummy, @dummy, @dummy, @col2, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy)
SET accident_index=@col1, accident_severity=@col2;

SELECT * FROM Accident LIMIT 10;

CREATE TABLE vehicles(
	accident_index VARCHAR(13),
    vehicle_type VARCHAR(50)
)

LOAD DATA INFILE 
'C:\Vehicles_2015.csv'
INTO TABLE vehicles
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@col1, @dummy, @col2, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy)
SET accident_index=@col1, vehicle_type=@col2;

SELECT * FROM vehicles LIMIT 10;

CREATE TABLE vehicle_types(
	vehicle_code INT,
    vehicle_type VARCHAR(50)
)

LOAD DATA INFILE 
'C:\vehicle_types.csv'
INTO TABLE vehicle_types
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SELECT * FROM vehicle_types;

--1.Evaluate the median severity value of accidents caused by various Motorcycles.*/

SET @rowindex := -1;
SELECT
   AVG(NEW_TABLE.Accident_Severity) AS MEDIAN
FROM
   (SELECT @rowindex:=@rowindex + 1 AS rowindex,
           v.vehicle_type, a.Accident_Severity
    FROM ACCIDENT A 
    LEFT JOIN VEHICLES V ON A.Accident_Index = V.Accident_Index
	LEFT JOIN VEHICLE_TYPES VT ON V.Vehicle_Type = VT.vehicle_type
    ORDER BY Accident_Severity) AS NEW_TABLE
WHERE
NEW_TABLE.rowindex IN (FLOOR(@rowindex / 2) , CEIL(@rowindex / 2));

/*Task 2. 
Evaluate Accident Severity and Total Accidents per Vehicle Type*/

SELECT vt.vehicle_type AS 'Vehicle Type', a.accident_severity AS 'Severity', COUNT(vt.vehicle_type) AS 'Number of Accidents'
FROM accident a
JOIN vehicles v ON a.accident_index = v.accident_index
JOIN vehicle_types vt ON v.vehicle_type = vt.vehicle_code
GROUP BY 1
ORDER BY 2,3;

/*Task 3. 
Calculate the Average Severity by vehicle type.*/

SELECT vt.vehicle_type AS 'Vehicle Type', AVG(a.accident_severity) AS 'Average Severity'
FROM accident a
JOIN vehicles v ON a.accident_index = v.accident_index
JOIN vehicle_types vt ON v.vehicle_type = vt.vehicle_code
GROUP BY 1;

/*Task 4. 
Calculate the Average Severity and Total Accidents by Motorcycle.*/

SELECT vt.vehicle_type AS 'Vehicle Type', AVG(a.accident_severity) AS 'Average Severity'
FROM accident a
JOIN vehicles v ON a.accident_index = v.accident_index
JOIN vehicle_types vt ON v.vehicle_type = vt.vehicle_code
WHERE vt.vehicle_type LIKE '%otorcycle%'
GROUP BY 1;