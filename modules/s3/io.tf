variable "bucket-prefix" {}
variable "depends-id" {}
variable "coreos-hyperkube-image" {}
variable "coreos-hyperkube-tag" {}
variable "internal-tld" {}
variable "name" {}
variable "region" {}

output "bucket-prefix" { value = "${ var.bucket-prefix }" }
output "depends-id" { value = "${null_resource.dummy_dependency.id}" }
