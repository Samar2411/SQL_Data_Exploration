-- Selecting the Imported data to make sure it is working 

select * from dbo.CovidDeaths
select * from dbo.CovidVaccinations

-- Selecting the data that we will be working with 
Select location, date, total_cases, new_cases, total_deaths, population 
from CovidDeaths
Order by location, date --order by 1,2 es el mismo 

-- Total cases Vs Total deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Percentage_Death
from CovidDeaths
Order by location, date

---- Total cases Vs Total deaths in Spain
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Percentage_Death
from CovidDeaths
where location = 'Spain' 
----- there were 455 cases since the time of the study until the end of the study which is in April 2021, by the end of the study , it showed that there is a 2.21% chance of death if you have Covid-19 
--Order by location, date

---- Total cases Vs Total deaths in Syria
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Percentage_Death
from CovidDeaths
where location = 'Syria' 
Order by location, date
-- the situation in Syria was probably more serious, at the start, the percentage was huge , a person dies from every 9 people having covid which is around 11%
--by the end of the study and after the vaccine, the percentages were a bit better, as out of 22733 cases, 1592 deaths, which is almost 7% , less than the percentages received at the start of the pandemic
-- the peak was by the end of March 2020, with a percentage of death around 20%

---- Total cases Vs Population in Syria - shows the total cases that got Covid out of the population
Select location, date, total_cases, population, (total_cases/population)*100 as Percentage_infected
from CovidDeaths
where location = 'Syria' 
Order by Percentage_infected


--Looking at What country had the highest Infection rate , we will have to use Max Aggregate function, then also maintain to make sure it is correct in execution
Select Location, Max(total_cases) as Highest_Infection_Rate, Max(total_cases/population)*100 as highest_Percentage_Infected_Per_Population
from dbo.CovidDeaths
group by population, location
order by highest_Percentage_Infected_Per_Population desc
--Looks like Andorra is the most infected country by a 17% rate




--Highest death population rate after covid , similar to the one above but replacing the total cases with the total deaths , top 50 countries 
Select top 50 (Location), Population, Max(cast(total_deaths as int)) as Highest_death_Rate
from dbo.CovidDeaths
where continent is not null
group by population, location
order by Highest_death_Rate desc


-- Showing the continent with the highest death count 
Select continent Population, Max(cast(total_deaths as int)) as Highest_death_Rate
from dbo.CovidDeaths
where continent is not null
group by continent
order by Highest_death_Rate desc

--Global Numbers 
Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
from dbo.CovidDeaths
where continent is not null 
group by date


--Looking at Total Population Vs Vaccinations population percentage
--Here we are supposed to pull information from both the Covid Deaths dataset and the Covid Vaccinations Dataset 
--To proform this , we have to make a join between the two datasets 

Select Dea.date, Dea.Population, Dea.Location, Dea.continent, Vac.new_vaccinations, (Vac.new_vaccinations/Dea.population)* 100 as Vaccinated_Percentage
from dbo.CovidDeaths Dea
join dbo.CovidVaccinations Vac
on Dea.date = Vac.date and Dea.location = Vac.location
where Dea.continent is not null and new_vaccinations is not null 
order by Vaccinated_Percentage desc

-- The problem with the previous SQL code is that it is dealing with the total final cases, or day by day cases 
-- we need to do an accumulative addition, where everyday, in every location, I will be able to know the total vaccinated number of people in a certain country in a particular day
-- to do this, we have to do a partition by 
Select dea.date, dea.location, dea.population,dea.continent,vac.new_vaccinations,sum(convert(int, new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_Over_Vaccination from dbo.CovidDeaths dea 
join dbo.CovidVaccinations vac 
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
--group by dea.location
order by 2,3 


-- So now we want to have to use the Rolling_Over_Vaccination Percentage, we will not be able to use it and call it at the same instruction
-- Solution is to use either a CTE or a temp table to be able to call this table and create the Vaccination percentage for each country
with PopVsVac(date, location, population, continent, new_vaccinations, Rolling_Over_Vaccination) -- should be the same number and same order of the select statement underneath it
as(
Select dea.date, dea.location, dea.population,dea.continent,vac.new_vaccinations,sum(convert(int, new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_Over_Vaccination from dbo.CovidDeaths dea 
join dbo.CovidVaccinations vac 
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null AND new_vaccinations is not null
--group by dea.location
--order by 2,3 
)

Select date, location, (Rolling_Over_Vaccination/population)*100 as Vaccinated_Percentage_by_Country from PopVsVac -- Calculating the Vaccinated Percentage by country




-- Creating a View of the table 
Create view PercentPopulation as 
Select dea.date, dea.location, dea.population,dea.continent,vac.new_vaccinations,sum(convert(int, new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_Over_Vaccination from dbo.CovidDeaths dea 
join dbo.CovidVaccinations vac 
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null AND new_vaccinations is not null



