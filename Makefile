SHELL += -eu

AWS_REGION := us-west-1
COREOS_CHANNEL := alpha
COREOS_VM_TYPE := hvm

AWS_EC2_KEY_NAME := k8s-testing
DIR_KEY_PAIR := .ec2-key-pair

.terraform: ; terraform get

_generated.tf:
	./scripts/generate-variables.sh \
		${AWS_REGION} ${COREOS_CHANNEL} ${COREOS_VM_TYPE} ${AWS_EC2_KEY_NAME} \
		> _generated.tf

.PHONY: all
all: create-key-pair generate apply

.PHONY: apply
apply: ## `terraform apply` - will perform a `terraform plan` first
apply: plan ; terraform apply

.PHONY: clean
clean: delete-key-pair
	rm _generated.tf ||:
	rm -rf .terraform ||:

.PHONY: destroy
destroy: ## `terraform destroy` - will perform a `terraform plan` first
destroy: plan ; terraform destroy

.PHONY: generate
generate: ## generate `_generated.tf`
generate: _generated.tf

.PHONY: get
get: ## `terraform get`
get: .terraform

help: ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

.PHONY: plan
plan: get ; terraform plan

.PHONY: test
test: ; echo ${AWS_ACCOUNT_ID}

include makefiles/*.mk

.DEFAULT_GOAL := help
