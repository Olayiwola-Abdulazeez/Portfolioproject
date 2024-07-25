--SELECT * INTO CovidDeathBackup
--FROM PortfolioProject..CovidDeath

--select*
--From PortfolioProject..CovidDeath
--order  by 3,4

----select*
----From PortfolioProject..CovidVaccination
----order  by 3,4

----select data that we are going to be using

--select location, date, total_cases, new_cases, total_deaths, population
--From PortfolioProject..CovidDeath

--select location, date, total_cases, total_deaths, (total_deaths/total_cases)
--From PortfolioProject..CovidDeath
--order  by 1,2

--ALTER TABLE PortfolioProject..CovidDeath
--ADD totalcasesinteger FLOAT, totaldeathsinteger FLOAT

--UPDATE PortfolioProject..CovidDeath
--SET totaldeathsinteger = TRY_CAST(total_deaths AS FLOAT), totalcasesinteger = TRY_CAST(total_cases AS FLOAT)

--select total_deaths
--From PortfolioProject..CovidDeath


select location, date, total_deaths, total_cases, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeath
order by 3,4

--ALTER TABLE PortfolioProject..CovidDeath
--DROP COLUMN total_deaths, total_cases

--EXEC sp_rename 'PortfolioProject..CovidDeath.totalcasesinteger', 'total_cases', 'COLUMN'

--shows the likelihoodof dying if you contact covid in Nigeria 
select location, date, total_deaths, total_cases, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeath
where location like 'nigeria'
order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 AS PopulationInfectedPercentage
From PortfolioProject..CovidDeath
--where location like 'nigeria'
order by 1,2

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARE TO POPULATION
select location, population, max(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 AS PopulationInfectedPercentage
From PortfolioProject..CovidDeath
--where location like 'nigeria'
GROUP BY location, population
order by PopulationInfectedPercentage desc

--showing countries with the highest deathcount per population

select location, max(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeath
--where location like 'nigeria'
where continent is not null
GROUP BY location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

select location, max(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeath
--where location like 'nigeria'
where continent is null
GROUP BY location
order by TotalDeathCount desc

select continent, max(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeath
--where location like 'nigeria'
where continent is not null
GROUP BY continent
order by TotalDeathCount desc

--showing continent with the highest death count per population 

select continent, population, max(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeath
--where location like 'nigeria'
where continent is not null
GROUP BY continent, population
order by TotalDeathCount desc

--GLOBAL NUMBERS

select SUM(new_cases), SUM(new_deaths), CASE WHEN SUM(new_cases) = 0 THEN 0 ELSE (SUM(new_deaths)/SUM(new_cases))*100 END as DeathPercentage 
from PortfolioProject..CovidDeath
where continent is not null
--group by date 
order by 1,2

--Looking at Total Population vs Vaccinations

SELECT a.continent, A.location, a.date, a.population, b.new_vaccinations, SUM(CAST(b.new_vaccinations as bigint)) OVER (Partition by a.location order by a.location, a.date) as RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeath A
JOIN PortfolioProject..CovidVaccination B
ON A.location = B.location
AND A.date = B.date
where a.continent is not null
order by 2,3

--USE CTE
with popvsvac (continent, location, Date, population, new_vaccinations, rollingPeopleVaccinated)
as
(SELECT a.continent, A.location, a.date, a.population, b.new_vaccinations, SUM(CAST(b.new_vaccinations as bigint)) OVER (Partition by a.location order by a.location, a.date) as RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeath A
JOIN PortfolioProject..CovidVaccination B
ON A.location = B.location
AND A.date = B.date
where a.continent is not null
--order by 2,3
)select *, (rollingPeopleVaccinated/population)*100 
from popvsvac


--temp table

create table #PercentpopulationVaccinated
(continent nvarchar (255), location nvarchar (255), Date datetime, population numeric, new_vaccinations numeric, rollingPeopleVaccinated numeric)

insert into #PercentpopulationVaccinated
SELECT a.continent, A.location, a.date, a.population, b.new_vaccinations, SUM(CAST(b.new_vaccinations as bigint)) OVER (Partition by a.location order by a.location, a.date) as RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeath A
JOIN PortfolioProject..CovidVaccination B
ON A.location = B.location
AND A.date = B.date
where a.continent is not null
--order by 2,3
select *, (rollingPeopleVaccinated/population)*100 
from #PercentpopulationVaccinated

--creating view to store data for later visualizations

create view PercentpopulationVaccinated as
SELECT a.continent, A.location, a.date, a.population, b.new_vaccinations, SUM(CAST(b.new_vaccinations as bigint)) OVER (Partition by a.location order by a.location, a.date) as RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeath A
JOIN PortfolioProject..CovidVaccination B
ON A.location = B.location
AND A.date = B.date
where a.continent is not null
--order by 2,3

select *
from PercentpopulationVaccinated 