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
      HYPERKUBE=${ var.hyperkube-image } \
      PODMASTER=${ var.podmaster-image } \
      REGION=${ var.region } \
        ${ path.module }/s3-cp ${ var.bucket-prefix }
EOF
  }

  region = "${ var.region }"
}
