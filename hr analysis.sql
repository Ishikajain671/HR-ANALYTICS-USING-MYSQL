CREATE DATABASE PROJECT_HR;

USE PROJECT_HR;

SELECT * FROM `human resources`; 

-- DATA CLEANING AND PRE PROCESSING --

-- CHANGING FIRST COLUMN NAME
ALTER TABLE `human resources`
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NOT NULL;

-- CHECKING CHANGES
DESCRIBE `human resources`;

-- UPDATING TABLE --

-- UPDATING HIRE_DATE

SET sql_safe_updates = 0;

UPDATE `human resources`
SET birthdate = CASE
		WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
        WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
        ELSE NULL
		END;
        
ALTER TABLE `human resources`
MODIFY COLUMN birthdate DATE;

-- CHECKING CHANGES
DESCRIBE `human resources`;

-- UPDATING HIRE_DATE
UPDATE `human resources`
SET hire_date = CASE
		WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
        WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
        ELSE NULL
		END;
        
ALTER TABLE `human resources`
MODIFY COLUMN hire_date DATE;

-- CHECKING CHANGES
DESCRIBE `human resources`;

-- UPDATING TERM_DATES
UPDATE `human resources`
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate !='';

UPDATE `human resources`
SET termdate = NULL
WHERE termdate = '';

-- CREATING AGE COLUMN
ALTER TABLE `human resources`
ADD column age INT;

UPDATE `human resources`
SET age = timestampdiff(YEAR,birthdate,curdate());


-- 1. TOTAL NUMBER OF EMPLOYEES, DEPARTMENTS, JOBTITLES
SELECT COUNT(emp_id) AS 'total employees' , COUNT(DISTINCT(department)) AS 'total departments',
 COUNT(DISTINCT(jobtitle)) AS'total job titles'
FROM `human resources`;

-- 2. NAMES OF EMPLOYEES
SELECT CONCAT(first_name,' ',last_name) as 'NAME' from `human resources`;

-- 3. SELECT MIN AND MAX AGE OF EMOLOYEES
SELECT min(age), max(age) FROM `human resources`;

-- 4. WHAT IS THE GENDER BREAKDOWN OF EMPLOYEES IN THR COMPAMY?
SELECT gender, COUNT(*) AS count 
FROM `human resources`
GROUP BY gender;

-- 5. WHAT IS THE RACE BREAKDOWN OF EMPLOYEES IN THR COMPAMY?
SELECT race, COUNT(*) AS count 
FROM `human resources`
WHERE termdate IS NULL #to only select existing employees
GROUP BY race;

-- 6. WHAT IS THE AGE DISTRIBUTION OF EMPLOYEES IN THE COMPANY
SELECT 
	CASE
		WHEN age>=18 AND age<=24 THEN '18-24'
        WHEN age>=25 AND age<=34 THEN '25-34'
        WHEN age>=35 AND age<=44 THEN '35-44'
        WHEN age>=45 AND age<=54 THEN '45-54'
        WHEN age>=55 AND age<=64 THEN '55-64'
        ELSE '65+'
	END AS age_group,
    COUNT(*) AS count
    FROM `human resources`
    WHERE termdate IS NULL
    GROUP BY age_group
    ORDER BY age_group;


-- 7. HOW MANY EMPLOYYES WORK AT HQ VS REMOTE
SELECT location, COUNT(location) FROM `human resources` 
WHERE termdate IS NULL
GROUP BY location;

-- 8. WHAT IS THE AVERAGE LENGTH OF EMPLOYMENT WHO HAVE BEEN TERMINATED
SELECT AVG(YEAR(TERMDATE)-YEAR(HIRE_DATE)) AS 'AVG_EMP_TENURE' FROM `human resources`
WHERE termdate IS NOT NULL AND termdate <= curdate();

-- 9. HOW DOES THE GENDER DISTRIBUTION VARY ACROSS DEPT AND JOB TITLES
SELECT gender, department, jobtitle, count(*) AS 'total'
FROM `human resources`
WHERE termdate IS NOT NULL
GROUP BY gender, department, jobtitle
ORDER BY gender, department, jobtitle;

SELECT department,gender,COUNT(*) AS 'total'
FROM `human resources`
WHERE termdate IS NOT NULL
GROUP BY department,gender
ORDER BY department,gender;

-- 10. WHAT IS THE DISTRIBUTION OF JOBTITLES ACROSS THE COMPANY
SELECT jobtitle, COUNT(*) AS count
FROM `human resources`
WHERE termdate IS NULL
GROUP BY jobtitle;

-- 11. WHICH DEPARTMENT HAVE THE HIGHEST TERMINATION RATE
SELECT department,
		COUNT(*) AS total_count,
        COUNT(CASE
				WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 
				END) AS terminated_count,
		ROUND((COUNT(CASE
					WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 
                    END)/COUNT(*))*100,2) AS termination_rate
		FROM `human resources`
	GROUP BY department
	ORDER BY termination_rate DESC; 

        
-- 12. WHAT IS THE DISTRIBUTION OF EMPLOYEES ACROSS LOCATION STATE AND CITY
SELECT location_state, COUNT(*) AS count
FROM `human resources`
WHERE termdate IS NULL
GROUP BY location_state;

SELECT location_city, COUNT(*) AS count
FROM `human resources`
WHERE termdate IS NULL
GROUP BY location_city;

-- 13. HOW DID THE COMPANY'S EMPLOYEE COUNT CHANGED OVERTIME BASES ON HIRE AND TERMINATION DATE
SELECT year,
		hires,
        terminations,
        hires-terminations AS net_change,
        (terminations/hires)*100 AS change_percent
	FROM(
			SELECT YEAR(hire_date) AS year,
            COUNT(*) AS hires,
            SUM(CASE 
					WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 
				END) AS terminations
			FROM `human resources`
            GROUP BY YEAR(hire_date)) AS subquery
GROUP BY year
ORDER BY year;

-- 14. WHAT IS THE TENURE DISTRIBUTION FOR EACH DEPARTMENT
SELECT department, round(avg(datediff(termdate,hire_date)/365),0) AS avg_tenure
FROM `human resources`
WHERE termdate IS NOT NULL AND termdate<= curdate()
GROUP BY department;

