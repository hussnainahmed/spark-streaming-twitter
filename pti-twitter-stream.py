from __future__ import (absolute_import, division, 
                        print_function, unicode_literals)

import os
import sys
from pyspark import SparkContext
from pyspark.streaming import StreamingContext
from pyspark.sql import SQLContext, Row
from pyspark import SparkContext
from pyspark.streaming import StreamingContext
import time
import datetime
from datetime import *
import pytz
from pytz import *
import json
import StringIO
from sqlalchemy import create_engine
import pandas
import MySQLdb

def getSqlContextInstance(sparkContext):
    if ('sqlContextSingletonInstance' not in globals()):
        globals()['sqlContextSingletonInstance'] = SQLContext(sparkContext)
    return globals()['sqlContextSingletonInstance']


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print >> sys.stderr, "Usage: noptel-stream-df.py <hostname> "
        exit(-1)
    host = sys.argv[1]
    sc = SparkContext(appName="PTITwitterStream")
    tdate = datetime.now(pytz.timezone('Asia/Karachi')).strftime("%y-%m-%d")
    ssc = StreamingContext(sc, 60)
    input = ssc.textFileStream("/user/flume/tweet-stream/%s" % tdate)
    #rec = input.map(lambda x: json.loads(x))
    def process(rdd):
        try:
            engine = create_engine("mysql+mysqldb://root:ptifinf94@localhost:3306/ptitweets")
            sqlContext = getSqlContextInstance(rdd.context)
            rowRdd = rdd
            wordsDataFrame = sqlContext.jsonRDD(rowRdd)
            wordsDataFrame.registerTempTable("ts")
            pti_text = sqlContext.sql("select text,created_at from ts where text IS NOT NULL and lang=\'en\'")
            df = pti_text.toPandas()
            df['text'] = df['text'].map(lambda x: x.encode('utf-8'))
     	    df['created_at']= df['created_at'].map(lambda y: (datetime.strptime(y,'%a %b %d %H:%M:%S +0000 %Y')+ timedelta(hours=5)))
            conn = engine.raw_connection()
            df.to_sql(name='tweet_text', con=conn,if_exists='append',    flavor='mysql',index=False, index_label='rowID')
            conn.close()
        except Exception as e: print(e)

    input.foreachRDD(process)
    ssc.start()
    ssc.awaitTermination()
