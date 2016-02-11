apply-etcd: get ; terraform apply -target module.etcd

destroy-etcd: ; terraform destroy -target module.etcd

plan-etcd: get ; terraform plan -target module.etcd

test-etcd:
	@ssh -A core@`terraform output bastion-ip` -- curl -sv etcd.k8s:2379/version
	@ssh -A core@`terraform output bastion-ip` -- curl -sv etcd.k8s:2379/health
	@ssh -A core@`terraform output bastion-ip` -- curl -sv etcd.k8s:2379/v2/members

.PHONY: apply-etcd destroy-etcd plan-etcd test-etcd
