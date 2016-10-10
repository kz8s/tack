# variables
variable "azs" {}
variable "cidr" {}
variable "name" {}
variable "region" {}
variable "hyperkube-tag" {}

variable "id" {}
variable "gateway-id" {}
variable "depends-id" {}

variable "subnet-ids-public" {}
variable "subnet-ids-private" {}

# outputs
output "depends-id" { value = "${ var.id }" }
output "gateway-id" { value = "${ var.gateway-id }" }
output "id" { value = "${ var.id }" }

output "subnet-ids-public" { value = "${ var.subnet-ids-public }" }
output "subnet-ids-private" { value = "${ var.subnet-ids-private }" }

