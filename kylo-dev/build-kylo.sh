#!/bin/bash

DIR_PATH="`( cd \"$MY_PATH\" && pwd )`"
echo "shell path =${DIR_PATH}"

source ${DIR_PATH}/scripts/config.sh

echo CLONE_URL=${CLONE_URL}
echo BRANCH=${BRANCH}

# skip install by default as we don't need the rpm/tarballs
if [ -z "${MODULES}" ] ; then
    MODULES=!install
    BUILD_ALL=true
fi
echo MODULES=${MODULES}

if [ -z "${KYLO_DIR}" ] ; then
    KYLO_DIR=${DIR_PATH}/kylo
fi
echo KYLO_DIR=${KYLO_DIR}

if [ -n "${CLONE_URL}" ] ; then
    echo "Cloning ${CLONE_URL} into ${KYLO_DIR}"
    git clone ${CLONE_URL} ${KYLO_DIR}
    if [ -n "${BRANCH}" ] ; then
        git checkout ${BRANCH}
    fi
fi

cd ${KYLO_DIR}
export MAVEN_OPTS="-Xms2g -Xmx4g"

KYLO_JARS_BASE=${DIR_PATH}/kylo-jars
rm -rf KYLO_JARS_BASE
mkdir KYLO_JARS_BASE

if [ "${BUILD_ALL}" = true ] ; then
    mvn install -pl "${MODULES}" -am -DskipTests
    # TODO copy everything ?! or compile rpm and run rpm
else
    for MODULE in "${MODULES[@]}"
    do
        cd ${MODULE}
        mvn install -DskipTests
        if [ "${MODULE}" = "services" ] ; then
            KYLO_JARS=${KYLO_JARS_BASE}/${MODULE}/lib
            mkdir -p ${KYLO_JARS}
            # if it's not sufficient, copy the kylo-*.jars from tarball with dependencies
            cp "${KYLO_DIR}"/services/service-app/target/kylo-service*.jar "${KYLO_JARS}"

        elif [ "${MODULE}" = "ui" ] ; then
            KYLO_JARS=${KYLO_JARS_BASE}/${MODULE}/lib
            mkdir -p ${KYLO_JARS}
            # if it's not sufficient, copy the kylo-*.jars from tarball with dependencies
            cp "${KYLO_DIR}"/ui/ui-app/target/kylo-ui-app-*.jar "${KYLO_JARS}"

        elif [ "${MODULE}" = "integrations" ] ; then
            KYLO_JARS=${KYLO_JARS_BASE}/${MODULE}/lib
            mkdir -p ${KYLO_JARS}
            # if it's not sufficient, copy the kylo-*.jars from tarball with dependencies
            cp "${KYLO_DIR}"/integrations/nifi-nar-bundles/nifi-hadoop-bundle/nifi-hadoop-processors/target/kylo-nifi-hadoop-processors-*.jar ""${KYLO_JARS}""
        else
            echo "Module not mapped to be copied to Docker img"
        fi
        cd -
    done
fi