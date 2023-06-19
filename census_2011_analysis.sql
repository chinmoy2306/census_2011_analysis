/* Data source: https://www.census2011.co.in */

CREATE SCHEMA census2011;
USE census2011;

/* Data imported from CSV file into mysql */

SHOW TABLES;

/* Data exploration and required cleaning/transformation */

-- On `popbycity` table    

SELECT * FROM popbycity;
DESC popbycity;

-- Transformation 1: `popbycity`: Changing Datatypes and adding foreignkey constraints to get a normalised dataset.

ALTER TABLE popbycity
ADD
	s_id INT FIRST,
ADD 
	c_id INT AFTER s_id,
ADD 
	CONSTRAINT s_id_fk1
	FOREIGN KEY(s_id) REFERENCES state(s_id),
ADD 
	CONSTRAINT c_id_fk
	FOREIGN KEY(c_id) REFERENCES city(c_id),
CHANGE 
	Literacy `Literacy_%` FLOAT;

UPDATE popbycity as p
JOIN city as c
	ON c.city = p.city
JOIN state as s
	ON s.state = p.state
SET
	p.c_id = c.c_id,
    p.s_id = s.s_id,
    `Literacy_%` = `Literacy_%` * 100;

-- ---------------xxx----------------

-- On `popbydistrict` table

SELECT * FROM popbydistrict;
DESC popbydistrict;

-- Transformation 3: `popbydistrict`: Changing Datatypes and adding foreignkey constraints to get a normalised dataset.

ALTER TABLE popbydistrict
ADD 
	d_id INT FIRST,
ADD 
	s_id INT AFTER d_id,
ADD 
	CONSTRAINT d_id_fk
	FOREIGN KEY(d_id) REFERENCES district(d_id),
ADD 
	CONSTRAINT s_id_fk2
	FOREIGN KEY(s_id) REFERENCES state(s_id),
CHANGE 
	Literacy `Literacy_%` FLOAT,
CHANGE 
	Growth `Growth_%` FLOAT;

UPDATE popbydistrict as p
JOIN state as s
	ON s.state = p.state
JOIN district as d
	ON d.district = p.district
SET
	p.d_id = d.d_id,
    p.s_id = s.s_id,
    `Literacy_%` = `Literacy_%` * 100,
    `Growth_%` = `growth_%` * 100;

-- ---------------xxx----------------
    
-- On `popbystate` table

SELECT * FROM popbystate;
DESC popbystate;

-- Transformation 3: `popbystate`: Changing Datatypes and adding foreignkey constraints to get a normalised dataset.

ALTER TABLE popbystate
ADD 
	s_id INT FIRST,
ADD 
	CONSTRAINT s_id_fk3
	FOREIGN KEY(s_id) REFERENCES state(s_id),
CHANGE 
	Literacy `Literacy_%` FLOAT,
CHANGE 
	Male `Male_%` FLOAT,
CHANGE 
	Female `Female_%` FLOAT,
CHANGE 
	`% Change` `%_Change` FLOAT;

UPDATE popbystate as p
JOIN state as s
	ON s.state = p.state
SET
	p.s_id = s.s_id,
    `Literacy_%` = `Literacy_%` * 100,
    `Male_%` = `male_%` * 100,
    `Female_%` = `Female_%` * 100,
    `%_Change` = `%_Change` * 100;

-- ---------------xxx----------------

SELECT * FROM popbycity;
SELECT * FROM popbydistrict;
SELECT * FROM popbystate;
select * from district;
select * from city;
select * from state;

/* Analysis performed */

/* Q1) What is the average literacy %, totol population, average sex-ratio of India according to the 2011 census data? */

SELECT 'India' AS Country, ROUND(AVG(`literacy_%`), 2) AS `Avg_literacy_%`, 
ROUND(SUM(population), 0) AS Total_pop, 
ROUND(AVG(`sex-ratio`), 0) AS `Average_sex-ratio`
FROM popbydistrict;


/* Q2) Which is the most populous district in each state? */

WITH cte_tbl AS
(
SELECT state, district, Population, ROW_NUMBER() OVER(PARTITION BY state ORDER BY Population DESC) as row_num
FROM popbydistrict
GROUP BY state, district, Population
ORDER BY 3 DESC
)
SELECT * FROM cte_tbl
WHERE row_num =1;

/* Q3) Which district has the highest population growth rate for each state? */

WITH cte_tbl  AS
(
SELECT state, district, Population, round(growth_perc*100,2) as `Growth%`, ROW_NUMBER() OVER(PARTITION BY state ORDER BY Growth_perc DESC) as row_num 
FROM popbydistrict
GROUP BY state, District, Population, Growth_perc
)
SELECT * FROM cte_tbl
WHERE row_num = 1;

/* Q4) Which are the top 5 states with the highest population and what are the corresponding male, female & literacy percentages? */

SELECT c.state, sum(Population), round(s.Male_perc * 100,2) as `male%`, round(s.Female_perc * 100,2) as `female%` 
from popbycity as c
JOIN popbystate as s
ON s.s_id = c.s_id
GROUP BY 1,3,4
ORDER BY 2 DESC
LIMIT 5;

/* Q5) Which districts have the lowest sex ratio for each state? */

WITH cte_tbl AS
(
SELECT state, district, Population, `Sex-Ratio`, ROW_NUMBER() OVER(PARTITION BY state ORDER BY `Sex-Ratio` ASC) AS row_num  
FROM popbydistrict
GROUP BY 1,2,3,4
ORDER BY 4 ASC
)
SELECT * FROM cte_tbl
WHERE row_num = 1
ORDER BY 3 DESC;

/* Q6) Which are the top 5 populous city in India? */

SELECT * FROM popbycity
ORDER BY Population DESC
LIMIT 5;

/* Q7) Which are the bottom 5 states in India with lowest sex-ratio and literacy percentage? */

DROP TABLE IF EXISTS lowest_states;
CREATE TEMPORARY TABLE lowest_states
(
state TEXT,
Avg_sex_ratio float,
Avg_literacy_perc float
);
INSERT INTO lowest_states
(
select state, AVG(`Sex-Ratio`), AVG(Literacy_perc * 100) from popbydistrict
GROUP BY state
ORDER BY 2 ASC, 3 ASC
LIMIT 5
);
select * from lowest_states;

/* Q8) Which are the top 5 states in India with highest sex-ratio and literacy percantage? */

DROP TABLE IF EXISTS highest_states;
CREATE TEMPORARY TABLE highest_states
(
state TEXT,
Avg_sex_ratio float,
Avg_literacy_perc float
);
INSERT INTO highest_states
(
select state, AVG(`Sex-Ratio`), AVG(Literacy_perc * 100) from popbydistrict
GROUP BY state
ORDER BY 2 DESC, 3 DESC
LIMIT 5
);

/* Q9) Show the top & bottom 5 states together based on Avg sex_ratio and literacy % respectively */

SELECT *, 'top_5_states' as tag FROM highest_states
UNION
SELECT *, 'bottom_5_states' as tag FROM lowest_states 
ORDER BY 2 DESC, 3 DESC;

/* Q10) What are the Male and Female population (in nos) for top 3 states by population and corresponding literate Male & Female population (in nos)? */

WITH cte_tbl AS
(
SELECT s.State, sum(d.Population) as total_pop, 
ROUND(d.Population / ( (d.`Sex-Ratio` / 1000) + 1), 0) as male_pop,
ROUND((d.Population * (d.`Sex-ratio` / 1000)) / ((d.`Sex-ratio` / 1000) + 1), 0) as female_pop,
s.`Male_Literacy_%` as m, s.`female_literacy_%` as f
FROM popbystate as s
JOIN popbydistrict as d
ON d.s_id = s.s_id
GROUP BY 1, 3, 4, 5, 6
ORDER BY 2 DESC, 3 DESC, 4 DESC
LIMIT 3
)
SELECT state, total_pop, female_pop, 
ROUND(male_pop * (m / 100), 0) as Literate_male_pop,
ROUND(female_pop * (f / 100), 0) as Literate_female_pop
FROM cte_tbl;

/* Q11) Show the total literate and illiterate population (in nos) for the top 3 most populous states of India. */

SELECT a.state, a.total_population, 
ROUND(a.total_population * a.Avg_literacy, 0) AS 'Literate_population',
ROUND(a.total_population * (1 - a.Avg_literacy), 0) AS 'Illiterate_population'
FROM
(
SELECT state, SUM(Population) as Total_population,
AVG(`Literacy_%`)/100 as Avg_Literacy
FROM popbydistrict 
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3
) as a ;