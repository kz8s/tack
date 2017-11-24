variable "ami-id" {}
variable "aws" {
  type = "map"
}
variable "cluster-domain" { default = "cluster.local" }
variable "depends-id" {}
variable "etcd-security-group-id" {}
variable "external-elb-security-group-id" {}
variable "instance-profile-name" {}
variable "instance-type" {}
variable "internal-tld" {}

variable "k8s" {
  type = "map"
}

variable "name" {}
variable "s3-bucket" {}
#variable "subnet-id-private" {}
variable "private-subnet-ids" { type = "list" }
variable "public-subnet-ids" { type = "list" }
#variable "subnet-id-public" {}
variable "vpc-id" {}
variable "cluster-size" { default = 3 }

variable "root-volume-size" { default = 50 }
variable "root-volume-type" { default = "gp2" }

#variable "azs" { default = ["us-east-1b", "us-east-1d", "us-east-1f"] }
variable "azs" { type = "list" }
variable "internal-zone-id" {}


variable "pod-ip-range" { default = "100.96.0.0/11" }
variable "service-cluster-ip-range" { default = "100.64.0.0/13" }
variable "dns-service-ip" { default = "100.64.0.10" }
variable "k8s-service-ip" { default = "100.64.0.1" }

output "depends-id" { value = "${ null_resource.dummy_dependency.id }" }
output "external-elb" { value = "${ aws_elb.external.dns_name }" }
output "internal-ips" { value = "${ join(",", aws_instance.apiserver.*.private_ip) }" }
output "dns-service-ip" { value = "${ var.dns-service-ip }" }

