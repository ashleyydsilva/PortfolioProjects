select * 
from CovidDeaths$
where continent in not null
order by 3,4 

--select * 
--from CovidVaccinations$
--order by 3,4 

---selecting data going to be used 
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
where continent is not null
order by 1,2


---looking at total case vs total deaths
---shows probability of death if contracted by covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
where location like '%states%'
and continent is not null
order by 1,2
 
 --- looking at total cases vs population 
 ---shows what percentage of populatioin got covid 
 select location, date,  population, total_cases,(total_cases/population)*100 as PercentagePopulation
from CovidDeaths$
--where location like '%states%'
order by 1,2
 

 ---looking at countries with highest infection rate compared to population 
 select location,  population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected
from CovidDeaths$
--where location like '%states%'
group by location, population
order by PercentagePopulationInfected desc


---showing countries with highest death count per population 
 select location,  max(cast(total_deaths as int)) as TotalDeathcount
from CovidDeaths$
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathcount desc



---LETS BREAK THINGS DOWN BY CONTINENT
---showing continents with highest death counts

 select continent,  max(cast(total_deaths as int)) as TotalDeathcount
from CovidDeaths$
--where location like '%states%'
where continent is NOT null
group by continent
order by TotalDeathcount desc


---global numbers 

select date,sum(new_cases)as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths$
--where location like '%states%'
where continent is not null
group by date 
order by 1,2



select   sum(new_cases)as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths$
--where location like '%states%'
where continent is not null
--group by date 
order by 1,2



--looking at total population vs vaccination 
select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeoplevaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location=vac.location 
	and dea.date=vac.date
where dea.continent is not null
order by 2,3


--Use CTE

with PopvsVac (continent, location , date, population ,New_Vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeoplevaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location=vac.location 
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--TEMP TABLE


drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeoplevaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location=vac.location 
	and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



--- creating view to store data for visualizations

create view PercentPopulationVaccinated as 
select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeoplevaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location=vac.location 
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated

----creating another view for Total Death count 

create view TotalDeathCount as
select continent,  max(cast(total_deaths as int)) as TotalDeathcount
from CovidDeaths$
--where location like '%states%'
where continent is NOT null
group by continent
--order by TotalDeathcount desc
