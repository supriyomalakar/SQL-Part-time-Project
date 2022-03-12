select * 
from CovidStatusGlobal..CovidDeath
order by 3,4


--for table- CovidVaccination

--select * 
--from CovidStatusGlobal..CovidVaccination
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from CovidStatusGlobal..CovidDeath
where continent is not null
order by 1,2

-- total cases VS  total deaths

-- chances of dying if contracted corona

select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as percentage_of_deaths
from CovidStatusGlobal..CovidDeath 
where continent is not null
order by 1,2

--In India

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as percentage_of_deaths
from CovidStatusGlobal..CovidDeath 
where continent is not null
where location = 'India'
order by 1,2

-- total cases vs population

select location, date, total_cases, population, (total_cases/population)*100 as percentage_of_infection
from CovidStatusGlobal..CovidDeath 
where continent is not null
order by 1,2

-- In India

select location, date, total_cases, population, (total_cases/population)*100 as percentage_of_infection
from CovidStatusGlobal..CovidDeath 
where continent is not null
where location = 'India'
order by 1,2


-- Countries which have highest infection rate in terms of population

select location, population, max(total_cases) as most_infection, max((total_cases/population))*100 as percentage_of_population_infection
from CovidStatusGlobal..CovidDeath 
where continent is not null
group by location, population
order by percentage_of_population_infection desc

--countries with highest death count in terms of polulation

select location, population, max(cast(total_deaths as int)) as most_deaths, max((cast(total_deaths as int)/population))*100 as percentage_of_population_died
from CovidStatusGlobal..CovidDeath 
where continent is not null
group by location, population
order by most_deaths desc



-- Analysing as per continent

-- continent wise data
select continent, max(convert(int, total_deaths)) as most_deaths, max((cast(total_deaths as int)/population))*100 as percentage_of_population_died
from CovidStatusGlobal..CovidDeath 
where continent is not null 
group by continent
order by most_deaths desc


--top countries with most deaths
 
Select location, continent, MAX(cast(total_deaths as int)) as most_deaths
from CovidStatusGlobal..CovidDeath 
Where continent is not null 
Group by location, continent
order by most_deaths desc


--Global numbers


--new cases and death from day 1 of 2020

select date, sum(new_cases) as new_cases, sum(cast(new_deaths as int)) as new_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidStatusGlobal..CovidDeath 
where continent is not null
group by date
order by 1,2


select * 
from CovidStatusGlobal..CovidVaccination
order by 3,4

--total population versus vaccination. 

select death.continent, death.location, death.date, death.population, Vac.new_vaccinations, sum(convert(int,Vac.new_vaccinations)) over (partition by death.location)
from CovidStatusGlobal..CovidDeath as Death
inner join CovidStatusGlobal..CovidVaccination as Vac
	on death.location = Vac.location
	and death.date=Vac.date
where death.continent is not null
order by 1,2



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from CovidStatusGlobal..CovidDeath as Death
inner join CovidStatusGlobal..CovidVaccination as Vac
	on death.location = Vac.location
	and death.date=Vac.date
where death.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select death.continent, death.location, death.date, death.population, Vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by death.Location Order by death.location, dea.Date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by death.Location Order by death.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not null 









