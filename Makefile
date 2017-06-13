
# Versions
ELASTICSEARCH_VERSION := 5.4.1
ACTIVEMQ_VERSION := 5.13.3
MARIADB_VERSION := 10.0

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
	@docker build -f Dockerfile-nifi -t dmalczyk/kylo-nifi .
	@docker build -f Dockerfile-hadoop -t dmalczyk/kylo-hadoop .
	@docker build -f Dockerfile-kylo -t dmalczyk/kylo .
	@echo "Build finished"

.PHONY: start
start:
	@echo "Starting stack kylo_stack ..."
	@docker stack deploy -c docker-compose.yml kylo_stack
	@echo "Started stack"

.PHONY: stop
stop:
	@echo "Stoping stack ..."
	@docker stack rm kylo_stack
	@echo "Stoped stack"