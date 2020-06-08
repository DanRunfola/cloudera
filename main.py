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
    import pandas as pd
    
    return(x)

def geoLog(message):
    filePath = "/home/dsmillerrunfol@campus.wm.edu/geoMesaLog.txt"
    with open(filePath, 'a') as f:
        f.write(message + "\n")


x = sc.parallelize([1,2,3,4]).mapPartitions(testx).collect()
geoLog(x)
