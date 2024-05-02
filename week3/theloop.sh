# this is how you start a bash script
#!/bin/bash

# print word count of each file in statement phrasing
for file in *.csv; do
    echo "$file has $(wc -l < $file) lines"
    done