# variables
variable "azs" {}
variable "cidr" {}
variable "name" {}
variable "region" {}

variable "id" {}
variable "gateway-id" {}
variable "subnet-ids" {}
variable "subnet-ids-private" {}

# outputs
output "gateway-id" { value = "${ var.gateway-id }" }
output "id" { value = "${ var.id }" }

output "subnet-ids" { value = "${ var.subnet-ids }" }
output "subnet-ids-private" { value = "${ var.subnet-ids-private }" }