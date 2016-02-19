variable "ami-id" {}
variable "bucket-prefix" {}
variable "etcd-ips" {}
variable "instance-type" {}
variable "key-name" {}
variable "internal-tld" {}
variable "name" {}
/*variable "region" {}*/
variable "subnet-ids" {}
variable "vpc-id" {}

output "security-group-id" { value = "${ aws_security_group.etcd.id }" }
