variable "ami-id" {}
variable "bucket-prefix" {}
variable "depends-id" {}
variable "etcd-ips" {}
variable "etcd-security-group-id" {}
variable "external-elb-security-group-id" {}
variable "hyperkube-image" {}
variable "instance-profile-name" {}
variable "instance-type" {}
variable "internal-tld" {}
variable "k8s-version" {}
variable "key-name" {}
variable "name" {}
variable "region" {}
variable "subnet-ids" {}
variable "vpc-cidr" {}
variable "vpc-id" {}

output "depends-id" { value = "${ null_resource.dummy_dependency.id }" }
output "external-elb" { value = "${ aws_elb.external.dns_name }" }
output "internal-ips" { value = "${ join(",", aws_instance.etcd.*.public_ip) }" }
