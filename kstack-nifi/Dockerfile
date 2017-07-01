# Daniel Malczyk
# ThinkBig Analytics, a Teradata Company

#basic image with CentOS and latest JDK
FROM airhacks/java

MAINTAINER Daniel Malczyk <dmalczyk@gmail.com>

# install dev tools
RUN yum clean all; \
    rpm --rebuilddb; \
    yum install -y curl which; \
    yum clean all

ENV NIFI_INSTALL_HOME /opt/nifi
ENV NIFI_USER nifi
ENV NIFI_GROUP users

# create nifi user and group
RUN /bin/bash -c 'useradd -r -m -s /bin/bash nifi'

# download and install NiFi with Kylo-provided script
COPY conf/install-nifi.sh .
RUN chmod u+x ./install-nifi.sh && \
    ./install-nifi.sh $NIFI_INSTALL_HOME $NIFI_USER $NIFI_GROUP

##This dir is shared with kylo img
#RUN mkdir -p $NIFI_INSTALL_HOME/data/lib/app
#COPY kylo-lib/*.tar.gz ./
##if Kylo img is build afterwards, newer versions from Kylo RPM will be used
#RUN tar -xzvf ./kylo-nifi-nars.tar.gz -C $NIFI_INSTALL_HOME/data/lib && rm ./kylo-nifi-nars.tar.gz
#RUN tar -xzvf ./kylo-spark-jars.tar.gz -C $NIFI_INSTALL_HOME/data/lib/app && rm ./kylo-spark-jars.tar.gz

VOLUME $NIFI_INSTALL_HOME/data

#install hadoop, spark and Hive clients
#------------
#Hadoop client config
RUN curl -s http://www.eu.apache.org/dist/hadoop/common/hadoop-2.7.1/hadoop-2.7.1.tar.gz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s ./hadoop-2.7.1 hadoop

ENV HADOOP_HOME /usr/local/hadoop
ENV HADOOP_INSTALL $HADOOP_HOME
ENV HADOOP_PREFIX $HADOOP_HOME
ENV PATH $PATH:$HADOOP_INSTALL/sbin
ENV HADOOP_MAPRED_HOME $HADOOP_INSTALL
ENV HADOOP_COMMON_HOME $HADOOP_INSTALL
ENV HADOOP_HDFS_HOME $HADOOP_INSTALL
ENV YARN_HOME $HADOOP_INSTALL
ENV PATH $HADOOP_HOME/bin:$PATH

RUN mkdir -p $HADOOP_PREFIX/etc/hadoop
COPY conf/core-site.xml.template2 $HADOOP_PREFIX/etc/hadoop/
RUN sed s/HOSTNAME/hadoophost/ $HADOOP_PREFIX/etc/hadoop/core-site.xml.template2 > $HADOOP_PREFIX/etc/hadoop/core-site.xml
ADD conf/hdfs-site.xml $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml

#Install spark to /usr/local/spark
#support for Hadoop 2.6.0
RUN curl -s http://d3kbcqa49mib13.cloudfront.net/spark-1.6.1-bin-hadoop2.6.tgz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s spark-1.6.1-bin-hadoop2.6 spark
ENV SPARK_HOME /usr/local/spark

ENV PATH $SPARK_HOME/bin:$PATH

# Install hive
RUN curl -s http://apache.mirrors.spacedump.net/hive/hive-2.1.1/apache-hive-2.1.1-bin.tar.gz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s apache-hive-2.1.1-bin hive
COPY conf/hive-site.xml /usr/local/hive/conf
RUN echo "export HIVE_HOME=/usr/local/hive" >> /etc/profile
RUN echo "export PATH=$PATH:/usr/local/hive/bin">> /etc/profile
ENV HIVE_HOME /usr/local/hive
ENV PATH $PATH:$HIVE_HOME/bin
# Create directory for hive logs
RUN mkdir -p /var/log/hive
# Increase PermGen space for hiveserver2 to fix OOM pb.
COPY conf/hive-env.sh /usr/local/hive/conf/

RUN echo "HADOOP_HOME=/usr/local/hadoop" >> /usr/local/hive/bin/hive-config.sh

# Prepare spark-hive integration, so spark sql will use hive tables defined in hive metastore, see https://spark.apache.org/docs/1.6.0/sql-programming-guide.html#hive-tables
RUN cp $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml $SPARK_HOME/conf
RUN cp $HIVE_HOME/conf/hive-site.xml $SPARK_HOME/conf

# For hive and spark sql integration, ? we can only do it at runtime since hostname is required in core-site.xml
RUN cp $HADOOP_PREFIX/etc/hadoop/core-site.xml $SPARK_HOME/conf
RUN echo spark.yarn.jar hdfs://hadoophost/spark/spark-assembly-1.6.0-hadoop2.6.0.jar > $SPARK_HOME/conf/spark-defaults.conf

# Download mysql jdbc driver and prepare hive metastore.
RUN curl -s -o $HIVE_HOME/lib/mysql-connector-java-5.1.41.jar http://central.maven.org/maven2/mysql/mysql-connector-java/5.1.41/mysql-connector-java-5.1.41.jar
# Make mysql driver available to kylo-spark-shell
RUN cp $HIVE_HOME/lib/mysql-connector-java-5.1.41.jar $SPARK_HOME/lib
#TODO check this at runtime
RUN echo "spark.executor.extraClassPath $SPARK_HOME/lib/mysql-connector-java-5.1.41.jar" >> $SPARK_HOME/conf/spark-defaults.conf
RUN echo "spark.driver.extraClassPath $SPARK_HOME/lib/mysql-connector-java-5.1.41.jar" >> $SPARK_HOME/conf/spark-defaults.conf

#------------
#configure kylo/nifi integration
#this part follows install-kylo-components.sh script
RUN echo -e "\n\n# Set kylo nifi configuration file directory path" >> $NIFI_INSTALL_HOME/current/conf/bootstrap.conf
RUN echo -e "java.arg.15=-Dkylo.nifi.configPath=$NIFI_INSTALL_HOME/ext-config" >> $NIFI_INSTALL_HOME/current/conf/bootstrap.conf

RUN echo "Installing the kylo libraries to the NiFi lib"
RUN mkdir $NIFI_INSTALL_HOME/current/lib/app
#$NIFI_INSTALL_HOME/data/lib is shared with Kylo img
RUN mkdir -p $NIFI_INSTALL_HOME/data/lib/app

RUN echo "Script for linking kylo jars to nifi libs, $NIFI_INSTALL_HOME"
COPY conf/create-symbolic-links.sh $NIFI_INSTALL_HOME
RUN chmod u+x $NIFI_INSTALL_HOME/create-symbolic-links.sh

# Download mysql jdbc driver and prepare hive metastore.
RUN mkdir -p /opt/nifi/mysql
RUN curl -s -o /opt/nifi/mysql/mysql-connector-java-5.1.41.jar http://central.maven.org/maven2/mysql/mysql-connector-java/5.1.41/mysql-connector-java-5.1.41.jar
RUN curl -s -o /opt/nifi/mysql/mariadb-java-client-1.5.7.jar https://downloads.mariadb.com/Connectors/java/connector-java-1.5.7/mariadb-java-client-1.5.7.jar

RUN echo "Copy the activeMQ required jars for the JMS processors to $NIFI_INSTALL_HOME/activemq"
RUN mkdir $NIFI_INSTALL_HOME/activemq
COPY activemq/*.jar $NIFI_INSTALL_HOME/activemq/

RUN echo "setting up temporary database in case JMS goes down"
RUN mkdir $NIFI_INSTALL_HOME/h2
RUN mkdir $NIFI_INSTALL_HOME/ext-config

COPY conf/config.properties $NIFI_INSTALL_HOME/ext-config
RUN chown -R $NIFI_USER:$NIFI_GROUP $NIFI_INSTALL_HOME

RUN echo "Creating flow file cache directory"
RUN mkdir $NIFI_INSTALL_HOME/feed_flowfile_cache/
RUN chown $NIFI_USER:$NIFI_GROUP $NIFI_INSTALL_HOME/feed_flowfile_cache/

RUN mkdir /var/log/nifi && \
    chown $NIFI_USER:$NIFI_GROUP /var/log/nifi

RUN echo "Creating the dropzone folder" && mkdir -p /var/dropzone
RUN chown nifi:nifi /var/dropzone
RUN chmod 774 /var/dropzone/

#sample data to run after kylo start
COPY sample_data/* /var/sampledata/
RUN chown -R nifi:nifi /var/sampledata

RUN groupadd supergroup
RUN usermod -a -G supergroup nifi

COPY scripts/nifi_bootstrap.sh /etc/nifi_bootstrap.sh
RUN chown root.root /etc/nifi_bootstrap.sh && \
    chmod u+x /etc/nifi_bootstrap.sh

ENTRYPOINT ["/etc/nifi_bootstrap.sh"]

# expose NiFi UI
EXPOSE 8079
