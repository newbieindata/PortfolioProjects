
Select *
From [Porfolio Project].dbo.CovidDeaths
Where continent IS not NULL
Order by 3,4

--Select *
--From CovidVaccinations
--Order by 3,4

Select Location, date, total_cases, new_cases, total_deaths,population
From [Porfolio Project].dbo.CovidDeaths
Order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract Covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
From [Porfolio Project].dbo.CovidDeaths
Where Location = 'Australia'
Order by 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population infected by Covid

Select Location, date, total_cases , population , (total_cases/population)*100 As PercentPopulationInfected
From [Porfolio Project].dbo.CovidDeaths
--Where Location = 'Australia'
Order by 1,2


--Looking at Countries with Highest infection rate compared to Population

Select Location, population, Max(total_cases) as HighestInfectionCount , Max((total_cases/population))*100 As PercentPopulationInfected
From [Porfolio Project].dbo.CovidDeaths
--Where Location = 'Australia'
Group By Location, population
Order by PercentPopulationInfected DESC


--Showing Countries with Highest Death Count per population

Select Location, Max(total_deaths) as HighestDeathCount 
From [Porfolio Project].dbo.CovidDeaths
Where continent IS not NULL
Group By location
Order by HighestDeathCount DESC


--LET'S BREAK THINGS DOWN INTO CONTINENT

--Showing the Continent with Highest Deaths Counts

Select continent, Max(total_deaths) as HighestDeathCount 
From [Porfolio Project].dbo.CovidDeaths
Where continent IS NOT NULL
Group By continent
Order by HighestDeathCount DESC


--GLOBAL NUMBERS

Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as bigint)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 As DeathPercentage
From [Porfolio Project].dbo.CovidDeaths
--Where Location = 'Australia'
Where continent IS NOT NULL
--GROUP BY date
Order by 1, 2


--Total Population vs Vaccinations

Select *
From [Porfolio Project] ..CovidDeaths dea
JOIN [Porfolio Project]..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date

 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From [Porfolio Project] ..CovidDeaths dea
JOIN [Porfolio Project]..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
Where dea.continent IS NOT NULL
Order BY 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingCountVaccination
From [Porfolio Project] ..CovidDeaths dea
JOIN [Porfolio Project]..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
Where dea.continent IS NOT NULL
Order BY 2,3


--USE of CTE

With PopvsVac(Continent, Location, Date, population, New_Vaccinations, RollingCountVaccination)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingCountVaccination
From [Porfolio Project] ..CovidDeaths dea
JOIN [Porfolio Project]..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
Where dea.continent IS NOT NULL
--Order BY 2,3
)
Select *, (rollingCountVaccination/Population)*100
From PopvsVac


--Use of TEMP Table

DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingCountVaccination numeric
)

INSERT into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingCountVaccination
From [Porfolio Project] ..CovidDeaths dea
JOIN [Porfolio Project]..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date

Select *, (rollingCountVaccination/Population)*100 as VaccinationPercentage
From #PercentPopulationVaccinated



--Creating View to store data for later visualization


USE [Porfolio Project]
Go
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingCountVaccination
From [Porfolio Project] ..CovidDeaths dea
JOIN [Porfolio Project]..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
Where dea.continent IS NOT NULL
--Order BY 2,3

SELECT 
OBJECT_SCHEMA_NAME(o.object_id) schema_name,o.name
FROM
sys.objects as o
WHERE
o.type = 'V';



