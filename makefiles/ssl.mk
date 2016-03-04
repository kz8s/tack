test-ssl:
	openssl x509 -in .cfssl/k8s-admin.pem -noout -text
	openssl x509 -in .cfssl/k8s-apiserver.pem -noout -text
	openssl x509 -in .cfssl/k8s-worker.pem -noout -text
	openssl x509 -in .cfssl/k8s-etcd.pem -noout -text

.PHONY: test-ssl
