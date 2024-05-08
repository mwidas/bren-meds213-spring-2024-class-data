-- Question 1: Some strategies were mentioned in class for reducing the possibility of performing UPDATEs and DELETEs that have catastrophic consequences. What strategy will you use?
-- For reducing the possibility of a catastrophic event I will use the strategy of creating the command and checking to ensure that it performs the select as expected. After that has been confirmed I will then do any deleting or updating.

-- Question 2: Your job is to create a trigger that will fire an UPDATE statement that will fill in a value for Egg_num in either situation above.
-- part 1
CREATE TRIGGER egg_filler
AFTER INSERT ON Bird_eggs
FOR EACH ROW
BEGIN
    UPDATE Bird_eggs
    SET Egg_num = (
        SELECT case
            WHEN MAX(Egg_num) IS NULL THEN 1
            ELSE MAX(Egg_num)+1
        END
        FROM Bird_eggs
        WHERE Nest_ID=New.Nest_ID
    )
    WHERE rowid=NEW.rowid;
END;

--Test trigger
CREATE TABLE Bird_eggs AS SELECT * FROM Bird_eggs;

.nullvalue -NULL-
SELECT * FROM Bird_eggs WHERE Nest_ID = '14eabaage01';


INSERT INTO Bird_eggs
    (Book_page, Year, Site, Nest_ID, Length, Width)
    VALUES ('b14.6', 2014, 'eaba', '14eabaage01', 12.35, 56.79);

-- WORKED!

-- part 2
CREATE TRIGGER egg_filler
AFTER INSERT ON Bird_eggs
FOR EACH ROW
BEGIN
    UPDATE Bird_eggs
    SET 
    Egg_num = (
        SELECT case
            WHEN MAX(Egg_num) IS NULL THEN 1
            ELSE MAX(Egg_num)+1
        END
        FROM Bird_eggs
        WHERE Nest_ID=New.Nest_ID
    ),
    Book_page = (
        SELECT b.Book_page
        FROM Bird_nests b 
        WHERE b.Nest_ID=New.Nest_ID),
    "Year" = (
        SELECT "Year"
        FROM Bird_nests b
        WHERE b.Nest_ID=New.Nest_ID),
    Site = (
        SELECT Site
        FROM Bird_nests b
        WHERE b.Nest_ID=New.Nest_ID)
    WHERE rowid=NEW.rowid;
END;

INSERT INTO Bird_eggs
    (Nest_ID, Length, Width)
    VALUES ('14eabaage01', 12.32, 56.74);

  INSERT INTO Bird_eggs
    (Nest_ID, Length, Width)
    VALUES ('14eabaage01', 12.38, 56.82);  

--WORKED!!

SELECT * FROM Bird_eggs WHERE Nest_ID = '14eabaage01';

--Question 3: 

-- 1. Compare the output of these three commands:

ls
ls .
ls "$(pwd)/../week3"

--Explain why you see what you see.
-- These all return the same outputs. ls lists everything in the current directory, ls . lists everything that is within a directory but specifies selecting everything, and ls "$(pwd)/../week3" gives the command to list the print of the working directory of week 3.

-- 2. Try the following two commands:

wc -l *.csv -- individual word counts by file
cat *.csv | wc -l -- total word counts

-- The first prints filenames and line counts. The second prints a bare number. Why does it print that number, and why does it not print any filenames?
-- The second command concatanates all of the lines of the csv's and then pipes into calculating counts of the files which results in just the total being printed and because there is no call for file names after the pipe there is no file name printed.

-- 3. You want to count the total number of lines in all CSV files and try this command:

cat *.csv | wc -l species.csv

-- What happens and why?
-- This returns just the word count from species.csv because you piped from the total documents and then specified only to count species.csv

-- 4. You’re given

name=Moe

-- and you’d like to print “Moe_Howard”. You try this:

echo "$name_Howard"

--but that doesn’t quite work. What fix can you apply to $name to make this command give the desired effect?
-- echo $name"_Howard"


--5. You create a script and run it like so:

bash myscript.sh *.csv

--What are the values of variables $1 and $#? Explain why the script does not see just one argument passed to it.
-- Variable $# is the number of arguments, variable $1 would be the first argument listed. The script does not see just one argument passed to it because environment variables are inheritied and the command given * means select all so the file could be looking for any of those particular variables.


--6. You create a script and run it like so:

bash myscript.sh "$(date)" $(date)

-- In your script, what is the value of variable $3?
-- The value of variable 3 would be the 3rd argument and there is no 3rd argument given so it would be nothing.

--7. Create a file you don’t care about (because you’re about to destroy it):

echo "yo ho a line of text" > junk_file.txt
echo "another line" >> junk_file.txt

-- You want to sort the lines in this file, so you try:

sort junk_file.txt

-- Well that prints the lines in sorted order, but it doesn’t actually change the file. You recall section 7 and try:

sort junk_file.txt > junk_file.txt

-- What happens and why? How can you sort the lines in your file? (Hint: it involves creating a second file and using mv.)
-- Running this line removed both lines of text from the file. As the command given indicates to post the output of the command which is nothing to the file. 
-- To sort the lines in the file 

sort junk_file.txt > junk_file_sort.txt

-- 8. You want to delete all files ending in .csv, so you type (don’t actually try this):

rm * .csv

-- but as can be seen, your thumb accidentally hit the space bar and you got an extra space in there. What will rm do in this case?
-- The extra space will cause everything to be removed from the directory that is a .csv and that does not have an extension.

--Harness

-- run with 1000

--not_in
bash query_timer.sh not_in 1000 'SELECT Code
    FROM Species
    WHERE Code NOT IN (SELECT DISTINCT Species FROM Bird_nests);' \
     database.db timings.csv

--outer
bash query_timer.sh outer 1000 'SELECT Code
    FROM Bird_nests RIGHT JOIN Species
    ON Species = Code
    WHERE Nest_ID IS NULL;' \
     database.db timings.csv

-- set
bash query_timer.sh set 1000 'SELECT Code FROM Species
EXCEPT
SELECT DISTINCT Species FROM Bird_nests;' \
     database.db timings.csv


-- run with 100

--not_in
bash query_timer.sh not_in 100 'SELECT Code
    FROM Species
    WHERE Code NOT IN (SELECT DISTINCT Species FROM Bird_nests);' \
     database.db timings.csv

--outer
bash query_timer.sh outer 100 'SELECT Code
    FROM Bird_nests RIGHT JOIN Species
    ON Species = Code
    WHERE Nest_ID IS NULL;' \
     database.db timings.csv

-- set
bash query_timer.sh set 100 'SELECT Code FROM Species
EXCEPT
SELECT DISTINCT Species FROM Bird_nests;' \
     database.db timings.csv
