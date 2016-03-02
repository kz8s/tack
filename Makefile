SHELL += -eu

AWS_REGION := us-west-1
COREOS_CHANNEL := alpha
COREOS_VM_TYPE := hvm

AWS_EC2_KEY_NAME := k8s-testing

DIR_KEY_PAIR := .key-pair
DIR_SSL := .ssl

## generate key-pair, variables and then `terraform apply`
all: create-key-pair ssl init apply

## destroy and remove everything
clean: destroy delete-key-pair
	rm terraform.{tfvars,tfplan} ||:
	rm -rf .terraform ||:
	rm -rf tmp ||:
	rm -rf .cfssl ||:

.cfssl:
	./scripts/init-cfssl .cfssl

.PHONY: module.%
module.%: get init
	terraform plan -target $@
	terraform apply -target $@

prereqs: ; aws --version && cfssl version && jq --version && terraform --version

## ssh into bastion host
ssh: ; @ssh -A core@`terraform output bastion-ip`

## create tls artifacts
ssl: .cfssl

## smoke it
test: test-ssl test-route53 test-etcd

include makefiles/*.mk

.DEFAULT_GOAL := help
.PHONY: all clean prereqs sl test
