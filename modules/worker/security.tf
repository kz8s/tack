resource "aws_security_group" "worker" {
  name = "worker"
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

  tags {
    Name = "worker"
  }
}
