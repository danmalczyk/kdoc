# Kylo Docker Layers and Services
# Daniel Malczyk, dmalczyk@gmail.com

The work is based on Keven Wang's Kylo in Docker: https://github.com/keven4ever/kylo_docker/tree/multi_container

This project aims to dockerize Kylo deployment from source so that the adjacent
services are in separate containers and Kylo container is built from NiFi container.
As a goal, Kylo image docker build from sources should be matter of seconds rather than minutes or more...

Each layer should contain only the necessary minimums of settings needed to run with Kylo.
Everything Kylo-related and not needed in deployment-time should be in Kylo layer.

https://docs.google.com/document/d/1nWLF5cOm2nEC-y-LmOK4AcdtNRfTNRcgB9CcGxPbU74/edit

So far, the NiFi layer is ready:

docker build -t "kylo_nifi:latest" -f Dockerfile-nifi .
docker run -d -p8079:8079 --name kylo_nifi kylo_nifi:latest
docker stack deploy -c docker-compose.yml kylo_stack