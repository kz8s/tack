resource "aws_vpc" "main" {
  cidr_block = "${ var.cidr }"

  enable_dns_hostnames = true
  enable_dns_support = true

  tags {
    Name = "k8s-${ var.name }"
    Cluster = "${ var.name }"
    builtWith = "terraform"
  }
}

resource "null_resource" "dummy_dependency" {
  depends_on = [
    "aws_vpc.main",
    "aws_nat_gateway.nat"
  ]
}
