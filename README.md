## Kylo Docker Layers and Services
## KDOC v2 splits installation scripts into separate images and requires linking Dockerfiles with Kylo repo

```
cd [kylo_root_dir]
ln -s [kdoc_root_dir]/kylo/Dockerfile
ln -s [kdoc_root_dir]/kylo/dockerstack_conf/
```
(This is a temporary setting. In the future, Dockerfile and config should be integral part of Kylo)

The work is based on Keven Wang's Kylo in Docker: https://github.com/keven4ever/kylo_docker

This project aims to dockerize Kylo deployment from source so that the adjacent
services are in separate containers and Kylo container is built from NiFi container.
As a goal, Kylo image docker build from sources should be matter of seconds rather than minutes or more...

Each layer should contain only the necessary minimums of settings needed to run with Kylo.
Everything Kylo-related and not needed in deployment-time should be in Kylo layer.

https://docs.google.com/presentation/d/1juClfDMePmRcdonlK6k4fmc5QAw3D9bvWAmDyemqe7c/edit#slide=id.g22f3240589_1_10
## CURRENT STATUS
The stack is working and tested by ingesting userdata2.csv to parquet

## HOW TO RUN - tasks 1 - 5 are just first-time settings
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
 
5. Init docker swarm
```
docker swarm init #first-time init, no need to reissue
```

6. Deploy Kylo stack
```
docker stack deploy -c docker-compose.yml kylo_stack
```

7. First time docker pulls all the images (6 GiB) and starts the stack,
    it takes quite a long time ("docker events" will show the progress)
    further boots are just service starts)

8. Open Kylo from browser at localhost:8400 ("docker ps" must show 4 running containers, Kylo takes up to 15mins to start)

## DEVELOPER HOW-TO RUN BY CLAUDIU
### Start swarm - one time init
```
docker swarm init
```

### Download kylo.rpm (or build from source and link Kylo RPM to ./kylo_rpm/kylo.rpm)
```
mkdir kylo_rpm
curl -o ./kylo_rpm/kylo.rpm -L http://bit.ly/2r4P47A
```

## Build/Start/Stop everything

### Fetch images
Fetch elasticsearch, activemq, mysql from dockerhub

```
make fetch
```

### Build images
```
make build
```

### Build kylo dev image
Builds a kylo image with the latest kylo src. Check [kylo dev readme](kylo-dev/README.md)

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
Runs a stack with the latest kylo src. Check [kylo dev readme](kylo-dev/README.md)

```
make start-dev

# wait up to 15min and open http://localhost:8400
```

### Stop stack
```
make stop
# alternatively docker stack rm kylo_stack
```

## TODO
- docker images should be ran with unpriviledged user (kylo/nifi)
- add feed templates to the kylo prd image
- docker-compose.yml:
    - change/parametrize MYSQL_ROOT_PASSWORD
- externalize mariadb data directory volume
- externalize kylo and nifi volumes with user data (maybe elasticsearch too?)
- make Kylo jars thinner, i.e. change jars and wars dependencies so that external framework libs (Spring) etc are in the image before Kylo jars (is this still useful since the kylo dev image only takes the kylo jars ?)
- separate Hadoop services to another container
- tune Elasticsearch
