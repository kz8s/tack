variable "ami-id" {}
variable "bucket-prefix" {}
variable "coreos-hyperkube-image" {}
variable "coreos-hyperkube-tag" {}
variable "depends-id" { default = "self" }
variable "instance-profile-name" {}
variable "instance-type" {}
variable "internal-tld" {}
variable "key-name" {}
variable "name" {}
variable "region" {}
variable "security-group-id" {}
variable "subnet-ids" {}
variable "vpc-id" {}
variable "dns-service-ip" {} 

output "depends-id" { value = "${ null_resource.dummy_dependency.id }" }
