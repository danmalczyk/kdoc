include settings.mk

.PHONY: all
all: build

.PHONY: build
build:
	@echo "Building image dmalczyk/$(IMAGE_NAME) ..."
	./build-kylo.sh
	@docker build -t dmalczyk/$(IMAGE_NAME) . 
	@echo "Build finished"

.PHONY: clean
clean:
	rm -rf kylo