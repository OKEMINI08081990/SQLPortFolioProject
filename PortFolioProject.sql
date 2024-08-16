Select *
From PortFolioProject..CovidDeaths
where continent is not null
order by 3,4


Select location, date, total_cases, new_cases, total_deaths, population
From PortFolioProject..CovidDeaths
where continent is not null
order by 1,2

--Total cases vs Total Deaths
--Shows likelihood of dying if one contracts covid in his country

Select location, date, total_cases, total_deaths, (total_deaths)/(NULLIF(total_cases,0))*100 as DeathPercentage
From PortFolioProject..CovidDeaths
where continent is not null
order by 1,2 desc

Select location, date, total_cases, total_deaths, (total_deaths)/(NULLIF(total_cases,0))*100 as PercentageofPopulationInfected
From PortFolioProject..CovidDeaths
where location like '%nigeria%'
order by 1,2 desc

--Looking at Total cases VS Population
--Shows what percentage of population got covid

Select location, date, population, total_cases, (total_cases)/(NULLIF(population,0))*100 as PercentageofPopulationInfected
From PortFolioProject..CovidDeaths
where location like '%nigeria%'
order by 1,2 desc

--Countries with highest infection rates compare to population

Select location, population, MAX(total_cases)as HighestInfection, MAX(CAST(total_cases as int))/(NULLIF(population,0))*100 as 
PercentageofPopulationInfected
From PortFolioProject..CovidDeaths
--where location like '%nigeria%'
Group by location, population
order by PercentageofPopulationInfected desc

--Countries with highest death count per population

Select location, MAX(cast(total_deaths as int))as TotalDeathCount 
From PortFolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

--Breakdown by Continent

Select Continent, MAX(cast(total_deaths as int))as TotalDeathCount 
From PortFolioProject..CovidDeaths
where continent is not null
Group by Continent
order by TotalDeathCount desc

Select location, MAX(cast(total_deaths as int))as TotalDeathCount 
From PortFolioProject..CovidDeaths
where continent is null
Group by location
order by TotalDeathCount desc

--GLOBAL NUMBERS

Select location, date, SUM(new_cases) as Total_cases, SUM(CAST(new_deaths as int)) as Total_deaths, sum(new_deaths)/sum(NULLIF(new_cases,0))*100 as 
DeathPercentage
From PortFolioProject..CovidDeaths
where continent is not null
Group by location, date
order by 1,2 desc

Select date, SUM(new_cases) as Total_cases, SUM(CAST(new_deaths as int)) as Total_deaths, sum(new_deaths)/sum(NULLIF(new_cases,0))*100 as 
DeathPercentage
From PortFolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2 desc

Select SUM(new_cases) as Total_cases, SUM(CAST(new_deaths as int)) as Total_deaths, sum(new_deaths)/sum(NULLIF(new_cases,0))*100 as 
DeathPercentage
From PortFolioProject..CovidDeaths
where continent is not null
--Group by date
order by 1,2 desc


--JOINING TWO TABLES

Select*
From PortFolioProject..CovidVaccinations

Select*
From PortFolioProject..CovidDeaths dea
 Join PortFolioProject..CovidVaccinations vac
 On dea.location=vac.location
  and dea.date=vac.date
  order by 1,2

  --Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortFolioProject..CovidDeaths dea
 Join PortFolioProject..CovidVaccinations vac
 On dea.location=vac.location
  and dea.date=vac.date
  where dea.continent is not null
  order by 1,2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortFolioProject..CovidDeaths dea
 Join PortFolioProject..CovidVaccinations vac
 On dea.location=vac.location
  and dea.date=vac.date
  where dea.continent is not null
  order by 2,3


  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  ,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location)
From PortFolioProject..CovidDeaths dea
 Join PortFolioProject..CovidVaccinations vac
 On dea.location=vac.location
  and dea.date=vac.date
  where dea.continent is not null
  order by 1,2,3

  
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  ,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location) as TotalVacc
From PortFolioProject..CovidDeaths dea
 Join PortFolioProject..CovidVaccinations vac
 On dea.location=vac.location
  and dea.date=vac.date
  where dea.location like '%nigeria%'
  order by 1,2,3


  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  ,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
From PortFolioProject..CovidDeaths dea
 Join PortFolioProject..CovidVaccinations vac
 On dea.location=vac.location
  and dea.date=vac.date
  where dea.continent is not null
  order by 1,2,3


   Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  ,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
From PortFolioProject..CovidDeaths dea
 Join PortFolioProject..CovidVaccinations vac
 On dea.location=vac.location
  and dea.date=vac.date
  where dea.location like '%nigeria%'
  order by 1,2,3


     --CTE

With popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
   Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  ,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
From PortFolioProject..CovidDeaths dea
 Join PortFolioProject..CovidVaccinations vac
 On dea.location=vac.location
  and dea.date=vac.date
  where dea.location is not null
  order by 2,3
 offset 0 rows
  )
  select*, (RollingPeopleVaccinated/population)*100
  From popvsvac

  --TEMP TABLE

  Drop Table if exists #PrcentPopulationVaccinated
  Create Table #PrcentPopulationVaccinated
  (
  Continent nvarchar(225),
  Location nvarchar(225),
  Date datetime,
  Population numeric,
  New_Vaccinations numeric,
  RollingPeopleVaccinated numeric
  )
  Insert into #PrcentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  ,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
From PortFolioProject..CovidDeaths dea
 Join PortFolioProject..CovidVaccinations vac
 On dea.location=vac.location
  and dea.date=vac.date
  where dea.location is not null
  order by 2,3
 offset 0 rows
  select*, (RollingPeopleVaccinated/population)*100
  From #PrcentPopulationVaccinated


  --Creating View to Store Data for later Visualization

--  Create view PrcentPopulationVaccinated as
--  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--  ,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
--From PortFolioProject..CovidDeaths dea
-- Join PortFolioProject..CovidVaccinations vac
-- On dea.location=vac.location
--  and dea.date=vac.date
--  where dea.location is not null
--  --order by 2,3
-- --offset 0 rows

 Select *
 From PrcentPopulationVaccinated

