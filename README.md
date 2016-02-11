# terraform-aws-coreos-kubernetes
Terraform module for create Kubernetes cluster running on CoreOS in an AWS VPC.

## Features
* AWS VPC with NAT gateway and bastion host
* etcd DNS Discovery

## Inspiration From
* [Code examples to create CoreOS cluster on AWS with Terraform](https://github.com/xuwang/aws-terraform)

## References
* [Generate EC2 Key Pair](https://github.com/xuwang/aws-terraform/blob/master/scripts/aws-keypair.sh)
* [Self documenting Makefile](https://gist.github.com/prwhite/8168133)
* [Makefile `help` target](https://gist.github.com/rcmachado/af3db315e31383502660)
* [etcd DNS Discovery](https://coreos.com/etcd/docs/latest/clustering.html#dns-discovery)
