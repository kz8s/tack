variable "etcd-ips" { default = "10.0.0.10,10.0.0.11,10.0.0.12" }
variable "name" {}
variable "vpc-id" {}

output "internal-zone-id" { value = "${ aws_route53_zone.internal.zone_id }" }
output "internal-name-servers" { value = "${ aws_route53_zone.internal.name_servers }" }
