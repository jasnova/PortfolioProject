--select *
--from PortfolioProject..covidDeaths$
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population_density
from PortfolioProject..covidDeaths$
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

select location, date, total_cases,  total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..covidDeaths$
Where location like'%states%'
order by 1,2


--Looking at the Total Cases vs Population


select location, date, total_cases,  population_density, (total_cases/population_density)*100 as PercentPopulationInfected
From PortfolioProject..covidDeaths$
--Where location like'%states%'
order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population
select location, population_density, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population_density))*100 as PercentPopulationInfected
From PortfolioProject..covidDeaths$
--Where location like'%states%'
Group by location, population_density
order by PercentPopulationInfected desc


--showing countries with highest deat count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..covidDeaths$

--Where location like'%states%'
where continent is not null
Group by location
order by TotalDeathCount desc

-- break things down by continent

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..covidDeaths$
--Where location like'%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--global numbers
select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..covidDeaths$
--Where location like'%states%'
where continent is not null
--group by date
order by 1,2

select date sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..covidDeaths$
--Where location like'%states%'
where continent is not null
group by date
order by 1,2


--looking at total population vs vaccinations
SET ANSI_WARNINGS OFF
GO
select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
, (rollingpeoplevaccinated/population)*100
from PortfolioProject..covidDeaths$ dea
join PortfolioProject..covidVacinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use cte
With popvsvac(continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
from PortfolioProject..covidDeaths$ dea
join PortfolioProject..covidVacinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *
from popvsvac