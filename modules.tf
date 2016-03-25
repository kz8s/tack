resource "aws_cloudwatch_log_group" "k8s" {
  name = "k8s-${ var.name }"
  retention_in_days = 3
}

module "s3" {
  source = "./modules/s3"

  bucket-prefix = "${ var.aws.account-id }-${ var.name }-${ var.aws.region }"
  name = "${ var.name }"
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
  instance-profile-name = "${ module.iam.instance-profile-name-master }"
  instance-type = "${ var.instance-type.etcd }"
  internal-tld = "${ var.internal-tld }"
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

module "worker" {
  source = "./modules/worker"

  ami-id = "${ var.coreos-aws.ami }"
  bucket-prefix = "${ module.s3.bucket-prefix }"
  instance-profile-name = "${ module.iam.instance-profile-name-worker }"
  instance-type = "${ var.instance-type.worker }"
  internal-tld = "${ var.internal-tld }"
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

resource "null_resource" "initialize" {

  triggers {
    bastion-ip = "${ module.bastion.ip }"
    # todo: change trigger to etcd elb dns name
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
      "/bin/bash -c 'until curl --silent http://127.0.0.1:8080/version; do sleep 5; done'",
      "echo ✓ Read scheduler key from etcd:",
      "/bin/bash -c 'until etcdctl get scheduler; do sleep 5; done'",
      "echo ✓ Read controller key from etcd:",
      "/bin/bash -c 'until etcdctl get scheduler; do sleep 5; done'",
      "echo ✓ scheduler and controller setup",
    ]
  }

}
