resource "null_resource" "dummy_dependency" {

  depends_on = [
    "aws_instance.pki"
  ]

}
