variable "ami-id" {}
variable "bucket-prefix" {}
variable "depends-id" {}
variable "hyperkube-image" {}
variable "instance-profile-name" {}
variable "instance-type" {}
variable "internal-tld" {}
variable "k8s-version" {}
variable "key-name" {}
variable "name" {}
variable "region" {}
variable "security-group-id" {}
variable "subnet-ids" {}
variable "vpc-id" {}

output "depends-id" { value = "${ null_resource.dummy_dependency.id }" }
