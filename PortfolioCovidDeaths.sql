--Running both tables to see what is the data like 

--Select * from PortfolioProject.dbo.CovidDeaths
--order by 3,4

--Select * from PortfolioProject.dbo.CovidVaccinations
--order by 3,4





-- Selecting the data that we are going to be using
--select location, date, total_cases, new_cases, total_deaths, population 
--from PortfolioProject..CovidDeaths
--order by 1,2

--Calculating the percentage of the people who died compared to total cases for each country 
--select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as percentage
--from PortfolioProject..CovidDeaths
--order by 1,2
-- 4.2 meaning you have a 4.2% chance of dying in case you got covid-19


-- Checking the United states latest death percentage, showing the likelihood if you got Covid in your country
--select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as percentage
--from PortfolioProject..CovidDeaths
--where location like '%states%'
--order by total_cases desc

-- Calculating total cases compared to total population
--Select location, date, total_cases, population, (total_cases/population)*100 as Cases_vs_Population
--from PortfolioProject..CovidDeaths
--where location like '%spain%'
--Order by Cases_vs_Population desc

--Looking at the countries that have the highest infection rate compared to its population
