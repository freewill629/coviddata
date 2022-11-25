SELECT * FROM covid.dbo.deaths;
SELECT * FROM covid.dbo.vaccinations;

SELECT location,date,total_cases,new_cases,total_deaths,population 
FROM covid..deaths
ORDER BY location,date;

--Total Cases V/S Deaths 

SELECT a.*,(a.Total_Deaths/a.Total_Cases)*100 AS Death_Percentage FROM
(SELECT location,MAX(CAST(total_cases AS FLOAT)) AS Total_Cases,MAX(CAST(total_deaths AS FLOAT)) AS Total_Deaths
FROM covid..deaths
GROUP BY location) a
ORDER BY Death_Percentage DESC;

--SELECT location,date,total_cases,new_cases,total_deaths,population 
--FROM covid..deaths
--WHERE location='North Korea';

--Covid death rate in India (Likelihood of death if you catch COVID in india)


SELECT a.*,(a.Total_Deaths/a.Total_Cases)*100 AS Death_Percentage FROM
(SELECT location,MAX(CAST(total_cases AS FLOAT)) AS Total_Cases,MAX(CAST(total_deaths AS FLOAT)) AS Total_Deaths
FROM covid..deaths
GROUP BY location) a
WHERE location = 'India';

--Total Cases V/S Population

SELECT a.*, (a.total_cases/a.total_population)*100 AS cases_percent FROM
(SELECT location,MAX(total_cases) AS total_cases,MAX(population) AS total_population
FROM covid..deaths
GROUP BY location) a
ORDER BY location;

--Percentage of Population Who caught Covid in India

SELECT a.*, (a.total_cases/a.total_population)*100 AS cases_percent FROM
(SELECT location,MAX(total_cases) AS total_cases,MAX(population) AS total_population
FROM covid..deaths
GROUP BY location) a
WHERE location = 'India';

--Top 10 Countries Who caught covid compared to their population

SELECT TOP 10 a.*, (a.total_cases/a.total_population)*100 AS cases_percent FROM
(SELECT location,MAX(total_cases) AS total_cases,MAX(population) AS total_population
FROM covid..deaths
GROUP BY location) a
ORDER BY cases_percent DESC;

--Top 10 Countries with highest death rate

SELECT TOP 10 a.*,(a.Total_Deaths/a.Total_Cases)*100 AS Death_Percentage FROM
(SELECT location,MAX(CAST(total_cases AS FLOAT)) AS Total_Cases,MAX(CAST(total_deaths AS FLOAT)) AS Total_Deaths
FROM covid..deaths
GROUP BY location) a
WHERE location NOT LIKE '%North Korea%'
ORDER BY Death_Percentage DESC;


--Top 10 Countries with highest death count

SELECT TOP 10 a.location, MAX(a.Total_Deaths) AS Total_Deaths FROM
(SELECT location,CAST(total_cases AS FLOAT) AS Total_Cases,CAST(total_deaths AS FLOAT) AS Total_Deaths, continent
FROM covid..deaths WHERE continent IS NOT NULL)a
GROUP BY a.location
ORDER BY Total_Deaths DESC;

--Death Count By Continent

SELECT a.continent, SUM(a.Total_Deaths) AS Death_Count_Continent FROM
(SELECT location, MAX(CAST(total_deaths AS FLOAT)) AS Total_Deaths, continent
FROM covid..deaths
WHERE continent IS NOT NULL
GROUP BY location,continent) a
GROUP BY a.continent
ORDER BY Death_Count_Continent DESC;

--Total Cases, Total Deaths and Death Percentage Worldwide

SELECT SUM(b.Total_Cases) AS Total_cases,SUM(b.Total_Deaths) AS Total_Deaths, SUM(b.Death_Percentage)/COUNT(*) AS Death_Percentage FROM
(SELECT a.*,(a.Total_Deaths/a.Total_Cases)*100 AS Death_Percentage FROM
(SELECT location,MAX(CAST(total_cases AS FLOAT)) AS Total_Cases,MAX(CAST(total_deaths AS FLOAT)) AS Total_Deaths
FROM covid..deaths
WHERE location NOT LIKE '%North Korea%'
GROUP BY location) a)b

--Total Populations V/S Total Vaccinations
SELECT location, MAX(a.population) AS population,SUM(CAST(a.new_vaccinations AS BIGINT)) AS total_vaccinations FROM
(SELECT continent,location,population,new_vaccinations
FROM covid..vaccinations WHERE continent IS NOT NULL) a
GROUP BY location
ORDER BY total_vaccinations DESC;


--Window Function

SELECT a.location,MAX(a.population) AS population, MAX(a.total_vaccinations) AS total_vaccinations FROM
(SELECT date,continent,location,population,new_vaccinations, SUM(CONVERT(BIGINT,new_vaccinations)) OVER(PARTITION BY location ORDER BY location,date) AS total_vaccinations
FROM covid..vaccinations WHERE continent IS NOT NULL) a
GROUP BY location
ORDER BY total_vaccinations DESC;
--Vaccination Percentage

SELECT location, (MAX(CAST(a.people_vaccinated AS BIGINT))/MAX(a.population))*100 AS vaccination_percent FROM
(SELECT continent,location,population,people_vaccinated
FROM covid..vaccinations WHERE continent IS NOT NULL) a
GROUP BY location
ORDER BY vaccination_percent DESC;

-- Population Vs Vaccinations (Total vaccinations using Window functions and CTE)
WITH popvac (date,location,population,newvaccinations,rollingpeoplevaccinated)
AS
(SELECT covid.dbo.deaths.date,covid.dbo.deaths.location, covid.dbo.deaths.population, covid.dbo.vaccinations.new_vaccinations,SUM(CAST(covid.dbo.vaccinations.new_vaccinations AS bigint)) OVER(PARTITION BY covid.dbo.deaths.location ORDER BY covid.dbo.deaths.location,covid.dbo.deaths.date) AS rollingpeoplevaccinated
FROM covid.dbo.deaths
INNER JOIN covid.dbo.vaccinations
ON covid.dbo.deaths.date = covid.dbo.vaccinations.date 
AND covid.dbo.deaths.location = covid.dbo.vaccinations.location
WHERE covid.dbo.deaths.continent IS NOT NULL)
SELECT *, (rollingpeoplevaccinated/population)*100 AS vaccinationpercentage
FROM popvac
ORDER BY location,date;

--VIEWS

--Total Cases V/S Deaths View

CREATE VIEW total_cases_vs_deayths AS
SELECT a.*,(a.Total_Deaths/a.Total_Cases)*100 AS Death_Percentage FROM
(SELECT location,MAX(CAST(total_cases AS FLOAT)) AS Total_Cases,MAX(CAST(total_deaths AS FLOAT)) AS Total_Deaths
FROM covid..deaths
GROUP BY location) a;
--ORDER BY Death_Percentage DESC;
SELECT * FROM total_cases_vs_deayths;

--Total Cases V/S Population View

CREATE VIEW total_cases_vs_popuation AS
SELECT a.*, (a.total_cases/a.total_population)*100 AS cases_percent FROM
(SELECT location,MAX(total_cases) AS total_cases,MAX(population) AS total_population
FROM covid..deaths
GROUP BY location) a;
--ORDER BY location;

--Top 10 Countries Who caught covid compared to their population View

CREATE VIEW top10covid AS
SELECT TOP 10 a.*, (a.total_cases/a.total_population)*100 AS cases_percent FROM
(SELECT location,MAX(total_cases) AS total_cases,MAX(population) AS total_population
FROM covid..deaths
GROUP BY location) a;
--ORDER BY cases_percent DESC;

--Top 10 Countries with highest death rate View

CREATE VIEW deathrate AS
SELECT TOP 10 a.*,(a.Total_Deaths/a.Total_Cases)*100 AS Death_Percentage FROM
(SELECT location,MAX(CAST(total_cases AS FLOAT)) AS Total_Cases,MAX(CAST(total_deaths AS FLOAT)) AS Total_Deaths
FROM covid..deaths
GROUP BY location) a
WHERE location NOT LIKE '%North Korea%'
ORDER BY Death_Percentage DESC;


--Top 10 Countries with highest death count View

CREATE VIEW deathcount AS
SELECT TOP 10 a.location, MAX(a.Total_Deaths) AS Total_Deaths FROM
(SELECT location,CAST(total_cases AS FLOAT) AS Total_Cases,CAST(total_deaths AS FLOAT) AS Total_Deaths, continent
FROM covid..deaths WHERE continent IS NOT NULL)a
GROUP BY a.location
ORDER BY Total_Deaths DESC;

--Death Count By Continent VIEW

CREATE VIEW deathbycontinent AS
SELECT a.continent, SUM(a.Total_Deaths) AS Death_Count_Continent FROM
(SELECT location, MAX(CAST(total_deaths AS FLOAT)) AS Total_Deaths, continent
FROM covid..deaths
WHERE continent IS NOT NULL
GROUP BY location,continent) a
GROUP BY a.continent;
--ORDER BY Death_Count_Continent DESC;

--Total Cases, Total Deaths and Death Percentage Worldwide View


--Total Populations V/S Total Vaccinations View

CREATE VIEW popvac AS
SELECT location, MAX(a.population) AS population,SUM(CAST(a.new_vaccinations AS BIGINT)) AS total_vaccinations FROM
(SELECT continent,location,population,new_vaccinations
FROM covid..vaccinations WHERE continent IS NOT NULL) a
GROUP BY location;
--ORDER BY total_vaccinations DESC;