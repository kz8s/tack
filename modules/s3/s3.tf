resource "aws_s3_bucket" "ssl" {
  acl = "private"
  bucket = "${ var.bucket-prefix }"
  force_destroy = true
  tags {
    Cluster = "${ var.name }"
    Name = "k8s"
    builtWith = "terraform"
  }

  provisioner "local-exec" {
    command = "HYPERKUBE=${ var.hyperkube-image} ./scripts/s3-cp-manifests ${ var.bucket-prefix }"
  }

}
