variable "ami-id" {}
variable "bucket-prefix" {}
variable "external-elb-security-group-id" {}
variable "etcd-ips" {}
variable "etcd-security-group-id" {}
variable "hyperkube-image" {}
variable "instance-profile-name" {}
variable "instance-type" {}
variable "k8s-version" {}
variable "key-name" {}
variable "internal-tld" {}
variable "name" {}
variable "region" {}
variable "subnet-ids" {}
variable "vpc-cidr" {}
variable "vpc-id" {}

output "external-elb" { value = "${ aws_elb.external.dns_name }" }
output "internal-ips" { value = "${ join(",", aws_instance.etcd.*.public_ip) }" }

variable "depends-id" {}
output "depends-id" { value = "${null_resource.dummy_dependency.id}" }
