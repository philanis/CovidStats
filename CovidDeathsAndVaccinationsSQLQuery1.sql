
--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
--(1,2,3,4, used in Tableau Project)

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

--Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in particular country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%south africa%'
AND continent IS NOT NULL
ORDER BY 1, 2

--Total Cases vs Total Population
--Percantage of poulation that contracted Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as ContractedPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2


--1
--Total NewCasesCases, TotalNewDeaths and DeathPercentage
SELECT SUM(new_cases) as TotalNewCases, SUM(CAST(new_deaths AS INT)) AS TotalNewDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2


--2
SELECT location, SUM(CAST(new_deaths AS INT)) AS DeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY DeathCount DESC


--3
--Countries with highest infection rate 
SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 as ContractedPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY ContractedPercentage DESC

--4
--Countries with highest infection rate (includes dates)
SELECT location, date, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 as ContractedPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY location, population, date
ORDER BY ContractedPercentage DESC


--Countries with the highest Death count per population
SELECT location, MAX(CAST(total_deaths AS INT)) AS DeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY DeathCount DESC


--Countries with the highest Death count per population
SELECT location, MAX(CAST(total_deaths AS INT)) AS DeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY DeathCount DESC


--Continent with the highest Death count per population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS DeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY DeathCount DESC




--Total NewCasesCases, TotalNewDeaths and DeathPercentage grouped by date
SELECT date, SUM(new_cases) as TotalNewCases, SUM(CAST(new_deaths AS INT)) AS TotalNewDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

-- Joins both tables
SELECT *
 FROM PortfolioProject..CovidDeaths AS dea
 JOIN PortfolioProject..CovidVaccination AS vacc
 ON dea.location = vacc.location
 AND dea.date = vacc.date


 -- Total population vs Total vaccinations
 -- Shows Percentage of Population that has recieved at least one Covid Vaccine
 SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
 FROM PortfolioProject..CovidDeaths AS dea
 JOIN PortfolioProject..CovidVaccination AS vacc
  ON dea.location = vacc.location
  AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


 -- Total population vs Total vaccinations Cummulative
 -- Shows Percentage of Population that has recieved at least one Covid Vaccine
 SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, 
 SUM(CAST(vacc.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS CummulativePeopleVaccinated
 FROM PortfolioProject..CovidDeaths AS dea
 JOIN PortfolioProject..CovidVaccination AS vacc
  ON dea.location = vacc.location
  AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Using CTE
 -- Total population vs Total vaccinations Cummulative Percentage
 WITH PopvsVacc (continent, location, date, population, new_vaccinations, CummulativePeopleVaccinated) AS
(
 SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, 
 SUM(CAST(vacc.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS CummulativePeopleVaccinated
 FROM PortfolioProject..CovidDeaths AS dea
 JOIN PortfolioProject..CovidVaccination AS vacc
  ON dea.location = vacc.location
  AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (CummulativePeopleVaccinated/population)*100
FROM PopvsVacc


-- Using TEMP Table
 -- Total population vs Total vaccinations Cummulative Percentage
 DROP table if exists #PopulationVaccinatedPercent
 Create table #PopulationVaccinatedPercent
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 CummulativePeopleVaccinated numeric
 )
 INSERT INTO #PopulationVaccinatedPercent
 SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, 
 SUM(CAST(vacc.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS CummulativePeopleVaccinated
 FROM PortfolioProject..CovidDeaths AS dea
 JOIN PortfolioProject..CovidVaccination AS vacc
  ON dea.location = vacc.location
  AND dea.date = vacc.date
--WHERE dea.continent IS NOT NULL
SELECT *, (CummulativePeopleVaccinated/population)*100
FROM #PopulationVaccinatedPercent


--Creating View for visualisation
CREATE VIEW PopulationVaccinatedPercentages
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, 
SUM(CAST(vacc.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS CummulativePeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccination AS vacc
  ON dea.location = vacc.location
  AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL
