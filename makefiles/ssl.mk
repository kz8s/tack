test-ssl:
	@echo
	openssl x509 -in ${DIR_CFSSL}/k8s-admin.pem -noout -text
	@echo
	openssl x509 -in ${DIR_CFSSL}/k8s-apiserver.pem -noout -text
	@echo
	openssl x509 -in ${DIR_CFSSL}/k8s-worker.pem -noout -text
	@echo
	openssl x509 -in ${DIR_CFSSL}/k8s-etcd.pem -noout -text

.PHONY: test-ssl
