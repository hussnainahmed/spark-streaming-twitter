#!/bin/sh
/usr/bin/hadoop fs -rmr /user/flume/tweet-stream/$(date  --date="2 days ago" +"%y-%m-%d")
/usr/bin/hadoop fs -mkdir /user/flume/tweet-stream/$(date  --date="-2 days ago" +"%y-%m-%d")
