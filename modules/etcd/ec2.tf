resource "aws_instance" "etcd" {
  count = "${var.cluster-size}"

  # not required with subnet_id
  availability_zone = "${ element(var.azs, count.index) }"
  ami = "${ var.ami-id }"
  associate_public_ip_address = false
  iam_instance_profile = "${ var.instance-profile-name }"
  instance_type = "${ var.instance-type }"
  key_name = "${ var.aws["key-name"] }"

  root_block_device {
    volume_size = "${var.root-volume-size}"
    volume_type = "${var.root-volume-type}"
  }

  source_dest_check = true
  subnet_id = "${ element(var.private-subnet-ids, count.index) }"

  tags {
    builtWith = "terraform"
    depends-id = "${ var.depends-id }"
    KubernetesCluster = "${ var.name }" # used by kubelet's aws provider to determine cluster
    kz8s = "${ var.name }"
    Name = "kz8s-etcd${ count.index + 1 }"
    role = "etcd"
    visibility = "private"
  }

  user_data = "${ element(data.template_file.cloud-config.*.rendered, count.index) }"
  vpc_security_group_ids = [ "${ var.etcd-security-group-id }" ]
}
