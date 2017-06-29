
# Versions
ELASTICSEARCH_VERSION := 5.4.1
ACTIVEMQ_VERSION := 5.13.3
MARIADB_VERSION := 10.0

.PHONY: all
all: fetch build start

.PHONY: fetch
fetch:
	@echo "Fetching images ..."
	@docker pull docker.elastic.co/elasticsearch/elasticsearch:$(ELASTICSEARCH_VERSION)
	@docker pull rmohr/activemq:$(ACTIVEMQ_VERSION)
	@docker pull mariadb:$(MARIADB_VERSION)
	@echo "Fetch finished"

.PHONY: build
build:
	@echo "Building images ..."
	@docker build -t dmalczyk/kstack-nifi:2.0 ./kstack-nifi
	@docker build -t dmalczyk/kstack-hadoophost:2.0 ./kstack-hadoophost
	@docker build -t dmalczyk/kstack-kylo:2.0 ./kstack-kylo
	@echo "Build finished"

.PHONY: start
start:
	@echo "Starting stack kylo_stack ..."
	@docker stack deploy -c docker-compose_2_0.yml kylo_stack
	@echo "Started stack"

.PHONY: start-dev
start-dev:
	@echo "Starting stack kylo_stack ..."
	@docker stack deploy -c docker-compose_2_0-dev.yml kylo_stack
	@echo "Started stack"

.PHONY: stop
stop:
	@echo "Stoping stack ..."
	@docker stack rm kylo_stack
	@echo "Stoped stack"