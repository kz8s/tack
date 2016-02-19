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

  ingress = {
    from_port = 22
    to_port = 22
    protocol = "tcp"
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


resource "aws_instance" "etcd" {
  count = "${ length( split(",", var.etcd-ips) ) }"

  ami = "${ var.ami-id }"
  associate_public_ip_address = true
  iam_instance_profile = "${ aws_iam_instance_profile.master.name }"
  instance_type = "${ var.instance-type }"
  key_name = "${ var.key-name }"
  private_ip = "${ element(split(",", var.etcd-ips), count.index) }"

  root_block_device {
    volume_size = 124
    volume_type = "gp2"
  }

  security_groups = [
    "${ aws_security_group.etcd.id }",
  ]

  source_dest_check = false
  subnet_id = "${ element( split(",", var.subnet-ids), 0 ) }"
  user_data = "${ element(template_file.cloud-config.*.rendered, count.index) }"

  tags {
    Name = "etcd${ count.index + 1 }"
    Cluster = "${ var.name }"
    role = "etcd"
  }
}
