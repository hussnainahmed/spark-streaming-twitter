ADD JAR /var/lib/hive/hive-serdes-1.0-SNAPSHOT.jar;
INSERT OVERWRITE LOCAL DIRECTORY  '/tmp/out_tweet' ROW FORMAT DELIMITED FIELDS TERMINATED BY '>' LINES TERMINATED BY '\n' select text,created_at from tweets where text IS NOT NULL and lang='en';
