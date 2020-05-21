#!/bin/bash


if [ $# -eq 0 ]
  then
    echo "No s3 bucket with path provided. gendata.sh <s3bucket-with-path>"
    exit 1
fi

SCALE=1000 # Scale factor

sql_exec() {
  oc exec -it presto-coordinator-0 presto-cli -- --server presto:8080 --catalog hive --execute "$1"
}

declare TABLES="$(sql_exec "SHOW TABLES FROM tpcds.sf1;" | sed s/\"//g)"

sql_exec "CREATE SCHEMA hive.tpcds WITH (location = 's3a://$1/');"
for tab in $TABLES; do
  sql_exec "CREATE TABLE tpcds.$tab AS SELECT * FROM tpcds.sf$SCALE.$tab;"
done