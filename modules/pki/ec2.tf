resource "aws_instance" "pki" {

  ami = "${ var.ami-id }"
  associate_public_ip_address = false

  iam_instance_profile = "${ aws_iam_instance_profile.pki.name }"
  instance_type = "${ var.instance-type }"
  key_name = "${ var.aws["key-name"] }"

  source_dest_check = true
  subnet_id = "${ element( split(",", var.subnet-ids), 0 ) }"

  tags  {
    builtWith = "terraform"
    kz8s = "${ var.name }"
    depends-id = "${ var.depends-id }"
    Name = "kz8s-pki"
    role = "pki"
  }

  user_data = "${ data.template_file.user-data.rendered }"

  vpc_security_group_ids = [
    "${ aws_security_group.pki.id }",
  ]

}
