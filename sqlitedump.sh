#!/bin/bash
DB=$1
# get list of tables as a single column without migration_log
TABLES=$(sqlite3 $DB .tables | sed -r 's/(\S+)\s+(\S)/\1\n\2/g' | grep -v migration_log)
# output sql to truncate all target tables
for t in $TABLES; do
    echo "TRUNCATE TABLE $t;"
done

# output sql to insert data into all target tables
for t in $TABLES; do
    echo -e ".headers on"
    echo -e ".mode insert $t\nselect * from $t;"
# sed is for adding a backslash to \t,\r,\n,\t & \" so they are properly escaped for MySQL
# awk is to convert double-quotes to backticks to properly quote reserved column names for MySQL
# TODO: add ability to add backticks for MYSQL_RESERVED_WORDS
done | sqlite3 $DB | sed -e 's/\\[rnut"]/\\&/g' |  awk -f escape.awk
