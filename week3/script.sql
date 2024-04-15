-- Things to know about duckdb
-- you need to be in the repository where this is stored
-- control C gets you out of permaloading for a singular command
-- to get you out of DuckDB in the terminal .exit or control D
-- * = all columns
-- SQL is case insensitive

-- open database.db in duckdb in terminal
duckdb database.db

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
SELECT * FROM Species;
SELECT  Code, Common_name FROM Species;
SELECT Species FROM Bird_nests;
SELECT DISTINCT Species FROM Bird_nests;

-- ordering of results 
SELECT DISTINCT Species FROM Bird_nests ORDER BY Species;

--Exercise: what distinct locations occur in the site table and order them and limit to 3 results
SELECT DISTINCT Location FROM Site ORDER BY Location LIMIT 3;