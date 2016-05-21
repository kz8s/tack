#!/bin/bash -eu

PREFIX=kz8s
IMAGE=example-dns-server
TAG=latest

function cleanup {
  printf "\n✓ Kill and remove container named: %s\n" $IMAGE
  {
    docker kill ${IMAGE} ||:
    docker rm ${IMAGE} ||:
  } &> /dev/null
}
cleanup

DOCKER_IP=$(echo $DOCKER_HOST | awk -F'[/:]' '{print $4}')
: ${DOCKER_IP:=$(ifconfig docker0 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*')}
echo "✓ Docker Host IP: $DOCKER_IP"

echo "✓ Create container in detached mode:"
docker run --detach --publish 8080:8080 --name ${IMAGE} ${PREFIX}/${IMAGE}:${TAG}

#
trap cleanup EXIT

echo "✓ taking a short nap; before curl'ing '/ping'"
sleep 1
curl "${DOCKER_IP}:8080/ping?asdf=sdaf&asdf=9"

echo "✓ Done"
