SHELL += -eu

AWS_REGION ?= us-west-1
COREOS_CHANNEL ?= beta
COREOS_VM_TYPE ?= hvm

CONTEXT_NAME ?= $(or $(shell cat .context 2>/dev/null),default)
CLUSTER_NAME ?= $(CONTEXT_NAME)
AWS_EC2_KEY_NAME ?= k8s-$(CLUSTER_NAME)

DIR_CONTEXT := contexts/${CONTEXT_NAME}
DIR_KEY_PAIR := ${DIR_CONTEXT}/.keypair
DIR_CFSSL := ${DIR_CONTEXT}/.cfssl

# pull in any environment overrides
include ${DIR_CONTEXT}/env.mk

.PHONY: tt
tt:
	echo CLUSTER_NAME = ${CLUSTER_NAME}
	echo AWS_EC2_KEY_NAME = ${AWS_EC2_KEY_NAME}

CONTEXTS=default \
         test \

CONTEXT_TARGET=$(CONTEXTS:%=%-context)

## set currently selected context
$(CONTEXT_TARGET): %-context: contexts/%
	@echo $(@:%-context=%) > .context
	@if [ -a contexts/$(@:%-context=%)/tmp/kubeconfig ] ; then source contexts/$(@:%-context=%)/tmp/kubeconfig ; fi;

CONTEXT_DIR=$(CONTEXTS:%=contexts/%)
$(CONTEXT_DIR):
	mkdir -p $@
	cp contexts/_env.mk.template $@/env.mk
	cp contexts/_io.tf.template $@/io.tf
	cp contexts/_modules.tf.template $@/modules.tf

## get the currently selected context
get-context:
	@echo "${CONTEXT_NAME}"

.PHONY: $(CONTEXT_TARGET) get-context

## generate key-pair, variables and then `terraform apply`
all: prereqs create-keypair ssl init apply

rm:
	rm     ${DIR_CONTEXT}/terraform.{tfvars,tfplan} ||:
	rm -rf ${DIR_CONTEXT}/.terraform ||:
	rm -rf ${DIR_CONTEXT}/.cfssl ||:
	rm -rf ${DIR_CONTEXT}/tmp ||:

## destroy and remove everything
clean: destroy delete-keypair rm

${DIR_CFSSL}:
	./scripts/init-cfssl ${DIR_CFSSL} ${AWS_REGION}

.PHONY: module.%
module.%: get init
	${TERRAFORM_CMD} plan -target $@
	${TERRAFORM_CMD} apply -target $@

## print version of each prerequisite
prereqs:
	aws --version
	cfssl version
	jq --version
	which kubectl
	terraform --version

## ssh into bastion host
ssh: ; @ssh -A core@`${TERRAFORM_CMD} output bastion-ip`

## create tls artifacts
ssl: ${DIR_CFSSL}

## smoke it
test: test-ssl test-route53 test-etcd

include makefiles/*.mk

.DEFAULT_GOAL := help
.PHONY: all clean rm prereqs ssh ssl test
