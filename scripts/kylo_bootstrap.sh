#!/bin/bash

/etc/hadoop_bootstrap.sh

#echo "Sleeping 120s (waiting for the stack to stabilize)..."
#sleep 120

echo "Starting NiFi"
/opt/nifi/current/bin/nifi.sh start

#setup Kylo database, service mariadb
echo "Setup Kylo database in MySQL"
/opt/kylo/setup/sql/mysql/setup-mysql.sh mariadb root hadoop

# sleep 240 sec to make sure nifi is ready
echo "Sleeping 30s (waiting for NiFi)..."
sleep 30
echo "Starting kylo apps"
#/opt/kylo/start-kylo-apps.sh
/opt/kylo/kylo-ui/bin/run-kylo-ui.sh start
/opt/kylo/kylo-services/bin/run-kylo-services.sh start
/opt/kylo/kylo-services/bin/run-kylo-spark-shell.sh start

cp -r /var/sampledata/* /var/dropzone/


CMD=${1:-"exit 0"}
if [[ "$CMD" == "-d" ]];
then
#	service sshd stop
	/usr/sbin/sshd -p22 -D -d
else
	/bin/bash -c "$*"
fi