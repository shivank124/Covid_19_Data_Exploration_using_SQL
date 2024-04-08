use Covid_19_SQL_Project

select * from CovidDeaths$
where continent is not null
order by 3,4

select * from CovidVaccinations$
order by 3,4


-- Select the Data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
where continent is not null
order by 1,2


-- Lokking at Total Cases Vs Total Deaths
select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,4) as DeathPercentage
from CovidDeaths$
where location like '%india%' and continent is not null
order by 1,2


-- Looking at Total Cases Vs Population
--Shows what population got Covid
select location, date, population, total_cases, round((total_cases/population)*100,4) as PercentagePopulationInfected
from CovidDeaths$
where location like '%india%' and continent is not null

order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population
select location, population, max(total_cases) as HighestInfectionCount, round(max(total_cases/population)*100,4) as PercentagePopulationInfected
from CovidDeaths$
--where location like '%india%'
where continent is not null
group by location, population
order by PercentagePopulationInfected desc


-- Showing the Countries with the Highest Deaths Count per Population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
--where location like '%india%'
where continent is not null
group by location
order by TotalDeathCount desc


--Lets break down by Continent
--Showing the continent with the highrest death counts
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
--where location like '%india%'
where continent is not null
group by continent
order by TotalDeathCount desc


--Global Numbers
select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100
as DeathPercentage
from CovidDeaths$
--where location like '%india%' and 
where continent is not null
--group by date
order by 1,2 



--Global Numbers by Dates
select date, sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100
as DeathPercentage
from CovidDeaths$
--where location like '%india%' and 
where continent is not null
group by date
order by 1,2 

--Looking at Total Population Vs Vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Use CTEs
with PopVsVac (Contitnent, Location, Date, Population, New_Vaccination, RollingPeapleVaccined)
as 
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeapleVaccined/Population)*100 from PopVsVac


--Temp Table
drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
select *, (RollingPeopleVaccinated/Population)*100 from #PercentPopulationVaccinated


--Creating View to store data for later visualization
create view PercentagePOpulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3 

select * from 
PercentagePOpulationVaccinated