SHELL += -eu

AWS_REGION ?= us-west-1
COREOS_CHANNEL ?= stable
COREOS_VM_TYPE ?= hvm

CLUSTER_NAME ?= testing
AWS_EC2_KEY_NAME ?= k8s-$(CLUSTER_NAME)

DIR_KEY_PAIR := .keypair
DIR_SSL := .ssl

.PHONY: tt
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

## ssh into bastion host
ssh: ; @ssh -A core@`terraform output bastion-ip`

## create tls artifacts
ssl: .cfssl

## smoke it
test: test-ssl test-route53 test-etcd

include makefiles/*.mk

.DEFAULT_GOAL := help
.PHONY: all clean module.% prereqs ssl test
