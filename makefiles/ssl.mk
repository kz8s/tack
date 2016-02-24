INIT-SSL := ./scripts/init-ssl
INIT-SSL-CA := ./scripts/init-ssl-ca

$(DIR_SSL)/: ; mkdir -p $@

$(DIR_SSL)/admin.pem: $(DIR_SSL)/ca.pem
	$(INIT-SSL) $(DIR_SSL) admin k8s-admin \
		IP.1=127.0.0.1,IP.2=10.0.0.15,DNS.3=*.*.compute.internal,DNS.4=*.ec2.internal

# TODO: fix elb hard coded us-west-1 wild card
$(DIR_SSL)/apiserver.pem: $(DIR_SSL)/ca.pem
	$(INIT-SSL) $(DIR_SSL) k8s-apiserver k8s-apiserver \
		IP.1=127.0.0.1,IP.2=10.0.0.15,IP.3=10.3.0.1,DNS.1=master.k8s,DNS.2=*.us-west-1.elb.amazonaws.com

$(DIR_SSL)/ca.pem: | $(DIR_SSL)/ ; $(INIT-SSL-CA) $(DIR_SSL)

$(DIR_SSL)/etcd.pem: $(DIR_SSL)/ca.pem
	$(INIT-SSL) $(DIR_SSL) etcd coreos-etcd \
		IP.1=127.0.0.1,IP.2=10.0.0.10,IP.3=10.0.0.11,IP.4=10.0.0.12,DNS.1=etcd.k8s

$(DIR_SSL)/worker.pem: $(DIR_SSL)/ca.pem
	$(INIT-SSL) $(DIR_SSL) k8s-worker k8s-worker \
		IP.1=127.0.0.1,DNS.3=*.*.compute.internal,DNS.4=*.ec2.internal

create-ssl: $(DIR_SSL)/ca.pem $(DIR_SSL)/admin.pem $(DIR_SSL)/apiserver.pem $(DIR_SSL)/etcd.pem $(DIR_SSL)/worker.pem

destroy-ssl:
	@-rm -rf $(DIR_SSL)/
	@-rm .srl

test-ssl:
	openssl x509 -in .ssl/admin.pem -noout -text
	openssl x509 -in .ssl/k8s-apiserver.pem -noout -text
	openssl x509 -in .ssl/k8s-worker.pem -noout -text
	openssl x509 -in .ssl/etcd.pem -noout -text

.PHONY: create-ssl destroy-ssl test-ssl
