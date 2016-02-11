# terraform-aws-coreos-kubernetes

[![Join the chat at https://gitter.im/kz8s/terraform-aws-coreos-kubernetes](https://badges.gitter.im/kz8s/terraform-aws-coreos-kubernetes.svg)](https://gitter.im/kz8s/terraform-aws-coreos-kubernetes?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Circle CI](https://circleci.com/gh/kz8s/terraform-aws-coreos-kubernetes/tree/master.svg?style=svg)](https://circleci.com/gh/kz8s/terraform-aws-coreos-kubernetes/tree/master)

Terraform module for creating a Kubernetes cluster running on CoreOS in an AWS VPC.

## Features
* AWS VPC with NAT gateway and bastion host
* etcd DNS Discovery Bootstrap
* Terraform [Pattern Modules]

## Prerequisites
* [AWS Command Line Interface](http://aws.amazon.com/documentation/cli/)
* [Terraform](https://www.terraform.io/)
* [jq](https://stedolan.github.io/jq/)

Quick install prerequisites on Mac OS X with [Homebrew](http://brew.sh/):

```bash
brew install awscli jq terraform
```

## Inspired By
* [Code examples to create CoreOS cluster on AWS with Terraform](https://github.com/xuwang/aws-terraform)
* [Kubernetes on CoreOS](https://github.com/coreos/coreos-kubernetes)
* [kaws: tool for deploying multiple Kubernetes clusters](https://github.com/InQuicker/kaws)
* [Terraform Infrastructure Design Patterns](https://www.opencredo.com/2015/09/14/terraform-infrastructure-design-patterns/)

## References
* [Generate EC2 Key Pair](https://github.com/xuwang/aws-terraform/blob/master/scripts/aws-keypair.sh)
* [Self documenting Makefile](https://gist.github.com/prwhite/8168133)
* [Makefile `help` target](https://gist.github.com/rcmachado/af3db315e31383502660)
* [etcd DNS Discovery](https://coreos.com/etcd/docs/latest/clustering.html#dns-discovery)
* [ssl artifact generation](https://github.com/coreos/coreos-kubernetes/tree/master/lib)
