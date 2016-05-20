PREFIX := kz8s
IMAGE := example-dns-server
TAG := latest

all: build test

build: ; @docker build --no-cache --tag ${PREFIX}/${IMAGE}:${TAG} .

clean: ; @docker rmi --force ${PREFIX}/${NAME}:${TAG}

kill: ; @docker kill ${IMAGE}

run:
	@docker run --detach --name ${IMAGE} --publish 8080:8080  \
		${PREFIX}/${IMAGE}:${TAG}

test:
	@./test-docker.sh

.PHONY: all build clean test
