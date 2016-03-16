resource "aws_vpc" "main" {
  cidr_block = "${ var.cidr }"

  enable_dns_hostnames = true
  enable_dns_support = true

  tags {
    KubernetesCluster = "${ var.cluster-id }"
    Name = "k8s"
    Cluster = "${ var.name }"
    builtWith = "terraform"
  }
}
