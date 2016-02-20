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
  iam_instance_profile = "${ aws_iam_instance_profile.bastion.name }"
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

  /*user_data = "${ var.user-data }"*/
  user_data = <<EOF
#cloud-config

---
coreos:
  update:
    reboot-strategy: etcd-lock

  etcd2:
    discovery-srv: k8s
    proxy: on

  units:
    - name: etcd2.service
      command: start
    - name: s3-iam-get.service
      command: start
      content: |
        [Unit]
        Description=s3-iam-get
        [Service]
        Type=oneshot
        RemainAfterExit=yes
        ExecStartPre=-/usr/bin/mkdir -p /opt/bin
        ExecStartPre=/usr/bin/curl -L -o /opt/bin/s3-iam-get \
          https://raw.githubusercontent.com/kz8s/s3-iam-get/master/s3-iam-get
        ExecStart=/usr/bin/chmod +x /opt/bin/s3-iam-get
EOF
}
