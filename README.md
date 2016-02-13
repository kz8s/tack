# terraform-aws-coreos-kubernetes

[![Gitter](https://badges.gitter.im/kz8s/tack.svg)](https://gitter.im/kz8s/tack?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
[![Circle CI](https://circleci.com/gh/kz8s/tack.svg?style=svg)](https://circleci.com/gh/kz8s/tack)

Terraform module for creating a Kubernetes cluster running on CoreOS in an AWS VPC.

## Features
* AWS VPC with NAT gateway and bastion host
* Automated CoreOS AMI sourcing
* etcd DNS Discovery Bootstrap
* Terraform Pattern Modules
* Sane defaults for single command cluster spin up: `make all`

## Prerequisites
* [AWS Command Line Interface](http://aws.amazon.com/documentation/cli/)
* [Terraform](https://www.terraform.io/)
* [jq](https://stedolan.github.io/jq/)

Quick install prerequisites on Mac OS X with [Homebrew](http://brew.sh/):

```bash
$ brew install awscli jq terraform
```

## Inspiration
* [Code examples to create CoreOS cluster on AWS with Terraform](https://github.com/xuwang/aws-terraform) by [xuwang](https://github.com/xuwang)
* [Kubernetes on CoreOS](https://github.com/coreos/coreos-kubernetes)
* [kaws: tool for deploying multiple Kubernetes clusters](https://github.com/InQuicker/kaws)
* [Terraform Infrastructure Design Patterns](https://www.opencredo.com/2015/09/14/terraform-infrastructure-design-patterns/) by [Bart Spaans](https://www.opencredo.com/author/bart/)
* [The infrastructure that runs Brandform](https://github.com/brandfolder/infrastructure)

## References
* [Generate EC2 Key Pair](https://github.com/xuwang/aws-terraform/blob/master/scripts/aws-keypair.sh)
* [Self documenting Makefile](https://gist.github.com/prwhite/8168133)
* [Makefile `help` target](https://gist.github.com/rcmachado/af3db315e31383502660)
* [etcd dns discovery bootstrap](https://coreos.com/etcd/docs/latest/clustering.html#dns-discovery)
* [ssl artifact generation](https://github.com/coreos/coreos-kubernetes/tree/master/lib)
