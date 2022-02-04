Select*
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 3,4

--Select*
--From PortfolioProject..CovidVaccinations
--Order By 3,4

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER By 1,2

-- Looking at Toatal Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%canada%'
ORDER By 1,2

-- Looking at Total cases vs Population
-- Shows percentage of population that got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%canada%'
ORDER By 1,2

-- Looking at countries with highest infection rate compared to population

SELECT location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population)*100) as CovidPercentage
FROM PortfolioProject..CovidDeaths
Group BY location, population
ORDER By CovidPercentage desc

-- Showing countries with the highest Death count per population.

SELECT location, MAX(CAST(total_deaths as Int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group BY location
ORDER By TotalDeathCount desc

-- Break down by Continent
SELECT location, MAX(CAST(total_deaths as Int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is null
Group BY location
ORDER By TotalDeathCount desc


-- Showing the continents with the highest Death Count

SELECT continent, MAX(CAST(total_deaths as Int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group BY continent
ORDER By TotalDeathCount desc


-- Global numbers

SELECT date, SUM(new_cases) as total_cases, SUM(Cast(new_deaths as Int)) as total_deaths, SUM(Cast(new_deaths as Int))/ SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER By 1,2

SELECT SUM(new_cases) as total_cases, SUM(Cast(new_deaths as Int)) as total_deaths, SUM(Cast(new_deaths as Int))/ SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER By 1,2

-- Looking at total population vs Vaccination


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated;
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

-- Use CTE

WITH PopvsVac (Continent, location, date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM PopvsVac

-- Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
loaction nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM #PercentPopulationVaccinated


-- Creating View to store dat for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated



