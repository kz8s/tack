resource "aws_ebs_volume" "etcd" {
  count = "${ length( split(",", var.azs) ) }"

  availability_zone = "${ element( split(",", var.azs), 0 ) }"

  type = "gp2"
  size = 100

  tags {
    builtWith = "terraform"
    Cluster = "${ var.name }"
    depends-id = "${ var.depends-id }"
    KubernetesCluster = "${ var.name }"
    Name = "etcd${ count.index + 1 }-${ var.name }"
    role = "etcd,apiserver"
    version = "${ var.coreos-hyperkube-tag }"
  }
}

resource "aws_volume_attachment" "etcd" {
  count = "${ length( split(",", var.azs) ) }"

  device_name = "/dev/xvdf"
  volume_id = "${ element(aws_ebs_volume.etcd.*.id, count.index) }"
  instance_id = "${ element(aws_instance.etcd.*.id, count.index) }"
}

resource "aws_instance" "etcd" {
  count = "${ length( split(",", var.etcd-ips) ) }"

  ami = "${ var.ami-id }"
  associate_public_ip_address = false
  iam_instance_profile = "${ var.instance-profile-name }"
  instance_type = "${ var.instance-type }"
  key_name = "${ var.key-name }"
  private_ip = "${ element(split(",", var.etcd-ips), count.index) }"

  root_block_device {
    volume_size = 124
    volume_type = "gp2"
  }

  source_dest_check = false
  subnet_id = "${ element( split(",", var.subnet-ids-private), 0 ) }"

  tags {
    builtWith = "terraform"
    depends-id = "${ var.depends-id }"
    KubernetesCluster = "${ var.name }" # used by kubelet's aws provider to determine cluster
    kz8s = "${ var.name }"
    Name = "kz8s-etcd${ count.index + 1 }"
    role = "etcd,apiserver"
    version = "${ var.hyperkube-tag }"
    visibility = "private"
  }

  user_data = "${ element(template_file.cloud-config.*.rendered, count.index) }"
  vpc_security_group_ids = [ "${ var.etcd-security-group-id }" ]
}

resource "null_resource" "dummy_dependency" {
  depends_on = [
    "aws_instance.etcd",
    "aws_ebs_volume.etcd",
    "aws_volume_attachment.etcd"
  ]
}
