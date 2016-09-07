variable "bucket-prefix" {}
variable "coreos-hyperkube-image" {}
variable "coreos-hyperkube-tag" {}
variable "depends-id" {}
variable "internal-tld" {}
variable "name" {}
variable "region" {}
variable "service-ip-range" { default = "10.3.0.0/24" }

output "bucket-prefix" { value = "${ var.bucket-prefix }" }
output "depends-id" { value = "${ null_resource.dummy_dependency.id }" }
