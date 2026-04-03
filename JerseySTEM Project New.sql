-- Aim: Ranking 
-- -- For The Visualization visit https://public.tableau.com/app/profile/olubunmi.ojo/viz/JerseyStemProjectTableauVisualization/Dashboard1

-- 1. The New Jersey Counties by number of students between 5-8 grade from Title 1 schools
-- 2. Within each Title 1 School District, the individual schools by number of students in grade 5-8.

-- Note: The New Jersey data was converted from pdf to csv using the Tabula software for it to be usable in MySQL AND the enrollment dataset was converted from excel worksheet to csv in Microsoft excel.

-- Data Cleaning In MySQL

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or Blank Values
-- 4. Remove Any Columns

-- Remove Duplicates

-- It is best practice to not work on the original data file but to create extra copies

CREATE TABLE new_enrollment_data_1
LIKE `recent 2024-2025 enrollment data`; 

INSERT new_enrollment_data_1
SELECT *
FROM `recent 2024-2025 enrollment data`;

SELECT *
FROM new_enrollment_data_1
;

-- To check for duplicates

WITH duplicate_cte AS 
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY `County Name`, `District Name`, `School Name`, `Total Enrollment`, `Fifth Grade`, `Sixth Grade`, `Seventh Grade`, `Eighth Grade`) AS row_num
FROM new_enrollment_data_1
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;
-- No duplicates were found for the required column

-- Standardize The Data

SELECT DISTINCT `County Code`, `County Name`, `District Code`, `District Name`, `School Code`, `School Name`
FROM new_enrollment_data_1
; 

SELECT  `Fifth Grade`, `Sixth Grade`, `Seventh Grade`, `Eighth Grade`
FROM new_enrollment_data_1
; 

-- Null Values or Blank Values

SELECT `School Name`, `County Name`, `District Name` 
FROM new_enrollment_data_1
WHERE `School Name` IS NULL OR `School Name` = ''
OR `County Name` IS NULL OR `County Name` = ''
OR `District Name` IS NULL OR `District Name` = '';

-- No NULL or blanks were found for columns school name, district name and county name.

SELECT `Fifth Grade`, `Sixth Grade`, `Seventh Grade`, `Eighth Grade` 
FROM new_enrollment_data_1
WHERE `Fifth Grade` IS NULL OR `Fifth Grade` = ''
OR `Sixth Grade` IS NULL OR `Sixth Grade` = ''
OR `Seventh Grade` IS NULL OR `Seventh Grade` = ''
OR `Eighth Grade` IS NULL OR `Eighth Grade` = '' ;

-- No NULL or blanks were found for Fifth Grade, Sixth Grade, Seventh Grade, Eighth Grade only zeros.

-- Exploring Data for ranking and to find trends or patterns.

SELECT DISTINCT  `County Name`, SUM(`Fifth Grade`) AS 5th, SUM(`Sixth Grade`) AS 6th, SUM(`Seventh Grade`) AS 7th, SUM(`Eighth Grade`) AS 8th
FROM new_enrollment_data_1
GROUP BY `County Name` 
ORDER BY 5th DESC, 6th DESC, 7th DESC, 8th DESC; 

SELECT DISTINCT (`School Name`), `District Name`, SUM(`Fifth Grade`) AS 5th, SUM(`Sixth Grade`) AS 6th, SUM(`Seventh Grade`) AS 7th, SUM(`Eighth Grade`) AS 8th
FROM new_enrollment_data_1
GROUP BY  `School Name`, `District Name`
ORDER BY 5th DESC, 6th DESC, 7th DESC , 8th DESC; 

DESCRIBE new_enrollment_data_1;

-- The zeros in the numerical columns are not responding like numbers so let's trim for hidden spaces

UPDATE new_enrollment_data_1
SET `Fifth Grade` = TRIM(`Fifth Grade`),
	`Sixth Grade` = TRIM(`Sixth Grade`),
	`Seventh Grade` = TRIM(`Seventh Grade`),
	`Eighth Grade` = TRIM(`Eighth Grade`);
    
ALTER TABLE new_enrollment_data_1
MODIFY `Fifth Grade` INT,
MODIFY `Fifth Grade` INT,
MODIFY `Seventh Grade` INT,
MODIFY `Eighth Grade` INT;

-- Ranking For Enrollment Data (2024-2025). 	I used cast to remove any number that is 

SELECT `County Name`, `District Name`, `School Name`, `Fifth Grade`, `Sixth Grade`, `Seventh Grade`, `Eighth Grade`  
FROM new_enrollment_data_1
WHERE CAST(`Fifth Grade` AS UNSIGNED) >= 0
AND CAST(`Sixth Grade` AS UNSIGNED) >= 0
AND CAST(`Seventh Grade` AS UNSIGNED) >= 0
AND CAST(`Eighth Grade` AS UNSIGNED) >= 0
ORDER BY `County Name` DESC, `District Name` DESC, `School Name` DESC, `Fifth Grade` DESC, `Sixth Grade` DESC, `Seventh Grade` DESC, `Eighth Grade` DESC; 

-- Ranking A: New Jersey Counties versus Total Number Of 5th-8th grade students

SELECT DISTINCT `County Name`, SUM(`Fifth Grade`) AS 5th, SUM(`Sixth Grade`) AS 6th, SUM(`Seventh Grade`) AS 7th, SUM(`Eighth Grade`) AS 8th
FROM new_enrollment_data_1
GROUP BY `County Name`
ORDER BY 5th DESC, 6th DESC, 7th DESC, 8th DESC;

-- Ranking B: Title 1 School District, the individual schools by number of students in grade 5-8

SELECT DISTINCT `District Name`, `School Name`, SUM(`Fifth Grade`) AS 5th, SUM(`Sixth Grade`) AS 6th, SUM(`Seventh Grade`) AS 7th, SUM(`Eighth Grade`) AS 8th
FROM new_enrollment_data_1
GROUP BY `District Name`, `School Name` 
ORDER BY `District Name` DESC, 5th DESC, 6th DESC, 7th DESC, 8th DESC;


SELECT `%Fifth Grade`, `%Sixth Grade`, `%Seventh Grade`, `%Eighth Grade`  
FROM new_enrollment_data_1
WHERE CAST(`%Fifth Grade` AS UNSIGNED) >= 0
AND CAST(`%Sixth Grade` AS UNSIGNED) >= 0
AND CAST(`%Seventh Grade` AS UNSIGNED) >= 0
AND CAST(`%Eighth Grade` AS UNSIGNED) >= 0
ORDER BY `%Fifth Grade` DESC, `%Sixth Grade` DESC, `%Seventh Grade` DESC, `%Eighth Grade` DESC;

-- To explore the csv files for Title 1 Schools New Jersey by first modifying the column names

SELECT DISTINCT `LEA ID`
FROM `full tabula-newjerseypdf-40553`;

ALTER TABLE `full tabula-newjerseypdf-40553`
DROP COLUMN `District`;

ALTER TABLE `full tabula-newjerseypdf-40553`
CHANGE COLUMN `MyUnknownColumn` `District` VARCHAR(255);

ALTER TABLE `full tabula-newjerseypdf-40553`
CHANGE COLUMN `Under the Recovery Act*` `Title 1 Allocations` VARCHAR(255);

SELECT DISTINCT (`District`), SUM(`Title 1 Allocations`)
FROM `full tabula-newjerseypdf-40553`
GROUP BY `District` ;

-- Now To explore Public Schools Dataset that includes school grade levels

SELECT *
FROM `recent njpubschool(public school grade levels)`;

-- Ranking A again for the public school data: New Jersey Counties versus Total Number Of 5th-8th grade students

SELECT DISTINCT `County Name`, SUM(`Grade 5`) AS 5th, SUM(`Grade 6`) AS 6th, SUM(`Grade 7`) AS 7th, SUM(`Grade 8`) AS 8th
FROM `recent njpubschool(public school grade levels)`
GROUP BY `County Name`
ORDER BY 5th DESC, 6th DESC, 7th DESC, 8th DESC;

-- -- Ranking B again for the public school data: Title 1 School District, the individual schools by number of students in grade 5-8
WITH duplicate_cte AS 
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY `County Name`, `District Name`, `School Name`, `NCES Code`,`Grade 5`, `Grade 6`, `Grade 7`, `Grade 8`) AS row_num
FROM `recent njpubschool(public school grade levels)`
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- No duplicates were found for the public school dataset after checking with the required columns for ranking

SELECT DISTINCT `District Name`, `School Name`, SUM(`Grade 5`) AS 5th, SUM(`Grade 6`) AS 6th, SUM(`Grade 7`) AS 7th, SUM(`Grade 8`) AS 8th
FROM `recent njpubschool(public school grade levels)`
GROUP BY `District Name`, `School Name` 
ORDER BY `District Name` DESC, 5th DESC, 6th DESC, 7th DESC, 8th DESC;

-- To get the overall number of students from 5th to 8th grade for each county from the enrollment dataset
SELECT `County Name`, `Fifth Grade`, `Sixth Grade`, `Seventh Grade`, `Eighth Grade`, (`Fifth Grade` + `Sixth Grade` + `Seventh Grade` + `Eighth Grade`) AS Overall
FROM new_enrollment_data_1
ORDER BY Overall DESC ;

-- To get the overall number of students from grade 5 to 8 for each district from public school dataset
SELECT `District Name`, `Grade 5`, `Grade 6`, `Grade 7` `Grade 8`, (`Grade 5` + `Grade 6` + `Grade 7` + `Grade 8`) AS Overall
FROM `recent njpubschool(public school grade levels)`
ORDER BY Overall DESC;

SELECT *
FROM `recent njpubschool(public school grade levels)`;

-- For The Visualization visit https://public.tableau.com/app/profile/olubunmi.ojo/viz/JerseyStemProjectTableauVisualization/Dashboard1

-- Observations

-- From the Tableau Visualization, Bergen County had the highest number of students from 5th to 8th grade.
-- Newark Public School District had the highest number of students from grade 5 to 8
-- This Visualization gives a clear insight into the counties and districts that need more development probably in terms of quality of education, resources such as educational facilities, security in those areas or maybe just a better marketing strategy to bring in more students and offer them quality education.
