apply-route53: get ; terraform apply -target module.route53

destroy-route53: ; terraform destroy -target module.route53

plan-route53: get ; terraform plan -target module.route53

test-route53:
	@ssh -A core@`terraform output bastion-ip` -- nslookup etcd.k8s
	@ssh -A core@`terraform output bastion-ip` -- dig k8s ANY
	@ssh -A core@`terraform output bastion-ip` -- dig +noall +answer SRV _etcd-server._tcp.k8s
	@ssh -A core@`terraform output bastion-ip` -- dig +noall +answer SRV _etcd-client._tcp.k8s
	@ssh -A core@`terraform output bastion-ip` -- dig +noall +answer etcd.k8s

.PHONY: apply-route53 destroy-route53 plan-route53 test-route53
