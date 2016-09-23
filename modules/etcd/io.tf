variable "ami-id" {}
variable "bucket-prefix" {}
variable "cluster-domain" {}
variable "hyperkube-image" {}
variable "hyperkube-tag" {}
variable "depends-id" {}
variable "dns-service-ip" {}
variable "etcd-ips" {}
variable "etcd-security-group-id" {}
variable "external-elb-security-group-id" {}
variable "instance-profile-name" {}
variable "instance-type" {}
variable "internal-tld" {}
variable "key-name" {}
variable "name" {}
variable "pod-ip-range" {}
variable "region" {}
variable "service-cluster-ip-range" {}
variable "subnet-ids-private" {}
variable "subnet-ids-public" {}
variable "vpc-id" {}

output "depends-id" { value = "${ null_resource.dummy_dependency.id }" }
output "external-elb" { value = "${ aws_elb.external.dns_name }" }
output "internal-ips" { value = "${ join(",", aws_instance.etcd.*.public_ip) }" }
