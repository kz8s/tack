# This is merged in with terraform.tfvars for override/existing VPC purposes.  Only to be used in conjunction with modules_override.tf
#
# The existing VPC CIDR range, ensure that the the etcd, controller and worker IPs are in this range
# cidr.vpc = "10.0.0.0/16"
# 
# etcd server static IPs, ensure that they fall within the exisiting VPC public subnet ranges 
# (they will likely match up subnet-1,subnet-2,subnet-3, etc), if you have only 2 subnets the 3rd will "wrap around" 
# etcd-ips = "10.0.0.10,10.0.1.11,10.0.0.12"
#
# Put your existing VPC info here:
# vpc-existing.id = "vpc-"
# vpc-existing.gateway-id = "igw-"
# vpc-existing.subnet-ids = "subnet-,subnet-"
# vpc-existing.subnet-ids-private = "subnet-,subnet-"