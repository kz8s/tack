resource "aws_vpc" "main" {
  cidr_block = "${ var.cidr }"

  enable_dns_hostnames = true
  enable_dns_support = true

  tags {
    builtWith = "terraform"
    KubernetesCluster = "${ var.name }"
    kz8s = "${ var.name }"
    Name = "kz8s-${ var.name }"
    version = "${ var.hyperkube-tag }"
    visibility = "private,public"
  }
}

resource "null_resource" "dummy_dependency" {
  depends_on = [
    "aws_vpc.main",
    "aws_nat_gateway.nat"
  ]
}
