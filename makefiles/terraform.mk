.terraform: ; terraform get

_generated.tf:
	./scripts/generate-variables.sh \
		${AWS_REGION} ${COREOS_CHANNEL} ${COREOS_VM_TYPE} ${AWS_EC2_KEY_NAME} \
		> _generated.tf

## terraform apply
apply: plan ; terraform apply

## terraform destroy
destroy: ; terraform destroy

## generate variables
generate: _generated.tf

## terraform get
get: ; terraform get

## terraform plan
plan: get generate ; terraform plan -out terraform.tfplan

## terraform show
show: ; terraform show

.PHONY: apply destroy generate get plan show
