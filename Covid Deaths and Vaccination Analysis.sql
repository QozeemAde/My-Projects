/*This is a portfolio project on covid 19. The tables contained are covid-19 deaths and vaccinations for every country between the period it was first discovered.
The data set was gotten from kaggle  and was loaded into the database I created named PorfolioProject.*/

Use PortfolioProject

-- Viewing all the dataset in covid death table
SELECT *
FROM CovidDeaths
--ORDER BY 3,4

--Viewing the whole  columns in covid vaccinations table

SELECT *
FROM CovidVaccinations
--ORDER BY 3,4

--Using the order by clause to view some column in the data set.
SELECT location, date , total_cases, new_cases, total_deaths, population
FROM  CovidDeaths
ORDER BY 1,2

--Comparing the Total cases vs total deaths 
--   This shows the likelihood that someone may die of Covid if infected in Nigeria

SELECT location, date ,total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) as PercentageDeath
FROM  CovidDeaths
WHERE location LIKE 'Nigeria'
ORDER BY 2 

-- Looking at Total cases vs Population
	--Percentage of population that got infected by covid 
SELECT location, date ,population, total_cases, ROUND((total_cases/population)*100,2) as Percentage_population_infected
FROM  CovidDeaths
WHERE location LIKE 'Nigeria'
ORDER BY 2

-- Getting the country with the highest infection rate

SELECT location,population,MAX(total_cases) as Highest_infection, ROUND(MAX(total_cases/population)*100,2) as Max_percent_count
FROM  CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY Max_percent_count DESC

-- Countries with highest deaths

SELECT location, MAX(CAST(total_deaths AS int)) as Highest_death
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY Highest_death DESC


-- DRILLING DOWN TO CONTINENT 

SELECT continent, MAX(CAST(total_deaths AS int)) as Highest_death
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY Highest_death DESC


--Selecting all continents
/*
SELECT DISTINCT(continent)
FROM CovidDeaths*/



--WORLD NUMBERS 

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_death,(SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as death_percent
FROM  CovidDeaths
WHERE continent is not null 
ORDER BY 1,2

/*
JOINING THE VACCINATION AND DEATH TABLE */

--vaccinated population

SELECT d.continent, d.location, d.date ,d.population, v.new_vaccinations 
FROM CovidDeaths d
JOIN CovidVaccinations v
ON d.location= v.location 
AND d.date = v.date 
WHERE d.continent is not null
ORDER BY 1,2,3

-- ROLLING TOTAL PEOPLE VACCINATED BY LOCATION

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations , SUM(CONVERT(bigint,v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as rolling_people_vaccinated_by_location
FROM CovidDeaths d
JOIN CovidVaccinations v
ON d.location= v.location 
AND d.date = v.date 
WHERE d.continent is not null
--GROUP BY d.location, d.continent
ORDER BY 2,3

-- PERCENTAGE VACCINATED OF POPULATION USING CTE

WITH popvsvac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated_by_location)
as
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations , SUM(CONVERT(bigint,v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as rolling_people_vaccinated_by_location
FROM CovidDeaths d
JOIN CovidVaccinations v
ON d.location= v.location 
AND d.date = v.date 
WHERE d.continent is not null
)
SELECT * , (rolling_people_vaccinated_by_location/population)*100 as percent_population_vacc
FROM popvsvac
