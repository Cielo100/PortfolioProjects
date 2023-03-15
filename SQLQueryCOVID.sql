SELECT * 
FROM [Portfolio Project]..CovidDeaths
Where continent is not null
ORDER BY 3,4

--SELECT * 
--FROM [Portfolio Project]..CovidVaccinations
--ORDER BY 3,4

--Select data that we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM [Portfolio Project]..CovidDeaths
ORDER BY 1,2 


--Looking at total cases vs. total deaths
-- Shows likelihood of contracting covid in country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location like '%states%'
AND continent is not null
ORDER BY 1,2  

--Looking at total cases vs population
--Shows what percentage of population got covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectedPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2  

--Look at countries with highest infection rate compared to population
SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 AS PercentofPopulationInfected
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
GROUP BY Location,Population,continent
ORDER BY PercentofPopulationInfected desc  

--LETS BREAK THINGS DOWN BY CONTINENT

-- Showing the contients with the highest death counts 
--ShowingCountries with the Highest Death Count per population
SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount 
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
Where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc  

-- GLOBAL NUMBERS

--By Date
SELECT  date, SUM(new_cases) AS total_cases,SUM(cast(new_deaths AS int))AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2 

--Total deaths compared to totalcases
SELECT SUM(new_cases) AS total_cases,SUM(cast(new_deaths AS int))AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2 


--Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER by 2,3 

--USE CTE

WITH PopvsVac (continent, location, date, population,New_vaccinations, RollingPeopleVaccinated)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER by 2,3 (cant be in here) 
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


--TEMP table
DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER by 2,3 (cant be in here) 

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualization
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER by 2,3 (cant be in here) 

SELECT *
From PercentPopulationVaccinated