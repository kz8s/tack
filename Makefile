SHELL += -eu

BLUE	:= \033[0;34m
GREEN	:= \033[0;32m
RED		:= \033[0;31m
NC		:= \033[0m

DIR_KEY_PAIR	:= .keypair
DIR_SSL				:= .cfssl

# CIDR_PODS: flannel overlay range
# - https://coreos.com/flannel/docs/latest/flannel-config.html
#
# CIDR_SERVICE_CLUSTER: apiserver parameter --service-cluster-ip-range
# - http://kubernetes.io/docs/admin/kube-apiserver/
#
# CIDR_VPC: vpc subnet
# - http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Subnets.html#VPC_Sizing
# - https://www.terraform.io/docs/providers/aws/r/vpc.html#cidr_block
#

# ∨∨∨∨∨∨∨∨∨∨∨∨∨∨∨∨∨∨∨∨∨∨∨∨∨∨∨∨∨∨∨∨∨∨∨∨∨∨∨∨∨∨∨

AWS_REGION						?= us-west-2
COREOS_CHANNEL				?= stable
COREOS_VM_TYPE				?= hvm
CLUSTER_NAME 					?= test

AWS_EC2_KEY_NAME			?= kz8s-$(CLUSTER_NAME)
AWS_EC2_KEY_PATH			:= ${DIR_KEY_PAIR}/${AWS_EC2_KEY_NAME}.pem
INTERNAL_TLD 					:= ${CLUSTER_NAME}.kz8s

HYPERKUBE_IMAGE				?= quay.io/coreos/hyperkube
HYPERKUBE_TAG					?= v1.6.2_coreos.0

CIDR_VPC							?= 10.0.0.0/16
CIDR_PODS							?= 10.2.0.0/16
CIDR_SERVICE_CLUSTER	?= 10.3.0.0/24

K8S_SERVICE_IP				?= 10.3.0.1
K8S_DNS_IP						?= 10.3.0.10

ETCD_IPS 							?= 10.0.10.10,10.0.10.11,10.0.10.12

# Alternative:
# CIDR_PODS ?= "172.15.0.0/16"
# CIDR_SERVICE_CLUSTER ?= "172.16.0.0/24"
# K8S_SERVICE_IP ?= 172.16.0.1
# K8S_DNS_IP ?= 172.16.0.10

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.addons: ; @scripts/do-task "initialize add-ons" \
	./scripts/init-addons

## generate key-pair, variables and then `terraform apply`
all: prereqs create-keypair init apply
	@echo "${GREEN}✓ terraform portion of 'make all' has completed ${NC}\n"
	@$(MAKE) post-terraform

.PHONY: post-terraform
post-terraform:
	@$(MAKE) get-ca
	@$(MAKE) create-admin-certificate
	@$(MAKE) create-kubeconfig
	@$(MAKE) wait-for-cluster
	@$(MAKE) .addons
	@$(MAKE) create-addons
	@$(MAKE) create-busybox
	kubectl get no
	@echo "${BLUE}❤ worker nodes may take several minutes to come online ${NC}"
	@$(MAKE) instances
	kubectl --namespace=kube-system get cs
	@echo "etcd-0 incorrectly reporting as unhelathy"
	@echo "https://github.com/kubernetes/kubernetes/issues/27343"
	@echo "https://github.com/kubernetes/kubernetes/pull/39716"
	@echo "View nodes:"
	@echo "% make nodes"
	@echo "---"
	@echo "View uninitialized kube-system pods:"
	@echo "% make pods"
	@echo "---"
	@echo "View ec2 instance info:"
	@echo "% make instances"
	@echo "---"
	@echo "Status summaries:"
	@echo "% make status"
	@echo "---"
	@echo "Watching pod status"
	@scripts/watch-pods-until


## destroy and remove everything
clean: destroy delete-keypair
	@-pkill -f "kubectl proxy" ||:
	@-rm -rf .addons ||:
	@-rm terraform.tfvars ||:
	@-rm terraform.tfplan ||:
	@-rm -rf .terraform ||:
	@-rm -rf tmp ||:
	@-rm -rf ${DIR_SSL} ||:

create-addons: ; @scripts/do-task "create add-ons" kubectl create -f .addons/

create-admin-certificate: ; @scripts/do-task "create admin certificate" \
	scripts/create-admin-certificate \
		${DIR_SSL} \
		`terraform output name` \
		${DIR_KEY_PAIR}/${AWS_EC2_KEY_NAME}.pem \
		`terraform output bastion-ip`

create-busybox: ; @scripts/do-task "create busybox test pod" \
	kubectl create -f test/pods/busybox.yml

create-kubeconfig:
	@OUTDIR=tmp \
	NAME=`terraform output name` \
	CA_PATH=${DIR_SSL}/ca.pem \
	MASTER_ELB_URL=`terraform output external-elb` \
	ADMIN_CERT_PATH=${DIR_SSL}/k8s-admin.pem \
	ADMIN_KEY_PATH=${DIR_SSL}/k8s-admin-key.pem \
	scripts/create-kubeconfig

## start proxy and open kubernetes dashboard
dashboard: ; @./scripts/dashboard

get-ca:
	@OUTDIR=${DIR_SSL} \
	PKI_S3_BUCKET=`terraform output s3-bucket` \
	scripts/do-task "get root ca certificate" scripts/get-ca

## show instance information
instances: ; @scripts/instances \
	`terraform output name` \
	`terraform output region`

## journalctl on etcd1
journal: ; @scripts/ssh \
	${DIR_KEY_PAIR}/${AWS_EC2_KEY_NAME}.pem \
	`terraform output bastion-ip` \
	"ssh `terraform output etcd1-ip` journalctl -fl"

prereqs: ; @scripts/do-task "checking prerequisities" scripts/prereqs

## ssh into etcd1
ssh:
	@scripts/ssh \
		${DIR_KEY_PAIR}/${AWS_EC2_KEY_NAME}.pem \
		`terraform output bastion-ip` \
		"ssh `terraform output etcd1-ip`"

## ssh into bastion host
ssh-bastion:
	@scripts/ssh \
		${DIR_KEY_PAIR}/${AWS_EC2_KEY_NAME}.pem \
		`terraform output bastion-ip`

## status
status: instances ; scripts/status

## smoke it
test: test-ssl test-route53 test-etcd pods dns

wait-for-cluster: ; @scripts/do-task "wait-for-cluster" scripts/wait-for-cluster

include makefiles/*.mk

.DEFAULT_GOAL := help
.PHONY: all clean create-addons create-admin-certificate create-busybox
.PHONY: get-ca instances journal prereqs ssh ssh-bastion ssl status test
.PHONY: wait-for-cluster
