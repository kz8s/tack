resource "aws_instance" "bastion" {
  ami = "${ var.ami-id }"
  associate_public_ip_address = true
  iam_instance_profile = "${ aws_iam_instance_profile.bastion.name }"
  instance_type = "${ var.instance-type }"
  key_name = "${ var.key-name }"

  # TODO: force private_ip to prevent collision with etcd machines

  source_dest_check = false
  subnet_id = "${ element( split(",", var.subnet-ids), 0 ) }"

  tags  {
    builtWith = "terraform"
    Cluster = "${ var.name }"
    depends-id = "${ var.depends-id }"
    Name = "bastion-k8s-${ var.name }"
    Role = "bastion"
  }

  user_data = "${ template_file.user-data.rendered }"

  vpc_security_group_ids = [
    "${ var.security-group-id }",
  ]
}

resource "template_file" "user-data" {
  template = <<EOF
#cloud-config

---
coreos:
  update:
    reboot-strategy: etcd-lock

  etcd2:
    discovery-srv: ${ internal-tld }
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

  vars {
    internal-tld = "${ var.internal-tld }"
  }
}

resource "null_resource" "dummy_dependency" {
  depends_on = [ "aws_instance.bastion" ]
}
