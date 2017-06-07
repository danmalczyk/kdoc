#!/bin/bash

# sleep 30 sec to make sure nifi is ready
echo "Sleeping 30s..."
sleep 30s

echo "Starting kylo apps"
/opt/kylo/start-kylo-apps.sh

cp -r /var/sampledata/* /var/dropzone/


CMD=${1:-"exit 0"}
if [[ "$CMD" == "-d" ]];
then
	service sshd stop
	/usr/sbin/sshd -D -d
else
	/bin/bash -c "$*"
fi