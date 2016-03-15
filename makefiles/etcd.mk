test-etcd:
	@echo
	ssh -A core@`${TERRAFORM_CMD} output bastion-ip` '( curl -s etcd.k8s:2379/version )' \
		| grep '{"etcdserver":"2.2.3","etcdcluster":"2.2.0"}'
	@echo
	ssh -A core@`${TERRAFORM_CMD} output bastion-ip` '( curl -s etcd.k8s:2379/health )' \
		| grep '{"health": "true"}'
	@echo
	ssh -A core@`${TERRAFORM_CMD} output bastion-ip` '( curl -s etcd.k8s:2379/v2/members )' \
		| grep -o '"name":' | wc -l | grep 3

.PHONY: test-etcd
