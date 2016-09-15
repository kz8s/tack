variable "ami-id" {}
variable "bucket-prefix" {}
variable "coreos-hyperkube-image" {}
variable "coreos-hyperkube-tag" {}
variable "depends-id" {}
variable "dns-service-ip" {}
variable "etcd-ips" {}
variable "master-security-group-id" {}
variable "external-elb-security-group-id" {}
variable "instance-profile-name" {}
variable "instance-type" {}
variable "internal-tld" {}
variable "key-name" {}
variable "name" {}
variable "pod-ip-range" {}
variable "region" {}
variable "service-ip-range" {}
variable "subnet-ids" {}
variable "vpc-cidr" {}
variable "vpc-id" {}
variable "internal-zone-id" {}

output "depends-id" { value = "${ null_resource.dummy_dependency.id }" }
output "external-elb" { value = "${ aws_elb.external.dns_name }" }
output "internal-ips" { value = "${ join(",", aws_instance.master.*.private_ip) }" }
