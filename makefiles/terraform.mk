.terraform: ; terraform get

terraform.tfvars:
	./scripts/init-variables ${AWS_REGION} ${COREOS_CHANNEL} ${COREOS_VM_TYPE} ${AWS_EC2_KEY_NAME} >$@
	echo "name = \"${CLUSTER_NAME}\"" >>$@
	IP=`scripts/myip` && echo "cidr.allow-ssh = \"$${IP}/32\"" >>$@
	echo "aws.key-name = \"${AWS_EC2_KEY_NAME}\"" >>$@
	echo "aws.region = \"${AWS_REGION}\"" >>$@

## terraform apply
apply: plan ; terraform apply

## terraform destroy
destroy: ; terraform destroy

## terraform get
get: ; terraform get

## generate variables
init: terraform.tfvars

## terraform plan
plan: get init
	terraform validate
	terraform plan -out terraform.tfplan

## terraform show
show: ; terraform show

.PHONY: apply destroy get init plan show
