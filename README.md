## Kylo Docker Layers and Services

The work is based on Keven Wang's Kylo in Docker: https://github.com/keven4ever/kylo_docker/tree/multi_container

This project aims to dockerize Kylo deployment from source so that the adjacent
services are in separate containers and Kylo container is built from NiFi container.
As a goal, Kylo image docker build from sources should be matter of seconds rather than minutes or more...

Each layer should contain only the necessary minimums of settings needed to run with Kylo.
Everything Kylo-related and not needed in deployment-time should be in Kylo layer.

https://docs.google.com/presentation/d/1s-uNcb0QwEIYUqmN_-c-QqVRTYM5_AxluYp9Nxy_iQk/edit#slide=id.g226f3b27bd_0_29

## CURRENT STATUS
The containers are ready but the Kylo image doesn't boot properly.

```
docker swarm init
docker stack deploy -c docker-compose.yml kylo_stack
```

## TODO
have working stack (localhost:8400 -> Kylo login -> ingest sampledata)
```
docker-compose.yml:
change/parametrize MYSQL_ROOT_PASSWORD,
set resource limits (memory, cpu),
externalize mariadb data directory volume
```
```
externalizing volumes with the data
using kylo-ui and kylo-services wars and jars instead of kylo.rpm or kylo.tar
