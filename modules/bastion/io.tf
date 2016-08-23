variable "ami-id" {}
variable "bucket-prefix" {}
variable "cidr-allow-ssh" {}
variable "depends-id" {}
variable "instance-type" {}
variable "internal-tld" {}
variable "key-name" {}
variable "name" {}
variable "security-group-id" {}
variable "subnet-ids" {}
variable "vpc-id" {}

output "depends-id" { value = "${null_resource.dummy_dependency.id}" }
output "ip" { value = "${ aws_instance.bastion.public_ip }" }
