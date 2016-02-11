SHELL += -eu

AWS_REGION := us-west-1
COREOS_CHANNEL := stable
COREOS_VM_TYPE := hvm

AWS_EC2_KEY_NAME := k8s-testing

DIR_KEY_PAIR := .ec2-key-pair


clean: destroy delete-key-pair
	rm _generated.tf ||:
	rm -rf .terraform ||:


include makefiles/*.mk

.DEFAULT_GOAL := help
.PHONY: all clean test
