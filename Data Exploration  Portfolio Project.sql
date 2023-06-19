SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Portion of data to be explored

SELECT continent, location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

--Looking at Total Cases Vs Total Deaths
--The query below shows the likelihood of dying when infected with the covid virus

SELECT continent, location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

SELECT continent, location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location like '%Nigeria%'
AND continent IS NOT NULL
ORDER BY 1, 2

--Nigeria generally had fewer cases and the risk of deaths was generally between 1-3.6%



--Taking a look at Total Cases Vs Population
--Shows the percentage of the population that contacted the covid virus

SELECT continent, location, date, population, total_cases, (total_cases/population)*100 AS PopCasePercentage
FROM CovidDeaths
WHERE location like '%Nigeria%'
AND continent IS NOT NULL
ORDER BY 1, 2


--Looking at Countries with higher infection rate compared to the population

SELECT continent, location, population, MAX(total_cases) AS HighestInfectionCount, 
MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, location, population
ORDER BY PercentPopulationInfected DESC

--Countries with the higest death count per population

SELECT continent, location,MAX(cast(total_deaths AS int)) AS HighestDeathCount 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, location
ORDER BY HighestDeathCount DESC


SELECT continent, location,population,MAX(cast(total_deaths AS int)) AS HighestDeathCount, 
MAX((total_deaths/population)*100) AS PopulationDeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, location, population
ORDER BY PopulationDeathPercentage DESC


--BREAKING THE DATA DOWN BY CONTINENT

--SELECT location,MAX(cast(total_deaths AS int)) AS HighestDeathCount 
--FROM CovidDeaths
--WHERE continent IS NULL
--GROUP BY location
--ORDER BY HighestDeathCount DESC

--Showing continents with the highest death count per population

SELECT continent,MAX(cast(total_deaths AS int)) AS HighestDeathCount 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC


--LOOKING AT THE GLOBAL NUMBERS

--Cases recorded and number of deaths per day

SELECT date, SUM(new_cases) AS TotalCases,
SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
SUM(CAST(new_deaths AS INT))/SUM(new_cases) *100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

--Total cases recorded and number of deaths during the pandemic world wide

SELECT SUM(new_cases) AS TotalCases,
SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
SUM(CAST(new_deaths AS INT))/SUM(new_cases) *100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL


--Looking at Total Population Vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location 
ORDER BY dea.location,dea.date ) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--Looking at percentage of population vaccinated
--Using CTE

WITH PopVsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location 
ORDER BY dea.location,dea.date ) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentagePeopleVaccinated
FROM PopVsVac


--Using TEMP TABLE

DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentagePopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location 
ORDER BY dea.location,dea.date ) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentagePeopleVaccinated
FROM #PercentagePopulationVaccinated

--Creating views to store data for later visualizations

CREATE VIEW PercentagePopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location 
ORDER BY dea.location,dea.date ) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL




