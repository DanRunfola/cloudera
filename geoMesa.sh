#Download geoMesa binaries / untar
#https://github.com/locationtech/geomesa/releases/download/geomesa_2.11-2.4.0/geomesa-accumulo_2.11-2.4.0-bin.tar.gz

#conf directory
#add this to conf/geomesa-site.xml


<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <property>
        <name>geomesa.tools.accumulo.site.xml</name>
        <value>/etc/accumulo/conf/accumulo-site.xml</value>
        <description>Path to the accumulo site xml config file. This is used
            to look up information about the accumulo cluster such as the
            master or zookeeper names.
        </description>
        <final>false</final>
    </property>
</configuration>


#conf/geomesa-env.sh
setvar ACCUMULO_HOME /opt/cloudera/parcels/ACCUMULO/lib/accumulo
setvar ACCUMULO_CONF_DIR /etc/accumulo/conf
setvar HADOOP_HOME /opt/cloudera/parcels/CDH/lib/hadoop
setvar HADOOP_CONF_DIR /etc/hadoop/conf
hadoopCDH="1"
setvar HADOOP_COMMON_HOME /opt/cloudera/parcels/CDH/lib/hadoop
setvar YARN_HOME /opt/cloudera/parcels/CDH/lib/hadoop-yarn
setvar HADOOP_MAPRED_HOME /opt/cloudera/parcels/CDH/lib/hadoop-mapreduce
setvar HADOOP_HDFS_HOME /opt/cloudera/parcels/CDH/lib/hadoop-hdfs
setvar HADOOP_MAPRED_HOME /opt/cloudera/parcels/CDH/lib/hadoop-mapreduce

#Test:
bin/geomesa-accumulo env
bin/geomesa-accumulo classpath
bin/geomesa-accumulo version

#conf/reference.conf
#sfts are simple feature types
#This defines the schema of the attribute table
#of the geoJSON (or whatever)

#application.conf
#conf/sfts
#(will need to mkdir)
#conf/sfts/geoboundaries/reference.conf
geomesa.sfts {
 geoboundary-adm = {
  attributes = [
   {name="shapeName",    type="String",  index=false }
   {name="shapeISO",    type="String",  index=false }
   {name="shapeID",  type="String",  index=false}
   {name="shapeGroup",     type="String",  index=true }
   {name="shapeType",     type="String",  index=true }
   {name="geometry",  type="MultiPolygon", index=true, srid=4326, default=true}
  ]
  user-data = {
   geomesa.mixed.geometries=true
  }
 }
}
geomesa.converters {
 geoboundary-adm-collection-geojson = {
  type = "json"
  id-field = "$shapeID"
  feature-path = "$.features"
  fields = [
   {name="shapeName",    json-type="string",  path="$.properties.shapeName"    }
   {name="shapeISO",    json-type="string",  path="$.properties.shapeISO"   }
   {name="shapeID",  json-type="string",  path="$.properties.ISO_Code"  }
   {name="shapeGroup",     json-type="string",  path="$.properties.iso"    }
   {name="shapeType",     json-type="string",  path="$.properties.adm"    }
   {name="geometry",  json-type="geometry", path="$.geometry", transform="multipolygon($0)"}
  ]
  options {
   error-mode="raise-errors"
   validators=["has-geo"]
  }
 }
}

#conf/reference.conf
#Add teh path reference to the above.

bin/geomesa-accumulo env

should now list converter - i.e., 
geoboundary-adm
geoboundary-adm-collection-geojson

###
kinit
accumulo shell
password - root : (in slack will change)
accumulo shell -u root 

createuser dsmillerrunfol

can also use dsmillerrunfol, has equivalent rights, generated after logging in to root with
grant -s System.GRANT -u dsmillerrunfol
System.GRANT
System.CREATE_TABLE
System.DROP_TABLE
System.ALTER_TABLE
System.CREATE_USER
System.SYSTEM
System.CREATE_NAMESPACE
System.OBTAIN_DELEGATION_TOKEN

#then from accumulo shell
createnamespace gB

#See if it worked:
namespace

#Next:
config - lets you see all config

#Edit config
config -s general.vfs.context.classpath.${NAMESPACE}=hdfs://NAME_NODE_FDQN:54310/accumulo/classpath/${NAMESPACE}/[^.].*.jar
config -ns ${NAMESPACE} -s table.classpath.context=${NAMESPACE}
#I.e.:
config -s general.vfs.context.classpath.gB=hdfs://nameservice1/accumulo/classpath/gB/[^.].*.jar
config -ns gB -s table.classpath.context=gB

#Check they took:
config
config -ns gB

#Note, config alone lets you see the full list of current config
#in case you need a hdfs path, for example.
#Next you need to create the above folder on HDFS
#This is where we'll put JARs for distribution
hdfs dfs -mkdir /accumulo/classpath/${NAMESPACE}

hdfs dfs -mkdir /accumulo/classpath/gb/

#put geomesa-accumulo-distributed-runtime_2.11-2.4.0.jar into that hdfs folder
hdfs dfs -copyFromLocal /home/dsmillerrunfol@campus.wm.edu/cloudera/libs/geomesa-accumulo_2.11-2.4.0/dist/accumulo/geomesa-accumulo-distributed-runtime_2.11-2.4.0.jar /accumulo/classpath/gB/


#Create schema
./bin/geomesa-accumulo create-schema -u dsmillerrunfol --catalog gB.hp --feature-name adm --spec geoboundary-adm

#Ingest a boundary
wget https://www.geoboundaries.org/data/geoBoundaries-3_0_0/AFG/ADM1/geoBoundaries-3_0_0-AFG-ADM1.geojson

./bin/geomesa-accumulo ingest -u dsmillerrunfol --catalog gB.hp --feature-name adm --converter geoboundary-adm-collection-geojson --spec geoboundary-adm /home/dsmillerrunfol@campus.wm.edu/cloudera/geoBoundaries-3_0_0-AFG-ADM1.geojson 

./bin/geomesa-accumulo ingest help

#Setup conda environment however you want on a node that can submit
#Make sure to include python-hdfs
#Create your gen.sh file for it

#/home/dsmillerrunfol@campus.wm.edu/cloudera/gen.sh

#cd into your environmental folder of anaconda and run the above gen script


#python
import geomesa_pyspark
conf = geomesa_pyspark.configure(
         jars=['/home/dsmillerrunfol@campus.wm.edu/geomesa-accumulo-spark-runtime_2.11-2.3.1.jar'],
         packages=['geomesa_pyspark','pytz'],
         spark_home='/opt/cloudera/parcels/CDH-6.2.0-1.cdh6.2.0.p0.967373/lib/spark').\
       setAppName('DanTest')
conf.get('spark.master')
# u'yarn'
from pyspark.sql import SparkSession
spark = ( SparkSession
    .builder
    .config(conf=conf)
    .enableHiveSupport()
    .getOrCreate() )
params = {
    "accumulo.instance.id":    "accumulo",
    "accumulo.zookeepers":     "m1a.geo.sciclone.wm.edu:2181,m1b.geo.sciclone.wm.edu:2181,m2.geo.sciclone.wm.edu:2181",
    "accumulo.user":           "dsmillerrunfol",
    "accumulo.password":       "geomesa",
    "accumulo.catalog":        "gB.hp"
}
feature = "adm"
df = ( spark
    .read
    .format("geomesa")
    .options(**params)
    .option("geomesa.feature", feature)
    .load() )
df.createOrReplaceTempView("adm")
spark.sql("show tables").show()

spark.sql("""select * from tbl""").show()
