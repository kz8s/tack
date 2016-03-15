test-route53:
	@echo
	ssh -A core@`${TERRAFORM_CMD} output bastion-ip` '( nslookup etcd.k8s )'
	@echo
	ssh -A core@`${TERRAFORM_CMD} output bastion-ip` '( dig k8s ANY )'
	@echo
	ssh -A core@`${TERRAFORM_CMD} output bastion-ip` '( dig +noall +answer SRV _etcd-server._tcp.k8s )'
	@echo
	ssh -A core@`${TERRAFORM_CMD} output bastion-ip` '( dig +noall +answer SRV _etcd-client._tcp.k8s )'
	@echo
	ssh -A core@`${TERRAFORM_CMD} output bastion-ip` '( dig +noall +answer etcd.k8s )'

.PHONY: test-route53
