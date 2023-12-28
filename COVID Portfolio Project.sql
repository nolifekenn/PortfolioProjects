SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4
 
 -- looking at the total cases vs total deaths
 -- shows the likelihood of dying if you contract the covid in your country 
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%states'
ORDER BY 3,4

-- looking at total cases vs population 
-- shows what percentage of the population got Covid 
SELECT Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE Location = 'Philippines'
ORDER BY 1, 2

-- looking at countries with highest infection rate compared to population 
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC

-- looking at countries with highest death count per population 
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- let's break things down by continent 
-- showing continents with highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent 
ORDER BY TotalDeathCount DESC

-- global numbers 
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases)*100) as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2


-- looking at total population vs vaccinations 
SELECT dea.continent, dea.Location, dea.date, dea.population, vax.new_vaccinations, SUM(cast(vax.new_vaccinations as int)) OVER (PARTITION BY dea.Location
ORDER BY dea.Location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vax
	ON dea.location = vax.location
	and dea.date = vax.date
WHERE dea.continent is not null 
ORDER BY 2, 3


-- use CTE
WITH PopvsVax (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.Location, dea.date, dea.population, vax.new_vaccinations, SUM(cast(vax.new_vaccinations as int)) OVER (PARTITION BY dea.Location
ORDER BY dea.Location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vax
	ON dea.location = vax.location
	and dea.date = vax.date
WHERE dea.continent is not null 
-- ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as VaccinePercentagePerPopulation
FROM PopvsVax



-- TEMP TABLE 
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric,
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.Location, dea.date, dea.population, vax.new_vaccinations, SUM(cast(vax.new_vaccinations as int)) OVER (PARTITION BY dea.Location
ORDER BY dea.Location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vax
	ON dea.location = vax.location
	and dea.date = vax.date
-- WHERE dea.continent is not null 
-- ORDER BY 2, 3
SELECT *
FROM #PercentPopulationVaccinated


-- create view to store data in for later visualizations
CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.Location, dea.date, dea.population, vax.new_vaccinations, SUM(cast(vax.new_vaccinations as int)) OVER (PARTITION BY dea.Location
ORDER BY dea.Location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vax
	ON dea.location = vax.location
	and dea.date = vax.date
WHERE dea.continent is not null 
-- ORDER BY 2, 3


SELECT * 
FROM PercentPopulationVaccinated