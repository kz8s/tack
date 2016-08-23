resource "aws_security_group" "bastion" {
  description = "k8s bastion security group"

  egress = {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress = {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "${ var.cidr-allow-ssh }" ]
  }

  name = "bastion-${ var.name }"

  tags {
    Cluster = "${ var.name }"
    Name = "bastion-${ var.name }"
    builtWith = "terraform"
  }

  vpc_id = "${ var.vpc-id }"
}

resource "aws_security_group" "etcd" {
  description = "k8s etcd security group"

  egress = {
    from_port = 0
    to_port = 0
    protocol = "-1"
    /*self = true*/
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress = {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
    cidr_blocks = [ "${ var.cidr-vpc }" ]
  }

  name = "etcd-${ var.name }"

  tags {
    Cluster = "${ var.name }"
    Name = "etcd-${ var.name }"
    builtWith = "terraform"
  }

  vpc_id = "${ var.vpc-id }"
}

resource "aws_security_group" "external-elb" {
  description = "k8s master (apiserver) external elb"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    /*cidr_blocks = [ "${ var.cidr-vpc }" ]*/
    security_groups = [ "${ aws_security_group.etcd.id }" ]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  name = "master-external-elb-${ var.name }"

  tags {
    Cluster = "${ var.name }"
    Name = "master-external-elb-${ var.name }"
    builtWith = "terraform"
  }

  vpc_id = "${ var.vpc-id }"
}

resource "aws_security_group" "worker" {
  description = "k8s worker security group"

  egress = {
    from_port = 0
    to_port = 0
    protocol = "-1"
    /*self = true*/
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress = {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
    cidr_blocks = [ "${ var.cidr-vpc }" ]
  }

  name = "worker-${ var.name }"

  tags {
    Cluster = "${ var.name }"
    Name = "worker-${ var.name }"
    builtWith = "terraform"
  }

  vpc_id = "${ var.vpc-id }"
}
