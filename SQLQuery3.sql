select * from db2..CovidDeaths$

select * from db2..CovidVaccinations$

--Select Data for graph
SELECT location,date,total_cases,new_cases,total_Deaths,population
FROM db2..coviddeaths$
ORDER BY 1,2



--Total Cases vs Total Deaths
SELECT location,date,total_cases,new_cases,total_Deaths,(total_cases/total_deaths)*100 as Lethality ,population
FROM db2..coviddeaths$
ORDER BY 1,2

--Percentage of Pop Infected
SELECT location,population,MAX(total_cases) as Total_Cases, MAX((total_cases/population))*100 as Pop_Perc_Inf
FROM db2..coviddeaths$
GROUP BY location,population
ORDER BY 1,2



--Highest Death Count by Country
select location, MAX(CAST(total_deaths as int)) as Total_Deaths
from db2..CovidDeaths$
WHERE continent is not null
GROUP BY location
order by Total_Deaths desc



--Highest Death Count by Continent
select continent, MAX(CAST(total_deaths as int)) as Total_Deaths
from db2..CovidDeaths$
WHERE continent is not null
GROUP BY continent
order by Total_Deaths desc



With PopVsVac(Continent,Location, Date, Population, New_Vaccinations, Area_Vaccination)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int))OVER(Partition by dea.location order by dea.location, dea.date) as Rolling_Vaccination
FROM db2..CovidDeaths$ dea
JOIN db2..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *,(Area_Vaccination/population)*100 as Perc_Vac
FROM PopVsVac



---------------------------------------------------------------
---------------------------------------------------------------

--Temp Table
DROP TABLE if exists #Percentage_Population_Vacc
CREATE TABLE #Percentage_Pop_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
Rolling_People_Vac numeric,

)
--Total pop vs Vaccinations
INSERT INTO #Percentage_Pop_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int))OVER(Partition by dea.location order by dea.location, dea.date) as Area_Vaccination
FROM db2..CovidDeaths$ dea
JOIN db2..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
order by continent



CREATE VIEW PercentPopVac as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int))OVER(Partition by dea.location order by dea.location, dea.date) as Area_Vaccination
FROM db2..CovidDeaths$ dea
JOIN db2..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
