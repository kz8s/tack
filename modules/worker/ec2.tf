resource "aws_launch_configuration" "worker" {
  associate_public_ip_address = false
  iam_instance_profile = "${ aws_iam_instance_profile.worker.name }"
  image_id = "${ var.ami-id }"
  instance_type = "${ var.instance-type }"
  key_name = "${ var.key-name }"

  security_groups = [
    "${ aws_security_group.worker.id }",
  ]

  user_data = "${ template_file.cloud-config.rendered }"

  # Storage
  ebs_block_device {
    device_name = "/dev/xvdf"
    volume_size = 250
    volume_type = "gp2"
  }

  root_block_device {
    volume_size = 52
    volume_type = "gp2"
  }

  /*lifecycle {
    create_before_destroy = true
  }*/
}

resource "aws_autoscaling_group" "worker" {
  name = "worker"

  desired_capacity = "5"
  health_check_grace_period = 60
  health_check_type = "EC2"
  force_delete = true
  launch_configuration = "${ aws_launch_configuration.worker.name }"
  max_size = "5"
  min_size = "3"
  vpc_zone_identifier = [ "${ split(",", var.subnet-ids) }" ]

  tag {
    key = "Name"
    value = "worker"
    propagate_at_launch = true
  }

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
}
