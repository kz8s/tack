.terraform: ; terraform get

terraform.tfvars:
	@./scripts/init-variables

module.%:
	@echo "${BLUE}❤ make $@ - commencing${NC}"
	@time terraform apply -target $@
	@echo "${GREEN}✓ make $@ - success${NC}"
	@sleep 5.2

## terraform apply
apply: plan
	@echo "${BLUE}❤ terraform apply - commencing${NC}"
	# terraform apply -target=module.pki
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
