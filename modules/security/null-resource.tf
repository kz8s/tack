resource "null_resource" "dummy_dependency" {

  depends_on = [
    "aws_security_group.bastion",
    "aws_security_group.etcd",
    "aws_security_group.external-elb",
    "aws_security_group.pki",
    "aws_security_group.worker",
  ]

}
