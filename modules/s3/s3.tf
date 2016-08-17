resource "aws_s3_bucket" "ssl" {
  acl = "private"
  bucket = "${ var.bucket-prefix }"
  force_destroy = true

  tags {
    builtWith = "terraform"
    Cluster = "${ var.name }"
    Name = "k8s"
  }

  provisioner "local-exec" {
    command = <<EOF
REGION=${ var.region } \
INTERNAL_TLD=${ var.internal-tld } \
HYPERKUBE=${ var.hyperkube-image } \
${ path.module }/s3-cp ${ var.bucket-prefix }
EOF
  }

  region = "${ var.region }"
}
