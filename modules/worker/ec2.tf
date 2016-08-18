resource "aws_launch_configuration" "worker" {
  ebs_block_device {
    device_name = "/dev/xvdf"
    volume_size = 250
    volume_type = "gp2"
  }

  iam_instance_profile = "${ var.instance-profile-name }"
  image_id = "${ var.ami-id }"
  instance_type = "${ var.instance-type }"
  key_name = "${ var.key-name }"

  security_groups = [
    "${ var.security-group-id }",
  ]

  user_data = "${ template_file.cloud-config.rendered }"

  # Storage


  root_block_device {
    volume_size = 52
    volume_type = "gp2"
  }

  /*lifecycle {
    create_before_destroy = true
  }*/
}

resource "aws_autoscaling_group" "worker" {
  name = "worker-${ var.name }"

  desired_capacity = "5"
  health_check_grace_period = 60
  health_check_type = "EC2"
  force_delete = true
  launch_configuration = "${ aws_launch_configuration.worker.name }"
  max_size = "5"
  min_size = "3"
  vpc_zone_identifier = [ "${ split(",", var.subnet-ids) }" ]

  tag {
    key = "builtWith"
    value = "terraform"
    propagate_at_launch = true
  }

  tag {
    key = "Cluster"
    value = "${ var.name }"
    propagate_at_launch = true
  }

  tag {
    key = "depends-id"
    value = "${ var.depends-id }"
    propagate_at_launch = false
  }

  # used by kubelet's aws provider to determine cluster
  tag {
    key = "KubernetesCluster"
    value = "${ var.name }"
    propagate_at_launch = true
  }

  tag {
    key = "Name"
    value = "worker-${ var.name }"
    propagate_at_launch = true
  }
}

resource "null_resource" "dummy_dependency" {
  depends_on = [
    "aws_launch_configuration.worker",
    "aws_autoscaling_group.worker",
  ]
}
