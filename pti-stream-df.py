import os
import sys
from pyspark import SparkContext
from pyspark.streaming import StreamingContext
from pyspark.sql import SQLContext, Row
from pyspark import SparkContext
from pyspark.streaming import StreamingContext
import datetime
from datetime import *
import pytz
from pytz import *
import json
import StringIO
import pandas
from sqlalchemy import create_engine


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
    tdate = datetime.now(pytz.timezone('UTC')).strftime("%y-%m-%d")
    ssc = StreamingContext(sc, 60)
    input = ssc.textFileStream("/user/flume/tweet-stream/%s" % tdate)
    #rec = input.map(lambda x: json.loads(x))



    # Convert RDDs of the words DStream to DataFrame and run SQL query
    def process(rdd):


        try:
            # Get the singleton instance of SQLContext
            sqlContext = getSqlContextInstance(rdd.context)

            # Convert RDD[String] to RDD[Row] to DataFrame
            rowRdd = rdd
            wordsDataFrame = sqlContext.jsonRDD(rowRdd)

            # Register as table
            wordsDataFrame.registerTempTable("ts")

            pti_text = sqlContext.sql("select text,created_at from ts where text IS NOT NULL and lang=\'en\'")
            #pti_text.show()
            pandas_df = pti_text.toPandas()
	    print pandas_df

        except Exception as e: print(e)
            #pass


    input.foreachRDD(process)
    ssc.start()
    ssc.awaitTermination()


