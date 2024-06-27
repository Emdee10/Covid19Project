select *
from Covid_19_project..CovidDeaths
where continent is not null

--select *
--from Covid_19_project..Covid_Vaccinations

select Location, date, total_cases, new_cases, total_deaths, population
from Covid_19_project..CovidDeaths
where continent is not null

--Looking at Total Case vs Total Deaths
--Showing likelihood of death 

select Location, date, total_cases, total_deaths,(convert(float,total_deaths) /total_cases)*100 as DeathPercentage
from Covid_19_project..CovidDeaths
where location like '%United Kingdom%'
and continent is not null

--Looking at Total Cases vs Population
--Showing the percentage of the population that contracted covid

select Location, date, population, total_cases,(total_cases/ population )*100 as InfectedPopulationPercentage
from Covid_19_project..CovidDeaths
where location like '%United Kingdom%'
and continent is not null

--Looking at country with the highest total infection count & percentage compared to population

select CAST(Location as nvarchar(100))Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/ population ))*100 as InfectedPopulationPercentage
from Covid_19_project..CovidDeaths
where continent is not null
Group by CAST(Location as nvarchar(100)), population
order by 4 desc


cast(total_cases as nvarchar(100)

--BREAKING THE DATA DOWN BY CONTINENT
--Showing cotinents with the highest death count

select CAST(continent as nvarchar(100))Continent,MAX(CAST(total_deaths as int)) as HighestDeathCount
from Covid_19_project..CovidDeaths
where continent is not null
Group by CAST(continent as nvarchar(100))
order by 2

Looking at Total Case vs Total Deaths
--Showing likelihood of death 

select Continent, date, total_cases, total_deaths,(convert(float,total_deaths) /total_cases)*100 as DeathPercentage
from Covid_19_project..CovidDeaths
where location like '%United Kingdom%'
and continent is not null

Looking at Total Cases vs Population
--Showing the percentage of the population that contracted covid

select continent, date, population, total_cases,(total_cases/ population )*100 as InfectedPopulationPercentage
from Covid_19_project..CovidDeaths
where location like '%United Kingdom%'
and continent is not null

--Looking at continent with the highest total infection count & percentage compared to population

select CAST(continent as nvarchar(100))Continent, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/ population ))*100 as InfectedPopulationPercentage
from Covid_19_project..CovidDeaths
where continent is not null
Group by CAST(continent as nvarchar(100)), population
order by 4 desc

--GLOBAL NUMBERS

select SUM(cast(new_cases as int))as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
	SUM(cast(new_deaths as int))/SUM(cast(new_cases as float))*100 as DeathPercentage
from Covid_19_project..CovidDeaths
where continent is not null
--where location like '%United Kingdom%'
--group by date
order by 1

--Looking at Total Population vs Vaccination

select Cast(dea.continent as nvarchar(100))Continent, Cast(dea.location as nvarchar(100))Location, dea.date, population,
	vac.new_vaccinations, Sum(Cast(vac.new_vaccinations as int)) 
	Over (partition by Cast(dea.location as nvarchar(100)) order by Cast(dea.location as nvarchar(100)), 
	dea.date) as RollingPeopleVaccinaed
from Covid_19_project..CovidDeaths dea
join Covid_19_project..Covid_Vaccinations vac
on dea.iso_code = vac.iso_code
and dea.date= vac.date
where dea.continent is not null
order by 2,3


--USE CTE

with PopvsVac_cte as
(select Cast(dea.continent as nvarchar(100))Continent, Cast(dea.location as nvarchar(100))Location, dea.date, population,
	vac.new_vaccinations, Sum(Cast(vac.new_vaccinations as int)) 
	Over (partition by Cast(dea.location as nvarchar(100)) order by Cast(dea.location as nvarchar(100)), 
	dea.date) as RollingPeopleVaccinaed
from Covid_19_project..CovidDeaths dea
join Covid_19_project..Covid_Vaccinations vac
on dea.iso_code = vac.iso_code
and dea.date= vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinaed/population) as PercentVaccinated
from PopvsVac_cte

--CREATING TEMPORARY TABLE

Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_Vacinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select Cast(dea.continent as nvarchar(100))Continent, Cast(dea.location as nvarchar(100))Location, dea.date, population,
	vac.new_vaccinations, Sum(Cast(vac.new_vaccinations as int)) 
	Over (partition by Cast(dea.location as nvarchar(100)) order by Cast(dea.location as nvarchar(100)), 
	dea.date) as RollingPeopleVaccinaed
from Covid_19_project..CovidDeaths dea
join Covid_19_project..Covid_Vaccinations vac
on dea.iso_code = vac.iso_code
and dea.date= vac.date
where dea.continent is not null
--order by 2,3


select *, (RollingPeopleVaccinated/population) as PercentVaccinated
from #PercentPopulationVaccinated
order by 2,3


--Creating view to store data for visualisation

Create View PercentPopulationVaccinated as
select Cast(dea.continent as nvarchar(100))Continent, Cast(dea.location as nvarchar(100))Location, dea.date, population,
	vac.new_vaccinations, Sum(Cast(vac.new_vaccinations as int)) 
	Over (partition by Cast(dea.location as nvarchar(100)) order by Cast(dea.location as nvarchar(100)), 
	dea.date) as RollingPeopleVaccinaed
from Covid_19_project..CovidDeaths dea
join Covid_19_project..Covid_Vaccinations vac
on dea.iso_code = vac.iso_code
and dea.date= vac.date
where dea.continent is not null
--order by 2,3
