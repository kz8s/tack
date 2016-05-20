PREFIX := kz8s
IMAGE := example-dns-client
TAG := latest

all: build test

build: ; @docker build --no-cache --tag ${PREFIX}/${IMAGE}:${TAG} .

clean: ; @docker rmi --force ${PREFIX}/${NAME}:${TAG}

kill: ; @docker kill ${IMAGE}

run:
	@docker run --rm ${PREFIX}/${IMAGE}:${TAG} "http://google.com"

test:
	@./test-docker.sh

.PHONY: all build clean test
