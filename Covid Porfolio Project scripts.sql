select *
from PortfolioProject..[Covid Vaccinations]
where continent is not NULL
order by 3,4

select *
from PortfolioProject..CovidDeaths
where continent is not NULL
order by 3,4

--select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
--where continent is not NULL
order by 1,2

--Looking at total case to total death
-- Show the likelyhood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where continent is not NULL
where location like '%state%'
order by 1,2


-- Looking at total cases vs Total Population

select location, date, total_cases, population, (total_cases/population) * 100 as PercentofPopulation
from PortfolioProject..CovidDeaths
where location like '%state%'
and continent is not NULL
order by 1,2

-- What country has the highest infection rate compare to population

select location, max(total_cases) as HightestInfectionCount, population, max((total_cases/population)) * 100 as PercentpPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%state%'
group by location, population
order by PercentpPopulationInfected desc

--showing the country with the highest death count per popluation

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%state%'
where continent is not NULL
group by location
order by TotalDeathCount desc
-- United State is #1 and the highest.


-- LET'S BREAK THINGS DOWN BY CONTINENTS

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where loc	ation like '%state%'
where continent is not NULL
group by continent
order by TotalDeathCount desc


-- Global numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

-- deaths whole world 
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2


-- how to join the two xlms data


select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..[Covid Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date

	-- Looking at total population vs vaccinations


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) 
OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopeleVaccination
--(RollingPeopeleVaccination/population) * 100  -- Cannot use a column we create to do math
from PortfolioProject..CovidDeaths dea
join PortfolioProject..[Covid Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Create CTE to use calculated date in a table "RollingPeopeleVaccination"

with PopvsVac (continent, location, date, popluation, new_vaccinations, RollingPeopeleVaccination)
as
(

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) 
OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopeleVaccination
--(RollingPeopeleVaccination/population) * 100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..[Covid Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

)
-- must run everything with the "with" clause^^
select *, (RollingPeopeleVaccination/popluation) * 100
from PopvsVac


-- TEMP Table --
Drop table if exists #PercentpopluationVaccinated
create table #PercentpopluationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
poplulation numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentpopluationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) 
OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopeleVaccination
--(RollingPeopeleVaccination/population) * 100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..[Covid Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select *, (RollingPeopleVaccinated/poplulation) * 100
from #PercentpopluationVaccinated

-- Creating view to store data for later visulizations

create view PercentPopluationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) 
OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopeleVaccination
--(RollingPeopeleVaccination/population) * 100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..[Covid Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3



--  create view Looking at total population vs vaccinations

create view TotalPopluationvsVaccinations as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) 
OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopeleVaccination
--(RollingPeopeleVaccination/population) * 100  -- Cannot use a column we create to do math
from PortfolioProject..CovidDeaths dea
join PortfolioProject..[Covid Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3


-- Make sure to CHANGE avaiable database to selected location-- it will store it in view folder but under that database
select *
from TotalPopluationvsVaccinations


-- create view for Global numbers
create view Globalnumbers as
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
--order by 1,2

select *
from Globalnumbers
order by date