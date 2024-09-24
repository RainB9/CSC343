SET SEARCH_PATH TO Project;
DROP TABLE IF exists VaccWithDaily CASCADE;


create table VaccWithDaily(
    country_name TEXT NOT NULL,
    VaccPercentage Float NOT NULL,
    total_before_vac INT NOT NULL,
    total_after_vac INT NOT NULL,
    diff INT NOT NULL
);


--  vaccination rate
DROP VIEW IF EXISTS VaccWithPop CASCADE;

CREATE VIEW VaccWithPop AS
SELECT Country.country_name, Vaccination.people_fully_vaccinated, Population.population_2020
FROM Vaccination JOIN Country On Vaccination.country_code3 = Country.Alpha3_code
                 JOIN Population On Population.country_code3 = Country.Alpha3_code;


-- total daily case before first vac date
DROP VIEW IF EXISTS DailyBeforeVac CASCADE;
CREATE VIEW DailyBeforeVac as
select country_name, sum(new_cases) as total_cases
from Country join Population on Country.Alpha3_code = Population.country_code3
join Daily_cases on Alpha2_code = country_code2
join Vaccination on Vaccination.country_code3 = Country.Alpha3_code
where date::date < first_vaccine_date::date
group by country_name;


-- total daily case after first vac date
DROP VIEW IF EXISTS DailyAfterVac CASCADE;
CREATE VIEW DailyAfterVac as
select country_name, sum(new_cases) as total_cases
from Country join Population on Country.Alpha3_code = Population.country_code3
join Daily_cases on Alpha2_code = country_code2
join Vaccination on Vaccination.country_code3 = Country.Alpha3_code
where date::date >= first_vaccine_date::date
group by country_name;


-- combine the views together
DROP VIEW IF EXISTS VaccAndDaily CASCADE;

CREATE VIEW VaccAndDaily as
select VaccWithPop.country_name, CAST(people_fully_vaccinated AS DECIMAL) / population_2020 AS VaccPercentage,DailyBeforeVac.total_cases as total_before_vac, DailyAfterVac.total_cases as total_after_vac
from VaccWithPop JOIN DailyBeforeVac on VaccWithPop.country_name = DailyBeforeVac.country_name
join DailyAfterVac on VaccWithPop.country_name = DailyAfterVac.country_name
;

DROP VIEW IF EXISTS addChange CASCADE;

CREATE VIEW addChange as
select country_name, VaccPercentage, total_before_vac, total_after_vac, total_after_vac-total_before_vac as diff
from VaccAndDaily
;

--  insert into the table
insert into VaccWithDaily(
    select * from addChange
);


