variable "ami-id" {}
variable "aws" {
  type = "map"
}
variable "depends-id" {}
variable "etcd-security-group-id" {}
variable "instance-profile-name" {}
variable "instance-type" {}
variable "internal-tld" {}
variable "internal-zone-id" {}

variable "root-volume-size" { default = 50 }
variable "root-volume-type" { default = "gp2" }
variable "cluster-size" { default = 3 }
variable "azs" { default = ["us-east-1b", "us-east-1d", "us-east-1f"] }

variable "name" {}
variable "s3-bucket" {}
variable "subnet-id-private" {}
variable "private-subnet-ids" { type = "list" }
variable "subnet-id-public" {}
variable "vpc-id" {}
#variable "etcd-ips" {}

output "depends-id" { value = "${ null_resource.dummy_dependency.id }" }
output "internal-ips" { value = "${ join(",", aws_instance.etcd.*.private_ip) }" }
output "etcd-ips" { value = "${ join(",", aws_instance.etcd.*.private_ip) }" }
