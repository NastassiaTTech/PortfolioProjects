Select *
from [PortfolioProject]..[CovidDeath]
where continent is not null
order by 3,4

--Select *
--from [PortfolioProject]..[CovidVaccinations]
--order by 3,4;

-- Select data going to use

Select location, date,new_cases,total_cases,total_deaths, population
FROM [PortfolioProject]..[CovidDeath]
where continent is not null
ORDER BY 1,2

--Viewing Total Cases vs Total Deaths
Select location, date,new_cases,total_cases,total_deaths,(convert(float,[total_deaths])/convert(float,[total_cases]))*100 as DeathPercentage 
FROM [PortfolioProject]..[CovidDeath]
WHERE Location like '%states%' AND
continent is not null
ORDER BY 1,2

--Viewing Total Cases vs Population
--Shows what percentatge of population contracted Covid

Select location, date,total_cases,population,(convert(float,[total_cases])/ population)*100 as PercentOfPopulationInfected 
FROM [PortfolioProject]..[CovidDeath]
WHERE Location like '%states%'
ORDER BY 1,2

--Looking at Countries with highest infection rate compared to population

Select location,population,MAX(total_cases) as Highest_Infection_Count,MAX(convert(float,[total_cases])/ population)*100 as PercentOfCaseByPop
FROM [PortfolioProject]..[CovidDeath]
--WHERE Location like '%states%'
GROUP BY location,population
ORDER BY PercentOfCaseByPop DESC;

--Showing Countries with highest Death Count per Population

Select location, MAX(convert(int,[total_deaths])) as TotalDeathCount
FROM [PortfolioProject]..[CovidDeath]
where continent is not null
GROUP By location
ORDER By TotalDeathCount DESC; 

--BREAK THINGS DOWN BY CONTINENT


--Showing the continents with the highest death count population
Select continent, MAX(convert(int,[total_deaths])) as TotalDeathCount
FROM [PortfolioProject]..[CovidDeath]
where continent is  not null
GROUP By continent
ORDER By TotalDeathCount DESC

--looking at Total Population vs Vaccinations

Select dea.continent, dea.location,dea.date,dea.population, vac.[new_vaccinations]
, SUM(CAST(vac.new_vaccinations AS BIGINT)) over (Partition by dea.location Order by dea.location, dea.date)
As RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM [PortfolioProject]..[CovidDeath] as dea
join [PortfolioProject]..[CovidVaccinations] as vac
	ON dea.location =vac.location
	AND dea.date = vac.date
where dea.continent is not null
ORDER BY 2,3

--USE CTE

WITH PopvsVac (Continent,Location, Date, Population, [new_vaccinations],RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.[new_vaccinations]
, SUM(CAST(vac.new_vaccinations AS BIGINT)) over (Partition by dea.location Order by dea.location, dea.date)
As RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100 
FROM [PortfolioProject]..[CovidDeath] as dea
JOIN [PortfolioProject]..[CovidVaccinations] as vac
	ON dea.location =vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *, (RollingPeopleVaccinated/population)*100 AS Rolling_Percent_Vaccinated
FROM PopvsVac;

--TEMP TABLE
--Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.[new_vaccinations]
, SUM(CAST(vac.new_vaccinations AS BIGINT)) over (Partition by dea.location Order by dea.location, dea.date)
As RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100 
FROM [PortfolioProject]..[CovidDeath] as dea
JOIN [PortfolioProject]..[CovidVaccinations] as vac
	ON dea.location =vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100 AS Rolling_Percent_Vaccinated
FROM #PercentPopulationVaccinated

--Creating a view for visualization
Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.[new_vaccinations]
, SUM(CAST(vac.new_vaccinations AS BIGINT)) over (Partition by dea.location Order by dea.location, dea.date)
As RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100 
FROM [PortfolioProject]..[CovidDeath] as dea
JOIN [PortfolioProject]..[CovidVaccinations] as vac
	ON dea.location =vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null