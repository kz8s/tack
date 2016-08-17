variable "bucket-prefix" {}
variable "hyperkube-image" {}
variable "k8s-version" {}
variable "name" {}
variable "region" {}
variable "internal-tld" { default = "k8s" }
variable "service-ip-range" { default = "10.3.0.0/24" }
output "bucket-prefix" { value = "${ var.bucket-prefix }" }
