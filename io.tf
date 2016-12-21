provider "aws" { region = "${ var.aws["region"] }" }

# variables
variable "aws" {
  default = {
    account-id = ""
    azs = ""
    key-name = ""
    region = ""
  }
}
variable "cidr" {
  default = {
    allow-ssh = "0.0.0.0/0"
    pods = "10.2.0.0/16"
    service-cluster = "10.3.0.0/24"
    vpc = "10.0.0.0/16"
  }
}
variable "cluster-domain" { default = "cluster.local" }
variable "coreos-aws" {
  default = {
    ami = ""
    channel = ""
    type = ""
  }
}
variable "dns-service-ip" { default = "10.3.0.10" }
variable "etcd-ips" { default = "10.0.10.10,10.0.10.11,10.0.10.12" }
variable "instance-type" {
  default = {
    bastion = "t2.nano"
    etcd = "m3.medium"
    worker = "m3.medium"
  }
}
variable "internal-tld" {}
variable "k8s" {
  default = {
    hyperkube-image = "quay.io/coreos/hyperkube"
    hyperkube-tag = "v1.5.1_coreos.0"
  }
}
variable "k8s-service-ip" { default = "10.3.0.1" }
variable "name" {}
variable "s3-bucket" {}
variable "vpc-existing" {
  default = {
    id = ""
    gateway-id = ""
    subnet-ids-public = ""
    subnet-ids-private = ""
  }
}

# outputs
output "azs" { value = "${ var.aws["azs"] }" }
output "bastion-ip" { value = "${ module.bastion.ip }" }
output "cluster-domain" { value = "${ var.cluster-domain }" }
output "dns-service-ip" { value = "${ var.dns-service-ip }" }
output "etcd1-ip" { value = "${ element( split(",", var.etcd-ips), 0 ) }" }
output "external-elb" { value = "${ module.etcd.external-elb }" }
output "internal-tld" { value = "${ var.internal-tld }" }
output "name" { value = "${ var.name }" }
output "region" { value = "${ var.aws["region"] }" }
output "s3-bucket" { value = "${ var.s3-bucket }" }
output "subnet-ids-private" { value = "${ module.vpc.subnet-ids-private }" }
output "subnet-ids-public" { value = "${ module.vpc.subnet-ids-public }" }
output "worker-autoscaling-group-name" { value = "${ module.worker.autoscaling-group-name }" }
