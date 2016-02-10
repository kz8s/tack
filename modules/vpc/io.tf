# variables
variable "azs" {}
variable "cidr" {}
variable "name" {}
variable "region" {}

# outputs
output "gateway-id" { value = "${ aws_internet_gateway.main.id }" }
output "id" { value = "${ aws_vpc.main.id }" }
output "route-table-id" { value = "${ aws_route_table.main.id }" }
output "subnet-ids" { value = "${ join(",", aws_subnet.subnets.*.id) }" }
