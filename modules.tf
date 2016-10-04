module "s3" {
  source = "./modules/s3"
  depends-id = "${ module.vpc.depends-id }"

  bucket-prefix = "${ var.s3-bucket }"
  hyperkube-image = "${ var.k8s["hyperkube-image"] }"
  hyperkube-tag = "${ var.k8s["hyperkube-tag"] }"
  internal-tld = "${ var.internal-tld }"
  name = "${ var.name }"
  region = "${ var.aws["region"] }"
  service-cluster-ip-range = "${ var.cidr["service-cluster"] }"
}

module "vpc" {
  source = "./modules/vpc"
  depends-id = ""

  azs = "${ var.aws["azs"] }"
  cidr = "${ var.cidr["vpc"] }"
  hyperkube-tag = "${ var.k8s["hyperkube-tag"] }"
  name = "${ var.name }"
  region = "${ var.aws["region"] }"
}

module "security" {
  source = "./modules/security"

  cidr-allow-ssh = "${ var.cidr["allow-ssh"] }"
  cidr-vpc = "${ var.cidr["vpc"] }"
  name = "${ var.name }"
  vpc-id = "${ module.vpc.id }"
}

module "iam" {
  source = "./modules/iam"
  depends-id = "${ module.s3.depends-id }"

  bucket-prefix = "${ var.s3-bucket }"
  name = "${ var.name }"
}

module "route53" {
  source = "./modules/route53"
  depends-id = "${ module.iam.depends-id }"

  etcd-ips = "${ var.etcd-ips }"
  internal-tld = "${ var.internal-tld }"
  name = "${ var.name }"
  vpc-id = "${ module.vpc.id }"
}

module "etcd" {
  source = "./modules/etcd"
  depends-id = "${ module.route53.depends-id }"

  ami-id = "${ var.coreos-aws["ami"] }"
  bucket-prefix = "${ var.s3-bucket }"
  cluster-domain = "${ var.cluster-domain }"
  hyperkube-image = "${ var.k8s["hyperkube-image"] }"
  hyperkube-tag = "${ var.k8s["hyperkube-tag"] }"
  dns-service-ip = "${ var.dns-service-ip }"
  etcd-ips = "${ var.etcd-ips }"
  etcd-security-group-id = "${ module.security.etcd-id }"
  external-elb-security-group-id = "${ module.security.external-elb-id }"
  instance-profile-name = "${ module.iam.instance-profile-name-master }"
  instance-type = "${ var.instance-type["etcd"] }"
  internal-tld = "${ var.internal-tld }"
  key-name = "${ var.aws["key-name"] }"
  name = "${ var.name }"
  pod-ip-range = "${ var.cidr["pods"] }"
  region = "${ var.aws["region"] }"
  service-cluster-ip-range = "${ var.cidr["service-cluster"] }"
  subnet-ids-private = "${ module.vpc.subnet-ids-private }"
  subnet-ids-public = "${ module.vpc.subnet-ids-public }"
  vpc-id = "${ module.vpc.id }"
}

module "bastion" {
  source = "./modules/bastion"
  depends-id = "${ module.etcd.depends-id }"

  ami-id = "${ var.coreos-aws["ami"] }"
  bucket-prefix = "${ var.s3-bucket }"
  cidr-allow-ssh = "${ var.cidr["allow-ssh"] }"
  instance-type = "${ var.instance-type["bastion"] }"
  internal-tld = "${ var.internal-tld }"
  key-name = "${ var.aws["key-name"] }"
  name = "${ var.name }"
  security-group-id = "${ module.security.bastion-id }"
  subnet-ids = "${ module.vpc.subnet-ids-public }"
  vpc-id = "${ module.vpc.id }"
}

module "worker" {
  source = "./modules/worker"
  depends-id = "${ module.route53.depends-id }"

  ami-id = "${ var.coreos-aws["ami"] }"
  bucket-prefix = "${ var.s3-bucket }"
  capacity = {
    desired = 3
    max = 5
    min = 3
  }
  cluster-domain = "${ var.cluster-domain }"
  hyperkube-image = "${ var.k8s["hyperkube-image"] }"
  hyperkube-tag = "${ var.k8s["hyperkube-tag"] }"
  dns-service-ip = "${ var.dns-service-ip }"
  instance-profile-name = "${ module.iam.instance-profile-name-worker }"
  instance-type = "${ var.instance-type["worker"] }"
  internal-tld = "${ var.internal-tld }"
  key-name = "${ var.aws["key-name"] }"
  name = "${ var.name }"
  region = "${ var.aws["region"] }"
  security-group-id = "${ module.security.worker-id }"
  subnet-ids = "${ module.vpc.subnet-ids-private }"
  volume_size = {
    ebs = 250
    root = 52
  }
  vpc-id = "${ module.vpc.id }"
  worker-name = "general"
}

/*
module "worker2" {
  source = "./modules/worker"
  depends-id = "${ module.route53.depends-id }"

  ami-id = "${ var.coreos-aws["ami"] }"
  bucket-prefix = "${ var.s3-bucket }"
  capacity = {
    desired = 2
    max = 2
    min = 2
  }
  coreos-hyperkube-image = "${ var.k8s["coreos-hyperkube-image"] }"
  coreos-hyperkube-tag = "${ var.k8s["coreos-hyperkube-tag"] }"
  dns-service-ip = "${ var.dns-service-ip }"
  instance-profile-name = "${ module.iam.instance-profile-name-worker }"
  instance-type = "${ var.instance-type["worker"] }"
  internal-tld = "${ var.internal-tld }"
  key-name = "${ var.aws["key-name"] }"
  name = "${ var.name }"
  region = "${ var.aws["region"] }"
  security-group-id = "${ module.security.worker-id }"
  subnet-ids = "${ module.vpc.subnet-ids-private }"
  volume_size = {
    ebs = 250
    root = 52
  }
  vpc-id = "${ module.vpc.id }"
  worker-name = "special"
}
*/

module "kubeconfig" {
  source = "./modules/kubeconfig"

  admin-key-pem = ".cfssl/k8s-admin-key.pem"
  admin-pem = ".cfssl/k8s-admin.pem"
  ca-pem = ".cfssl/ca.pem"
  master-elb = "${ module.etcd.external-elb }"
  name = "${ var.name }"
}
