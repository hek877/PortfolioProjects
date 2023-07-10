Select *
From [Portfolio Project]..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From [Portfolio Project]..CovidVaccinations
--order by 3,4;

--Select Data that will be used

Select Location, date, total_cases, new_cases,total_deaths, population 
From [Portfolio Project]..CovidDeaths
Where continent is not null
Order by 1,2;

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying from covid if contracted by country
Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage 
From [Portfolio Project]..CovidDeaths
Where location like '%states'
Order by 1,2;

--Looking at Total Cases vs Population
--Shows Population Contraction Rate
Select Location, date, total_cases, population,(total_cases/population)*100 as ContractionPercentage 
From [Portfolio Project]..CovidDeaths
--Where location like '%states'
Order by 1,2;

--Looking at Highest Contraction Rate by County
Select Location, Population, MAX(total_cases) as HighestContractionCount, MAX((total_cases/population))*100 as PercentageofPopulationInfected 
From [Portfolio Project]..CovidDeaths
--Where location like '%states'
Group by location, population
Order by PercentageofPopulationInfected desc


--Showing Highest Death Count per Population
Select Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%states'
Where continent is not null
Group by location
Order by TotalDeathCount desc

--Broken Down by Continent
Select location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%states'
Where continent is null
Group by location
Order by TotalDeathCount desc

--Global Numbers
Select SUM(new_cases)as Total_Cases, SUM(cast(new_deaths as int))as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage--,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage 
From [Portfolio Project]..CovidDeaths
--Where location like '%states'
where continent is not null
--Group by date
Order by 1,2;

--Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinationCount,
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--CTE

--Total Population vs Vaccinations
With PopvsVac (Continent, Location ,Date ,Population ,New_Vaccinations ,RollingVaccinationCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinationCount
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingVaccinationCount/Population)*100
From PopvsVac 

--TEMP Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Locatio nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinationCount numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinationCount
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select *, (RollingVaccinationCount/Population)*100
From #PercentPopulationVaccinated 


--Creating View to store data for later vizualization
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinationCount
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated