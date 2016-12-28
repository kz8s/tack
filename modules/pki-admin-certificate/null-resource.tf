resource "null_resource" "create-admin-certificate" {

  provisioner "local-exec" {

    command = <<EOF

${ path.module }/create-admin-credentials \
  ${ var.output-directory } \
  ${ var.name } \
  ${ var.aws-key-path } \
  ${ var.bastion-ip }

EOF

  }

}
