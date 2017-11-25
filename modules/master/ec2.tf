data "aws_subnet" "selected" {
  count = "${var.cluster-size}"
  id = "${ element(var.private-subnet-ids, count.index) }"
}

resource "aws_instance" "apiserver" {
  count = "${var.cluster-size}"

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
    Name = "kz8s-apiserver${ count.index + 1 }"
    role = "apiserver"
    version = "${ var.k8s["hyperkube-tag"] }"
    visibility = "private"
  }

  depends_on = [ "aws_s3_bucket_object.calico-addon" ]

  user_data = "${ element(data.template_file.cloud-config.*.rendered, count.index) }"
  vpc_security_group_ids = [ "${ var.etcd-security-group-id }" ]
}

resource "null_resource" "dummy_dependency" {
  depends_on = [ "aws_instance.apiserver" ]

  triggers {
    cluster_instance_ids = "${join(",", aws_instance.apiserver.*.id)}"
  }


  provisioner "local-exec" {
    command = <<EOF
      echo ${path.module}/../scripts/wait-for-cluster
      echo ${path.module}/../scripts/get-ca
      echo ${path.module}/../scripts/create-admin-certificate
      echo ${path.module}/../scripts/create-kubeconfig
  EOF
  }
}
