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

resource "aws_instance" "bastion" {
  ami = "${ var.ami-id }"
  associate_public_ip_address = true
  instance_type = "${ var.instance-type }"
  key_name = "${ var.key-name }"

  security_groups = [
    "${ aws_security_group.bastion.id }",
  ]

  source_dest_check = false
  subnet_id = "${ element( split(",", var.subnet-ids), 0 ) }"

  tags  {
    Name = "bastion"
    Cluster = "${ var.name }"
    Role = "bastion"
  }
}
