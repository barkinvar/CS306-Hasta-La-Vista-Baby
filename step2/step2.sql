SET SQL_SAFE_UPDATES = 0; # for the DELETE STATEMENTS TO BE PROCESSED

CREATE TABLE country(

country_code VARCHAR(10) NOT NULL,
country_name VARCHAR(50) NOT NULL,

PRIMARY KEY (country_code)
);

CREATE TABLE continent(

continent_code VARCHAR(10) NOT NULL,
continent_name VARCHAR(50) NOT NULL,

PRIMARY KEY (continent_code)
);

CREATE TABLE population(

country_code VARCHAR(10) NOT NULL,
pop_year INT NOT NULL,
life_exp REAL,
num_pop INT,
pop_density REAL,

PRIMARY KEY (country_code, pop_year),
Foreign Key (country_code) References
country(country_code) ON DELETE CASCADE
);

CREATE TABLE s_deaths(

country_code VARCHAR(10) NOT NULL,
death_stat_year INT NOT NULL,
percentage_among_all_deaths REAL,

PRIMARY KEY (country_code, death_stat_year),
FOREIGN KEY (country_code) REFERENCES
country(country_code) ON DELETE CASCADE
);


CREATE TABLE smoker(

country_code VARCHAR(10) NOT NULL,
smoker_stat_year INT NOT NULL,
percentage_among_all_adults REAL,

PRIMARY KEY (country_code, smoker_stat_year),
FOREIGN KEY (country_code) REFERENCES
country(country_code) ON DELETE CASCADE
);

CREATE TABLE located(

continent_code VARCHAR(5) NOT NULL,
country_code VARCHAR(5) NOT NULL,

PRIMARY KEY (country_code), # each country can at most one continent, whereas a continent can have many countries

FOREIGN KEY (continent_code) REFERENCES
continent(continent_code) ON DELETE CASCADE,

FOREIGN KEY (country_code) REFERENCES
country(country_code) ON DELETE CASCADE
);

SELECT * FROM smoker;
UPDATE population INNER JOIN populationdensity ON population.country_code = populationdensity.Code AND population.pop_year = populationdensity.Year SET population.country_code = populationdensity.Code, population.pop_year = populationdensity.Year, population.pop_density = populationdensity.popd;
DROP TABLE populationdensity;

CREATE TABLE Taxes(

country_code VARCHAR(10) NOT NULL,
tobacco_stat_year INT NOT NULL,
percentage_increase_tobacco INT,

PRIMARY KEY (country_code, tobacco_stat_year),
FOREIGN KEY (country_code) REFERENCES
country(country_code) ON DELETE CASCADE
);

CREATE TABLE M_Disorder(

country_code VARCHAR(10) NOT NULL,
mental_health_stat_year INT NOT NULL,
depression_rate REAL,

PRIMARY KEY (country_code, mental_health_stat_year),
FOREIGN KEY (country_code) REFERENCES
country(country_code) ON DELETE CASCADE
);