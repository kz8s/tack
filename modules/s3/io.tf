variable "bucket-prefix" {}
variable "hyperkube-image" {}
variable "k8s-version" {}
variable "name" {}

output "bucket-prefix" { value = "${ var.bucket-prefix }" }
