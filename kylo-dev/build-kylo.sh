#!/bin/bash

export MAVEN_OPTS="-Xms2g -Xmx4g"

DIR_PATH="`( cd \"$MY_PATH\" && pwd )`"
echo "shell path =${DIR_PATH}"

source ${DIR_PATH}/scripts/config.sh

echo CLONE_URL=${CLONE_URL}
echo BRANCH=${BRANCH}

if [ -z "${KYLO_DIR}" ] ; then
    KYLO_DIR=${DIR_PATH}/kylo
fi
echo KYLO_DIR=${KYLO_DIR}

if [ -n "${CLONE_URL}" ] && [ ! -d "${KYLO_DIR}" ] ; then
    echo "Cloning ${CLONE_URL} into ${KYLO_DIR}"
    # Will fail if ${KYLO_DIR} non-empty, but still continue
    git clone ${CLONE_URL} ${KYLO_DIR}
    if [ -n "${BRANCH}" ] ; then
        cd ${KYLO_DIR}
        git checkout ${BRANCH}
    fi
    mvn install -pl '!install' -am -DskipTests
    cd -
fi

cd ${KYLO_DIR}

KYLO_JARS_BASE=${DIR_PATH}/kylo-jars
rm -rf ${KYLO_JARS_BASE}
mkdir -p ${KYLO_JARS_BASE}/lib

KYLO_JARS_TMP=/tmp/kylo-docker-jars
mkdir -p ${KYLO_JARS_TMP}

for MODULE in "${MODULES[@]}" ; do
    echo "Copying jars for module ${MODULE}"
    KYLO_JARS=${KYLO_JARS_BASE}/kylo-${MODULE}/lib

    if [ "${MODULE}" = "services" ] ; then
        mkdir -p ${KYLO_JARS}
        tar -xzf ${KYLO_DIR}/${MODULE}/service-app/target/kylo-*-distribution.tar.gz -C ${KYLO_JARS_TMP}
        mv "${KYLO_JARS_TMP}"/kylo-service-app*/lib/kylo-*.jar "${KYLO_JARS}"

    elif [ "${MODULE}" = "ui" ] ; then
        mkdir -p ${KYLO_JARS}
        tar -xzf ${KYLO_DIR}/${MODULE}/ui-app/target/kylo-*-distribution.tar.gz -C ${KYLO_JARS_TMP}
        mv "${KYLO_JARS_TMP}"/kylo-ui-app*/lib/kylo-*.jar "${KYLO_JARS}"

    elif [ "${MODULE}" = "integrations" ] ; then
        cp "${KYLO_DIR}"/${MODULE}/nifi/nifi-nar-bundles/nifi-hadoop-bundle/nifi-hadoop-processors/target/kylo-nifi-*.jar "${KYLO_JARS_BASE}/lib"

    else
        echo "Module not mapped to be copied to Docker img"
    fi
done

rm -rf ${KYLO_JARS_TMP}