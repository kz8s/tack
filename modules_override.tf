# # Overrides the vpc module in the modules.tf, just loads the variables defined for the existing vpc and reuses those
# #
# # Uncomment to enable the override
# module "vpc" {
#   source = "./modules/vpc-existing"
#   azs = "${ var.aws["azs"] }"
#   cidr = "${ var.cidr["vpc"] }"
#   name = "${ var.name }"
#   region = "${ var.aws["region"] }"
#   id = "${ var.vpc-existing["id"] }"
#   gateway-id = "${ var.vpc-existing["gateway-id"] }"
#   subnet-ids-public = "${ var.vpc-existing["subnet-ids-public"] }"
#   subnet-ids-private = "${ var.vpc-existing["subnet-ids-private"] }"
# }