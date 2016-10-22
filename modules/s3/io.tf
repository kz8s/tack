variable "bucket-prefix" {}
variable "hyperkube-image" {}
variable "hyperkube-tag" {}
variable "depends-id" {}
variable "internal-tld" {}
variable "name" {}
variable "region" {}
variable "service-cluster-ip-range" {}

output "bucket-prefix" { value = "${ var.bucket-prefix }" }
output "depends-id" { value = "${ null_resource.dummy_dependency.id }" }
