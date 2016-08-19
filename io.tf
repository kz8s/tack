provider "aws" { region = "${ var.aws.region }" }

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
    vpc = "10.0.0.0/16"
    allow-ssh = "0.0.0.0/0"
  }
}
variable "coreos-aws" {
  default = {
    ami = ""
    channel = ""
    type = ""
  }
}
variable "etcd-ips" { default = "10.0.0.10,10.0.0.11,10.0.0.12" }
variable "instance-type" {
  default = {
    bastion = "t2.nano"
    etcd = "c4.large"
    worker = "c4.large"
  }
}
variable "internal-tld" {}
variable "k8s" {
  default = {
    coreos-hyperkube-image = "quay.io/coreos/hyperkube"
    coreos-hyperkube-tag = "v1.3.5_coreos.0"
  }
}
variable "name" {}
variable "s3-bucket" {}

# outputs
output "azs" { value = "${ var.aws.azs }" }
output "bastion-ip" { value = "${ module.bastion.ip }" }
output "external-elb" { value = "${ module.etcd.external-elb }" }
output "internal-tld" { value = "${ var.internal-tld }" }
output "s3-bucket" { value = "${ var.s3-bucket }" }
output "subnet-ids" { value = "${ module.vpc.subnet-ids }" }
