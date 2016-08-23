test-route53:
	@ssh -A core@`terraform output bastion-ip` '( nslookup etcd.`terraform output internal-tld` )'
	@ssh -A core@`terraform output bastion-ip` '( dig `terraform output internal-tld` ANY )'
	@ssh -A core@`terraform output bastion-ip` '( dig +noall +answer SRV _etcd-server._tcp.`terraform output internal-tld` )'
	@ssh -A core@`terraform output bastion-ip` '( dig +noall +answer SRV _etcd-client._tcp.`terraform output internal-tld` )'
	@ssh -A core@`terraform output bastion-ip` '( dig +noall +answer etcd.`terraform output internal-tld` )'

.PHONY: test-route53
