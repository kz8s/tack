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
  associate_public_ip_address = false
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
  user_data = <<USER_DATA
#cloud-config

---
coreos:

  etcd2:
    name: etcd${ count.index + 1 }
    advertise-client-urls: http://etcd${ count.index+1 }.${ var.internal-tld }:2379
    discovery-srv: ${ var.internal-tld }
    initial-advertise-peer-urls: http://etcd${ count.index+1 }.${ var.internal-tld }:2380
    initial-cluster-state: new
    initial-cluster-token: etcd-cluster-${ var.name }
    listen-client-urls: http://0.0.0.0:2379
    listen-peer-urls: http://0.0.0.0:2380


  units:
    - name: etcd2.service
      command: start

  update:
    reboot-strategy: etcd-lock
USER_DATA

  tags {
    Name = "etcd${ count.index + 1 }"
    Cluster = "${ var.name }"
    role = "etcd"
  }
}
