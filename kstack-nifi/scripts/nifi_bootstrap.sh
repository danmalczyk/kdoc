#!/bin/bash
#this part needs to be run only after kylo put jars to the shared dir 
attempts=20
while [ $attempts -gt 0 ]
do
    echo "trying to link Kylo libs"
    echo "testing for kylo libs presence"
    KYLO_NARS_COUNT=$(ls -1 /opt/nifi/data/lib/kylo-nifi*.nar | wc -l)
    KYLO_JARS_COUNT=$(ls -1 /opt/nifi/data/lib/app/kylo-spark*.jar | wc -l)
    if [ $KYLO_NARS_COUNT -ge "8" ] && [ $KYLO_JARS_COUNT -ge "6" ] 
    then 
        break
    else
        echo "kylo libs not ready"
        ((attempts--))
        sleep 10
    fi
done

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
