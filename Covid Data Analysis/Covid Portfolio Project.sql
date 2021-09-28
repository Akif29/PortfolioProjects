/*
Queries used for Tableau Project
*/



-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc





SELECT * 
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4


--SELECT * 
--FROM [Portfolio Project]..CovidVacinations
--WHERE continent IS NOT NULL
--ORDER BY 3, 4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in United Arab Emirates
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location LIKE '%Emirates%'
ORDER BY 1, 2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
SELECT location, date, population,total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths
WHERE location LIKE '%Emirates%'
ORDER BY 1, 2


-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Looking at Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Breaking things by continent
-- Showing Continents with the Highest Death Count
SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global Numbers
SELECT SUM(total_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2



-- USE CTE
WITH PopvsVax (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS(
-- Looking at Total Population vs Vaccinations
SELECT ded.continent, vax.location, ded.date, ded.population, vax.new_vaccinations,
SUM(CONVERT(INT,vax.new_vaccinations)) OVER (PARTITION BY ded.location ORDER BY ded.location, ded.date) AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths ded
JOIN [Portfolio Project]..CovidVacinations vax
	ON ded.location = vax.location
	AND ded.date = vax.date
WHERE ded.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated/population) *100
FROM PopvsVax


-- TEMP TABLE
CREATE TABLE #PercentagePopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)


INSERT INTO #PercentagePopulationVaccinated
SELECT ded.continent, vax.location, ded.date, ded.population, vax.new_vaccinations,
SUM(CONVERT(INT,vax.new_vaccinations)) OVER (PARTITION BY ded.location ORDER BY ded.location, ded.date) AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths ded
JOIN [Portfolio Project]..CovidVacinations vax
	ON ded.location = vax.location
	AND ded.date = vax.date
WHERE ded.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population) *100
FROM #PercentagePopulationVaccinated


-- Creating View to store data for visualization
CREATE VIEW PercentagePopulationVaccinated 
AS
SELECT ded.continent, vax.location, ded.date, ded.population, vax.new_vaccinations,
SUM(CONVERT(INT,vax.new_vaccinations)) OVER (PARTITION BY ded.location ORDER BY ded.location, ded.date) AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths ded
JOIN [Portfolio Project]..CovidVacinations vax
	ON ded.location = vax.location
	AND ded.date = vax.date
WHERE ded.continent IS NOT NULL

SELECT *
FROM PercentagePopulationVaccinated