.terraform: ; terraform get

terraform.tfvars:
	./scripts/init-variables \
		${AWS_REGION} ${COREOS_CHANNEL} ${COREOS_VM_TYPE} ${AWS_EC2_KEY_NAME} \
	> $@

## terraform apply
apply: plan ; terraform apply

## terraform destroy
destroy: ; terraform destroy

## generate variables
init: terraform.tfvars

## terraform get
get: ; terraform get

## terraform plan
plan: get generate ; terraform plan -out terraform.tfplan

## terraform show
show: ; terraform show

.PHONY: apply destroy generate get init plan show
