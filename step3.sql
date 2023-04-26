use project_db_12_04_23;

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

alter table smoker add constraint percentage_check check  (percentage_among_all_adults >= 0 and percentage_among_all_adults <= 100) ;
alter table smoker add constraint year_check_2 check (smoker_stat_year >= 1970 and smoker_stat_year < 2024);


/* TRIGGERS */
drop trigger before_insert_smoker;

delimiter $$

create trigger before_insert_smoker before insert on smoker for each row
begin

IF NEW.smoker_stat_year >= 2024 then
	set NEW.smoker_stat_year = 2032;
end if;

if NEW.smoker_stat_year < 1970 then
	set NEW.smoker_stat_year = 1970;
end if;

if  NEW.percentage_among_all_adults > 100 then
	set NEW.percentage_among_all_adults = 100;
end if;

if NEW.percentage_among_all_adults < 0 then
	set NEW.percentage_among_all_adults = 0;
end if;


end$$

delimiter ;
delimiter $$

create trigger before_update_smoker before update on smoker for each row
begin

IF NEW.smoker_stat_year >= 2024 then
	set NEW.smoker_stat_year = 2032;
end if;

if NEW.smoker_stat_year < 1970 then
	set NEW.smoker_stat_year = 1970;
end if;

if  NEW.percentage_among_all_adults > 100 then
	set NEW.percentage_among_all_adults = 100;
end if;

if NEW.percentage_among_all_adults < 0 then
	set NEW.percentage_among_all_adults = 0;
end if;

end$$

delimiter ;

/* TRIGGER TESING */
insert into smoker values('ALB', 1940, 110); /* fixed */
update smoker set smoker_stat_year = 1950, percentage_among_all_adults = 50 where country_code = 'TUR' and smoker_stat_year = 1970 and percentage_among_all_adults = 100;
select * from smoker where country_code = 'ALB' and smoker_stat_year = 1970 and percentage_among_all_adults = 100; /* year corrected to 1970 from 1950 by the before update trigger */
select * from smoker where country_code = 'ALB' and smoker_stat_year = 1940 and percentage_among_all_adults = 110; /* year corrected to 1970 from 1950 by the before update trigger */



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

/*-------------------------------------------------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------------------------------------------------*/

SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

/* select max smoker */
select  max_yr.smoker_stat_year, max_yr.yearly_max, s2.country_code from 
( select s.smoker_stat_year, max(s.percentage_among_all_adults) yearly_max from smoker s group by s.smoker_stat_year) max_yr, smoker s2 
	where s2.percentage_among_all_adults = max_yr.yearly_max;
    
/* select max smoker after 2010 */
select  max_yr.smoker_stat_year, max_yr.yearly_max, s2.country_code from 
( select s.smoker_stat_year, max(s.percentage_among_all_adults) yearly_max from smoker s group by s.smoker_stat_year having s.smoker_stat_year > 2010) max_yr, smoker s2 
	where s2.percentage_among_all_adults = max_yr.yearly_max;
    
/* select min smoker -- min example */
select  min_yr.smoker_stat_year, min_yr.yearly_min, s2.country_code from 
( select s.smoker_stat_year, min(s.percentage_among_all_adults) yearly_min from smoker s group by s.smoker_stat_year) min_yr, smoker s2 
	where s2.percentage_among_all_adults = min_yr.yearly_min;

/* select min smoker before 2010 */
select  min_yr.smoker_stat_year, min_yr.yearly_min, s2.country_code from 
( select s.smoker_stat_year, min(s.percentage_among_all_adults) yearly_min from smoker s group by s.smoker_stat_year having s.smoker_stat_year < 2010) min_yr, smoker s2 
	where s2.percentage_among_all_adults = min_yr.yearly_min;

/* select max from death */
select s2.country_code, max_yr.death_stat_year, max_yr.yearly_max from 
( select s.death_stat_year, max(s.percentage_among_all_deaths) yearly_max from s_deaths s group by s.death_stat_year) max_yr, s_deaths s2 
	where s2.percentage_among_all_deaths = max_yr.yearly_max;

/* select max from mental disorder -- max example */
select max_yr.mental_health_stat_year, max_yr.yearly_max, s2.country_code from 
( select s.mental_health_stat_year, max(s.depression_rate) yearly_max from M_Disorder s group by s.mental_health_stat_year) max_yr, M_Disorder s2 
	where max_yr.yearly_max = s2.depression_rate;

/* western europe average smoker percentage query -- sum example */
select ( sum(avg_of_country_no_yr.avg_depression_of_country) / 8 /* # countries in western europe */) from
(select avg(s.depression_rate) avg_depression_of_country from M_Disorder s where s.country_code = 'GBR' or s.country_code = 'IRL' 
	OR s.country_code = 'NLD' OR s.country_code = 'BEL' or s.country_code = 'PRT' or s.country_code = 'ESP' or s.country_code = 'FRA' or s.country_code = 'LUX' 
    group by s.country_code having (s.country_code in (select country_code from country) ) ) avg_of_country_no_yr;

/* # of countries in europe which have records of having higher than avg smoker rates in any recorded year  --  example for count */ 
select count(ccode), continent_code
from (select distinct m_avg_in_continent.ccode, l.continent_code from 
(select distinct mavg_smoke.country_code as ccode from more_than_avg_smoker_per_yr mavg_smoke) m_avg_in_continent,
continent cont, located l where l.country_code = m_avg_in_continent.ccode) temp group by continent_code having (continent_code in (select continent_code from continent));

/** VIEWS */
create view more_than_avg_smoker_per_yr as select s2.country_code, s2.smoker_stat_year, s2.percentage_among_all_adults, avg_yr.yearly_avg from 
( select s.smoker_stat_year, avg(s.percentage_among_all_adults) yearly_avg from smoker s group by s.smoker_stat_year) avg_yr, smoker s2 
	where s2.percentage_among_all_adults >= avg_yr.yearly_avg and avg_yr.smoker_stat_year = s2.smoker_stat_year;

create view more_than_avg_smoker_per_yr_after_2000 as select s2.country_code, s2.smoker_stat_year, s2.percentage_among_all_adults, avg_yr.yearly_avg from 
( select s.smoker_stat_year, avg(s.percentage_among_all_adults) yearly_avg from smoker s group by s.smoker_stat_year having smoker_stat_year >= 2000) avg_yr, smoker s2 
	where s2.percentage_among_all_adults >= avg_yr.yearly_avg and avg_yr.smoker_stat_year = s2.smoker_stat_year;

create view more_than_avg_smoker_per_yr_between_2000_2010 as select s2.country_code, s2.smoker_stat_year, s2.percentage_among_all_adults, avg_yr.yearly_avg from 
( select s.smoker_stat_year, avg(s.percentage_among_all_adults) yearly_avg from smoker s group by s.smoker_stat_year having smoker_stat_year >= 2000 and smoker_stat_year <= 2010) avg_yr, smoker s2 
	where s2.percentage_among_all_adults >= avg_yr.yearly_avg and avg_yr.smoker_stat_year = s2.smoker_stat_year;

create view more_than_avg_smoker_per_yr_after_2010 as select s2.country_code, s2.smoker_stat_year, s2.percentage_among_all_adults, avg_yr.yearly_avg from 
( select s.smoker_stat_year, avg(s.percentage_among_all_adults) yearly_avg from smoker s group by s.smoker_stat_year having smoker_stat_year >= 2010) avg_yr, smoker s2 
	where s2.percentage_among_all_adults >= avg_yr.yearly_avg and avg_yr.smoker_stat_year = s2.smoker_stat_year;

select * from more_than_avg_smoker_per_yr_after_2010;
select * from more_than_avg_smoker_per_yr_between_2000_2010;

create view less_than_avg_smoker_per_yr as select s2.country_code, s2.smoker_stat_year, s2.percentage_among_all_adults, avg_yr.yearly_avg from 
( select s.smoker_stat_year, avg(s.percentage_among_all_adults) yearly_avg from smoker s group by s.smoker_stat_year) avg_yr, smoker s2 
	where s2.percentage_among_all_adults < avg_yr.yearly_avg and avg_yr.smoker_stat_year = s2.smoker_stat_year;

create view less_than_avg_smoker_per_yr_after_2000 as select s2.country_code, s2.smoker_stat_year, s2.percentage_among_all_adults, avg_yr.yearly_avg from 
( select s.smoker_stat_year, avg(s.percentage_among_all_adults) yearly_avg from smoker s group by s.smoker_stat_year having s.smoker_stat_year > 2000) avg_yr, smoker s2 
	where s2.percentage_among_all_adults < avg_yr.yearly_avg and avg_yr.smoker_stat_year = s2.smoker_stat_year;


select * from more_than_avg_smoker_per_yr;
select * from less_than_avg_smoker_per_yr;

create view less_than_avg_country_deaths_per_yr as select s2.country_code, s2.death_stat_year, s2.percentage_among_all_deaths, avg_yr.yearly_avg from 
( select s.death_stat_year, avg(s.percentage_among_all_deaths) yearly_avg from s_deaths s group by s.death_stat_year) avg_yr, s_deaths s2 
	where s2.percentage_among_all_deaths < avg_yr.yearly_avg and avg_yr.death_stat_year = s2.death_stat_year;

create view more_than_avg_country_deaths_per_yr as select s2.country_code, s2.death_stat_year, s2.percentage_among_all_deaths, avg_yr.yearly_avg from 
( select s.death_stat_year, avg(s.percentage_among_all_deaths) yearly_avg from s_deaths s group by s.death_stat_year) avg_yr, s_deaths s2 
	where s2.percentage_among_all_deaths >= avg_yr.yearly_avg and avg_yr.death_stat_year = s2.death_stat_year;

create view more_than_avg_country_deaths_per_yr as select s2.country_code, s2.death_stat_year, s2.percentage_among_all_deaths, avg_yr.yearly_avg from 
( select s.death_stat_year, avg(s.percentage_among_all_deaths) yearly_avg from s_deaths s group by s.death_stat_year) avg_yr, s_deaths s2 
	where s2.percentage_among_all_deaths >= avg_yr.yearly_avg and avg_yr.death_stat_year = s2.death_stat_year;

create view leading_depressed_countries as select avg_yearly.avg_depression, m.depression_rate,  avg_yearly.mental_health_stat_year, m.country_code
from ( select m_inner.mental_health_stat_year, avg(m_inner.depression_rate) avg_depression from M_disorder m_inner group by m_inner.mental_health_stat_year) avg_yearly, M_disorder m 
where m.mental_health_stat_year = avg_yearly.mental_health_stat_year and avg_yearly.avg_depression < m.depression_rate;

create view high_tax_countries as select avg_all.avg_tax_yr, t.country_code, t.percentage_increase_tobacco, t.tobacco_stat_year
from (select avg(t_inner.percentage_increase_tobacco) avg_tax_yr, t_inner.tobacco_stat_year from taxes t_inner group by t_inner.tobacco_stat_year) avg_all, taxes t 
	where t.percentage_increase_tobacco > avg_all.avg_tax_yr and avg_all.tobacco_stat_year = t.tobacco_stat_year;


/** VIEW TESTS **/
select * from more_than_avg_country_deaths_per_yr;

select * from less_than_avg_country_deaths_per_yr;

select * from leading_depressed_countries;

select * from high_tax_countries;

select * from lowest_tax_rate_per_yr;

select * from leading_mental_disorder_per_yr;

select * from leading_country_deaths_per_yr;

select * from higher_than_avg_smoking_rate;

/* JOINS - DATA INSIGHT */
select s.country_code, s.smoker_stat_year AS year, s.percentage_among_all_adults, d.percentage_among_all_deaths
FROM more_than_avg_smoker_per_yr s INNER JOIN more_than_avg_country_deaths_per_yr d
ON s.smoker_stat_year = d.death_stat_year AND s.country_code = d.country_code;

select s.country_code, s.smoker_stat_year AS year, s.percentage_among_all_adults, d.depression_rate
FROM more_than_avg_smoker_per_yr s INNER JOIN leading_depressed_countries d
ON s.country_code = d.country_code AND s.smoker_stat_year = d.mental_health_stat_year;

select l.country_code, l.smoker_stat_year AS year, l.percentage_among_all_adults, p.life_exp
FROM more_than_avg_smoker_per_yr l INNER JOIN population p
ON l.country_code = p.country_code AND l.smoker_stat_year = p.pop_year;


SELECT *
FROM (
  SELECT country_code, smoker_stat_year AS year, percentage_among_all_adults, NULL AS percentage_increase_tobacco
  FROM more_than_avg_smoker_per_yr s
  UNION ALL
  SELECT t.country_code, t.tobacco_stat_year AS year, s.percentage_among_all_adults, COALESCE(NULL, t.percentage_increase_tobacco)
  FROM taxes t, more_than_avg_smoker_per_yr s
  WHERE s.country_code = t.country_code AND s.smoker_stat_year = t.tobacco_stat_year AND percentage_increase_tobacco IS NOT NULL
) AS union_table
WHERE EXISTS (
  SELECT *
  FROM more_than_avg_smoker_per_yr s, taxes t
  WHERE((s.country_code = union_table.country_code AND t.country_code = union_table.country_code) AND
		(s.smoker_stat_year = union_table.year AND t.tobacco_stat_year = union_table.year) AND 
        union_table.percentage_increase_tobacco IS NOT NULL)
);

select l.country_code, l.smoker_stat_year AS year, l.percentage_among_all_adults, t.percentage_increase_tobacco
FROM more_than_avg_smoker_per_yr  l LEFT OUTER JOIN taxes t
ON l.country_code = t.country_code AND l.smoker_stat_year = t.tobacco_stat_year 
WHERE t.percentage_increase_tobacco IS NOT NULL AND l.country_code IS NOT NULL

UNION

select l.country_code, l.smoker_stat_year AS year, l.percentage_among_all_adults, t.percentage_increase_tobacco 
FROM more_than_avg_smoker_per_yr l RIGHT OUTER JOIN taxes t
ON l.country_code = t.country_code AND l.smoker_stat_year = t.tobacco_stat_year 
WHERE t.percentage_increase_tobacco IS NOT NULL AND l.country_code IS NOT NULL;


select l.country_code, l.smoker_stat_year AS year, l.percentage_among_all_adults, t.percentage_increase_tobacco 
FROM more_than_avg_smoker_per_yr l RIGHT OUTER JOIN taxes t
ON l.country_code = t.country_code AND l.smoker_stat_year = t.tobacco_stat_year 
WHERE t.percentage_increase_tobacco IS NOT NULL AND l.country_code IS NOT NULL;


select l.country_code, l.smoker_stat_year AS year, l.percentage_among_all_adults, t.percentage_increase_tobacco
FROM more_than_avg_smoker_per_yr  l LEFT OUTER JOIN taxes t
ON l.country_code = t.country_code AND l.smoker_stat_year = t.tobacco_stat_year 
WHERE t.percentage_increase_tobacco IS NOT NULL AND l.country_code IS NOT NULL

UNION

select l.country_code, l.smoker_stat_year AS year, l.percentage_among_all_adults, t.percentage_increase_tobacco 
FROM more_than_avg_smoker_per_yr l RIGHT OUTER JOIN taxes t
ON l.country_code = t.country_code AND l.smoker_stat_year = t.tobacco_stat_year 
WHERE t.percentage_increase_tobacco IS NOT NULL AND l.country_code IS NOT NULL;

select s.country_code, s.smoker_stat_year AS year, s.percentage_among_all_adults, m.depression_rate
FROM smoker s INNER JOIN m_disorder m
ON s.smoker_stat_year = m.mental_health_stat_year AND s.country_code = m.country_code;

/* STORED PROCEDURE */
delimiter $$
CREATE PROCEDURE smoker_data_by_country(in c_code varchar(3))
BEGIN
    SELECT * FROM smoker WHERE country_code = c_code;
END $$
delimiter ;

call smoker_data_by_country('TUR');
call smoker_data_by_country('BEL');

/* IN AND EXISTS PART */
#SELECT M.country_code,M.mental_health_stat_year, M.depression_rate FROM M_Disorder M WHERE M.country_code in (SELECT S.country_code FROM s_deaths S WHERE death_stat_year>1995);
SELECT distinct M.country_code, M.mental_health_stat_year, M.depression_rate
FROM M_Disorder M 
WHERE M.country_code IN 
    (SELECT S.country_code 
     FROM s_deaths S 
     WHERE S.death_stat_year > 2015 
     AND S.country_code IN 
         (SELECT M2.country_code 
          FROM M_Disorder M2 
          WHERE M2.mental_health_stat_year > 2015)
    ) and M.mental_health_stat_year > 2015;
SELECT M.country_code, M.mental_health_stat_year, M.depression_rate FROM M_Disorder M WHERE EXISTS (SELECT S.country_code FROM s_deaths S WHERE death_stat_year>2015 AND M.country_code=S.country_code) and M.mental_health_stat_year > 2015;

SELECT S.country_code, S.smoker_stat_year,S.percentage_among_all_adults FROM smoker S WHERE S.country_code in (SELECT SS.country_code FROM s_deaths SS WHERE percentage_among_all_deaths>14.0);


ALTER TABLE Taxes
ADD CONSTRAINT check_tobacco_tax_increase
CHECK (
  (
    SELECT COUNT(*) FROM Taxes t2
    WHERE t2.country_code = Taxes.country_code
      AND t2.tobacco_stat_year = Taxes.tobacco_stat_year - 1) = 1);

alter table M_Disorder drop constraint check_depression_rate_positive_2;

ALTER TABLE M_Disorder
ADD CONSTRAINT check_M_health_stat_yr
CHECK (mental_health_stat_year >= 1970 and mental_health_stat_year <= 2023); # 

ALTER TABLE smoker
ADD CONSTRAINT check_smoker_perc
CHECK(percentage_among_all_adults >= 0 and percentage_among_all_adults <= 100);

alter table M_Disorder drop constraint check_depression_rate_positive_1;

ALTER TABLE smoker
ADD CONSTRAINT check_death_stat_year_smoker
CHECK (smoker_stat_year >= 1970 AND smoker_stat_year <= 2023
);

insert into smoker values ('TUR', 2032, 150);
insert into values ('TUR', 2032, 150);

alter table s_deaths drop constraint check_death_stat_year;
