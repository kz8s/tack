module "s3" {
  source = "./modules/s3"

  # variables
  aws = "${ var.aws }"
  bucket = "kz8s-pki-${ var.name }-${ var.aws["account-id"] }-${ var.aws["region"] }"
  name = "${ var.name }"
}

module "vpc" {
  source = "./modules/vpc"
  depends-id = ""

  # variables
  azs = "${ var.aws["azs"] }"
  cidr = "${ var.cidr["vpc"] }"
  hyperkube-tag = "${ var.k8s["hyperkube-tag"] }"
  name = "${ var.name }"
  region = "${ var.aws["region"] }"
}

module "route53" {
  source = "./modules/route53"
  depends-id = "${ module.vpc.depends-id }"

  # variables
  etcd-ips = "${ var.etcd-ips }"
  internal-tld = "${ var.internal-tld }"
  name = "${ var.name }"

  # modules
  vpc-id = "${ module.vpc.id }"
}

module "pki" {
  source = "./modules/pki"
  depends-id = "${ module.vpc.depends-id }"

  # variables
  ami-id = "${ var.coreos-aws["ami"] }"
  aws = "${ var.aws }"
  cidr-vpc = "${ var.cidr["vpc"] }"
  instance-type = "${ var.instance-type["pki"] }"
  internal-tld = "${ var.internal-tld }"
  ip = "${ var.pki-ip }"
  k8s = "${ var.k8s }"
  name = "${ var.name }"

  # modules
  instance-profile-name = "${ module.iam.instance-profile-name-pki }"
  internal-zone-id = "${ module.route53.internal-zone-id }"
  s3-bucket = "${ module.s3.bucket }"
  s3-bucket-arn = "${ module.s3.bucket-arn }"
  security-group-id = "${ module.security.pki-id }"
  subnet-id = "${ element( split(",", module.vpc.subnet-ids-private), 0 ) }"
  vpc-id = "${ module.vpc.id }"
}

module "security" {
  source = "./modules/security"
  depends-id = "${ module.vpc.depends-id }"

  # variables
  cidr-allow-ssh = "${ var.cidr["allow-ssh"] }"
  cidr-vpc = "${ var.cidr["vpc"] }"
  name = "${ var.name }"

  # modules
  vpc-id = "${ module.vpc.id }"
}

module "iam" {
  source = "./modules/iam"
  depends-id = "${ module.pki.depends-id }"

  # variables
  name = "${ var.name }"

  # modules
  s3-bucket-arn = "${ module.s3.bucket-arn }"
}

module "bastion" {
  source = "./modules/bastion"
  depends-id = "${ module.vpc.depends-id }"

  # variables
  ami-id = "${ var.coreos-aws["ami"] }"
  aws = "${ var.aws }"
  instance-type = "${ var.instance-type["bastion"] }"
  internal-tld = "${ var.internal-tld }"
  key-name = "${ var.aws["key-name"] }"
  name = "${ var.name }"

  # modules
  instance-profile-name = "${ module.iam.instance-profile-name-bastion }"
  s3-bucket = "${ module.s3.bucket }"
  s3-bucket-arn = "${ module.s3.bucket-arn }"
  security-group-id = "${ module.security.bastion-id }"
  subnet-id = "${ element( split(",", module.vpc.subnet-ids-public), 0 ) }"
  vpc-id = "${ module.vpc.id }"
}

module "etcd" {
  source = "./modules/etcd"
  depends-id = "${ module.route53.depends-id }"

  # variables
  ami-id = "${ var.coreos-aws["ami"] }"
  aws = "${ var.aws }"
  cluster-domain = "${ var.cluster-domain }"
  dns-service-ip = "${ var.dns-service-ip }"
  etcd-ips = "${ var.etcd-ips }"
  instance-type = "${ var.instance-type["etcd"] }"
  internal-tld = "${ var.internal-tld }"
  ip-k8s-service = "${ var.k8s-service-ip }"
  k8s = "${ var.k8s }"
  name = "${ var.name }"
  pod-ip-range = "${ var.cidr["pods"] }"
  service-cluster-ip-range = "${ var.cidr["service-cluster"] }"

  # modules
  etcd-security-group-id = "${ module.security.etcd-id }"
  external-elb-security-group-id = "${ module.security.external-elb-id }"
  instance-profile-name = "${ module.iam.instance-profile-name-master }"
  s3-bucket = "${ module.s3.bucket }"
  subnet-id-private = "${ element( split(",", module.vpc.subnet-ids-private), 0 ) }"
  subnet-id-public = "${ element( split(",", module.vpc.subnet-ids-public), 0 ) }"
  vpc-id = "${ module.vpc.id }"
}

module "worker" {
  source = "./modules/worker"
  depends-id = "${ module.route53.depends-id }"

  # variables
  ami-id = "${ var.coreos-aws["ami"] }"
  aws = "${ var.aws }"
  capacity = {
    desired = 3
    max = 5
    min = 1
  }
  cluster-domain = "${ var.cluster-domain }"
  dns-service-ip = "${ var.dns-service-ip }"
  instance-type = "${ var.instance-type["worker"] }"
  internal-tld = "${ var.internal-tld }"
  k8s = "${ var.k8s }"
  name = "${ var.name }"
  volume_size = {
    ebs = 250
    root = 52
  }
  worker-name = "general"

  # modules
  instance-profile-name = "${ module.iam.instance-profile-name-worker }"
  s3-bucket = "${ module.s3.bucket }"
  security-group-id = "${ module.security.worker-id }"
  subnet-id = "${ element( split(",", module.vpc.subnet-ids-private), 0 ) }"
  vpc-id = "${ module.vpc.id }"
}
