#!/bin/bash
SQL="DELETE FROM pti_sent WHERE TIMESTAMP(dt) < (NOW() - INTERVAL 20160 MINUTE);"

MYSQL_USER="root"
MYSQL_PASS="ptifinf94"
MYSQL_DB="ptitweets"

echo $SQL | /usr/bin/mysql --user=$MYSQL_USER --password=$MYSQL_PASS $MYSQL_DB

