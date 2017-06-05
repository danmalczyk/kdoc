#!/bin/bash
/opt/nifi/current/bin/nifi.sh start
tail -f /var/log/nifi/nifi-app.log
#CMD=${1:-"exit 0"}
#if [[ "$CMD" == "-d" ]];
#then
#        /usr/sbin/sshd -D -d
#else
#        /bin/bash -c "$*"
#fi
