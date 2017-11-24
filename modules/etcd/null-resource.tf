resource "null_resource" "dummy_dependency" {
  depends_on = [ 
    "aws_instance.etcd",
    "aws_route53_record.etcd-server-tcp",
    "aws_route53_record.etcd-client-tcp",
    "aws_route53_record.A-etcd",
    "aws_route53_record.A-etcds",
  ]
}
