-- Create new table covid_deaths with chosen columns which will be analize and convert their type

DROP TABLE if exists covid_deaths_conv
CREATE TABLE covid_deaths_conv (
	iso_code nvarchar(255),
	continent nvarchar(255),
	location nvarchar(255),
	population float,
	new_cases int,
	new_deaths int,
	date date,
	icu_patients int,
	hosp_patients int,
);


INSERT INTO covid_deaths_conv
SELECT iso_code, continent, location, 
	Round(Convert(float,population),0),
	Round(Convert(float,new_cases),0),
	Round(Convert(float, new_deaths),0),
	Convert(date,date),
	Round(Convert(float,icu_patients),0),
	Round(Convert(float,hosp_patients),0)
FROM covid_project..covid_deaths;

SELECT *
FROM covid_deaths_conv
ORDER BY location, date;


-- create columns total_cases, total_deaths

ALTER TABLE covid_project..covid_deaths_conv
ADD total_cases int,
	total_deaths int;


WITH bf AS 
(
SELECT *,
SUM(new_cases) OVER (PARTITION BY location ORDER BY location, date)  cases,
SUM(new_deaths) OVER (PARTITION BY location ORDER BY location, date) deaths
FROM covid_deaths_conv
)
UPDATE bf
SET total_cases = cases,
	total_deaths = deaths;


--- data exploration

-- total cases and deaths in the world and deaths rate

SELECT  Sum(new_cases) AS total_cases, Sum(new_deaths) AS total_deaths, Sum(new_deaths)/ CAST(Sum(new_cases) AS float)*100 AS deaths_percentage
FROM covid_deaths_conv
WHERE continent IS NOT NULL;



--  number of cases compared to population

SELECT location, Max(total_cases/population)*100 infection_rate
FROM covid_deaths_conv
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY infection_rate DESC;


-- 20 countries with the highest number of deaths compared to population

SELECT Top 20 location, Max(total_deaths/population)*100 death_rate
FROM covid_deaths_conv
Where continent IS NOT NULL AND population > 1000000
GROUP BY location
ORDER BY death_rate DESC;


SELECT date, new_cases, new_deaths 
FROM covid_deaths_conv
WHERE location LIKE '%poland%'
ORDER BY date;


-- add column population to vaccinations table

ALTER TABLE project..covid_vacctinations
ADD population FLOAT;


UPDATE vac
SET population = deaths.population
FROM covid_project..covid_vacctinations vac 
INNER JOIN covid_project..covid_deaths_conv deaths
ON vac.location = deaths.location;


SELECT MAX(population), location
FROM covid_project..covid_vacctinations
GROUP BY location
ORDER BY 1 DESC;

-- vaccinations data exprolation


SELECT * 
FROM covid_project..covid_vacctinations;


-- number of vaccination per population

SELECT location, max(CAST(total_vaccinations as float))/population*100 AS vac_per_pop
FROM covid_project..covid_vacctinations
GROUP BY location, population
ORDER BY vac_per_pop DESC


-- number of test per population

SELECT location, max(CAST(total_tests as float))/population AS tests_per_pop
FROM covid_project..covid_vacctinations
GROUP BY location, population
ORDER BY tests_per_pop DESC

-- number of tests per number of cases

SELECT deaths.location, MAX(deaths.total_cases) / MAX(CAST(vac.total_tests AS FLOAT))
FROM covid_project..covid_deaths_conv deaths
INNER JOIN covid_project..covid_vacctinations vac
ON deaths.location = vac.location
AND deaths.date = Convert(date, vac.date)
WHERE vac.total_tests != 0
GROUP BY deaths.location;









