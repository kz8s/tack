variable "bucket-prefix" {}
variable "name" {}

output "bucket-prefix" { value = "${ var.bucket-prefix }" }
