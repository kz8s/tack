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
$ brew update && brew install awscli cfssl jq kubernetes-cli terraform
```

Tested with prerequisite versions:

```bash
$ aws --version
aws-cli/1.10.18 Python/2.7.10 Darwin/15.4.0 botocore/1.4.9

$ cfssl version
Version: 1.2.0
Revision: dev
Runtime: go1.6

$ jq --version
jq-1.5

$ kubectl version --client
Client Version: version.Info{Major:"1", Minor:"2", GitVersion:"v1.2.2+528f879", GitCommit:"528f879e7d3790ea4287687ef0ab3f2a01cc2718", GitTreeState:"not a git tree"}

$ terraform --version
Terraform v0.6.14
```

## Launch Stack

`make all` will create:
- AWS Key Pair (PEM file)
- client and server TLS assets
- s3 bucket for TLS assets (secured by IAM roles for master and worker nodes)
- Cloud Watch log group for docker logs
- AWS VPC with private and public subnets
- Route 53 internal zone for VPC
- Etcd cluster bootstrapped from Route 53
- High Availability Kubernetes configuration (masters running on etcd nodes)
- Autoscaling worker node group across subnets in selected region
- kube-system namespace and addons: DNS, UI, Dashboard

```bash
$ make all
```

To open dashboard:

```bash
$ make dashboard
```

To destroy, remove and generally undo everything:

```
$ make clean
```

`make all` and `make clean` should be idempotent - should an error occur simply try running the command again and things should recover from that point.

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
