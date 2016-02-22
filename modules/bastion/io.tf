variable "ami-id" {}
variable "bucket-prefix" {}
variable "cidr-allow-ssh" {}
variable "instance-type" {}
variable "key-name" {}
variable "name" {}
variable "security-group-id" {}
variable "subnet-ids" {}
/*variable "user-data" {}*/
variable "vpc-id" {}

output "ip" { value = "${ aws_instance.bastion.public_ip }" }
/*output "security-group-id" { value = "${ aws_security_group.bastion.id }" }*/
