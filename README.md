# database-migrator
This script dumps data from a grafana sqlite database in a format that works with MySQL. It is intended to assist in migrating Grafana instances from the default sqlite database (grafana.db) to MySQL (or a MySQL-compatible DB like MariaDB). 

The Grafana help docs discuss what DB options are supported by Grafana: https://grafana.com/docs/grafana/latest/administration/configuration/#type

Use the script like this to create the MySQL dump file (which will be used later as a script to insert data into the MySQL database):

```bash
cp sqlitedump.sh <PATH_TO_GRAFANA_DB>
cp escape.awk <PATH_TO_GRAFANA_DB>
sqlitedump.sh <PATH_TO_GRAFANA_DB>/grafana.db > grafana.sql
```

Before importing this into your new MySQL DB:
- configure your grafana.ini to use the MySQL DB (per https://grafana.com/docs/grafana/latest/administration/configuration/#database)
- start Grafana to let it set up the DB and table structures in MySQL
- stop Grafana

Then you can import the SQL dump file to populate the content (be warned it truncates the tables first, so any existing data in mysql will be lost). Something like this:

```bash
mysql grafana < grafana.sql
```
## notes
If you are using MacOSX you might need to install `gawk` to be used for the `escape.awk` script. MacOSX `awk` (`brew install awk`) is not the GNU implementation, download `gawk` with `brew install gawk` and then alias it for `awk` using `alias awk=gawk`.

troubleshoot
- (optional) you might have to create a grafana database in your MySQL DB for migrations to work

## Caveats
- do not change the Grafana version (e.g., 7.1.3) or flavor (e.g., OSS, Enterprise) between the export and import of the database
- Postgres support may require some additional processing of the SQL file: see https://grafana.com/blog/2020/01/13/how-to-migrate-your-configuration-database/
- In order for your datasource passwords to function after migration to your new database, make sure that the new Grafana environment is using the same `secret_key` as your old environment (in the grafana.ini: https://grafana.com/docs/grafana/latest/administration/configuration/#secret_key)

## Character set: may need to be `utf8mb4`
In order to avoid errors like "Incorrect string value" during import of the data into MySQL, you may find it is necessary to change the MySQL charset to `utf8mb4`. One way to do this is to add `character-set-server=utf8mb4` in your my.cnf.

## You must fix import errors
SQLite uses case-sensitive indexes. But MySQL unique indexes are not case-sensitive for columns using a ci collation (the default). Thus you may hit some errors like this while importing the SQL dump into MySQL:

```
ERROR 1062 (23000) at line 4989: Duplicate entry 'SomeKeyName' for key 'UQE_tag_key_value'
```

This means that two values conflicted because they were different to SQLite (due to its case-sensitivity), but they appear to be the same to MySQL.

It is important that you fix these errors, or the import will be incomplete. I.e., you will need to maually edit the SQL dump file to identify the lines that include conflicting key names (i.e., keys that are the same but have different case), and either delete or edit one of those lines to make the keys unique, then re-run the step to import the SQL file into MySQL. You may have to do this multiple times, until the import runs without errors.

## Test procedure using Docker container
Caution: this procedure is for testing only, because the DB will be lost when the Docker container is stopped.

Creating a temporary MySQL container for testing.

```
docker run --rm -i -t -d \
--name mytestsql  \
-e MYSQL_DATABASE=grafana \
-e MYSQL_USER=grafana \
-e MYSQL_PASSWORD=grafana \
-e MYSQL_ROOT_PASSWORD=grafana \
-p 3306:3306 \
mariadb
```

Restoring the database inside the container with docker exec.

```
docker exec -i mytestsql mysql grafana -ugrafana -pgrafana < grafana.sql
```
