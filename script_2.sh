#Run this script from hadoopuser

ssh-keygen
ssh-copy-id hadoopuser@localhost
cat <<EOF | tee >> /etc/sysctl.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF
cat /proc/sys/net/ipv6/conf/all/disable_ipv6


sudo mv /home/diems/hadoop-3.2.1.tar.gz /usr/local
cd /usr/local
sudo tar -xvf hadoop-3.2.1.tar.gz
sudo ln -s hadoop-3.2.1 hadoop
ls -ltr
sudo chown -R hadoopuser:hadoop hadoop-3.2.1
ls -ltr
sudo chown -R hadoopuser:hadoop hadoop
ls -ltr
sudo chmod 777 hadoop-3.2.1

cat <<EOF | tee >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh
export HADOOP_OPTS=-Djava.net.preferIPv4Stack=true
export HADOOP_HOME_WARN_SUPPRESS="TRUE"
export JAVA_HOME=/usr/local/java/jdk1.8.0_241
EOF

. ~/.bashrc

cat <<EOF | tee >> ~/.bashrc
export HADOOP_HOME=/usr/local/hadoop
export HADOOP_PREFIX=/usr/local/hadoop
export HADOOP_MAPRED_HOME=/usr/local/hadoop
export HADOOP_COMMON_HOME=/usr/local/hadoop
export HADOOP_HDFS_HOME=/usr/local/hadoop
export HADOOP_YARN_HOME=/usr/local/hadoop
export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop

export HADOOP_COMMON_LIB_NATIVE_DIR=/usr/local/hadoop/lib/native
export HADOOP_OPTS="-Djava.library.path=/usr/local/hadoop/lib"

export JAVA_HOME=/usr/local/java/jdk1.8.0_241

unaliasfs&> /dev/null
aliasfs="hadoopfs"
unaliashis&> /dev/null
aliashis="fs -ls"

export PATH=$PATH:/usr/local/hadoop/bin:$PATH:/usr/local/java/jdk1.8.0_241/bin:/usr/local/hadoop/sbin

EOF

. ~/.bashrc

sudo mkdir -p /app/hadoop/tmp
sudo chown -R hadoopuser:hadoop /app/hadoop/tmp/
sudo chmod -R 777 /app/hadoop/tmp/

cat <<EOF | tee > /usr/local/hadoop/etc/hadoop/yarn-site.xml
<?xml version="1.0"?>
<configuration>

<property>
	<name>yarn.nodemanager.aux-services</name>
	<value>mapreduce_shuffle</value>
</property>

<property>
	<name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
	<value>org.apache.hadoop.mapred.ShuffleHandler</value>
</property>

</configuration>
EOF

cat <<EOF | tee > /usr/local/hadoop/etc/hadoop/core-site.xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>
<property>
<name>hadoop.tmp.dir</name>
<value>/app/hadoop/tmp</value>
</property>

<property>
<name>fs.default.name</name>
<value>hdfs://localhost:9000</value>
</property>

</configuration>
EOF

#cp /usr/local/hadoop/etc/hadoop/mapred-site.xml.template /usr/local/hadoop/etc/hadoop/mapred-site.xml

cat <<EOF | tee > /usr/local/hadoop/etc/hadoop/mapred-site.xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>
<property>
<name>mapreduce.framework.name</name>
<value>yarn</value>
</property>
</configuration>
EOF


sudo mkdir -p /usr/local/hadoop/yarn_data/hdfs/namenode

sudo mkdir -p /usr/local/hadoop/yarn_data/hdfs/datanode

sudo chmod 777 /usr/local/hadoop/yarn_data/hdfs/namenode

sudo chmod 777 /usr/local/hadoop/yarn_data/hdfs/datanode

sudo chown -R hadoopuser:hadoop /usr/local/hadoop/yarn_data/hdfs/namenode

sudo chown -R hadoopuser:hadoop /usr/local/hadoop/yarn_data/hdfs/datanode


cat <<EOF | tee > /usr/local/hadoop/etc/hadoop/hdfs-site.xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>
<property>
<name>dfs.replication</name>
<value>1</value>
</property>

<property>
<name>dfs.namenode.name.dir</name>
<value>file:/usr/local/hadoop/yarn_data/hdfs/namenode</value>
</property>

<property>
<name>dfs.datanode.data.dir</name>
<value>file:/usr/local/hadoop/yarn_data/hdfs/datanode</value>
</property>

</configuration>
EOF

hadoop namenode -format

start-dfs.sh
jps
start-yarn.sh
jps




