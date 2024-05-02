--Problem 1
-- open database.db in duckdb in terminal
duckdb database.db

-- look at tables
.table

-- make a temporary table 
CREATE TEMP TABLE Nulltable(
    col1 int,
);

SELECT * FROM Nulltable;

INSERT INTO Nulltable (col1)
VALUES (4),
        (NULL),
        (3),
        (5);

-- returns 4.0
SELECT AVG(Col1) FROM Nulltable;

-- if the Null was not factored into the calculation the AVG() would return 4
-- if the Null was factored into the calculation the AVG function would return NULL
-- What is returned is that the AVG() ignores the NULL and therefore calculates 4.0

-- returns 3.0
-- take the sum of Col1 and divide by the count of all the rows includin the NULL values ie. 12/4
SELECT SUM(Col1)/COUNT(*) FROM NULLtable;
-- returns 4.0
-- takes the sum of Col1 and divides by the number of values present ie. 12/3
SELECT SUM(Col1)/COUNT(Col1) FROM NULLtable;

-- The query that is correct is the second query. For the aerage we only want to count the rows that have values that are contributing to the average. 

--Problem2
-- open database.db in duckdb in terminal
duckdb database.db

-- this is conceptually flawed
SELECT Site_name, MAX(Area) FROM Site;
-- This is flawed because Area is not sorted by Site_name as databases have no inherent order. Therefore in this query the MAX(Area) call is asking to group by site_name and then find the max of a different column. The MAX() is not an aggregate function and will not perform both of these tasks when we have not called the area column. 

-- Find the site name and area of the site having the largest area. Do so by ordering the rows in a particularly convenient order, and using LIMIT to select just the first row.
SELECT Site_name, MAX(Area) AS Max_area FROM Site
    GROUP BY Site_name
    ORDER BY -Max_area
    LIMIT 1;

-- Do the same, but use a nested query. First, create a query that finds the maximum area. Then, create a query that selects the site name and area of the site whose area equals the maximum.
SELECT Site_name, Area FROM Site WHERE Area = (
    SELECT MAX(Area) FROM Site);

-- Problem 3
-- open database.db in duckdb in terminal
duckdb database.db

.tables

-- view bird_eggs tables
SELECT * FROM Bird_nests;

-- create column in averages that computes Average volume of bird_eggs
CREATE TEMP TABLE Averages AS
    SELECT Nest_ID, AVG((3.14/6) * (Width^2) * Length) AS Avg_volume
        FROM Bird_eggs
        GROUP BY Nest_ID;

-- join table with bird_nests
CREATE TEMP TABLE Averages_vol AS
SELECT Species, MAX(Avg_volume) AS MaxAvg_volume
    FROM Bird_nests JOIN Averages USING (Nest_ID)
    GROUP BY Species;

-- join table with Species to get scientific name
SELECT Scientific_name, MaxAvg_volume
    FROM Averages_vol JOIN Species 
    ON Species.Code = Averages_vol.Species
    ORDER BY MaxAvg_volume DESC;

--Bonus points if you can do it all in one statement
