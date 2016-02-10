apply-bastion: ; terraform apply -target module.bastion

destroy-bastion: ; terraform destroy -target module.bastion

plan-bastion: ; terraform plan -target module.bastion

ssh: ## ssh into bastion host
	@ssh -A core@`terraform output bastion-ip`
