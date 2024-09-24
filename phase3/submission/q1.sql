SET SEARCH_PATH TO Project;
DROP TABLE IF exists FullyVac CASCADE;
DROP TABLE IF exists RegionVacRate CASCADE;
DROP TABLE IF exists initial_PopulationCase CASCADE;
DROP TABLE IF exists final_PopulationCase CASCADE;


-- tables for saving the query result
create table initial_PopulationCase(
    country_name TEXT NOT NULL,
    quarter INT NOT NULL,
    years INT NOT NULL,
    quarter_cases INT NOT NULL,
    quarter_change INT
);

create table final_PopulationCase(
    country_name TEXT NOT NULL,
    quarter INT NOT NULL,
    years INT NOT NULL,
    quarter_cases INT NOT NULL,
    quarter_change INT
);

CREATE TABLE FullyVac(
	country_name TEXT NOT NULL PRIMARY KEY,
    percent FLOAT NOT NULL
);

CREATE TABLE RegionVacRate(
    WHO_region TEXT NOT NULL,
    Vaccination_rate FLOAT NOT NULL
);


-- cases related
DROP VIEW IF EXISTS Answer CASCADE;
DROP VIEW IF EXISTS AnswerWithChange CASCADE;
DROP VIEW IF EXISTS Final CASCADE;

-- with everthing in table except change
CREATE VIEW Answer as(
select country_name, extract(quarter from date) as quarter, extract(year from date) as years, sum(new_cases) as quarter_cases
from Country join Population on Alpha3_code = country_code3
join Daily_cases on Alpha2_code = country_code2
group by country_name,population_2020, quarter, years
order by country_name, years
);
-- add lag here
CREATE VIEW AnswerWithChange AS(
select country_name, quarter,years, quarter_cases, LAG(quarter_cases,1) OVER (
			ORDER BY country_name, years
		) previous_q
from Answer
);
-- add change here
CREATE VIEW Final as(
    select country_name, quarter,years, quarter_cases, quarter_cases - previous_q as quarter_change
    FROM AnswerWithChange
);
-- insert the table
insert into initial_PopulationCase(
    select * from Final
);
-- set every country's initial change to 0
UPDATE initial_PopulationCase
set quarter_change = 0
where quarter = 1 and years = 2020;

--  add our final result
insert into final_PopulationCase(
    select * from initial_PopulationCase
    order by country_name, years, quarter
);

DROP TABLE IF EXISTS initial_PopulationCase;



-- vaccine related
DROP VIEW IF EXISTS VaccWithPop CASCADE;

CREATE VIEW VaccWithPop AS
SELECT Country.country_name, Vaccination.WHO_region, Vaccination.people_fully_vaccinated, Population.population_2020
FROM Vaccination JOIN Country On Vaccination.country_code3 = Country.Alpha3_code
                 JOIN Population On Population.country_code3 = Country.Alpha3_code;

-- queries that answers the question
INSERT INTO FullyVac (
    SELECT country_name, CAST(people_fully_vaccinated AS DECIMAL) / population_2020 AS percentage
    FROM VaccWithPop
);

INSERT INTO RegionVacRate (
    SELECT WHO_region, CAST(SUM(people_fully_vaccinated) AS DECIMAL) / SUM(population_2020) AS percentage
    FROM VaccWithPop GROUP BY WHO_region
);