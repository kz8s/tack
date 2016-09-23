resource "aws_internet_gateway" "main" {
  vpc_id = "${ aws_vpc.main.id }"

  tags {
    builtWith = "terraform"
    KubernetesCluster = "${ var.name }"
    kz8s = "${ var.name }"
    Name = "kz8s-${ var.name }"
    version = "${ var.hyperkube-tag }"
  }
}

resource "aws_subnet" "public" {
  count = "${ length( split(",", var.azs) ) }"

  availability_zone = "${ element( split(",", var.azs), count.index ) }"
  cidr_block = "10.0.${ count.index }.0/24"
  vpc_id = "${ aws_vpc.main.id }"

  tags {
    "kubernetes.io/role/elb" = "${ var.name }"
    builtWith = "terraform"
    KubernetesCluster = "${ var.name }"
    kz8s = "${ var.name }"
    Name = "kz8s-${ var.name }"
    version = "${ var.hyperkube-tag }"
    visibility = "public"
  }
}

resource "aws_route" "public" {
  route_table_id = "${ aws_vpc.main.main_route_table_id }"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${ aws_internet_gateway.main.id }"
}

resource "aws_route_table_association" "public" {
  count = "${ length(split(",", var.azs)) }"

  route_table_id = "${ aws_vpc.main.main_route_table_id }"
  /*route_table_id = "${ aws_route_table.public.id }"*/
  subnet_id = "${ element(aws_subnet.public.*.id, count.index) }"
}
