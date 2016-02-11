SHELL += -eu

AWS_REGION := us-west-1
COREOS_CHANNEL := stable
COREOS_VM_TYPE := hvm

AWS_EC2_KEY_NAME := k8s-testing
DIR_KEY_PAIR := .ec2-key-pair

.terraform: ; terraform get

_generated.tf:
	./scripts/generate-variables.sh \
		${AWS_REGION} ${COREOS_CHANNEL} ${COREOS_VM_TYPE} ${AWS_EC2_KEY_NAME} \
		> _generated.tf

all: create-key-pair generate apply ## generate key-pair, variables and then `terraform apply`

apply: plan ## `terraform apply`
	terraform apply

clean: destroy delete-key-pair
	rm _generated.tf ||:
	rm -rf .terraform ||:

destroy: ## `terraform destroy`
	terraform destroy

generate: _generated.tf ## generate variables

get: ## `terraform get`
	terraform get

## Display this help text
help:
	$(info Available targets)
	@awk '/^[a-zA-Z\-\_0-9]+:/ {                    \
		nb = sub( /^## /, "", helpMsg );              \
		if(nb == 0) {                                 \
			helpMsg = $$0;                              \
			nb = sub( /^[^:]*:.* ## /, "", helpMsg );   \
		}                                             \
		if (nb)                                       \
			print  $$1 "\t" helpMsg;                    \
	}                                               \
	{ helpMsg = $$0 }'                              \
	$(MAKEFILE_LIST) | column -ts $$'\t' |          \
	grep --color '^[^ ]*'

plan: get generate ## terraform plan
	terraform plan -out terraform.tfplan

show: ## terraform show
	terraform show

include makefiles/*.mk

.DEFAULT_GOAL := help
.PHONY: all apply clean destroy generate get help plan show
