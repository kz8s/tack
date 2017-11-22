variable "cidr-allow-ssh" {}
variable "cidr-vpc" {}
variable "depends-id" {}
variable "name" {}
variable "vpc-id" {}

output "bastion-id" { value = "${ aws_security_group.bastion.id }" }
output "depends-id" { value = "${ null_resource.dummy_dependency.id }" }
output "etcd-id" { value = "${ aws_security_group.etcd.id }" }
output "external-elb-id" { value = "${ aws_security_group.external-elb.id }" }
output "pki-id" { value = "${ aws_security_group.pki.id }" }
output "worker-id" { value = "${ aws_security_group.worker.id }" }
output "elk-worker-id" { value = "${ aws_security_group.elk-worker.id }" }
output "concourse-worker-id" { value = "${ aws_security_group.concourse-worker.id }" }
