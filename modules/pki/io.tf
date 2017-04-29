variable "ami-id" {}
variable "aws" {
  type = "map"
}
variable "cidr-vpc" {}
variable "depends-id" {}
variable "instance-profile-name" {}
variable "instance-type" {}
variable "internal-tld" {}
variable "internal-zone-id" {}
variable "k8s" {
  type = "map"
}
variable "name" {}
variable "ip" {}
variable "s3-bucket" {}
variable "s3-bucket-arn" {}
variable "security-group-id" {}
variable "subnet-id" {}
variable "vpc-id" {}

output "depends-id" { value = "${ null_resource.dummy_dependency.id }" }
output "ip" { value = "${ aws_instance.pki.private_ip }" }
