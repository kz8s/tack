variable "bucket-prefix" {}
variable "name" {}
variable "cluster-id" {}

output "bucket-prefix" { value = "${ var.bucket-prefix }" }
