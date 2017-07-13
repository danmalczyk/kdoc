## Kylo Docker Layers and Services


## CURRENT STATUS
This is an experimental Kylo deployment, not officially supported.
Tested on ingesting userdata2.csv via standard ingest.
Hadoop namenode, hive server and spark master are in separate container now.
Nifi and Kylo are in separate containers now.
Both kylo and nifi images are based on common "hadoopclient" image.
Version 3.5 is updated and build from github sources on 20170713 (ver. 0.8.2. official release day) 

## REMOVE SHARED DOCKER VOLUME BEFORE RUNNING A NEW VERSION
```
docker volume rm kstack_nifilib
```

## OVERVIEW
The work is based on Keven Wang's Kylo in Docker: https://github.com/keven4ever/kylo_docker

This project aims to dockerize Kylo deployment from source so that the adjacent
services are in separate containers and Kylo container is built from NiFi container.
As a goal, Kylo image docker build from sources should be matter of seconds rather than minutes or more...

Each layer should contain only the necessary minimums of settings needed to run with Kylo.

Containers schema:

https://docs.google.com/presentation/d/1juClfDMePmRcdonlK6k4fmc5QAw3D9bvWAmDyemqe7c/edit#slide=id.g22f3240589_1_20

Current status is as per slide above (separate containers for hadoop services and for NiFi)

## HOW TO RUN - tasks 1 - 6 are just first-time settings
1. Change "vm.max_map_count" kernel varialble in the VM running docker daemon: https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#docker-cli-run-prod-mode.
So if you are using macbook with Docker for Mac installed (note, docker for mac https://docs.docker.com/docker-for-mac/install/ is different from previous generation of docker on mac which is Docker machine https://docs.docker.com/machine/), then you can follow steps below
```
# Launch a terminal in your macbook and start a screen session to connect to the VM which is the host of docker containers
screen ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/tty
# Click "enter" once to get shell prompt, then type in shell command "login"
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
4. * download docker-compose_3_5.yml from danmalczyk/kdoc GitHub repo
   * in the directory where docker-compose_3_5.yml is, create shared mountpoint for Kylo container:
```
wget https://github.com/danmalczyk/kdoc/blob/master/docker-compose_3_5.yml
mkdir -p ./kylo-stack-mountpoints/kyloshare
```

5. * download Makefile from danmalczyk/kdoc GitHub repo and run a task to download all the images needed:
```
wget https://github.com/danmalczyk/kdoc/blob/master/Makefile
make fetch-stable
```

   * __OR__ *pull all the Kylo Stack images manually*
```
docker pull docker.elastic.co/elasticsearch/elasticsearch:5.4.1
docker pull rmohr/activemq:5.13.3
docker pull mariadb:10.0
docker pull dmalczyk/kstack-hadoopservice:3.5
docker pull dmalczyk/kstack-nifi:3.5
docker pull dmalczyk/kstack-kylo:3.5
```
6. Init docker swarm
```
docker swarm init #first-time init, no need to reissue
```

7. Deploy Kylo stack
```
docker stack deploy -c docker-compose_3_5.yml kstack
```

8. Open Kylo from browser at localhost:8400 ("docker ps" must show 6 running containers, Kylo takes up to 15mins to start)

9. For testing, use kylo template ./kstack-nifi/sample_data/data_ingest.zip , as the URLs must be changed according to the new hostnames, see below. Keep that in mind when creating/modifying further templates.

10. If anything goes wrong, remove stack, find the cause and start again from point 7.
```
docker stack ps --no-trunc kstack
docker stack rm kstack
```

## URL hostnames for stack services
remember to use service names instead of localhost when calling different services:
```
kylo - for Kylo UI, Kylo services and Kylo Spark shell
nifi - for NiFi
mariadb - for the DB
elasticsearch - for ElasticSearch
hadoopservice - for HDFS, Hive and Spark master.
```
---

## DEVELOPER HOW-TO

### Start swarm - one time init
```
docker swarm init
```

### Build from source and copy Kylo RPM to ./kstack-kylo/kylo_rpm/kylo.rpm), tested with v. 0.8.2

### Build kylo dev image
Builds a kylo image with the latest kylo src. Check [kylo dev readme](kstack-kylo-dev/README.md)

```
cd kylo-dev
make
cd -
```

### Start stack
Don't forget to fetch and build the images before starting.

```
make start

# wait up to 15min and open http://localhost:8400
```

### Start dev stack
Runs a stack with the latest kylo src. Check [kylo dev readme](kstack-kylo-dev/README.md)

```
make start-dev

# wait up to 15min and open http://localhost:8400
```

### Stop stack
```
make stop
# alternatively docker stack rm kstack
```

### Notes
- in some image build situations, security jwt key is not copied from kylo-ui to kylo-services, in that case use --no-cache when building kstack-kylo image

---

## TODO
- docker images should be ran with unpriviledged user (kylo/nifi)
- add feed templates to the kylo prod image
- run spark in yarn-cluster mode
- docker-compose.yml:
    - change/parametrize MYSQL_ROOT_PASSWORD
- externalize mariadb data directory volume? externalize kylo and nifi volumes with user data? (maybe elasticsearch too?)
- tune Elasticsearch
- tune hadoop cluster
- automate builds from Kylo GIT repo
