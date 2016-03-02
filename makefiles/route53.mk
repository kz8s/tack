test-route53:
	@ssh -A core@`terraform output bastion-ip` '( nslookup etcd.k8s )'
	@ssh -A core@`terraform output bastion-ip` '( dig k8s ANY )'
	@ssh -A core@`terraform output bastion-ip` '( dig +noall +answer SRV _etcd-server._tcp.k8s )'
	@ssh -A core@`terraform output bastion-ip` '( dig +noall +answer SRV _etcd-client._tcp.k8s )'
	@ssh -A core@`terraform output bastion-ip` '( dig +noall +answer etcd.k8s )'

.PHONY: test-route53
