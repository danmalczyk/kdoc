# Daniel Malczyk
# ThinkBig Analytics, a Teradata Company

#starting from NiFi image
FROM dmalczyk/kstack-nifi:latest

MAINTAINER Daniel Malczyk <dmalczyk@gmail.com>

# install dev tools
RUN yum clean all; \
    rpm --rebuilddb; \
    yum install -y mysql; \
    yum clean all

#TODO install hadoop, spark and Hive clients
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
RUN cp /usr/local/hadoop/etc/hadoop/hdfs-site.xml /usr/local/spark/conf
RUN cp /usr/local/hive/conf/hive-site.xml /usr/local/spark/conf

#------------

# add spark and hadoop path to PATH env variable for kylo user
RUN echo "export PATH=$PATH:/usr/java/default/bin:/usr/local/spark/bin:/usr/local/hadoop/bin" >> /etc/profile


#add kylo user
RUN /bin/bash -c 'useradd -r -m -s /bin/bash kylo;'

#download and install Kylo rpm
#RUN curl -o /tmp/kylo.rpm -L http://bit.ly/2r4P47A && rpm -ivh /tmp/kylo.rpm && rm /tmp/kylo.rpm
#COPY kylo_rpm/kylo0.8.1.rpm /tmp/kylo.rpm
COPY kylo_rpm/kylo.rpm /tmp/kylo.rpm
RUN rpm -ivh /tmp/kylo.rpm && rm /tmp/kylo.rpm

#install Kylo components to NiFi (and possibly start NiFi service)
ENV KYLO_INSTALL_NIFI_SUPPRESS_START "YES"
RUN echo "Install Kylo components to NiFi" && \
    /opt/kylo/setup/nifi/install-kylo-components.sh /opt/nifi /opt/kylo nifi nifi /opt/kylo/setup -o

RUN echo "Creating the dropzone folder" && mkdir -p /var/dropzone
RUN chown nifi:nifi /var/dropzone
RUN chmod 774 /var/dropzone/

#sample data to run after kylo start
COPY sample_data/* /var/sampledata/
RUN chown -R kylo:kylo /var/sampledata

#setup kylo
ENV KYLO_HOME=/opt/kylo
ENV PATH $PATH:$KYLO_HOME
COPY conf/application.properties /opt/kylo/kylo-services/conf/
COPY conf/config.properties /opt/nifi/ext-config/
COPY conf/spark.properties /opt/kylo/kylo-services/conf

# Align the same security.jwt.key as kylo-ui which is generated in kylo post-installation
RUN jwtkey=$(grep 'security.jwt.key' /opt/kylo/kylo-ui/conf/application.properties | awk -F  "=" '/1/ {print $2}') && sed -i "s/security\.jwt\.key=<insert-256-bit-secret-key-here>/security\.jwt\.key=${jwtkey}/" /opt/kylo/kylo-services/conf/application.properties
RUN echo "Kylo Installation complete"

# Download mysql jdbc driver and prepare hive metastore.
RUN curl -s -o /usr/local/apache-hive-2.1.1-bin/lib/mysql-connector-java-5.1.41.jar http://central.maven.org/maven2/mysql/mysql-connector-java/5.1.41/mysql-connector-java-5.1.41.jar
# Make mysql driver available to kylo-spark-shell
RUN cp /usr/local/hive/lib/mysql-connector-java-5.1.41.jar /opt/nifi/mysql/
RUN cp /opt/kylo/kylo-services/lib/mariadb-java-client-1.5.7.jar /opt/nifi/mysql/
RUN cp /usr/local/hive/lib/mysql-connector-java-5.1.41.jar /usr/local/spark/lib

# add spark and hadoop path to PATH env variable for kylo user
RUN echo "export PATH=$PATH:/usr/local/spark/bin:/usr/local/hadoop/bin" >> /etc/profile

# Add kylo and nifi user to supergroup otherwise kylo-spark-shell service which runs as kylo user will not be able to create database in hive.
RUN groupadd supergroup
RUN usermod -a -G supergroup kylo
RUN usermod -a -G supergroup nifi

# shared volume
RUN mkdir -p /var/share
VOLUME /var/share

COPY scripts/kylo_bootstrap.sh /etc/kylo_bootstrap.sh
RUN chown root.root /etc/kylo_bootstrap.sh
RUN chmod 700 /etc/kylo_bootstrap.sh

ENTRYPOINT ["/etc/kylo_bootstrap.sh"]

EXPOSE 8400
EXPOSE 8888
EXPOSE 8420
