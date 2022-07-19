#!/bin/bash
DB=$1
TABLES=$(sqlite3 $DB .tables | sed -r 's/(\S+)\s+(\S)/\1\n\2/g' | grep -v migration_log)
for t in $TABLES; do
    echo "TRUNCATE TABLE $t;"
done
for t in $TABLES; do
    column="$(sqlite3 $DB ".schema $t" | sed ':a;N;$!ba;s/\n//g;s/;/;\n/g' | grep "CREATE TABLE" | cut -d\( -f2- | tr ',' '\n' | sed 's/"/`/g' | sed -E 's/^ +//g' | cut -d\  -f1 | sed  ':a;N;$!ba;s/\n/,/g')"
    echo -e ".mode insert $t($column)\nselect * from $t;"  
done | sqlite3 $DB | sed -e 's/\\[rnut"]/\\&/g' | sed -E 's/^INSERT INTO "([a-z_][a-z_0-9]*\(([a-z_`][a-z_0-9`]*,?)+\))"/INSERT INTO \1/g'
