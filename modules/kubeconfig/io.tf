variable "admin-key-pem" {}
variable "admin-pem" {}
variable "ca-pem" {}
variable "master-elb" {}
variable "name" {}

output "kubeconfig" { value = "${ data.template_file.kubeconfig.rendered }" }
