variable "ami-id" {}
variable "bucket-prefix" {}
variable "cidr-allow-ssh" {}
variable "instance-type" {}
variable "key-name" {}
variable "name" {}
variable "security-group-id" {}
variable "subnet-ids" {}
variable "vpc-id" {}
variable "cluster-id" {}

output "ip" { value = "${ aws_instance.bastion.public_ip }" }
