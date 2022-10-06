#!/bin/bash
DB=$1
TABLES=$(sqlite3 $DB .tables | sed -r 's/(\S+)\s+(\S)/\1\n\2/g' | grep -v migration_log)
for t in $TABLES; do
    echo "TRUNCATE TABLE $t;"
done
for t in $TABLES; do
    echo -e ".headers on"
    echo -e ".mode insert $t\nselect * from $t;"  
done | sqlite3 $DB | sed -e 's/\\[rnut"]/\\&/g' |  awk -F VALUES '{ gsub(/"/, "`", $1); print $1 "VALUES" $2 }'
