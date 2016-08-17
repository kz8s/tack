resource "aws_instance" "etcd" {
  count = "${ length( split(",", var.etcd-ips) ) }"

  ami = "${ var.ami-id }"
  associate_public_ip_address = true
  iam_instance_profile = "${ var.instance-profile-name }"
  instance_type = "${ var.instance-type }"
  key_name = "${ var.key-name }"
  private_ip = "${ element(split(",", var.etcd-ips), count.index) }"

  root_block_device {
    volume_size = 124
    volume_type = "gp2"
  }

  vpc_security_group_ids = [ "${ var.etcd-security-group-id }" ]
  source_dest_check = false
  subnet_id = "${ element( split(",", var.subnet-ids), count.index ) }"
  user_data = "${ element(template_file.cloud-config.*.rendered, count.index) }"

  tags {
    builtWith = "terraform"
    Cluster = "${ var.name }"
    KubernetesCluster = "${ var.name }" # used by kubelet's aws provider to determine cluster
    Name = "etcd${ count.index + 1 }"
    role = "etcd,apiserver"
  }
}
