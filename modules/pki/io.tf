variable "ami-id" {}
variable "cidr-vpc" {}
variable "depends-id" {}
variable "instance-type" {}
variable "internal-tld" {}
variable "internal-zone-id" {}
variable "key-name" {}
variable "name" {}
variable "region" {}
variable "s3-bucket" {}
variable "subnet-ids" {}
variable "vpc-id" {}

output "depends-id" { value = "${ null_resource.dummy_dependency.id }" }
output "ip" { value = "${ aws_instance.pki.private_ip }" }
output "s3-bucket" { value = "${ var.s3-bucket }" }
output "s3-bucket-arn" { value = "${ aws_s3_bucket.pki.arn }" }
