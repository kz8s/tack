# terraform-aws-coreos-kubernetes

[![Gitter](https://badges.gitter.im/kz8s/tack.svg)](https://gitter.im/kz8s/tack?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
[![Circle CI](https://circleci.com/gh/kz8s/tack.svg?style=svg)](https://circleci.com/gh/kz8s/tack)

Terraform module for creating a Highly Available Kubernetes cluster running on CoreOS in an AWS VPC.

## Features

* TLS certificate generation

### AWS
* AWS VPC Public and Private subnets
* Bastion Host
* [Docker AWS Cloud Watch Logging Driver](https://docs.docker.com/engine/admin/logging/awslogs/)
* Multi-AZ Auto-Scaling Worker Nodes
* [NAT Gateway](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/vpc-nat-gateway.html)

### CoreOS
* etcd DNS Discovery Bootstrap

### Kubernetes
* [Highly Available ApiServer Configuration](http://kubernetes.io/v1.1/docs/admin/high-availability.html)
* Service accounts enabled
* SkyDNS utilizing cluster's etcd

### Terraform
* CoreOS AMI sourcing
* Terraform Pattern Modules

## Prerequisites
* [AWS Command Line Interface](http://aws.amazon.com/documentation/cli/)
* [CFSSL: CloudFlare's PKI and TLS toolkit](https://cfssl.org/)
* [jq](https://stedolan.github.io/jq/)
* [kubectl](http://kubernetes.io/v1.1/docs/user-guide/kubectl-overview.html)
* [Terraform](https://www.terraform.io/)

Quick install prerequisites on Mac OS X with [Homebrew](http://brew.sh/):

```bash
$ brew install awscli cfssl jq kubernetes-cli terraform
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

$ kubectl version
Client Version: version.Info{Major:"1", Minor:"1", GitVersion:"v1.1.8+a8af33d", GitCommit:"a8af33dc07ee08defa2d503f81e7deea32dd1d3b", GitTreeState:"not a git tree"}

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
*  [CFSSL: CloudFlare's PKI and TLS toolkit](https://cfssl.org/)
* [etcd dns discovery bootstrap](https://coreos.com/etcd/docs/latest/clustering.html#dns-discovery)
* [Generate EC2 Key Pair](https://github.com/xuwang/aws-terraform/blob/master/scripts/aws-keypair.sh)
* [Makefile `help` target](https://gist.github.com/rcmachado/af3db315e31383502660)
* [Self documenting Makefile](https://gist.github.com/prwhite/8168133)
* [ssl artifact generation](https://github.com/coreos/coreos-kubernetes/tree/master/lib)
