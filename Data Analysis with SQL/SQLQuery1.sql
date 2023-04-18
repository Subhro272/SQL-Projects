
Select *
From Subhro_DB..CovidDeaths$
Where continent is not null
order by 3, 4


Select *
From Subhro_DB..CovidVaccinations$
order by 3, 4

-- Select Data that we are going to be starting with

Select location, date, total_cases, new_cases, total_deaths, population
From Subhro_DB..CovidDeaths$
order by 1, 2

--total cases vs total deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From Subhro_DB..CovidDeaths$
Where location like '%states%'
order by 1, 2

-- total cases vs population

Select location, date, total_cases, population, (total_cases/population)*100 as Infection_Percentage
From Subhro_DB..CovidDeaths$
order by 1, 2

-- Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as Highest_Infection_Count,  Max((total_cases/population))*100 as Infection_Percentage
From Subhro_DB..CovidDeaths$
Group by location, population
order by Infection_Percentage desc

-- Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as Total_Death_Count
From Subhro_DB..CovidDeaths$
Where continent is not null 
Group by location
order by Total_Death_Count desc

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as Total_Death_Count
From Subhro_DB..CovidDeaths$
Where continent is not null 
Group by continent
order by Total_Death_Count desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as Death_Percentage
From Subhro_DB..CovidDeaths$
Where continent is not null
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
From Subhro_DB..CovidDeaths$ dea
Join Subhro_DB..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (continent, location, Date, Population, new_vaccinations, Rolling_People_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
From Subhro_DB..CovidDeaths$ dea
Join Subhro_DB..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (Rolling_People_Vaccinated/Population)*100
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Subhro_DB..CovidDeaths$ dea
Join Subhro_DB..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Subhro_DB..CovidDeaths$ dea
Join Subhro_DB..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 