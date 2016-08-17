test-route53:
	@ssh -A core@`terraform output bastion-ip` '( nslookup etcd.${INTERNAL_TLD} )'
	@ssh -A core@`terraform output bastion-ip` '( dig ${INTERNAL_TLD} ANY )'
	@ssh -A core@`terraform output bastion-ip` '( dig +noall +answer SRV _etcd-server._tcp.${INTERNAL_TLD} )'
	@ssh -A core@`terraform output bastion-ip` '( dig +noall +answer SRV _etcd-client._tcp.${INTERNAL_TLD} )'
	@ssh -A core@`terraform output bastion-ip` '( dig +noall +answer etcd.${INTERNAL_TLD} )'

.PHONY: test-route53
