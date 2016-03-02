# terraform-aws-coreos-kubernetes

[![Gitter](https://badges.gitter.im/kz8s/tack.svg)](https://gitter.im/kz8s/tack?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
[![Circle CI](https://circleci.com/gh/kz8s/tack.svg?style=svg)](https://circleci.com/gh/kz8s/tack)

Terraform module for creating a Highly Available Kubernetes cluster running on CoreOS in an AWS VPC.

## Features
* AWS VPC with [NAT gateway](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/vpc-nat-gateway.html) and bastion host
* [Amazon CloudWatch Logs docker logging driver](https://docs.docker.com/engine/admin/logging/awslogs/) support
* Automated CoreOS AMI sourcing
* [High Availability Kubernetes](http://kubernetes.io/v1.1/docs/admin/high-availability.html) Configuration
* TLS certificate generation using [CFSSL: CloudFlare's PKI and TLS toolkit](https://cfssl.org/)
* etcd DNS Discovery Bootstrap
* Terraform Pattern Modules
* Multi-AZ Auto-Scaling Worker Nodes
* SkyDNS utilizing cluster's etcd
* Service accounts enables
* IAM role secured S3 bootstrapping of CoreOS nodes
* Sane defaults for single command cluster spin up: `make all`

## Prerequisites
* [AWS Command Line Interface](http://aws.amazon.com/documentation/cli/)
* [CFSSL: CloudFlare's PKI and TLS toolkit](https://cfssl.org/)
* [Terraform](https://www.terraform.io/)
* [jq](https://stedolan.github.io/jq/)

Quick install prerequisites on Mac OS X with [Homebrew](http://brew.sh/):

```bash
$ brew install awscli cfssl jq terraform
```

Tested with prerequisite versions:

```bash
$ aws --version
aws-cli/1.10.8 Python/2.7.10 Darwin/15.2.0 botocore/1.3.28

$ cfssl version
Version: 1.1.0
Revision: dev
Runtime: go1.5.3

$ jq --version
jq-1.5

$ terraform --version
Terraform v0.6.12
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
