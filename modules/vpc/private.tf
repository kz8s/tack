resource "aws_eip" "nat" { vpc = true }

resource "aws_nat_gateway" "nat" {
  depends_on = [ "aws_internet_gateway.main" ]

  allocation_id = "${ aws_eip.nat.id }"
  subnet_id = "${ aws_subnet.public.0.id }"
}

resource "aws_subnet" "private" {
  count = "${ length( split(",", var.azs) ) }"

  availability_zone = "${ element( split(",", var.azs), count.index ) }"
  cidr_block = "10.0.${ count.index + 10 }.0/24"
  vpc_id = "${ aws_vpc.main.id }"

  tags {
    "kubernetes.io/role/internal-elb" = "${ var.name }"
    builtWith = "terraform"
    KubernetesCluster = "${ var.name }"
    Name = "private"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${ aws_vpc.main.id }"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${ aws_nat_gateway.nat.id }"
  }

  tags {
    Name = "private"
    Cluster = "${ var.name }"
    builtWith = "terraform"
  }
}

resource "aws_route_table_association" "private" {
  count = "${ length(split(",", var.azs)) }"

  route_table_id = "${ aws_route_table.private.id }"
  subnet_id = "${ element(aws_subnet.private.*.id, count.index) }"
}
