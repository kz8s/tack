resource "aws_vpc" "main" {
  cidr_block = "${ var.cidr }"

  enable_dns_hostnames = true
  enable_dns_support = true

  tags {
    Name = "k8s"
    Cluster = "${ var.name }"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${ aws_vpc.main.id }"

  tags {
    Name = "k8s"
    Cluster = "${ var.name }"
  }
}

resource "aws_subnet" "subnets" {
  count = "${ length( split(",", var.azs) ) }"

  availability_zone = "${ element( split(",", var.azs), count.index ) }"
  cidr_block = "10.0.${ count.index }.0/24"
  vpc_id = "${ aws_vpc.main.id }"

  tags {
    Name = "k8s"
    Cluster = "${ var.name }"
  }
}

resource "aws_route_table" "main" {
  vpc_id = "${ aws_vpc.main.id }"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${ aws_internet_gateway.main.id }"
  }

  tags {
    Name = "k8s"
    Cluster = "${ var.name }"
  }
}

resource "aws_route_table_association" "main" {
  count = "${ length(split(",", var.azs)) }"

  route_table_id = "${ aws_route_table.main.id }"
  subnet_id = "${ element(aws_subnet.subnets.*.id, count.index) }"
}

resource "aws_eip" "nat" { vpc = true }

resource "aws_nat_gateway" "nat" {
  depends_on = [ "aws_internet_gateway.main" ]

  allocation_id = "${ aws_eip.nat.id }"
  subnet_id = "${ aws_subnet.subnets.0.id }"
}
