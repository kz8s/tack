variable "ami-id" {}
variable "capacity" {
  default = {
    desired = 5
    max = 5
    min = 3
  }
}
variable "cluster-domain" {}
variable "depends-id" {}
variable "dns-service-ip" {}
variable "hyperkube-image" {}
variable "hyperkube-tag" {}
variable "instance-profile-name" {}
variable "instance-type" {}
variable "internal-tld" {}
variable "key-name" {}
variable "name" {}
variable "pki-s3-bucket" {}
variable "region" {}
variable "security-group-id" {}
variable "subnet-ids" {}
variable "volume_size" {
  default = {
    ebs = 250
    root = 52
  }
}
variable "vpc-id" {}
variable "worker-name" {}

output "autoscaling-group-name" { value = "${ aws_autoscaling_group.worker.name }" }
output "depends-id" { value = "${ null_resource.dummy_dependency.id }" }
