# variables
variable "azs" {}
variable "cidr" {}
variable "name" {}
variable "region" {}

# outputs
output "gateway-id" { value = "${ aws_internet_gateway.main.id }" }
output "id" { value = "${ aws_vpc.main.id }" }
output "route-table-id" { value = "${ aws_route_table.private.id }" }

output "subnet-ids" { value = "${ join(",", aws_subnet.public.*.id) }" }
output "subnet-ids-private" { value = "${ join(",", aws_subnet.private.*.id) }" }


variable "depends-id" {}
output "depends-id" { value = "${null_resource.dummy_dependency.id}" }