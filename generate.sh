export env="geomesa"
export wd="/home/dsmillerrunfol@campus.wm.edu/cloudera/"

cd /home/dsmillerrunfol@campus.wm.edu/anaconda3/envs/
zip -r /home/dsmillerrunfol@campus.wm.edu/cloudera/geomesa.zip geomesa 
cd /home/dsmillerrunfol@campus.wm.edu/cloudera/

echo "----------------------------------------"
echo "Create main spark-submit file"

# create spark submit file using conda environment
cat << EOF > ss-${env}
spark-submit \
--deploy-mode cluster \
--driver-memory=20g \
--conf spark.pyspark.driver.python=${conda_dir}/anaconda3/envs/${env}/bin/python \
--conf spark.pyspark.python=./ENV/${env}/bin/python \
--archives ${wd}/${env}.zip#ENV,/opt/cloudera/parcels/CDH-6.2.0-1.cdh6.2.0.p0.967373/lib/spark/python/lib/py4j-0.10.7-src.zip \
--jars ${jar_path},/opt/cloudera/parcels/CDH-6.2.0-1.cdh6.2.0.p0.967373/jars/httpclient-4.5.3.jar,/opt/cloudera/parcels/CDH-6.2.0-1.cdh6.2.0.p0.967373/jars/commons-httpclient-3.1.jar \
${run}
EOF

# create pyspark file
cat << EOF > ps-${env}
pyspark \
--driver-memory=20g \
--conf spark.rpc.message.maxSize=2047 \
--conf spark.pyspark.driver.python=${conda_dir}/anaconda3/envs/${env}/bin/python \
--conf spark.pyspark.python=./ENV/${env}/bin/python \
--archives ${wd}/${env}.zip#ENV,/opt/cloudera/parcels/CDH-6.2.0-1.cdh6.2.0.p0.967373/lib/spark/python/lib/py4j-0.10.7-src.zip \
--jars ${jar_path},/opt/cloudera/parcels/CDH-6.2.0-1.cdh6.2.0.p0.967373/jars/httpclient-4.5.3.jar,/opt/cloudera/parcels/CDH-6.2.0-1.cdh6.2.0.p0.967373/jars/commons-httpclient-3.1.jar
EOF

echo "----------------------------------------"
echo "Building Pyspark environment tests"


cat << EOF > tests/test-${env}
spark-submit \
--deploy-mode cluster \
--conf spark.pyspark.driver.python=${conda_dir}/anaconda3/envs/${env}/bin/python \
--conf spark.pyspark.python=./ENV/${env}/bin/python \
--archives ${wd}/${env}.zip#ENV,/opt/cloudera/parcels/CDH-6.2.0-1.cdh6.2.0.p0.967373/lib/spark/python/lib/py4j-0.10.7-src.zip \
--jars ${jar_path},/opt/cloudera/parcels/CDH-6.2.0-1.cdh6.2.0.p0.967373/jars/httpclient-4.5.3.jar,/opt/cloudera/parcels/CDH-6.2.0-1.cdh6.2.0.p0.967373/jars/commons-httpclient-3.1.jar \
${wd}/tests/test-${env}.py
EOF

# --conf spark.driver.extraClassPath=${jar_path} \
# --conf spark.executor.extraClassPath=${jar_path} \

# --py-files ${jar_path} \


# create python pyspark script to test that packages work
cat << EOF > tests/test-${env}.py
# pyspark template
import pyspark
from pyspark.sql import SparkSession
spark = (SparkSession.builder
    .master("yarn")
    .appName("test")
    .getOrCreate()
)
sc = spark.sparkContext
def testx(x):
EOF



cat << EOF >> tests/test-${env}.py
    import subprocess
    from hdfs.ext.kerberos import KerberosClient
    subprocess.call(["kinit", "dsmillerrunfol","-k","-t","/home/dsmillerrunfol@campus.wm.edu/cloudera/libs/dsmillerrunfol.keytab"])
    host = "https://m1a.geo.sciclone.wm.edu"
    port = 14000
    client = KerberosClient("{}:{}".format(host, port))
    hdfs_root = client.list("/")
    if "geoquery" in hdfs_root:
        print("HDFS connection success")
    else:
        raise Exception("Potential error with HDFS connection")

x = sc.parallelize([1,2,3,4]).mapPartitions(testx).collect()
print(x)
EOF
