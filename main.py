import pyspark
from pyspark.sql import SparkSession
spark = (SparkSession.builder
    .master("yarn")
    .appName("test")
    .getOrCreate()
)
sc = spark.sparkContext
def testx(x):
    #import pytz
    try:
        import pandas as pd
    except:
        x = "Imports failed."
    return(x)

def geoLog(message):
    filePath = "home/dsmillerrunfol@campus.wm.edu/cloudera/geoMesaLog.txt"
    with open(filePath, 'a') as f:
        f.write(message + "\n")


x = sc.parallelize([1,2,3,4]).mapPartitions(testx).collect()
geoLog(x)
