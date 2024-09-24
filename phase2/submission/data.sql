-- importing data
SET SEARCH_PATH TO Project;
DROP TABLE IF EXISTS tempPopulation CASCADE;
DROP TABLE IF EXISTS tempDaily CASCADE;
DROP TABLE IF EXISTS tempVacc CASCADE;
DROP TABLE IF EXISTS TempPHSM CASCADE;
-- country
\copy Country from 'cleaned_country.csv' with csv;


-- population
create table tempPopulation (
	country_code3 TEXT NOT NULL,
	population_2020 BIGINT
);
\copy tempPopulation from 'cleaned_pop.csv' with csv;

insert into Population (
    select * from tempPopulation
    where country_code3 in (
        select Alpha3_code from Country
    )
);
DROP TABLE tempPopulation CASCADE;

-- daily
create table tempDaily (
    date DATE NOT NULL,
	country_code2 TEXT NOT NULL,
	new_cases INT NOT NULL,
	new_death INT NOT NULL
);

\copy tempDaily from 'cleaned_daily.csv' with csv;

insert into Daily_cases (
    select * from tempDaily
    where country_code2 in (
        select Alpha2_code from Country
    )
);

DROP TABLE tempDaily CASCADE;

-- Vaccination
create table tempVacc (
    country_code3 TEXT NOT NULL PRIMARY KEY,
	WHO_region TEXT NOT NULL CHECK (WHO_region in ('AFRO', 'AMRO', 'SEARO', 'EURO', 'EMRO', 'WPRO')),
	total_vacc BIGINT NOT NULL,
	people_fully_vaccinated INT NOT NULL,
	first_vaccine_date TIMESTAMP NOT NULL
);

\copy tempVacc from 'cleaned_vacc.csv' with csv;

insert into Vaccination (
    select * from tempVacc
    where country_code3 in (
        select Alpha3_code from Country
    )
);

DROP TABLE tempVacc CASCADE;

-- PHSM
create table TempPHSM(
	date DATE NOT NULL,
	country_code3 TEXT NOT NULL,
	masks INT NOT NULL,
	travel INT NOT NULL,
	gatherings INT NOT NULL,
	schools INT NOT NULL,
	business INT NOT NULL,
	movements INT NOT NULL,
	total_measurement INT NOT NULL
);

\copy TempPHSM from 'cleaned_phsm.csv' with csv

insert into PHSM (
    select * from TempPHSM
    where country_code3 in (
        select Alpha3_code from Country
    )
);

DROP TABLE TempPHSM CASCADE;
