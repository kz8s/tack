SHELL += -eu

AWS_REGION ?= us-west-1
COREOS_CHANNEL ?= stable
COREOS_VM_TYPE ?= hvm

CLUSTER_NAME ?= testing
AWS_EC2_KEY_NAME ?= k8s-$(CLUSTER_NAME)

DIR_KEY_PAIR := .keypair
DIR_SSL := .ssl

USE_NAMED_INTERNAL_TLD := true

export INTERNAL_TLD ?= k8s

ifeq (${USE_NAMED_INTERNAL_TLD}, true)
  export INTERNAL_TLD := ${CLUSTER_NAME}.k8s
endif 

tt:
	@echo CLUSTER_NAME = ${CLUSTER_NAME}
	@echo AWS_EC2_KEY_NAME = ${AWS_EC2_KEY_NAME}

## generate key-pair, variables and then `terraform apply`
all: prereqs create-keypair ssl init apply
	@printf "\nInitializing add-ons\n" && ./scripts/init-addons

## destroy and remove everything
clean: destroy delete-keypair
	pkill -f "kubectl proxy" ||:
	rm terraform.{tfvars,tfplan} ||:
	rm -rf .terraform ||:
	rm -rf tmp ||:
	rm -rf .cfssl ||:

.cfssl: ; ./scripts/init-cfssl .cfssl ${AWS_REGION}

## start proxy and open kubernetes dashboard
dashboard: ; ./scripts/dashboard

## journalctl on etcd1 (10.0.0.10)
journal: ; @ssh -At core@`terraform output bastion-ip` ssh 10.0.0.10 journalctl -fl

module.%: get init
	terraform plan -target $@
	terraform apply -target $@

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

## ssh into etcd1 (10.0.0.10)
ssh: ; @ssh -A -t core@`terraform output bastion-ip` ssh 10.0.0.10

## ssh into bastion host
ssh-bastion: ; @ssh -A core@`terraform output bastion-ip`

## create tls artifacts
ssl: .cfssl

## smoke it
test: test-ssl test-route53 test-etcd pods dns

include makefiles/*.mk

.DEFAULT_GOAL := help
.PHONY: all clean journal module.% prereqs ssh ssh-bastion ssl test tt
