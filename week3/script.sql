-- Things to know about duckdb
-- you need to be in the repository where this is stored
-- control C gets you out of permaloading for a singular command
-- to get you out of DuckDB in the terminal .exit or control D
-- * = all columns
-- SQL is case insensitive

-- open database.db in duckdb in terminal
duckdb database.db;


-- select all columns from species table
SELECT * FROM Species;


-- show the first 10 rows
.maxrows 10
-- select all columns from species table
SELECT * FROM Species;

-- show me the tables that are within the repository where I am
.tables

-- limiting rows to only first 5
SELECT * FROM Species LIMIT 5;
-- show me the next 5 rows
SELECT * FROM Species LIMIT 5 OFFSET 5;

-- how many rows are present?
SELECT COUNT(*) FROM Species;

-- if you put a column name in count, how many non-null values?
SELECT COUNT(Scientific_name) FROM Species;

-- how many distinct values occur?
SELECT DISTINCT Species FROM Bird_nests;

-- can select which columns to return by naming them
SELECT * FROM Bird_eggs;
SELECT  Code, Common_name FROM Species;
SELECT Species FROM Bird_nests;
SELECT DISTINCT Species FROM Bird_nests;

-- ordering of results 
SELECT DISTINCT Species FROM Bird_nests ORDER BY Species;

--Exercise: what distinct locations occur in the site table and order them and limit to 3 results
SELECT DISTINCT Location FROM Site ORDER BY Location LIMIT 3;

-- *make sure you are in the correct directory*
SELECT * FROM Species;

SELECT Location FROM Site;
SELECT * FROM Site WHERE Area <200;
SELECT * FROM Site WHERE Area <200 AND Location LIKE '%USA';
SELECT * FROM Site WHERE Area <200 AND Location ILIKE '%usa';

-- expressions
SELECT Site_name, Area FROM Site;
SELECT Site_name, Area*2.47 FROM Site;
SELECT Site_name, Area*2.47 AS Area_acres FROM Site;
SELECT Site_name || 'foo' FROM Site;

--aggregation functions 
SELECT COUNT(*) FROM Site;
-- there are 16 rows in the site table
SELECT COUNT(*) AS num_rows FROM Site;

SELECT COUNT(Scientific_name) FROM Species;
SELECT DISTINCT Relevance FROM Species;
 
 -- MIN, MAX, AVG
 SELECT AVG(Area) FROM Site;

 -- grouping
 SELECT * FROM Site;
 SELECT Location, MAX(Area) FROM Site GROUP BY Location;

 SELECT Location, COUNT(*) FROM Site GROUP BY Location;


 SELECT Relevance, COUNT(*) FROM Species GROUP BY Relevance;


 SELECT Relevance, COUNT(Scientific_name) FROM Species GROUP BY Relevance;

 -- adding where clause 
 SELECT Location, MAX(Area) FROM Site GROUP BY Location;

-- LIKE makes things case sensitive and ILIKE makes it non case sensitive
 SELECT Location, MAX(Area)
    FROM Site
    WHERE Location LIKE '%Canada'
    GROUP BY Location;

-- select within Max_Area for Canada and locations that have > 200
SELECT Location, MAX(Area) AS Max_Area
    FROM Site
    WHERE Location LIKE '%Canada'
    GROUP BY Location
    HAVING Max_Area > 200;

-- relational algebra peaks through!
-- any query returns a baby table
SELECT COUNT(*) FROM Site; 
-- there is 1 row in my baby table
SELECT COUNT(*) FROM (SELECT COUNT(*) FROM Site);

-- examine first 3 rows of nest data
SELECT * FROM Bird_nests LIMIT 3;
-- there are 99 species recorded
SELECT COUNT(*) FROM Species;

-- we have nest data on 80 of the 99 species
SELECT * FROM Species
    WHERE Code NOT IN (SELECT DISTINCT Species FROM Bird_nests);

-- saving queries temporarily; to save a new table permanently to the database remove temp
CREATE TEMP TABLE t AS 
    SELECT * FROM Species
        WHERE Code NOT IN (SELECT DISTINCT Species FROM Bird_nests);
-- examine table
SELECT * FROM t;

-- saving queries permanently
CREATE TABLE t_perm AS 
    SELECT * FROM Species
        WHERE Code NOT IN (SELECT DISTINCT Species FROM Bird_nests);
-- examine table
SELECT * FROM t_perm;

-- see if t_perm saved to tables and it did 
.tables

--NULL processing
SELECT COUNT(*) FROM Bird_nests
    WHERE floatAge >5;
SELECT COUNT(*) FROM Bird_nests
    WHERE floatAge <=5;
SELECT COUNT(*) FROM Bird_nests;
    
-- can't answer this as the answer is NULL
SELECT COUNT(*) FROM Bird_nests WHERE floatAge = NULL;
-- returns the amount of Null values
SELECT COUNT(*) FROM Bird_nests WHERE floatAge IS NULL;

-- joins
SELECT * FROM Camp_assignment;
SELECT * FROM Personnel;
-- join camp-assignment and personnel by the observer and abbreviation columns
SELECT * FROM Camp_assignment JOIN Personnel
    ON Observer = Abbreviation;

SELECT * FROM Camp_assignment JOIN Personnel
    ON Camp_assignment.Observer = Personnel.Abbreviation;
 

-- multiway join
SELECT * FROM Camp_assignment AS ca JOIN Personnel p
    ON ca.Observer = p.Abbreviation
    JOIN Site s
    ON ca.SIte = s.Code
    LIMIT 3;

-- multiway join and select 1 observer 
SELECT * FROM Camp_assignment AS ca JOIN Personnel p
    ON ca.Observer = p.Abbreviation
    JOIN Site s
    ON ca.SIte = s.Code
    WHERE ca.Observer = 'lmckinnon'
    LIMIT 3;

-- order by: at the end
    SELECT * FROM Camp_assignment AS ca JOIN (
        SELECT * FROM Personnel ORDER BY Abbreviation
    ) p
    ON ca.Observer = p.Abbreviation
    JOIN Site s
    ON ca.SIte = s.Code
    WHERE ca.Observer = 'lmckinnon'
    LIMIT 3;

-- more on grouping 
-- how many bird eggs are in each nest
SELECT Nest_ID, COUNT(*) FROM Bird_eggs
    GROUP BY Nest_ID;
.maxrows 8

SELECT Species FROM Bird_nests WHERE Site = 'nome';
SELECT Species, COUNT(*) AS Nest_count
 FROM Bird_nests
  WHERE Site = 'nome'
  GROUP BY Species
  ORDER BY Species
  LIMIT 2;

  -- can nest queries
  SELECT Scientific_name, Nest_count FROM
    (SELECT Species, COUNT(*) AS Nest_count
    FROM Bird_nests
    WHERE Site = 'nome'
    GROUP BY Species
    ORDER BY Species
    LIMIT 2) JOIN Species ON Species = Code;

-- outer joins
CREATE TEMP TABLE a (cola integer, common INTEGER);
INSERT INTO a VALUES (1,1), (2,2), (3,3);
SELECT * FROM a;
CREATE TEMP TABLE b (common integer, colb INTEGER);
INSERT INTO b VALUES (2,2), (3,3), (4,4), (5,5);
SELECT * FROM b;
-- inner join
SELECT* FROM a INNER JOIN b using (common);
-- left or right outer join
SELECT * FROM a LEFT JOIN b USING (common);

-- how to set null values to show as null
.nullvalue -NULL-

--right join
SELECT * FROM a RIGHT JOIN b USING (common);

-- what species do *not* have nest data
 SELECT * FROM Species
  WHERE Code NOT IN (SELECT DISTINCT Species FROM Bird_nests);

-- lets do this with an outer join

-- first with a left join aka keeps all of species and adds bird_nests to the ones that match
SELECT Code
    FROM Species LEFT JOIN Bird_nests ON Code = Species;

SELECT COUNT(*) FROM Bird_nests WHERE Species = 'ruff';

SELECT Code
    FROM Species LEFT JOIN Bird_nests ON Code = Species
    WHERE Nest_ID IS NULL;

-- a gotcha when doing grouping
SELECT * FROM Bird_eggs;
SELECT * FROM Bird_nests JOIN Bird_eggs USING (Nest_ID)
    WHERE Nest_ID = '14eabaage01';

SELECT Nest_ID, COUNT(*)
    FROM Bird_nests JOIN Bird_eggs USING (Nest_ID)
    WHERE Nest_ID = '14eabaage01'
    GROUP BY Nest_ID;

--but what about this...asking for length when you have 3 length values, need to function length if wanted
SELECT Nest_ID, COUNT(*), Length
    FROM Bird_nests JOIN Bird_eggs USING (Nest_ID)
    WHERE Nest_ID = '14eabaage01'
    GROUP BY Nest_ID;

-- but what about this now? Most databases will allow this but duckdb won't
SELECT Nest_ID, Species, COUNT(*)
    FROM Bird_nests JOIN Bird_eggs USING (Nest_ID)
    WHERE Nest_ID = '14eabaage01'
    GROUP BY Nest_ID;

SELECT Nest_ID, ANY_VALUE(Species), COUNT(*)
    FROM Bird_nests JOIN Bird_eggs USING (Nest_ID)
    WHERE Nest_ID = '14eabaage01'
    GROUP BY Nest_ID;

--Views
select * FROM Camp_assignment;
select Year, Site, Name, Start, "End"
    From Camp_assignment JOIN Personnel
    ON Observer = Abbreviation;

-- a view looks just like a table, but it's not a real table
Create VIEW  v AS 
    SELECT Year, Site, Name, Start, "End"
    From Camp_assignment JOIN Personnel
    ON Observer = Abbreviation;

SELECT * FROM v;
CREATE VIEW v2 AS SELECT COUNT(*) FROM Species;
SELECT * FROM v2;

-- set operations: UNION, INTERSECT, EXCEPT
-- iffy example, acts like an rbind, this will also not select any null book pages
SELECT Book_page, Nest_ID, Egg_num, Length, Width FROM Bird_eggs;
SELECT Book_page, Nest_ID, Egg_num, Length*25.4, Width*25.4 FROM Bird_eggs
    WHERE Book_page = 'b14.6'
    UNION
SELECT Book_page, Nest_ID, Egg_num, Length, Width FROM Bird_eggs
    WHERE Book_page != 'b14.6';

--UNION vs UNION ALL
-- just mashes tables together
-- third way to answer which species have no nest data
SELECT Code from Species   
    EXCEPT SELECT DISTINCT Species FROM Bird_nests;

--inserting data
SELECT * FROM Species;
.maxrows 8
INSERT INTO Species VALUES ('abcd', 'thing', 'scientific name', NULL);
SELECT * FROM Species;
-- you can explicitly label the columns
INSERT INTO Species (Common_name, Scientific_name, Code, Relevance)
    VALUES('thing 2', 'another scientific name', 'efgh', NULL);

--take advantage of default values 
INSERT INTO Species (Common_name, Code) VALUES ('thing 3', 'ijkl');
SELECT * FROM Species;
.nullvalue -NULL-

--Update and Delete
--update a row
UPDATE Species SET Relevance = 'not sure yet' WHERE Relevance IS NULL;
SELECT * FROM Species;

-- delete rows that match this clause
Delete FROM Species WHERE Relevance = 'not sure yet';
SELECT * FROM Species;

-- safe delete practice
SELECT * FROM Species WHERE Relevance = 'Study species';
-- after confirming, then edit the statement
DELETE FROM Species WHERE Relevance = 'Study species';

--incomplete statement
-- leave off delete then add it after visual confirmation
FROM Species WHERE ...

COPY Species TO 'species_fixed.csv' (HEADER, DELIMITER ',');

-- Create table 
CREATE TABLE Snow_cover2 (
    Site VARCHAR NOT NULL,
    Year INTEGER NOT NULL CHECK (Year BETWEEN 1950 AND 2015),
    Date DATE NOT NULL,
    Plot VARCHAR, -- some Null in the data :/
    Location VARCHAR NOT NULL,
    Snow_cover INTEGER CHECK (Snow_cover > -1 AND Snow_cover < 101),
    Observer VARCHAR
);

.tables

-- shows that we have an empty table
SELECT * FROM Snow_cover2;

-- IMPORT data from csv
COPY Snow_cover2 FROM 'snow_cover_fixedman_JB.csv' (HEADER TRUE);

-- snow-cover 2 now has data in it
SELECT * FROM Snow_cover2;