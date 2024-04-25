-- open database
duckdb database_snow.db

--look at tables
.tables

--Question 1: Which sites have no egg data? Please answer this question using all three techniques demonstrated in class. In doing so, you will need to work with the Bird_eggs table, the Site table, or both. As a reminder, the techniques are:
-- Add an ORDER BY clause to your queries so that all three produce the exact same result
--Using a Code NOT IN (subquery) clause.
 SELECT Code FROM Site;
  WHERE Code NOT IN (SELECT DISTINCT Site FROM Bird_eggs);

--Using an outer join with a WHERE clause that selects the desired rows. Caution: make sure your IS NULL test is performed against a column that is not ordinarily allowed to be NULL. You may want to consult the database schema to remind yourself of column declarations.
SELECT Code
    FROM Site LEFT JOIN Bird_eggs ON Site = Code
    WHERE Egg_num IS NULL
    ORDER BY Code;

--Using the set operation EXCEPT.
SELECT Code from Site   
    EXCEPT SELECT DISTINCT Site FROM Bird_eggs
    ORDER BY Code;


--Question 2: The Camp_assignment table lists where each person worked and when. Your goal is to answer, Who worked with whom? That is, you are to find all pairs of people who worked at the same site, and whose date ranges overlap while at that site. This can be solved using a self-join.
-- Step 1. To the above join, add an ON clause that selects only those rows where the two people (the “A” person and the “B” person) worked at the same site: ON A.Site = .... You should wind up with a table with rows.
SELECT * FROM Camp_assignment A JOIN Camp_assignment B 
    ON A.Site = B.Site;

-- Step 2. We’ve matched up people working at the same site, but they don’t necessarily overlap in time. To the previous ON clause, add another condition that checks that the “A” person’s and the “B” person’s date ranges overlap.
SELECT * FROM Camp_assignment A JOIN Camp_assignment B 
    ON A.Site = B.Site
    WHERE A.End >= B.Start AND A.Start <= B.End;

-- Step 3. Well, there’s a problem. To better see it, add a clause WHERE A.Site = 'lkri' so you have only rows.
SELECT * FROM Camp_assignment A JOIN Camp_assignment B 
    ON A.Site = B.Site
    WHERE A.End >= B.Start 
        AND A.Start <= B.End 
        AND A.Site = 'lkri'
        AND A.Observer < B.Observer;

-- Clean up the table
SELECT A.Site, A.Observer AS Observer_1, B.Observer AS Observer_2 FROM Camp_assignment A JOIN Camp_assignment B 
    ON A.Site = B.Site
    WHERE A.End >= B.Start 
        AND A.Start <= B.End 
        AND A.Site = 'lkri'
        AND A.Observer < B.Observer;

--Bonus Problem
SELECT A.Site, p1.Name AS Name_1, p2.Name AS Name_2 FROM Camp_assignment A JOIN Camp_assignment B 
    ON A.Site = B.Site
    JOIN Personnel p1 ON A.Observer = p1.Abbreviation
    JOIN Personnel p2 ON B.Observer = p2.Abbreviation
    WHERE A.End >= B.Start 
        AND A.Start <= B.End 
        AND A.Site = 'lkri'
        AND A.Observer < B.Observer
    ORDER BY Name_2;


--Question 3: Who made this error? That is, looking at nest data for “nome” between 1998 and 2008 inclusive, and for which egg age was determined by floating, can you determine the name of the observer who observed exactly 36 nests?
SELECT Name, Count(ageMethod) AS Num_floated_nests FROM Bird_nests
JOIN Personnel ON Abbreviation = Observer
    WHERE Bird_nests.Site = 'nome' 
    AND Bird_nests.ageMethod = 'float'
    AND Bird_nests.Year >=1998
    AND Bird_nests.Year <=2008
GROUP BY Name
LIMIT 1;

 