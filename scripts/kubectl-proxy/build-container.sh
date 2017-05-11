#!/usr/bin/env bash

docker build -t $1/kubectl-proxy:1.6.2 -t $1/kubectl-proxy:latest $(dirname "$0")
docker push $1/kubectl-proxy:1.6.2
docker push $1/kubectl-proxy:latest
