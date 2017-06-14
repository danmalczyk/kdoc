#!/bin/bash

source config.sh

for MODULE in "${MODULES[@]}" ; do
    echo "Cleaning jars in ${MODULE}"
    if [ "${MODULE}" = "services" ] ; then
        rm -rf ${KYLO_HOME}/kylo-service/lib/kylo-service*.jar

    elif [ "${MODULE}" = "ui" ] ; then
        rm -rf ${KYLO_HOME}/kylo-ui/lib/kylo-ui-app-*.jar

    elif [ "${MODULE}" = "integrations" ] ; then
        rm -rf ${KYLO_HOME}/lib/kylo-nifi-hadoop-processors-*.jar
    else
        echo "Module not mapped to be copied to Docker img"
    fi

done