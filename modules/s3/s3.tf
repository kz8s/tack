resource "aws_s3_bucket" "ssl" {
  acl = "private"
  bucket = "${ var.bucket-prefix }"
  force_destroy = true

  tags {
    builtWith = "terraform"
    KubernetesCluster = "${ var.name }"
    Name = "kz8s-${ var.name }"
    version = "${ var.hyperkube-tag }"
  }

  provisioner "local-exec" {
    command = <<EOF

HYPERKUBE=${ var.hyperkube-image }:${ var.hyperkube-tag } \
INTERNAL_TLD=${ var.internal-tld } \
REGION=${ var.region } \
SERVICE_CLUSTER_IP_RANGE=${ var.service-cluster-ip-range } \
${ path.module }/s3-cp ${ var.bucket-prefix }
EOF

  }

  region = "${ var.region }"
}

resource "null_resource" "dummy_dependency" {
  depends_on = [ "aws_s3_bucket.ssl" ]
}
