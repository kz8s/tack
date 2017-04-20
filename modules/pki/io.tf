variable "ami-id" {}
variable "aws" {
  type = "map"
}
variable "cidr-vpc" {}
variable "depends-id" {}
variable "instance-type" {}
variable "internal-tld" {}
variable "internal-zone-id" {}
variable "k8s" {
  type = "map"
}
variable "name" {}
variable "s3-bucket" {}
variable "s3-bucket-arn" {}
variable "subnet-ids" {}
variable "vpc-id" {}

output "depends-id" { value = "${ null_resource.dummy_dependency.id }" }
output "ip" { value = "${ aws_instance.pki.private_ip }" }
