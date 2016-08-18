variable "depends-id" {}
variable "etcd-ips" {}
variable "internal-tld" {}
variable "name" {}
variable "vpc-id" {}

output "depends-id" { value = "${null_resource.dummy_dependency.id}" }
output "internal-name-servers" { value = "${ aws_route53_zone.internal.name_servers }" }
output "internal-zone-id" { value = "${ aws_route53_zone.internal.zone_id }" }
