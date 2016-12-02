.terraform: ; terraform get

terraform.tfvars:
	@./scripts/init-variables \
		${AWS_REGION} ${COREOS_CHANNEL} ${COREOS_VM_TYPE} ${AWS_EC2_KEY_NAME} \
		${INTERNAL_TLD} ${CLUSTER_NAME} `scripts/myip` ${CIDR_VPC} ${CIDR_PODS} \
		${CIDR_SERVICE_CLUSTER} ${K8S_SERVICE_IP} ${K8S_DNS_IP} ${ETCD_IPS} ${HYPERKUBE_IMAGE} ${HYPERKUBE_TAG}

module.%:
	@echo "${BLUE}❤ make $@ - commencing${NC}"
	@time terraform apply -target $@
	@echo "${GREEN}✓ make $@ - success${NC}"
	@sleep 5.2

## terraform apply
apply: plan
	@echo "${BLUE}❤ terraform apply - commencing${NC}"
	terraform apply
	@echo "${GREEN}✓ make $@ - success${NC}"

## terraform destroy
destroy: ; terraform destroy

## terraform get
get: ; terraform get

## generate variables
init: terraform.tfvars

## terraform plan
plan: get init
	terraform validate
	@echo "${GREEN}✓ terraform validate - success${NC}"
	terraform plan -out terraform.tfplan

## terraform show
show: ; terraform show

.PHONY: apply destroy get init module.% plan show
