#!/bin/bash

: ${HADOOP_PREFIX:=/usr/local/hadoop}

sh $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

rm /tmp/*.pid

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

# altering the core-site configuration
sed s/HOSTNAME/$HOSTNAME/ /usr/local/hadoop/etc/hadoop/core-site.xml.template2 > /usr/local/hadoop/etc/hadoop/core-site.xml

# setting spark defaults
echo spark.yarn.jar hdfs:///spark/spark-assembly-1.6.0-hadoop2.6.0.jar > $SPARK_HOME/conf/spark-defaults.conf
cp $SPARK_HOME/conf/metrics.properties.template $SPARK_HOME/conf/metrics.properties

/usr/sbin/sshd
ssh-keyscan `hostname` >> ~/.ssh/known_hosts
ssh-keyscan 0.0.0.0 >> ~/.ssh/known_hosts
ssh-keyscan localhost >> ~/.ssh/known_hosts
$HADOOP_PREFIX/sbin/start-dfs.sh
$HADOOP_PREFIX/sbin/start-yarn.sh

#database has to be ready at this point in mariadb service, making a few attempts with pause
attempts=5
while [ $attempts -gt 0 ]
do 
    cd /usr/local/hive/scripts/metastore/upgrade/mysql/ && mysql -hmariadb -uroot -phadoop -e "CREATE DATABASE IF NOT EXISTS hive;" && mysql -hmariadb -uroot -phadoop hive < ./hive-schema-2.1.0.mysql.sql
    [[ $? -eq 0 ]] && break
    ((attempts--))
    sleep 10
done


/etc/init.d/hive-server2 start

# For hive and spark sql integration, we can only do it at runtime since hostname is required in core-site.xml
cp $HADOOP_PREFIX/etc/hadoop/core-site.xml $SPARK_HOME/conf
# Somehow spark-defaults.conf always overwriten by some process, so we need to append mysql driver when run the container.
echo "spark.executor.extraClassPath $SPARK_HOME/lib/mysql-connector-java-5.1.41.jar" >> $SPARK_HOME/conf/spark-defaults.conf
echo "spark.driver.extraClassPath $SPARK_HOME/lib/mysql-connector-java-5.1.41.jar" >> $SPARK_HOME/conf/spark-defaults.conf

CMD=${1:-"exit 0"}
#CMD="-d"
if [[ "$CMD" == "-d" ]];
then
        /usr/sbin/sshd -p22 -D -d
else
        /bin/bash -c "$*"
fi
