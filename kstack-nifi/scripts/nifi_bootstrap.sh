#!/bin/bash
#this part needs to be run only after kylo put jars to the shared dir - maybe at runtime?
echo "Creating symbolic links to jar files"
/opt/nifi/create-symbolic-links.sh $NIFI_INSTALL_HOME $NIFI_USER $NIFI_GROUP

/opt/nifi/current/bin/nifi.sh start
#tail -f /var/log/nifi/nifi-app.log
CMD=${1:-"exit 0"}
if [[ "$CMD" == "-d" ]];
then
#        /usr/sbin/sshd -D -d
        tail -f /dev/null
else
        /bin/bash -c "$*"
fi
