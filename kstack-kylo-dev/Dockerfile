# ThinkBig Analytics, a Teradata Company

FROM dmalczyk/kylo:latest

ARG MODULES

COPY scripts/ .

RUN remove-jars.sh

# Updating kylo-services
COPY kylo-jars/ ${KYLO_HOME}/