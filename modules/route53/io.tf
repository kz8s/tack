variable "etcd-ips" {}
variable "internal-tld" {}
variable "name" {}
variable "vpc-id" {}

output "internal-zone-id" { value = "${ aws_route53_zone.internal.zone_id }" }
output "internal-name-servers" { value = "${ aws_route53_zone.internal.name_servers }" }

variable "depends-id" {}
output "depends-id" { value = "${null_resource.dummy_dependency.id}" }
