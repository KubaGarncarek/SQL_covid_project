-- Create new table covid_deaths with chosen columns which will be analize and convert their type

DROP TABLE if exists covid_deaths_conv
Create Table covid_deaths_conv (
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


Insert Into covid_deaths_conv
Select iso_code, continent, location, 
	Round(Convert(float,population),0),
	Round(Convert(float,new_cases),0),
	Round(Convert(float, new_deaths),0),
	Convert(date,date),
	Round(Convert(float,icu_patients),0),
	Round(Convert(float,hosp_patients),0)
From covid_project..covid_deaths;

SELECT *
FROM covid_deaths_conv
order by location, date;


-- create columns total_cases, total_deaths

ALTER TABLE covid_deaths_conv
ADD total_cases int,
	total_deaths int;


WITH bf as 
(
SELECT *,
SUM(new_cases) OVER (PARTITION by location ORDER BY location, date)  cases,
SUM(new_deaths) OVER (PARTITION by location ORDER BY location, date) deaths
FROM covid_deaths_conv
)
Update bf
Set total_cases = cases,
	total_deaths = deaths;


--- data exploration

-- total cases and deaths in the world and deaths rate

SELECT  Sum(new_cases) as total_cases, Sum(new_deaths) as total_deaths, Sum(new_deaths)/ CAST(Sum(new_cases) as float)*100 AS deaths_percentage
From covid_deaths_conv
Where continent is not null



--  number of cases compared to population

SELECT location, Max(total_cases/population)*100 infection_rate
From covid_deaths_conv
Where continent is not null
Group by location
Order by infection_rate desc


-- 20 countries with the highest number of deaths compared to population

SELECT Top 20 location, Max(total_deaths/population)*100 death_rate
From covid_deaths_conv
Where continent is not null AND population > 1000000
Group by location
Order by death_rate desc


SELECT date, new_cases, new_deaths 
From covid_deaths_conv
Where location like '%poland%'
order by date












