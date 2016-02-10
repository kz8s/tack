apply-route53: get ; terraform apply -target module.route53

destroy-route53: ; terraform destroy -target module.route53

plan-route53: get ; terraform plan -target module.route53

test-route53:
	@ssh -A core@`terraform output bastion-ip` -- nslookup etcd.k8s && dig k8s ANY

.PHONY: apply-route53 destroy-route53 plan-route53
