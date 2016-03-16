variable "name" {}

output "cluster-id" { value = "k8s-${ var.name }-cluster" }
