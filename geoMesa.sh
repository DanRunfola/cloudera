#Download geoMesa binaries / untar
#https://github.com/locationtech/geomesa/releases/download/geomesa_2.11-2.4.0/geomesa-accumulo_2.11-2.4.0-bin.tar.gz

#conf directory
#add this to geomesa-site.xml

<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <property>
        <name>geomesa.tools.accumulo.site.xml</name>
        <value></value>
        <description>Path to the accumulo site xml config file. This is used
            to look up information about the accumulo cluster such as the
            master or zookeeper names.
        </description>
        <final>false</final>
    </property>
</configuration>

#geomesa-env.sh
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


