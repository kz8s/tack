SHELL += -eu

BLUE := \033[0;34m
GREEN := \033[0;32m
RED := \033[0;31m
NC := \033[0m


AWS_REGION ?= us-east-1
COREOS_CHANNEL ?= stable
COREOS_VM_TYPE ?= hvm

CLUSTER_NAME ?= testing
AWS_EC2_KEY_NAME ?= k8s-$(CLUSTER_NAME)

INTERNAL_TLD := ${CLUSTER_NAME}.k8s

DIR_KEY_PAIR := .keypair
DIR_SSL := .cfssl

## generate key-pair, variables and then `terraform apply`
all: prereqs create-keypair ssl init apply
	@echo "${GREEN}✓ terraform portion of 'make all' has completed${NC}"
	@echo "${BLUE}❤ commence initializing addons ${NC}" && ./scripts/init-addons

## destroy and remove everything
clean: destroy delete-keypair
	pkill -f "kubectl proxy" ||:
	rm -rf .addons ||:
	rm terraform.{tfvars,tfplan} ||:
	rm -rf .terraform ||:
	rm -rf tmp ||:
	rm -rf ${DIR_SSL} ||:

.cfssl: ; ./scripts/init-cfssl ${DIR_SSL} ${AWS_REGION} ${INTERNAL_TLD}

## start proxy and open kubernetes dashboard
dashboard: ; ./scripts/dashboard

## journalctl on etcd1
journal: ; @ssh -At core@`terraform output bastion-ip` ssh `terraform output etcd1-ip` journalctl -fl

prereqs:
	aws --version
	@echo
	cfssl version
	@echo
	jq --version
	@echo
	kubectl version --client
	@echo
	terraform --version

## ssh into etcd1
ssh: ; @ssh -A -t core@`terraform output bastion-ip` ssh `terraform output etcd1-ip`

## ssh into bastion host
ssh-bastion: ; @ssh -A core@`terraform output bastion-ip`

## create tls artifacts
ssl: .cfssl

## smoke it
test: test-ssl test-route53 test-etcd pods dns

include makefiles/*.mk

.DEFAULT_GOAL := help
.PHONY: all clean journal prereqs ssh ssh-bastion ssl test tt
