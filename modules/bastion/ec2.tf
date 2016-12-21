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
    kz8s = "${ var.name }"
    depends-id = "${ var.depends-id }"
    Name = "kz8s-bastion"
    role = "bastion"
  }

  user_data = "${ data.template_file.user-data.rendered }"

  vpc_security_group_ids = [
    "${ var.security-group-id }",
  ]
}

data "template_file" "user-data" {
  template = "${ file( "${ path.module }/user-data.yml" )}"

  vars {
    internal-tld = "${ var.internal-tld }"
  }
}

resource "null_resource" "dummy_dependency" {
  depends_on = [ "aws_instance.bastion" ]
}
