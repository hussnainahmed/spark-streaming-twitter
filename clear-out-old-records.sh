#!/bin/bash
SQL="DELETE FROM tweet_text WHERE created_at < (NOW() - INTERVAL 120 MINUTE);"

MYSQL_USER="root"
MYSQL_PASS="ptifinf94"
MYSQL_DB="ptitweets"

echo $SQL | /usr/bin/mysql --user=$MYSQL_USER --password=$MYSQL_PASS $MYSQL_DB

