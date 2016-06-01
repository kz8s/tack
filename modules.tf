module "s3" {
  source = "./modules/s3"

  bucket-prefix = "${ var.aws.account-id }-${ var.name }-${ var.aws.region }"
  hyperkube-image = "${ var.k8s.hyperkube-image }"
  k8s-version = "${var.k8s.version}"
  name = "${ var.name }"
  region = "${ var.aws.region }"
}

module "vpc" {
  source = "./modules/vpc"

  azs = "${ var.aws.azs }"
  cidr = "${ var.cidr.vpc }"
  name = "${ var.name }"
  region = "${ var.aws.region }"
}

module "security" {
  source = "./modules/security"

  cidr-allow-ssh = "${ var.cidr.allow-ssh }"
  cidr-vpc = "${ var.cidr.vpc }"
  name = "${ var.name }"
  vpc-id = "${ module.vpc.id }"
}

module "iam" {
  source = "./modules/iam"

  bucket-prefix = "${ module.s3.bucket-prefix }"
  name = "${ var.name }"
}

module "route53" {
  source = "./modules/route53"

  etcd-ips = "${ var.etcd-ips }"
  name = "${ var.name }"
  internal-tld = "${ var.internal-tld }"
  vpc-id = "${ module.vpc.id }"
}

module "etcd" {
  source = "./modules/etcd"

  ami-id = "${ var.coreos-aws.ami }"
  bucket-prefix = "${ module.s3.bucket-prefix }"
  external-elb-security-group-id = "${ module.security.external-elb-id }"
  etcd-ips = "${ var.etcd-ips }"
  etcd-security-group-id = "${ module.security.etcd-id }"
  hyperkube-image = "${ var.k8s.hyperkube-image }"
  instance-profile-name = "${ module.iam.instance-profile-name-master }"
  instance-type = "${ var.instance-type.etcd }"
  internal-tld = "${ var.internal-tld }"
  k8s-version = "${var.k8s.version}"
  key-name = "${ var.aws.key-name }"
  name = "${ var.name }"
  region = "${ var.aws.region }"
  subnet-ids = "${ module.vpc.subnet-ids }"
  vpc-cidr = "${ var.cidr.vpc }"
  vpc-id = "${ module.vpc.id }"
}

module "bastion" {
  source = "./modules/bastion"

  ami-id = "${ var.coreos-aws.ami }"
  bucket-prefix = "${ module.s3.bucket-prefix }"
  cidr-allow-ssh = "${ var.cidr.allow-ssh }"
  instance-type = "${ var.instance-type.bastion }"
  key-name = "${ var.aws.key-name }"
  name = "${ var.name }"
  security-group-id = "${ module.security.bastion-id }"
  subnet-ids = "${ module.vpc.subnet-ids }"
  vpc-id = "${ module.vpc.id }"
}

resource "null_resource" "verify-etcd" {

  triggers {
    bastion-ip = "${ module.bastion.ip }"
    etcd-ips = "${ module.etcd.internal-ips }"
  }

  connection {
    agent = true
    bastion_host = "${ module.bastion.ip }"
    bastion_user = "core"
    host = "10.0.0.10"
    user = "core"
  }

  provisioner "remote-exec" {
    inline = [
      "/bin/bash -c 'echo checking etcd cluster health'",
      "/bin/bash -c 'until curl http://etcd.k8s:2379/health; do sleep 5 && echo .; done'",
    ]
  }
}

module "worker" {
  source = "./modules/worker"

  ami-id = "${ var.coreos-aws.ami }"
  bucket-prefix = "${ module.s3.bucket-prefix }"
  hyperkube-image = "${ var.k8s.hyperkube-image }"
  instance-profile-name = "${ module.iam.instance-profile-name-worker }"
  instance-type = "${ var.instance-type.worker }"
  internal-tld = "${ var.internal-tld }"
  k8s-version = "${var.k8s.version}"
  key-name = "${ var.aws.key-name }"
  name = "${ var.name }"
  region = "${ var.aws.region }"
  security-group-id = "${ module.security.worker-id }"
  subnet-ids = "${ module.vpc.subnet-ids-private }"
  vpc-id = "${ module.vpc.id }"
}

module "kubeconfig" {
  source = "./modules/kubeconfig"

  admin-key-pem = ".cfssl/k8s-admin-key.pem"
  admin-pem = ".cfssl/k8s-admin.pem"
  ca-pem = ".cfssl/ca.pem"
  master-elb = "${ module.etcd.external-elb }"
  name = "${ var.name }"
}

resource "null_resource" "verify" {

  triggers {
    bastion-ip = "${ module.bastion.ip }"
    # todo: change trigger to etcd elb dns name
    external-elb = "${ module.etcd.external-elb }"
    etcd-ips = "${ module.etcd.internal-ips }"
  }

  connection {
    agent = true
    bastion_host = "${ module.bastion.ip }"
    bastion_user = "core"
    host = "10.0.0.10"
    user = "core"
  }

  provisioner "remote-exec" {
    inline = [
      "/bin/bash -c 'until curl --silent http://127.0.0.1:8080/version; do sleep 5 && echo .; done'",
    ]
  }
}
