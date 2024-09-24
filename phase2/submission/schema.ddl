-- Schema for project
-- All data are come from WHO and World Bank
 
drop schema if exists Project cascade;
create schema Project;
set search_path to Project;

-- All countries
-- country_name is the name of the country,
-- Alpha2_code is the Alpha-2 country code for the country,
-- Alpha3_code is the Alpha-3 country code for the country,
create table Country (
	country_name TEXT NOT NULL PRIMARY KEY,
	Alpha2_code TEXT NOT NULL UNIQUE,
	Alpha3_code TEXT NOT NULL UNIQUE
);

-- All countries total population in 2020
-- country_code3 is the country code of the country (Alpha-3 code), 
-- population_2020 is the country's population in 2020.
create table Population (
	country_code3 TEXT NOT NULL,
	population_2020 BIGINT,
	PRIMARY KEY(country_code3),
	FOREIGN KEY (country_code3) REFERENCES Country(Alpha3_code)
);

-- Daily cases and deaths in each country
-- date is on which the cases and deaths were counted, 
-- country_code2 is the country code of the country (Alpha-2 code), 
-- new_cases is the number of new cases on that date,
-- new_death is the number of new deaths on that date
create table Daily_cases(
	date DATE NOT NULL,
	country_code2 TEXT NOT NULL,
	new_cases INT NOT NULL,
	new_death INT NOT NULL,
	PRIMARY KEY (date, country_code2),
	FOREIGN KEY (country_code2) REFERENCES Country(Alpha2_code)
);
	
-- Vaccination information in all countries.
-- country_code3 is the country code of the country (Alpha-3 code), 
-- WHO_region is which WHO region is the country in, WHO Member States are grouped 
-- into six WHO regions: Regional Office for Africa (AFRO), Regional Office for the 
-- Americas (AMRO), Regional Office for South-East Asia (SEARO), Regional Office for Europe (EURO), 
-- Regional Office for the Eastern Mediterranean (EMRO), 
-- and Regional Office for the Western Pacific (WPRO).
-- total_vacc is the cumulative total vaccine doses administered,
-- people_fully_vaccinated is number of persons fully vaccinated,
-- first_vaccine_date is the start/launch date of the first vaccine administered in each country.
create table Vaccination(
	country_code3 TEXT NOT NULL PRIMARY KEY,
	WHO_region TEXT NOT NULL CHECK (WHO_region in ('AFRO', 'AMRO', 'SEARO', 'EURO', 'EMRO', 'WPRO')),
	total_vacc BIGINT NOT NULL,
	people_fully_vaccinated INT NOT NULL,
	first_vaccine_date TIMESTAMP NOT NULL,
	FOREIGN KEY (country_code3) REFERENCES Country(Alpha3_code)
);

-- Public Health Social Measure
-- date: is the date when the measurement is put into force,
-- country_code3 is the country code of the country (Alpha-3 code), 
-- masks: wearing masks require level in the country, 0 is no mask policy and 100 is require wearking mask universally
-- travel: limitation level of international travels in the country, 0 is no travel limitation for all coutries and 100 is banned all travels for all countries
-- gatherings: Restrictions on gatherings in the country， 0 is no restrictions and 100 is restrions on gathering of 10 or less people or ban all gatherings
-- schools: closing of schools. 0 is no measures and 100 is no in-person teaching.
-- business: closing of business. 0 is no measures and 100 is closing all business except essential stores.
-- movements: restrictions on domestic movement. 0 is no measures and 100 is require to not leaving home except doing essntial activities.
-- total measurement: a calculated index of PHSM by the above features.

create table PHSM(
	date DATE NOT NULL,
	country_code3 TEXT NOT NULL,
	masks INT NOT NULL,
	travel INT NOT NULL,
	gatherings INT NOT NULL,
	schools INT NOT NULL,
	business INT NOT NULL,
	movements INT NOT NULL,
	total_measurement INT NOT NULL,
	PRIMARY KEY (date, country_code3),
	FOREIGN KEY (country_code3) REFERENCES Country(Alpha3_code)
);

