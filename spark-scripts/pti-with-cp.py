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
    

def functionToCreateContext():
    sc = SparkContext(appName="PTITwitterStream")   # new context
    ssc = new StreamingContext(sc, 60)
    tdate = datetime.now(pytz.timezone('Asia/Karachi')).strftime("%y-%m-%d")
    input = ssc.textFileStream("/user/flume/tweet-stream/%s" % tdate)
    ssc.checkpoint(checkpointDirectory)   # set checkpoint directory
    return ssc



if __name__ == "__main__":
    #sc = SparkContext(appName="PTITwitterStream")
    #tdate = datetime.now(pytz.timezone('Asia/Karachi')).strftime("%y-%m-%d")
    #ssc = StreamingContext(sc, 60)
    #input = ssc.textFileStream("/user/flume/tweet-stream/%s" % tdate)
    #rec = input.map(lambda x: json.loads(x))
    checkpointDirectory = '/user/flume/tweet-stream/sc'
    context = StreamingContext.getOrCreate(checkpointDirectory, functionToCreateContext)
    
    def process(rdd):
        try:
            engine = create_engine("mysql+mysqldb://root:ptifinf94@localhost:3306/ptitweets")
            sqlContext = getSqlContextInstance(rdd.context)
            rowRdd = rdd
            wordsDataFrame = sqlContext.jsonRDD(rowRdd)
            wordsDataFrame.registerTempTable("ts")
            pti_text = sqlContext.sql("select text,created_at from ts where text IS NOT NULL and lang=\'en\'")
            #output = pti_text.collect()
            #print output
            df = pti_text.toPandas()
            df['text'] = df['text'].map(lambda x: x.encode('utf-8'))
     	    #df['created_at']= df['created_at'].map(lambda y: time.mktime(time.strptime(y,"%a %b %d %H:%M:%S +0000 %Y")))
            #df['created_at']= df['created_at'].map(lambda y: datetime.strftime('%Y-%m-%d %H:%M:%S', (datetime.strptime(y,'%a %b %d %H:%M:%S +0000 %Y')+ timedelta(hours=5))))
	    df['created_at']= df['created_at'].map(lambda y: (datetime.strptime(y,'%a %b %d %H:%M:%S +0000 %Y')+ timedelta(hours=5)))
	    #df = df.encode('utf-8')
            #colmns = ['text','created_at']
            #df = changeencode(pandas_df, colmns)
            conn = engine.raw_connection()
            df.to_sql(name='tweet_text', con=conn,if_exists='append',    flavor='mysql',index=False, index_label='rowID')
            conn.close()
            #print df
        except Exception as e: print(e)

    context.foreachRDD(process)
    ssc.start()
    ssc.awaitTermination()

