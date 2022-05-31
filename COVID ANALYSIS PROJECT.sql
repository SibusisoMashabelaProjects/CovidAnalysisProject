USE CovidProject
SELECT *
FROM CovidProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM CovidProject..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths
ORDER BY 1,2

-- TOTAL CASES VS TOTAL DEATHS PERCENTAGE 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM CovidProject..CovidDeaths
WHERE location LIKE '%South Africa%'
ORDER BY 1,2

-- TOTAL POPULATION VS TOTAL CASES

SELECT location, date, total_cases, population, (total_cases/population)*100 AS Population_Percentage
FROM CovidProject..CovidDeaths
--WHERE location LIKE '%South Africa%'
ORDER BY 1,2


--COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count  , MAX((total_cases/population))*100 AS Population_Percentage_Infected
FROM CovidProject..CovidDeaths
--WHERE location LIKE '%South Africa%'
GROUP BY location, population
ORDER BY Population_Percentage_Infected DESC

--COUNTRIES WITH HIGHEST DEATH

SELECT location, MAX(CAST(total_deaths AS int)) as Highest_Death_Count
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%South Africa%'
GROUP BY location
ORDER BY Highest_Death_Count DESC

--BY CONTINENT
SELECT continent, MAX(CAST(total_deaths AS int)) as Highest_Death_Count
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%South Africa%'
GROUP BY continent
ORDER BY Highest_Death_Count DESC


--GLOBAL NUMBERS

SELECT SUM(new_cases) AS Total_cases, SUM(cast(new_deaths AS int)) As Total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS Death_Percentage
FROM CovidProject..CovidDeaths
--WHERE location LIKE '%South Africa%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2 

--VACCINATIONS TABLE
--TOTAL PPULATION VS VACCINATIONS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS Rolling_People_Vaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

WITH PopvSVac (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS Rolling_People_Vaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


)

SELECT *,(Rolling_People_Vaccinated/population)*100
FROM PopvSVac

--CREATING A TABLE
DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS Rolling_People_Vaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *,(Rolling_People_Vaccinated/population)*100
FROM #PercentagePopulationVaccinated

--CREATING VIEW TO STORE DATA
CREATE VIEW PercentagePopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS Rolling_People_Vaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


