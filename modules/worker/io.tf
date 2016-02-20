variable "ami-id" {}
variable "bucket-prefix" {}
variable "instance-type" {}
variable "internal-tld" {}
variable "key-name" {}
variable "name" {}
variable "subnet-ids" {}
variable "vpc-id" {}

output "security-group-id" { value = "${ aws_security_group.worker.id }" }
