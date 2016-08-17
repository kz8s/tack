variable "ami-id" {}
variable "bucket-prefix" {}
variable "cidr-allow-ssh" {}
variable "instance-type" {}
variable "key-name" {}
variable "name" {}
variable "security-group-id" {}
variable "subnet-ids" {}
variable "vpc-id" {}

output "ip" { value = "${ aws_instance.bastion.public_ip }" }


variable "depends-id" {}
output "depends-id" { value = "${null_resource.dummy_dependency.id}" }