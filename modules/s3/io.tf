variable "bucket-prefix" {}
variable "depends-id" {}
variable "hyperkube-image" {}
variable "internal-tld" {}
variable "k8s-version" {}
variable "name" {}
variable "region" {}

output "bucket-prefix" { value = "${ var.bucket-prefix }" }
output "depends-id" { value = "${null_resource.dummy_dependency.id}" }
