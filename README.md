## Kylo Docker Layers and Services

The work is based on Keven Wang's Kylo in Docker: https://github.com/keven4ever/kylo_docker

This project aims to dockerize Kylo deployment from source so that the adjacent
services are in separate containers and Kylo container is built from NiFi container.
As a goal, Kylo image docker build from sources should be matter of seconds rather than minutes or more...

Each layer should contain only the necessary minimums of settings needed to run with Kylo.
Everything Kylo-related and not needed in deployment-time should be in Kylo layer.

https://docs.google.com/presentation/d/1s-uNcb0QwEIYUqmN_-c-QqVRTYM5_AxluYp9Nxy_iQk/edit#slide=id.g226f3b27bd_0_29

## CURRENT STATUS
The stack is working and tested by ingesting userdata2.csv to parquet

## HOW TO RUN
1. Change "vm.max_map_count" kernel varialble in the VM running docker daemon: https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#docker-cli-run-prod-mode.
So if you are using macbook with Docker for Mac installed (note, docker for mac https://docs.docker.com/docker-for-mac/install/ is different from previous generation of docker on mac which is Docker machine https://docs.docker.com/machine/), then you can follow steps below
```
# Launch a termal in your macbook and start a screen session to connect to the VM which is the host of docker containers
screen ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/tty
# Click "enter" once to get shell promot, then type in shell command "login"
/ # login
# input login credential, root/<empty password>
moby login: root
# Input empty pwd by click enter
# Set the parameter
moby:~#sysctl -w vm.max_map_count=262144
# Then you can check if this parameter is set:
moby:~# sysctl vm.max_map_count
# You should see sth like below
vm.max_map_count = 262144
# At the end exit the screen session by type in Ctrl-A + D to exist the screen session, Hold Ctrl and A together then click D.
```
2. Tune Docker instance
```
Increase memory dedicated for Docker (Preferences -> Advanced, currently 9G)
```
3. Login to Docker Hub
```
docker login -u dockerhub_username -p dockerhub_passwd
```
4. Download docker-compose.yml from danmalczyk/kdoc GitHub repo 
 
5. Init docker swarm and deploy Kylo stack
```
docker swarm init #first-time init, no need to reissue
docker stack deploy -c docker-compose.yml kylo_stack
```

6. First time docker pulls all the images (6 GiB) and starts the stack,
    it takes quite a long time ("docker events" will show the progress)
    further boots are just service starts)

7. Open Kylo from browser at localhost:8400 ("docker ps" must show 4 running containers, Kylo takes up to 15mins to start)

When building Kylo image from Dockerfile-kylo, copy or link Kylo RPM to ./kylo_rpm/kylo.rpm
(not included, download from http://bit.ly/2r4P47A or mvn build from source )

## TODO

```
docker-compose.yml:
change/parametrize MYSQL_ROOT_PASSWORD,
externalize mariadb data directory volume
```
```
externalize kylo and nifi volumes with user data (maybe elasticsearch too?)
use kylo-ui and kylo-services wars and jars from maven build instead of kylo.rpm or kylo.tar
modify maven builds to be able to rebuild and redeploy just changed modules
make Kylo jars thinner, i.e. change jars and wars dependencies so that external framework libs (Spring) etc are in the image before Kylo jars
separate Hadoop services to another container
tune Elasticsearch
```
