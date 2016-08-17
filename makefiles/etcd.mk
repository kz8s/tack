test-etcd:
	ssh -A core@`terraform output bastion-ip` \
		'( curl -s http://etcd.`terraform output internal-tld`:2379/version )' \
		| grep '{"etcdserver":"2.3.2","etcdcluster":"2.3.0"}'
	ssh -A core@`terraform output bastion-ip` \
		'( curl -s http://etcd.`terraform output internal-tld`:2379/health )' \
		| grep '{"health": "true"}'
	ssh -A core@`terraform output bastion-ip` \
		'( curl -s http://etcd.`terraform output internal-tld`:2379/v2/members )' \
		| grep -o '"name":' | wc -l | grep 3

.PHONY: test-etcd
