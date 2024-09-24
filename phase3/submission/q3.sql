SET SEARCH_PATH TO Project;
DROP TABLE IF exists CasesAndPHSM CASCADE;

-- table for saving the query result
CREATE TABLE CasesAndPHSM(
	country_name TEXT NOT NULL,
	country_code3 TEXT NOT NULL,
    avg_new_cases FLOAT NOT NULL,
    avg_new_death FLOAT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    masks INT NOT NULL,
	travel INT NOT NULL,
	gatherings INT NOT NULL,
	schools INT NOT NULL,
	business INT NOT NULL,
	movements INT NOT NULL,
	total_measurement INT NOT NULL
);

-- Define views for intermediate steps
DROP VIEW IF EXISTS CleanedPHSM CASCADE;
DROP VIEW IF EXISTS TimePeriod CASCADE;
DROP VIEW IF EXISTS CasesBetween CASCADE;


CREATE VIEW CleanedPHSM AS
SELECT p1.date, p1.country_code3, p1.masks, p1.travel, p1.gatherings,
       p1.schools, p1.business, p1.movements, p1.total_measurement
FROM (
    SELECT PHSM.*,
           LAG(PHSM.total_measurement, 1) OVER (ORDER BY PHSM.country_code3, PHSM.date) AS tm
    FROM PHSM
) p1
WHERE p1.tm IS NULL OR p1.tm != p1.total_measurement
ORDER BY p1.country_code3, p1.date;


CREATE VIEW TimePeriod AS
SELECT Country.country_name, Country.Alpha2_code AS country_code2, CleanedPHSM.country_code3,
       LAG(CleanedPHSM.date, 1) over (order by CleanedPHSM.country_code3, CleanedPHSM.date) AS start_date, 
       CleanedPHSM.date AS end_date
FROM CleanedPHSM JOIN Country ON CleanedPHSM.country_code3 = Country.Alpha3_code 
order by CleanedPHSM.country_code3, CleanedPHSM.date;


CREATE VIEW CasesBetween AS
SELECT country_name, country_code3, AVG(new_cases) AS avg_new_cases, AVG(new_death) AS avg_new_death, start_date AS date, end_date
FROM Daily_cases NATURAL JOIN (
    SELECT * FROM TimePeriod WHERE start_date != NULL OR start_date < end_date
) tp1
WHERE Daily_cases.date BETWEEN start_date AND end_date
GROUP BY country_name, country_code3, start_date, end_date
ORDER BY country_name, country_code3, date, end_date;

-- queries that answers the question
INSERT INTO CasesAndPHSM (
    SELECT country_name, country_code3, avg_new_cases, avg_new_death,
           date as start_date, end_date, masks, travel, gatherings,
           schools, business, movements, total_measurement
    FROM CasesBetween NATURAL JOIN PHSM
);

-- display data from demo
SELECT * FROM CasesAndPHSM;