variable "aws" {
  type = "map"
}
variable "bucket" {}
variable "name" {}

output "bucket" { value = "${ var.bucket }" }
output "bucket-arn" { value = "${ aws_s3_bucket.pki.arn }" }
