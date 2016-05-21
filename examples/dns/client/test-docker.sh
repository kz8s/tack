#!/bin/bash -eu

PREFIX=kz8s
IMAGE=example-dns-client
TAG=latest

DOCKER_IP=$(echo $DOCKER_HOST | awk -F'[/:]' '{print $4}')
: ${DOCKER_IP:=$(ifconfig docker0 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*')}
echo "✓ Docker Host IP: $DOCKER_IP"

echo "✓ Hit google"
docker run --rm ${PREFIX}/${IMAGE}:${TAG} "http://google.com"

echo "✓ Done"
