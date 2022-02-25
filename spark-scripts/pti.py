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
      sc1 = SparkContext(appName="PTITwitterStream")   # new context
      tdate = datetime.now(pytz.timezone('Asia/Karachi')).strftime("%y-%m-%d")
      ssc1 = StreamingContext(sc1, 60)
      input = ssc1.textFileStream("/user/flume/tweet-stream/%s" % tdate)
      ssc1.checkpoint(checkpointDirectory)   # set checkpoint directory
      #return ssc

      def process(rdd):
          try:
              engine = create_engine("mysql+mysqldb://root:ptifinf94@localhost:3306/ptitweets")
              sqlContext1 = getSqlContextInstance(rdd.context)
              rowRdd = rdd
              wordsDataFrame = sqlContext1.jsonRDD(rowRdd)
              wordsDataFrame.registerTempTable("ts")
              pti_text = sqlContext1.sql("select text,created_at from ts where text IS NOT NULL and lang=\'en\'")
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

      input.foreachRDD(process)
      return ssc1




if __name__ == "__main__":
    checkpointDirectory = '/user/flume/tweet-stream/sc/'
    ssc1 = StreamingContext.getOrCreate(checkpointDirectory, functionToCreateContext)
    #rec = input.map(lambda x: json.loads(x))

    ssc1.start()
    ssc1.awaitTermination()

