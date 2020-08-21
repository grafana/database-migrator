# database-migrator
This script dumps data from a grafana sqlite database in a format that works with MySQL. It is intended to assist in migrating Grafana instances from the default sqlite database (grafana.db) to MySQL (or a MySQL-compatible DB like MariaDB). 

The Grafana help docs discuss what DB options are supported by Grafana: https://grafana.com/docs/grafana/latest/administration/configuration/#type

Use the script like this to create the MySQL dump file (which will be used later as a script to insert data into the MySQL database):

```
sqlitedump.sh grafana.db > grafana.sql
```

Before importing this into your new MySQL DB:
- configure your grafana.ini to use the MySQL DB (per https://grafana.com/docs/grafana/latest/administration/configuration/#database)
- start Grafana to let it set up the DB and table structures in MySQL
- stop Grafana

Then you can import the SQL dump file to populate the content (be warned it truncates the tables first, so any existing data in mysql will be lost). Something like this:

```
mysql grafana < grafana.sql
```

## Caveats
- do not change the Grafana version (e.g., 7.1.3) or flavor (e.g., OSS, Enterprise) between the export and import of the database
- Postgres support may require some additional processing of the SQL file: see https://grafana.com/blog/2020/01/13/how-to-migrate-your-configuration-database/

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
