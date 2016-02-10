SHELL += -eu

AWS_REGION := us-west-1
COREOS_CHANNEL := alpha
COREOS_VM_TYPE := hvm

AWS_EC2_KEY_NAME := k8s-testing
DIR_KEY_PAIR := .ec2-key-pair

.PHONY: all
all: test $(DIR_KEY_PAIR)/$(AWS_EC2_KEY_NAME).pem

.PHONY: clean
clean: delete-key-pair
	rm _generated.tf ||:

.PHONY: test
test: ; echo ${AWS_ACCOUNT_ID}

_generated.tf:
	./scripts/generate-variables.sh \
		${AWS_REGION} ${COREOS_CHANNEL} ${COREOS_VM_TYPE} > _generated.tf

# Load all resouces makefile
include makefiles/*.mk
