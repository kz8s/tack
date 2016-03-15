TERRAFORM_CMD := cd ${DIR_CONTEXT}; terraform

.terraform:
	${TERRAFORM_CMD} get

${DIR_CONTEXT}/terraform.tfvars:
	./scripts/init-variables ${AWS_REGION} ${COREOS_CHANNEL} ${COREOS_VM_TYPE} ${AWS_EC2_KEY_NAME} >$@
	echo "name = \"${CLUSTER_NAME}\"" >>$@
	IP=`curl -s http://myip.vg` && echo "cidr.allow-ssh = \"$${IP}/32\"" >>$@
	echo "aws.key-name = \"${AWS_EC2_KEY_NAME}\"" >>$@
	echo "aws.region = \"${AWS_REGION}\"" >>$@

## terraform apply
apply: plan
	${TERRAFORM_CMD} apply

## terraform destroy
destroy:
	${TERRAFORM_CMD} destroy

## terraform get
get:
	${TERRAFORM_CMD} get

## generate variables
init: ${DIR_CONTEXT}/terraform.tfvars

## terraform plan
plan: get init
	${TERRAFORM_CMD} validate
	${TERRAFORM_CMD} plan -out terraform.tfplan

## terraform show
show:
	${TERRAFORM_CMD} show

## terraform taint/apply null_resource.initialize
retry-init:
	${TERRAFORM_CMD} taint null_resource.initialize
	${TERRAFORM_CMD} apply -target=null_resource.initialize

.PHONY: apply destroy get init plan show retry-init
