apply-bastion: ; terraform apply -target module.bastion

destroy-bastion: ; terraform destroy -target module.bastion

plan-bastion: ; terraform plan -target module.bastion

ssh: ## ssh into bastion host
	# ssh-keyscan -H `terraform output bastion-ip` >> ~/.ssh/known_hosts
	@ssh -A core@`terraform output bastion-ip`

.PHONY: apply-bastion destroy-bastion plan-bastion ssh
