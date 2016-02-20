variable "admin-key-pem" {}
variable "admin-pem" {}
variable "ca-pem" {}
variable "master-elb" {}
variable "name" {}

output "kubeconfig" { value = "${ template_file.kubeconfig.rendered }" }
