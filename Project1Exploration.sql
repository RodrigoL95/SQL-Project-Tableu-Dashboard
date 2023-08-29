SELECT *
FROM BootcampDA.dbo.CovidDeaths1

order by 3,4


SELECT *
FROM BootcampDA.dbo.CovidVaccinations1
order by 3,4


SELECT location,date,total_cases,new_cases,total_deaths,population
FROM BootcampDA.dbo.CovidDeaths1
WHERE continent is not null
order by 1,2

--LOOKING AT TOTAL CASES VS DEATHS 
--Shows likelihood of dying if you contract covid in your country

SELECT location,CAST(date AS datetime) as date ,total_cases,total_deaths, CAST(total_deaths as float)/CAST(total_cases AS float)*100 as DeathPercentage
FROM BootcampDA.dbo.CovidDeaths1
WHERE location LIKE '%Mexico%' and 
continent is not null
order by 1,2

--LOOKING AT THE TOTAL CASES VS POPULATION

SELECT location,CAST(date AS datetime) as date ,Population,total_cases, CAST(total_cases as float)/CAST(population AS float)*100 as PopulationCovidPercentage
FROM BootcampDA.dbo.CovidDeaths1
WHERE continent is not null
order by 1,2

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location,Population,COALESCE(MAX(total_cases),0) AS HighestInfectionCount, COALESCE(ROUND(MAX(CAST(total_cases as float)/CAST(population AS float))*100,2),0) as PopulationCovidPercentage
FROM BootcampDA.dbo.CovidDeaths1
WHERE continent is not null
group by location, population
order by 4 DESC

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION AND DATE

SELECT location,Population,date,COALESCE(MAX(total_cases),0) AS HighestInfectionCount, COALESCE(ROUND(MAX(CAST(total_cases as float)/CAST(population AS float))*100,2),0) as PopulationCovidPercentage
FROM BootcampDA.dbo.CovidDeaths1
WHERE continent is not null
group by location, population,date
order by 5 DESC

--SHOWING THE COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION 

SELECT location,MAX(total_deaths) AS HighesDeathsCount
FROM BootcampDA.dbo.CovidDeaths1
WHERE continent is not null
group by location
order by 2 DESC

--SHOWING THE COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION AND CONTINENT 

SELECT continent,location, Maxim
FROM
(SELECT continent,location, MAX(total_deaths) as Maxim,  ROW_NUMBER() OVER (PARTITION BY continent ORDER BY MAX(total_deaths) DESC) as position
FROM BootcampDA.dbo.CovidDeaths1
WHERE continent is not null
GROUP BY continent,location
) POS

WHERE position = 1
ORDER BY 3 DESC

--GOLBAL NUMBERS UNTIL 2021

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, round(SUM(new_deaths)/SUM(new_cases)*100,2) as DeathPercentage
FROM BootcampDA.dbo.CovidDeaths1
--WHERE location LIKE '%Mexico%' and 
WHERE continent is not null
--GROUP BY date 
order by 1,2

--Deaths by country
--European Union is part to Europe

Select location, SUM(new_deaths) as TotalDeathCount
From BootcampDA.dbo.CovidDeaths1
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

--LOKING AT TOTAL POPULATION VS VACCINATIONS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) as RollingPeopleVaccinated
FROM BootcampDA.dbo.CovidDeaths1 dea
JOIN BootcampDA.dbo.Covidvaccinations1 vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
order by 2,3


-- USE CTE


WITH PopvsVac (continet, location, date, population, New_vaccinations, RollingPeolpleVaccinated)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) as RollingPeopleVaccinated
FROM BootcampDA.dbo.CovidDeaths1 dea
JOIN BootcampDA.dbo.Covidvaccinations1 vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)

SELECT*, (RollingPeolpleVaccinated/population)*100
FROM PopvsVac


--CREATING VIEWS TO VISUALIATE LATER 

CREATE VIEW PercentPopulationVaccinated AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) as RollingPeopleVaccinated
FROM BootcampDA.dbo.CovidDeaths1 dea
JOIN BootcampDA.dbo.Covidvaccinations1 vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null)

CREATE VIEW Highestcountriescount AS 

SELECT continent,location, maxi
FROM
(SELECT continent,location, MAX(total_deaths) as maxi,  ROW_NUMBER() OVER (PARTITION BY continent ORDER BY MAX(total_deaths) DESC) as position
FROM BootcampDA.dbo.CovidDeaths1
WHERE continent is not null
GROUP BY continent,location
) POS

WHERE position = 1



SELECT*
FROM Highestcountriescount

