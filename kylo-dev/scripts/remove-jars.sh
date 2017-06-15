#!/bin/bash

source config.sh

for MODULE in "${MODULES[@]}" ; do
    echo "Cleaning jars in module ${MODULE}"
    if [ "${MODULE}" = "services" ] ; then
        rm -rf ${KYLO_HOME}/kylo-services/lib/kylo-*.jar

    elif [ "${MODULE}" = "ui" ] ; then
        rm -rf ${KYLO_HOME}/kylo-ui/lib/kylo-*.jar

    elif [ "${MODULE}" = "integrations" ] ; then
        rm -rf ${KYLO_HOME}/lib/kylo-*.jar
    else
        echo "Module ${MODULE} not mapped to be copied to Docker img"
    fi

done