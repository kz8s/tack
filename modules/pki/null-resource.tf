resource "null_resource" "dummy_dependency" {

  depends_on = [
    "aws_instance.pki",
    "aws_route53_record.pki",
    "aws_iam_role.pki",
    "aws_security_group.pki",
  ]

}
