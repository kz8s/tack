resource "aws_security_group" "bastion" {
  name = "bastion"
  description = "bastion security group"
  vpc_id = "${ var.vpc-id }"

  ingress = {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "${ var.cidr-allow-ssh }" ]
  }

  egress = {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "aws_security_group" "etcd" {
  name = "etcd"
  description = "etcd security group"
  vpc_id = "${ var.vpc-id }"

  ingress = {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
    cidr_blocks = [ "10.0.0.0/16" ]
  }

  egress = {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "aws_security_group" "external-elb" {
  description = "External Master Load balancer"
  name = "master-external-elb"
  vpc_id = "${ var.vpc-id }"

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [ "0.0.0.0/0", ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "${ var.cidr-vpc }", ]
  }

  tags {
    Cluster = "${ var.name }"
    Name = "master-external-elb"
    builtWith = "terraform"
  }
}

resource "aws_security_group" "worker" {
  name = "worker"
  vpc_id = "${ var.vpc-id }"

  ingress = {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
    cidr_blocks = [ "${ var.cidr-vpc }", ]
  }

  egress = {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags {
    Cluster = "${ var.name }"
    Name = "worker"
    builtWith = "terraform"
  }
}
